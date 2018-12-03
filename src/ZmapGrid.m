classdef ZmapGrid
    % ZMAPGRID evenly-spaced X,Y [Z] grid with ability to be masked
    %
    % OBJ = ZMAPGRID(name,origin_degs, deltas_degs, limits_degs, follow_meridians)
    % OBJ = ZMAPGRID(NAME, GPC_STRUCT)
    %
    % ZMAPGRID properties:
    %
    %     Name - name of this grid
    %
    %     GridPoints  - [X1,Y1 ; ... ; Xn,Yn] Nx2 matrix of positions
    %     X - all X positions (points will repeat, since they represent matrix nodes)
    %     Y - all Y positions (points will repeat, since they represent matrix nodes)
    %
    %     Units - degrees or kilometers
    %     ActivePoints - logical mask
    %
    %     Xactive - X positions for active points [read-only]
    %     Yactive - Y positions for active points [read-only]
    %
    % ZMAPGRID methods:
    %
    %     Creation methods:
    %
    %     ZmapGrid - create a ZmapGrid
    %
    %     Plotting methods:
    %
    %     plot - plot the points in this grid
    %     pcolor - create a pcolor plot where each point of the grid is center of cell
    %
    %     Misc. methods:
    %
    %     ActiveGrid - [X Y; ..;Yn Yn] for active points [read-only]
    %     length - number of grid points
    %     isempty - true if no grid is defined
    %     MeshSize - [number of X, number of Y[, number of Z]]
    %     MaskWithShape - set the logicalmask to true where points are in polygon, false elsewhere
    %
    %     load - load grid from a .mat file [static method]
    %     save - save this grid to a .mat file
    %
    %     setGlobal - copy this grid into the globally used grid
    %
    %
    % see also gridfun, EventSelectionChoice, autogrid
    
    % TODO: update this to use a referenceEllipse
    
    properties
        Name  (1,:)     char         = ZmapGlobal.Data.GridOpts.Name % name of this grid
        Units (1,:)     char         = 'unk'                % degrees or kilometer
        ActivePoints    logical                             % logical mask
        X               double          % all X positions in matrix
        Y               double          % all Y positions in matrix
        Z               double          % all Y positions in matrix.
        Origin                          % [lon0, lat0, z0] of grid origin point. grid is created outward from here.
        PlotOpts        struct      = ZmapGlobal.Data.GridOpts.LineProps;
            
    end
    
    properties(Dependent)
        Xactive                         % all X positions for active points
        Yactive                         % all Y positions for active points
        Zactive                         % all Z positions for active points
        GridVector                      % Nx2 or Nx3 of all grid points [X1 Y1;...] or [X1,Y1,Z1; ...]
    end
    properties(Constant)
        Type                        = 'zmapgrid';
    end
    properties(Constant,Hidden)
        POSSIBLY_TOO_MANY_POINTS = 1000 * 1000 * 10;
        Planet = 'earth'
    end
    
    methods
        function obj = ZmapGrid(name, createFrom, varargin)
            %ZMAPGRID create a grid of points
            %
            %  OBJ = ZMAPGRID(); creates an empty grid
            %  
            %  OBJ = ZMAPGRID( NAME , 'FromGridOptions', GRID_OPTIONS) creates a grid from a 
            %  GridOptions object, which defines parameters such as delta-distances and units.
            %
            %  OBJ = ZMAPGRID( NAME , 'FromPoints', POINT_VECTOR) creates a grid given the sets of
            %  sets of points [X Y;...] or [X Y Z; ...] 
            % 
            %  OBJ = ZMAPGRID( NAME , 'FromMatrices', Xmatrix, Ymatrix [, Zmatrix]) creates the grid
            %  from a set of same-sized matrices 
            %
            %Additional options:
            %  ZMAPGRID(... , 'Shape', SHAPEOBJECT) where ShapeObject decended from the ShapeGeneral
            %  class.  For example, this could be a ShapeCircle or ShapePolygon. Active Grid points 
            %  are bounded by the shape
            %
            %  ZMAPGRID(... , 'RefEllipsoid', REF_ELLIPSOID) when provided with a referenceEllipsoid,
            %  units will be determined by the ellipsoid's LengthUnits.
            %
            %  ZMAPGRID(... , 'Units', UNIT_NAME)
            %
            %  ZMAPGRID(... , 'OriginPoint', [Lat, Lon, Depth]) defines the point within the Grid
            %  that is unmoving, even when the grid is resized, resampled, etc.
            %
            % see also: MESHGRID
            if ~exist('createFrom','var')
                createFrom = "FromNothing";
            end                
            
            %% gather and validate input
            
            p = inputParser;
            
            if nargin < 2 ,     createFrom = "FromNothing";   end
            if nargin > 0 ,     obj.Name   = name;            end
                        
            switch createFrom
                case "FromPoints"
                    p.addRequired('pointvector', @(x)isempty(x) || size(x,2)==2 || size(x,2)==3);
                    p.addParameter('Units','');
                case "FromMatrices"
                    p.addRequired('xmatrix');
                    p.addRequired('ymatrix');
                    p.addOptional('zmatrix',[]);
                    p.addParameter('Units','');
                case "FromGridOptions"
                    p.addRequired('gridoptions',@(x)isa(x,'GridOptions'));
                case "FromNothing"
                    % do nothing
                otherwise
                    error('do not know what to create from');
            end
            p.addParameter('OriginPoint'  , [nan nan 0]          , @(x)numel(x)==3 && isnumeric(x));
            p.addParameter('Shape'        , ShapeGeneral.ShapeStash()  , @(x)isa(x,'ShapeGeneral'));
            p.addParameter('RefEllipsoid' , []    , @(x)isa(x,'referenceEllipsoid') || isempty(x) );
            
            p.parse(varargin{:});
            
            myshape = p.Results.Shape;
            refEllipsoid = p.Results.RefEllipsoid; % contains units
            
            if ~isempty(refEllipsoid)
                obj.Units = refEllipsoid.LengthUnit;
            end
            
            %% create the grids
            switch createFrom
                case "FromPoints"
                    point_definition(p.Results.pointvector);
                    obj.Units = p.Results.Units;
                    
                case "FromMatrices"
                    hasSameSize =@(A,B) isequal(size(A), size(B));
                    
                    if isempty(p.Results.zmatrix)
                        assert(hasSameSize(p.Results.xmatrix, p.Results.ymatrix) );
                        matrix_definition(p.Results.xmatrix, p.Results.ymatrix);
                    else
                        assert(hasSameSize(p.Results.xmatrix, p.Results.ymatrix) );
                        assert(hasSameSize(p.Results.xmatrix, p.Results.zmatrix) );
                        matrix_definition(p.Results.xmatrix, p.Results.ymatrix, p.Results.zmatrix);
                    end
                    obj.Units = p.Results.Units;
                    
                case "FromGridOptions"
                    grid_option_definition(p.Results.gridoptions, refEllipsoid);
                    
                case "FromNothing"
                    return
                    
                otherwise
                    error('unknown grid options');
            end
                                    
            
            if isempty(obj.ActivePoints)
                obj.ActivePoints=true(size(obj.X));
            end
            
            return
            
            %% - - - specific creation helpers - - - %%
            
            function grid_option_definition(gridopt, refEllipsoid)
                
                % ZMAPGRID( NAME, GRIDOPTIONS)
                
                % assume it came from GridParameterChoice
                use_shape=gridopt.gridEntireArea & ~isempty(myshape);
                
                % also, assume it is requesting a 2d gid
                
                % 1st: FIGURE OUT ORIGIN POINT OF GRID
                ax=findobj(gcf,'Tag','mainmap_ax');
                if ~isempty(ax)
                    xl = xlim(ax); yl=ylim(ax);
                elseif isprop(varargin{1},'AbsoluteGridLimits')
                    xl=varargin{1}.AbsoluteGridLimits(1:2);
                    yl=varargin{1}.AbsoluteGridLimits(3:4);
                else
                    xl=[-179.9999 180]; 
                    yl=[-90 90];
                end
                minX=max([xl(1), -180]);
                maxX=min([xl(2), 180]);
                minY=max([yl(1), -90]);
                maxY=min([yl(2), 90]);
                
                if  ~isempty(gridopt.FixedAnchorPoint)
                    lonLatZ0=gridopt.FixedAnchorPoint;
                elseif use_shape
                    lonLatZ0=[myshape.X0 myshape.Y0];
                else
                    lonLatZ0=[mean([minX, maxX]), mean([minY, maxY])];
                end
                
                % 2nd: FIGURE OUT DELTAS
                deltasLonLatZ=[gridopt.dx, gridopt.dy];
                
                
                % 3rd: FIGURE OUT LIMITS
                limsLonLatZ=[minX maxX ; minY maxY];
                obj.Units = standardizeDistanceUnits(gridopt.horizUnits);
                
                obj.Origin=lonLatZ0;
                if gridopt.GridType == "XYZ" || gridopt.GridType == "XY"
                    if isempty(refEllipsoid)
                        [obj.X,obj.Y,obj.Z] = ZmapGrid.get_degree_grid(lonLatZ0,deltasLonLatZ,obj.Units, limsLonLatZ, gridopt.followMeridians);
                    else
                        [obj.X,obj.Y,obj.Z] = ZmapGrid.get_nondegree_grid(lonLatZ0, deltasLonLatZ, limsLonLatZ, refEllipsoid);
                    end
                else
                    % "XZ"
                    unimplemented_error()
                end
                if gridopt.GridType == "XY"
                    obj.Z=[];
                end
                
                if use_shape
                    obj=obj.MaskWithShape(myshape.Points);
                end
            end
            
            function point_definition(all_points)
                % where all_points is either
                %    [X1 Y1 ; ... ; Xn Yn] )
                % or
                %    [X1 Y1 Z1 ; ... ; Zn Yn Zn])
                
                assert(size(all_points,2) >= 2 && size(all_points,2) <=3);
                obj.X=all_points(:,1);
                obj.Y=all_points(:,2);
                if size(all_points,2)==3
                    obj.Z = all_points(:,3);
                end
            end
            
            function matrix_definition(Xmatrix, Ymatrix, Zmatrix)
                assert(isequal(size(Xmatrix),size(Ymatrix)),'X and Y should be the same size')
                obj.X=Xmatrix;
                obj.Y=Ymatrix;
                if exist('Zmatrix','var') && ~isempty(Zmatrix)
                    assert(isequal(size(Xmatrix),size(Ymatrix)),'size of Z matrix should match X and Y matrices');
                    obj.Z = Zmatrix;
                end
            end
            
            
        end
        
        %% basic access routines
        function gp = get.GridVector(obj)
            if ~isempty(obj)
                if isempty(obj.Z)
                    gp=[obj.X(:), obj.Y(:)];
                else
                    gp=[obj.X(:), obj.Y(:), obj.Z(:)];
                end
            else
                gp = [];
            end
        end
        
        %% masked access routines
        function x = get.Xactive(obj)
            x=obj.X(obj.ActivePoints);
        end
        
        function y = get.Yactive(obj)
            y=obj.Y(obj.ActivePoints);
        end
        
        function z = get.Zactive(obj)
            z=obj.Z(obj.ActivePoints);
        end
        function points = ActiveGrid(obj)
            points = obj.GridVector(obj.ActivePoints,:);
        end
        
        function obj = set.ActivePoints(obj, values)
            assert(isempty(values) || isequal(numel(values), numel(obj.X))); %#ok<MCSUP>
            obj.ActivePoints = logical(values);
        end
        
        function val = length(obj)
            val = numel(obj.X);
        end
        
        function val = isempty(obj)
            val = isempty(obj.X);
        end
        
        function obj = MaskWithShape(obj,polyX, polyY)
            % MaskWithShape sets the mask according to a polygon
            % does not change the actual grid!
            % obj = obj.MASKWITHSHAPE(shape)
            % obj = obj.MASKWITHSHAPE(polyX, polyY) where polyX and polyY define the polygon
            
            narginchk(1,3);
            nargoutchk(1,1);
            switch nargin
                case 2 % OBJ, POLYX
                    if isa(polyX,'ShapeGeneral')
                        obj.ActivePoints = polyX.isinterior(obj.X, obj.Y);
                        return
                    else
                        assert(size(polyX,2)==2, 'expecting [lon1, lat1 ; ...]');
                        polyY=polyX(:,2);
                        polyX(:,2)=[];
                    end
                    
                case 3 % OBJ, POLYX, POLYY
                    if polyX(1) ~= polyX(end) || polyY(1) ~= polyY(end)
                        warning('ZMAP:polygon:unclosedPolygon','polygon is not closed. adding a point to close it.')
                        polyX(end+1)=polyX(1);
                        polyY(end+1)=polyY(1);
                    end
            end
            if ~isempty(polyX) && ~isnan(polyX(1))
                obj.ActivePoints = inpoly([obj.X, obj.Y],[polyX, polyY]);
                %obj.ActivePoints = polygon_filter(polyX,polyY, obj.X, obj.Y, 'inside');
            else
                obj.ActivePoints = true(size(obj.X));
                disp('not filtering polygon, since no polygon provided');
            end
        end
        
        function obj=delete(obj)
            % remove current grid entirely
            grid_tag = ['grid_' obj.Name];
            prev_grid = findobj('Tag',grid_tag);
            delete(prev_grid);
            obj=ZmapGrid();
        end
        
        %% plotting routines
        function prev_grid=plot(obj, ax,varargin)
            % plot the current grid over axes(ax)
            % obj.PLOT() plots on the current axes
            %  obj.PLOT(ax) plots on the specified axes. if ax is empty, then the current axes will
            %     be used
            %
            %  obj.PLOT(ax,'name',value,...) sets the grid's properties after plotting/updating
            %
            %  obj.PLOT(..., 'ActiveOnly') will only plot the active points. This is useful when
            %   displaying the vertices within a polygon, for example.
            %
            %  if this figure already has a grid with this name, then it will be modified.
            
            if ~exist('ax','var') || isempty(ax)
                ax=gca;
            end
            def_opts={'color',FancyColors.rgb(obj.PlotOpts.Color),...
                'displayname','grid points',...
                'MarkerSize',obj.PlotOpts.MarkerSize,...
                'Marker',obj.PlotOpts.Marker,...
                'LineWidth',obj.PlotOpts.LineWidth,...
                'LineStyle','none'};
            varargin=[def_opts, varargin];
            useActiveOnly= numel(varargin)>0 && strcmpi(varargin{end},'ActiveOnly');
            if useActiveOnly && ~isempty(obj.ActivePoints)
                varargin(end)=[];
                x='Xactive';
                y='Yactive';
            else
                x='X';
                y='Y';
            end
            if ~all(ishandle(ax))
                error('invalid axes provided. If not specifying axes, but are providing additional options, lead with "[]". ex. obj.plot([],''color'',[ 1 1 0])');
            end
            grid_tag = ['grid_' obj.Name];
            prev_grid = findobj(ax,'Tag',grid_tag);
            if ~isempty(prev_grid)
                prev_grid.XData=obj.(x)(:);
                prev_grid.YData=obj.(y)(:);
                % disp('reusing grid on plot');
            else
                ax.NextPlot='add';
                prev_grid=line(ax,obj.(x)(:),obj.(y)(:),'Tag',grid_tag);
                ax.NextPlot='replace';
                % disp('created new grid on plot');
            end
            % make sure that grid is on the bottom layer
            chh=ax.Children;
            if ~isempty(prev_grid)
                ax.Children=[ax.Children(chh~=prev_grid); ax.Children(chh==prev_grid)];
            end
            
            if ~isempty(varargin)
                set(prev_grid,varargin{:});
            end
        end
        
        function h=pcolor(obj, ax, values, name)
            % PCOLOR create a pcolor plot where each point of the grid is center of cell
            % h = obj.PCOLOR(ax, values) plos the values as a pcolor plot, where
            % each grid point is contained within a color cell. the cells are divided halfway
            % between each point in the vector
            %  where :
            %    AX is the axis of choice (empty for gca)
            %    VALUES is a matrix of values that matches the grid in size.
            %
            %
            % h is a handle to the pcolor object
            %
            % see also gridpcolor
            if ~exist('name','var')
                name = '';
            end
            assert(numel(obj.X)==numel(values),'Number of values doesn''t match number of points')
            if isvector(values) && ~isvector(obj.X)
                values=reshape(values,size(obj.X));
            end
            h=gridpcolor(ax,obj.X, obj.Y, values, obj.ActivePoints, name);
        end
        
        function [c,h]=contourf(obj, ax, values, name, nlevels)
            % [c,h]=CONTOURF(obj,ax, values, name, nlevels)
            if ~exist('nlevels','var') || ~isempty(nlevels)
                nlevels=20;
            end
            
            [c,h]=contourf(ax,obj.X, obj.Y, reshape(values, size(obj.X)));
            % set the title
            h.LineStyle='none';
            h.DisplayName=name;
            if ~all(isnan(values))
                if numel(nlevels)>1
                    h.LevelList = nlevels;
                else
                    h.LevelList = linspace(floor(min(values(:))), ceil(max(values)), nlevels);
                end
            end
        end
        
        function h=imagesc(obj, ax, values, name)
            % imagesc create a imagesc plot where each point of the grid is center of cell
            % h = obj.pcolor(ax, values) plots the values as a pcolor plot, where
            % each grid point is contained within a color cell. the cells are divided halfway
            % between each point in the vector
            %  where :
            %    AX is the axis of choice (empty for gca)
            %    VALUES is a matrix of values that matches the grid in size.
            %
            %
            % h is a handle to the pcolor object
            %
            % see also gridpcolor
            if ~exist('name','var')
                name = '';
            end
            assert(numel(values)==numel(obj.X),'expect same number of values');
            if ~isequal(size(values),size(obj.X))
                values = reshape(values,size(obj.X));
            end
            
            % corners for image
            x = bounds2(obj.X);
            y = bounds2(obj.Y);
            try
                values(~obj.ActivePoints)=nan;
            catch
                values=double(values);
                values(~obj.ActivePoints)=nan;
            end
            %axes ax
            imAlpha=ones(size(values));
            imAlpha(isnan(values))=0;
            %imAlpha=~obj.ActivePoints;
            h=imagesc(x, y, values,'AlphaData',imAlpha);%, obj.ActivePoints,name);
            set(ax,'YDir','normal');
        end
        
        %% io routines
        function save(obj, filename, pathname)
            % save grid to .mat file
            ZG=ZmapGlobal.Data;
            if ~exist('filename','var')
                filename = fullfile(pathname,['zmapgrid_',obj.Name,'.m']);
                uisave('zmapgrid',filename)
            elseif ~exist('path','var')
                filename = fullfile(ZG.Directories.data,['zmapgrid_',obj.Name,'.m']);
                uisave('zmapgrid',filename)
            else
                uisave('zmapgrid',fullfile(pathname,filename));
            end
        end
    end
    
    methods(Static)

        function [lonMat,latMat,zMat] = get_degree_grid(lonLatZ0, deltasXYZ, deltaUnits,limsLonLatZ, FOLLOW_MERIDIANS)
            % GET_GRID given an origin point and dlon, dlat, returns a grid as 2 matrices
            %
            %[lonMat,latMat] = ZMAPGRID.GET_GRID(lon0,lat0,dLon,dLat, FOLLOW_MERIDIANS)
            % input is the origin point and arclength between points
            %    If FOLLOW_MERIDIANS, then x distances converge toward poles. otherwise
            %    they remain (relatiely) constant
            %
            %
            % when following the meridian lines, the longitude span covered by
            % the arc-distance at lat0 (along the rhumb!) remains constant.
            % that is, dLon 45 from origin (0,0) will always be 45, regardless of latitude.
            %
            % when ignoring meridian lines, and aiming for an approximately constant distance,
            % the dLon at each latitude will differ.
            %
            % output is  (lon, lat) or [lon, lat, z]
            %
            % limits can be retrieved from an axes
            %
            % use the axes limits (assumed degrees) to control size of grid
            % limsLonLatZ=[xlim(ax); ylim(ax); zlim(ax)]
            
            zMat    = [];
            % origin point
            lon0    = lonLatZ0(1);
            lat0    = lonLatZ0(2);
            
            %
            % deltas
            [dLat, dLon, dZ, deltaUnits] = deltasToDegrees(deltasXYZ, deltaUnits);            
            
            xlims_deg = limsLonLatZ(1,:);
            ylims_deg = limsLonLatZ(2,:);
            % pick out latitude spacing. Our grid will have this many rows.
            lats = ZmapGrid.vector_including_origin(lat0, dLat, ylims_deg);            
            
            if ~exist('FOLLOW_MERIDIANS','var')
                FOLLOW_MERIDIANS = standardizeDistanceUnits(deltaUnits) == "degrees";
            end
            
            if FOLLOW_MERIDIANS
                [~,dLon] = reckon('rh', lat0, 0, dLon,90);
                
                % resulting in a rectangular matrix where, on a globe lines will converge, but on a graph
                lonValues = ZmapGrid.vector_including_origin(lon0, dLon, xlims_deg);
                
                %creates a meshgrid of size numel(lonValues) x numel(lats)
                [lonMat,latMat] = meshgrid(lonValues,lats);
                
            else
                
                % number of degrees longitude covered by the arclength at each latitude
                [~,dLon_per_lat] = reckon('rh', lats, 0, dLon, 90);
                
                [lonMat, latMat] = ZmapGrid.get_lalo_matrices(dLon_per_lat, xlims_deg, lon0, lats, xlims_deg);
            end
            
            if numel(deltasXYZ)==3
                zlims_km = limsLonLatZ(3,:);
                zs       = ZmapGrid.vector_including_origin(lonLatZ0, deltasXYZ(3), zlims_km);
                lonMat   = repmat(lonMat,1,1,numel(zs));
                latMat   = repmat(latMat,1,1,numel(zs));
                zMat     = ones(size(lonMat));
                for n=1:numel(zs)
                    zMat(:,:,n) = zs(n);
                end
                assert(isequal(size(lonMat),size(zMat)));
            end
            
            %% subfunctions
            function d = toDegrees(value, originalUnit)
                % convert from any unit to degrees
                deltaUnits = standardizeDistanceUnits( originalUnit );
                if deltaUnits == "degrees"
                    d = value;
                else
                    d = km2deg(value .* unitsratio('kilometer', deltaUnits), obj.Planet);
                end     
            end
            
            function  [dLat, dLon, dZ, deltaUnits] = deltasToDegrees(deltasXYZ, deltaUnits)
                % get deltas in degrees (Horiz) and km (Vert) translating horiz units as necessary                    
                switch(numel(deltasXYZ))
                    case 0
                        gop = ZmapGlobal.Data.gridopt;
                        assert(~isempty(gop),...
                            'Grid options haven''t been defined. Define them or specify delta values for this function');
                        assert(gop.dx_units == gop.dy_units, 'expected dx & dy to be same units');
                        
                        dY         = gop.dy;
                        dX         = gop.dx;
                        deltaUnits = gop.dx_units; % assumes dx & dy are the same!
                        % dZ = gop.dz;
                    case 1
                        dY = deltasXYZ;
                        dX = deltasXYZ;
                        dZ = [];
                    case 2
                        dY = deltasXYZ(2);
                        dX = deltasXYZ(1);
                        dZ = [];
                    case 3
                        dY = deltasXYZ(2);
                        dX = deltasXYZ(1);
                        dZ = deltasXYZ(3);
                end
                dLon = toDegrees(dX, deltaUnits);
                dLat = toDegrees(dY, deltaUnits);
            end
        end
        
        
        function [lonMat,latMat,zMat] = get_nondegree_grid(lonLatZ0, deltasXYZ, limsLonLatZ, refEllipsoid)
            % [lonMat,latMat,zMat] = get_nondegree_grid(lonLatZ0, deltasXYZ, limsLonLatZ, refEllipsoid)
            % all delta units are the refEllipsoid units.  eg, km, m, cm, etc.
            
            lats = get_grid_lats( ...
                lonLatZ0        , ...  grid origin points, guaranteed to be in grid
                deltasXYZ(2)    , ...  delta Y
                limsLonLatZ(2,:), ...  Y limits
                refEllipsoid);
            
            xTotalDists = bounded_distance_at_each_latitude(limsLonLatZ(1,:), lats, refEllipsoid);
            
            [~,dLon_per_lat] = reckon('rh', lats(:), 0, deltasXYZ(1), 90, refEllipsoid);
            
            [lonMat, latMat] = ZmapGrid.get_lalo_matrices(dLon_per_lat, xTotalDists, lonLatZ0(1), lats, limsLonLatZ(1,:));
            zMat=[];
        end
        
        function totEstPts = estimate_points(dLon_per_lat , xTotalDists)
            totEstPts= ceil(sum( ( 1./dLon_per_lat ) .* range(xTotalDists) ));
            if totEstPts > ZmapGrid.POSSIBLY_TOO_MANY_POINTS
                error('ZMAPGRID:get_grid:TooManyGridPoints','Too many grid points: est. %d',totEstPts);
            end
        end
        
        function [lonMat, latMat] = get_lalo_matrices(dLon_per_lat, xTotalDists, lon0, lats, lonBounds)
            % This function deserves a name
            totEstPts = ZmapGrid.estimate_points(dLon_per_lat , xTotalDists);
            
            lonMat=nan(totEstPts,1);
            latMat=nan(totEstPts,1);
            nPts=0;
            
            for n=1:numel(lats)
                theseLonValues  = ZmapGrid.vector_including_origin(lon0, dLon_per_lat(n), lonBounds);
                myEnd                   = nPts + numel(theseLonValues);
                lonMat(nPts+1 : myEnd)  = theseLonValues(:);
                latMat(nPts+1 : myEnd)  = lats(n);
                nPts                    = myEnd;
            end
            
            if nPts < totEstPts
                lonMat(nPts+1:end) = [];
                latMat(nPts+1:end) = [];
            end
            [lonMat,latMat] = cols2matrix(lonMat,latMat,lon0);
        end
        
        function v = vector_including_origin(orig_deg, delta_deg, lims_deg)
            % VECTOR_INCLUDING_ORIGIN returns values in a range, gaurenteed to contain the origin value
            %
            % ZMAPGRID.VECTOR_INCLUDING_ORIGIN(orig_deg, delta_deg, lims_deg)
            v = unique([...
                orig_deg : -delta_deg : min(lims_deg) ,...
                orig_deg :  delta_deg : max(lims_deg)...
                ]);
            v( min(lims_deg)>v | v>max(lims_deg) ) = [];
        end
        
        function obj=load(filename, pathname)
            % mygrid = ZMAPGRID.LOAD() prompts user for a zmap grid file
            %
            % mygrid = ZMAPGRID.LOAD('grid1') -> attempts to load 'grid1' or 'zmapgrid_grid1.m' from
            % the data directory, and then anywhere the matlab path.
            %
            % mygrid = ZMAPGRID.LOAD('grid1', 'mydir') - attempts to load 'grid1' or
            % 'zmapgrid_grid1.m' from the mydir directory.
            %
            % the grid must be contained in a variable named 'zmapgrid' and of type ZmapGrid
            switch nargin
                case 0
                    [filename, pathname] = uigetfile('zmapgrid_*.m', 'Pick a ZmapGrid file');
                    fullfilename= fullfile(pathname,filename);
                case 1
                    if exist(fullfile(ZG.Directories.data,filename),'file')
                        fullfilename=fullfile(ZG.Directories.data,filename);
                    elseif exist(filename,'file')
                        fullfilename=filename;
                    else
                        fullfilename=fullfile(ZG.Directories.data,['zmapgrid_' filename '.m']);
                    end
                case 2
                    if exist(fullfile(pathname,filename),'file')
                        fullfilename=fullfile(pathname,filename);
                    else
                        fullfilename=fullfile(pathname,['zmapgrid_' filename '.m']);
                    end
            end
            try
                tmp=load(fullfilename,'zmapgrid');
                obj=tmp.zmapgrid;
                assert(isa(obj,'ZmapGrid'));
            catch ME
                errordlg(ME.message);
            end
        end
    end
end

%% -- other helper functions --

function lats = get_grid_lats(lonLatZ0, dY, latBounds, refEllipsoid)
    lat0 = lonLatZ0(2);
    lon0 = lonLatZ0(1);
    
    if latBounds(1) > latBounds(2)
        latBounds = latBounds([2,1]);
    end
    
    % calculate how far to the north and south the bounded region extends
    [NS_extents,az] = distance(lat0,lon0, latBounds,lon0, refEllipsoid);
    NS_extents(az==180) = -NS_extents(az==180); % swap signs for anything that is to the origin's south.
    
    % create evenly spaced values radiating from our latitude origin
    % dY = deltasXYZ(2);
    Ys = [fliplr( 0 : -dY : NS_extents(1)), dY : dY: NS_extents(2) ];  % relative offset in units from lat
    Ys(NS_extents(2)<Ys | Ys<NS_extents(1) ) = [];
    
    % project on the ellipsoid, getting latitudes for each of or rows of grid points.
    [lats,~] = reckon('rh', lat0,lon0, Ys, 0, refEllipsoid);
    lats = lats(:);
end

function xTotalDists = bounded_distance_at_each_latitude(lonBounds, lats, refEllipsoid)
    % calculate points representing the bounded region.
    mins_along_lon0 =  [lats(:), repmat(min(lonBounds), size(lats))];
    maxs_along_lon0 =  [lats(:), repmat(max(lonBounds), size(lats))];
    
    % how much physical distance is covered within the set boundaries for each latitude?
    xTotalDists = distance('rh', mins_along_lon0, maxs_along_lon0, refEllipsoid); %ellipsoid units
    if ~any(xTotalDists)
        % oops, reached around the entire ellipsoid. calculate half distance, then double it
        xTotalDists=distance('rh', [lats,lats.*0], (maxs_along_lon0-mins_along_lon0)/2, refEllipsoid) .*2;
    end
    
end

function [xs, ys] = cols2matrix(lonCol,latCol, lon0)
    % COLS2MATRIX convert columns of lats & lons into a matrix.
    %
    % [XS,YS]=cols2matrix(lonCol,latCol,lon0)
    %    LONCOL: column of longitudes, non-unique
    %    LATCOL: column of latitudes, non-unique
    %       Together, all points in grid would be included in [LONCOL, LATCOL]
    %    LON0: longitudes that are supposed to line up. this should be a longitude that
    %          exists at every latitude.
    
    ugy         = unique(latCol);               % lats in matrix
    nrows       = numel(ugy);                   % number of latitudes in matrix
    [~,example] = min(abs(latCol(:)));          % latitude closest to equator has most lons
    mostCommonY = latCol(example);              % account for the abs possibly flipping signs
    base_lon_idx= find(lonCol(latCol==mostCommonY)==lon0); % longitudes that must line up
    ncols       = sum(latCol(:)==mostCommonY);  % most lons in matrix
    ys          = repmat(ugy(:),1,ncols);
    xs          = nan(nrows,ncols);
    
    for n=1:nrows
        thislat     = ugy(n);                   % lat for this row
        these_lons  = lonCol(latCol==thislat);  % lons in this row
        row_length  = numel(these_lons);        % number of lons in this row
        
        main_lon_idx= find(these_lons==lon0);   % offset of X in this row
        offset      = base_lon_idx - main_lon_idx;
        xs(n,(1:row_length)+offset) = these_lons;
    end
    
end