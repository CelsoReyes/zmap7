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
    %     AutoCreateDeg -create ZDataGrid based on current Map extent/Catalog extent, whichever is smaller
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
    %
    properties
        Name (1,:) char = '' % name of this grid
        Units (1,:) char = 'unk' % degrees or kilometers
        ActivePoints logical    % logical mask
        X double % all X positions in matrix
        Y double % all Y positions in matrix
        Z double % all Y positions in matrix.
        Origin % [lon0, lat0, z0] of grid origin point. grid is created outward from here.
    end
    properties(Dependent)
        Xactive % all X positions for active points
        Yactive % all Y positions for active points
        Zactive % all Z positions for active points
        GridVector % Nx2 or Nx3 of all grid points [X1,Y1; X2,Y2;...] or [X1,Y1,Z1; X2,Y2,Z2; ...]
    end
    properties(Constant,Hidden)
        POSSIBLY_TOO_MANY_POINTS = 1000 * 1000;
    end
    
    methods
        function obj = ZmapGrid(name, varargin)
            %ZMAPGRID create a grid of points
            %   OBJ = ZMAPGRID(NAME, GPC_STRUCT) where gpc_struct has fields dx, dy, [dz,] dx_units, GridEntireArea.
            %
            % ZMAPGRID(name,origin_degs, deltas_degs, limits_degs, follow_meridians) where
            %   origin_degs is (Lon, Lat) or (Lon, Lat, Z_km). 
            %   delta_degs is [dLon, dLat] or [dLon, dLat, dZ_km]
            %   limits_degs is [lonMin lonMax ; latMin LatMax] or
            %      [lonMin lonMax ; latMin LatMax ; depthMin_km depthMax_km]
            %   follow_meridians is true or false.
            %
            %   ZMAPGRID(NAME, ALL_X, ALL_Y, UNITS) create a grid, where the X is the provided ALL_X
            %   Y is the provided ALL_Y.  This creates a grid [X1 Y1; X1 Y2; ... Xn Ym
            %
            %   ZMAPGRID(NAME,ALL_POINTS,UNITS); % NOT RECOMMENDED
            %
            % see also: MESHGRID
            if exist('name','var')
                obj.Name = name;
            end
            switch nargin
                case 0
                    % don't do much of anything.
                case 2
                    if isnumeric(varargin{1})
                        % ZMAPGRID( NAME , [X1,Y1;...;XnYn] )
                        warning('ZmapGrid works best when provided with X and Y matrices of points');
                        
                        assert(size(varargin{1},2) >= 2 && size(varargin{1},2) <=3);
                        obj.X=varargin{1}(:,1);
                        obj.Y=varargin{1}(:,2);
                        if size(varargin{1},2)==3
                            obj.Z = varargin{1}(:,3);
                        end
                    elseif isstruct(varargin{1})
                        % ZMAPGRID( NAME, GRIDOPTIONS)
                        
                        % assume it came from GridParameterChoice
                        ZG=ZmapGlobal.Data;
                        gridopt=varargin{1};
                        use_shape=isfield(gridopt,'GridEntireArea') &&...
                            ~gridopt.GridEntireArea;
                        
                        if use_shape
                            myshape=ZG.selection_shape;
                            use_shape = ~isempty(myshape); % no shape to use. cancel that order.
                            if ~use_shape
                                ZmapMessageCenter.set_warning('Polygon not defined',...
                                'Requested that grid conforms to shape, but no shape is defined.');
                            end
                        end
                        
                        % also, assume it is requesting a 2d gid
                        
                        % 1st: FIGURE OUT ORIGIN POINT OF GRID
                        ax=findobj(gcf,'Tag','mainmap_ax');
                        if use_shape
                            lonLatZ0=[myshape.X0 myshape.Y0];
                        else
                            lonLatZ0=[mean(xlim(ax)), mean(ylim(ax))];
                        end
                            
                        % 2nd: FIGURE OUT DELTAS
                        deltasLonLatZ=[gridopt.dx,gridopt.dy];
                        
                        
                        % 3rd: FIGURE OUT LIMITS
                        limsLonLatZ=[xlim(ax);ylim(ax)];
                        
                        follow_meridians=strcmp(gridopt.dx_units,'deg');
                        obj.Units = gridopt.dx_units;
                        
                        [obj.X,obj.Y,obj.Z] = ZmapGrid.get_grid(lonLatZ0,deltasLonLatZ,...
                                                                limsLonLatZ, follow_meridians);
                        
                        if use_shape
                            obj=obj.MaskWithShape(myshape.Points);
                        end
                    else
                        error('unknown');
                    end
                case 3
                    % ZMAPGRID( name, all_points, units)
                    warning('ZmapGrid works best when provided with X and Y matrices of points');
                    assert(size(varargin{1},2)==2);
                    obj.X=varargin{1}(:,1);
                    obj.Y=varargin{1}(:,2);
                    assert(ischar(varargin{2}));
                    obj.Units = varargin{2};
                case 4
                    % ZMAPGRID( name, Xmatrix, Ymatrix, units)
                    assert(isequal(size(varargin{1}),size(varargin{2})),'X and Y should be the same size');
                    obj.X=varargin{1};
                    obj.Y=varargin{2};
                    assert(ischar(varargin{3}));
                    obj.Units = varargin{3};
                case 5
                    %ZMAPGRID(name,origin_degs, deltas_degs, limits_degs, follow_meridians) 
                    lonLatZ0=varargin{1};
                    deltasLonLatZ = varargin{2};
                    limsLonLatZ = varargin{3};
                    follow_meridians = varargin{4};
                    obj.Units='degrees';
                    [obj.X,obj.Y,obj.Z] = ZmapGrid.get_grid(lonLatZ0,deltasLonLatZ,...
                                                            limsLonLatZ, follow_meridians);
                    
                otherwise
                    error('incorrect number of arguments %d', nargin);
            end
            
            if isempty(obj.ActivePoints)
                obj.ActivePoints=true(size(obj.X));
            end
            
        end
        
        % basic access routines
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
        
        % masked access routines
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
            % obj = obj.MASKWITHSHAPE() user selects polygon from gca
            % obj = obj.MASKWITHSHAPE(shape)
            % obj = obj.MASKWITHSHAPE(polyX, polyY) where polyX and polyY define the polygon
            report_this_filefun(mfilename('fullpath'));
            narginchk(1,3);
            nargoutchk(1,1);
            switch nargin
                case 2 % OBJ, POLYX
                    if isa(polyX,'ShapeGeneral')
                        polyY=polyX.Lat;
                        polyX=polyX.Lon;
                    else
                        assert(size(polyX,2)==2, 'expecting [lon1, lat1 ; ...]');
                        polyY=polyX(:,2);
                        polyX(:,2)=[];
                    end
                    
                case 1 % OBJ only
                    ZG=ZmapGlobal.Data;
                    if ~isempty(ZG.selection_shape) && ~isnan(ZG.selection_shape.Points(1))
                        polyX=ZG.selection_shape.Lon;
                        polyY=ZG.selection_shape.Lat;
                    end
                case 3 % OBJ, POLYX, POLYY
                    if polyX(1) ~= polyX(end) || polyY(1) ~= polyY(end)
                        warning('polygon is not closed. adding a point to close it.')
                        polyX(end+1)=polyX(1);
                        polyY(end+1)=polyY(1);
                    end
            end
            if ~isempty(polyX) && ~isnan(polyX(1))
                obj.ActivePoints = polygon_filter(polyX,polyY, obj.X, obj.Y, 'inside');
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
            def_opts={'color',[.5 .5 .5],'displayname','grid points','markersize',4,'marker','+'};
            varargin=[def_opts,varargin];
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
                disp('reusing grid on plot');
            else
                hold(ax,'on');
                prev_grid=line(ax,obj.(x)(:),obj.(y)(:),'Marker','+','Color','k','LineStyle','none','Tag',grid_tag);
                hold(ax,'off');
                disp('created new grid on plot');
            end
            % make sure that grid is on the bottom layer
            chh=ax.Children;
            ax.Children=[ax.Children(chh~=prev_grid); ax.Children(chh==prev_grid)];
             
            if numel(varargin)>1
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
            x = [min(obj.X) max(obj.X)];
            y = [min(obj.Y) max(obj.Y)];
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
        
        function setGlobal(obj)
            % set the globally used grid to this one.
            ZG=ZmapGlobal.Data;
            ZG.grid=obj;
        end
        
        function save(obj, filename, pathname)
            % save grid to .mat file
            ZG=ZmapGlobal.Data;
            if ~exist('filename','var')
                filename = fullfile(pathname,['zmapgrid_',obj.Name,'.m']);
                uisave('zmapgrid',filename)
            elseif ~exist('path','var')
                filename = fullfile(ZG.data_dir,['zmapgrid_',obj.Name,'.m']);
                uisave('zmapgrid',filename)
            else
                uisave('zmapgrid',fullfile(pathname,filename));
            end
        end
    end
    
    methods(Static, Access=protected)
        function [xs, ys] = cols2matrix(lonCol,latCol, lon0)
            % COLS2MATRIX convert columns of lats & lons into a matrix.
            %
            % [XS,YS]=cols2matrix(lonCol,latCol,lon0)
            %    LONCOL: column of longitudes, non-unique
            %    LATCOL: column of latitudes, non-unique
            %       Together, all points in grid would be included in [LONCOL, LATCOL]
            %    LON0: longitudes that are supposed to line up. this should be a longitude that
            %          exists at every latitude.
            
            ugy=unique(latCol); % lats in matrix
            nrows=numel(ugy); % number of latitudes in matrix
            [~,example]=min(abs(latCol(:))); % latitude closest to equator will have most number of lons in matrix
            mostCommonY=latCol(example); % account for the abs possibly flipping signs
            base_lon_idx=find(lonCol(latCol==mostCommonY)==lon0); % longitudes that must line up
            ncols=sum(latCol(:)==mostCommonY); % most number of lons in matrix
            ys=repmat(ugy(:),1,ncols);
            xs=nan(nrows,ncols);
            for n=1:nrows
                thislat=ugy(n); % lat for this row
                idx_lons=(latCol==thislat); % mask of lons in this row
                these_lons=lonCol(idx_lons); % lons in this row
                row_length=numel(these_lons); % number of lons in this row
                
                main_lon_idx=find(these_lons==lon0); % offset of X in this row
                offset=base_lon_idx - main_lon_idx;
                xs(n,(1:row_length)+offset)=these_lons;
            end
            
        end
    end
    
    methods(Static)
        function obj=AutoCreateDeg(name, ax, catalog)
            % creates a ZDataGrid based on current Map extent/Catalog extent, whichever is smaller.
            % obj = ZMAPGRID.AUTOCREATEDEG() greates a catalog based on mainmap and primary catalog
            % obj = ZMAPGRID.AUTOCREATEDEG(ax, catalog) specifies a map axis handle and a catalog to use.
            
            XBINS=20;
            YBINS=20;
            %ZBINS=5;
            ZG=ZmapGlobal.Data;
            switch nargin
                case 0
                    name='unnamed';
                    ax=mainmap('axes');
                    catalog=ZG.primeCatalog;
                case 1
                    ax=mainmap('axes');
                    catalog=ZG.primeCatalog;
                case 3
                    assert(isa(catalog,'ZmapCatalog'));
                    assert(isvalid(ax));
                otherwise
                    error('Either use AutoCreate(name) or AutoCreate(name, ax, catalog)');
            end
            
            mapWESN = axis(ax);
            x_start = max(mapWESN(1), min(catalog.Longitude));
            x_end = min(mapWESN(2), max(catalog.Longitude));
            y_start = max(mapWESN(1), min(catalog.Latitude));
            y_end = min(mapWESN(2), max(catalog.Latitude));
            %z_start = 0;
            %z_end = max(catalog.Depth);
            dx= (x_end - x_start)/XBINS;
            dy= (y_end - y_start)/YBINS;
            %dz =  (z_end - z_start)/ZBINS;
            %TODO make spacing more intelligent. maybe.
            %FIXME map units and this unit might be out of whack.
            obj=ZmapGrid(name,x_start, dx, x_end, y_start, dy, y_end, 'deg');
        end
        
        function [lonMat,latMat,zMat] = get_grid(lonLatZ0,deltasLonLatZ, limsLonLatZ, FOLLOW_MERIDIANS)
            % GET_GRID given an origin point and dlon, dlat, returns a grid as 2 matrices
            %
            %[lonMat,latMat] = ZMAPGRID.GET_GRID(lon0,lat0,dLon,dLat, FOLLOW_MERIDIANS)
            % input is the origin point and arclength between points
            %    If FOLLOW_MERIDIANS, then x distances converge toward poles. otherwise
            %    they remain (relatiely) constant
            %
            % output is 2 matrices (lon, lat)
            %
            % limits can be retrieved from an axes
            %
            % use the axes limits (assumed degrees) to control size of grid
            % limsLonLatZ=[xlim;(x)ylim(ax);zlim(ax);
            %ylims_deg = ylim(ax);
            %xlims_deg = xlim(ax);
            
            % base grid on a single distance, so that instead of separate dx & dy, we use dd
            %dist_arc = max([...
            %    distance(lat0,lon0,lat0,lon0+dLon,'degrees'),...
            %    distance(lat0,lon0,lat0+dLat,lon0,'degrees')]);
            
            %d.String=sprintf('Dist: %.3f (deg) [%.3f (km)]',dist_arc,deg2km(dist_arc));
            zMat=[];
            % origin point
            lon0=lonLatZ0(1);
            lat0=lonLatZ0(2);
            
            %
            % deltas
            switch(numel(deltasLonLatZ))
                case 0
                    % get from Zmap Global
                    ZG=ZmapGloba.Data; 
                    assert(~isempty(ZG.gridopt),...
                        'Grid options haven''t been defined. Define them or specify delta values for this functin');
                    switch ZG.gridopt.dx_units
                        case 'deg'
                           dLon=ZG.gridopt.dx;
                           if ~exist('FOLLOW_MERIDIANS','var')
                               % assumed intent with deg is to keep longitudes constant.
                               FOLLOW_MERIDIANS=true;
                           end
                        case 'km'
                            dLon=km2deg(ZG.gridopt.dx);
                           if ~exist('FOLLOW_MERIDIANS','var')
                               % assumed intent with km is to keep distance constant
                               FOLLOW_MERIDIANS=false;
                           end
                    end
                    switch ZG.gridopt.dy_units
                        case 'deg'
                            dLat=ZG.gridopt.dy;
                        case 'km'
                            dLon=Zkm2deg(ZG.gridopt.dy);
                    end
                case 1
                    dLat = deltasLonLatZ;
                    dLon = deltasLonLatZ;
                case 2
                    dLat = deltasLonLatZ(2);
                    dLon = deltasLonLatZ(1);
                case 3
                    dLat = deltasLonLatZ(2);
                    dLon = deltasLonLatZ(1);
                    dZ = deltasLonLatZ(3);
            end
            
            xlims_deg=limsLonLatZ(1,:);
            ylims_deg=limsLonLatZ(2,:);
            % pick out latitude spacing. Our grid will have this many rows.
            lats = ZmapGrid.vector_including_origin(lat0, dLat, ylims_deg);
            lonMat=[];
            latMat=[];
            
            if FOLLOW_MERIDIANS
                % when following the meridian lines, the longitude span covered by
                % the arc-distance at lat0 (along the rhumb!) remains constant.
                % that is, dLon 45 from origin (0,0) will always be 45, regardless of latitude.
                [~,dLon]=reckon('rh',lat0,0,dLon,90);
                
                % resulting in a rectangular matrix where, on a globe lines will converge, but on a graph
                lonValues = ZmapGrid.vector_including_origin(lon0, dLon, xlims_deg);
                
                %creates a meshgrid of size numel(lonValues) x numel(lats)
                [lonMat,latMat]=meshgrid(lonValues,lats);
                
            else
                % when ignoring meridian lines, and aiming for an approximately constant distance,
                % the dLon at each latitude will differ.
                
                % number of degrees longitude covered by the arclength at each latitude
                [~,dLon_per_lat]=reckon('rh',lats,0,dLon,90);
                
                for n=1:numel(lats)
                    theseLonValues = ZmapGrid.vector_including_origin(lon0, dLon_per_lat(n), xlims_deg);
                    lonMat=[lonMat;theseLonValues(:)]; %#ok<AGROW>
                    latMat=[latMat;repmat(lats(n),size(theseLonValues(:)))]; %#ok<AGROW>
                end
                
                [lonMat,latMat] = ZmapGrid.cols2matrix(lonMat,latMat,lon0);
                % each gridx & gridy are vectors.
            end
            if numel(deltasLonLatZ)==3
                zlims_km=limsLonLatZ(3,:);
                zs=vector_including_origin(lonLatZ0, deltasLonLatZ(3), zlims_km);
                lonMat=repmat(lonMat,1,1,numel(zs));
                latMat=repmat(latMat,1,1,numel(zs));
                zMat=ones(size(lonMat));
                for n=1:numel(zs)
                    zMat(:,:,n)=zs(n);
                end
                assert(isequal(size(lonMat),size(zMat)));
            end
        end
        
        function v = vector_including_origin(orig_deg, delta_deg, lims_deg)
            % VECTOR_INCLUDING_ORIGIN returns values in a range, gaurenteed to contain the origin value
            %
            % ZMAPGRID.VECTOR_INCLUDING_ORIGIN(orig_deg, delta_deg, lims_deg)
            v = unique([orig_deg : -delta_deg : min(lims_deg) , orig_deg : delta_deg :max(lims_deg)]);
            v(v>max(lims_deg)| v<min(lims_deg))=[];
        end
        
        %{
        function obj=FromVectors(name, x,y, z, units)
            % ZMAPGRID.FROMVECTORS creates a meshgrid from X and Y vectors
            % does not take actual distances into account, so that x spacing is
            % tighter toward the poles
            % obj=FromVectors(name, x,y, units)
            if isempty(z)
            [X, Y] =  meshgrid(x, y);
            obj=ZmapGrid(name,X,Y,units);
        end
        %}
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
                    if exist(fullfile(ZG.data_dir,filename),'file')
                        fullfilename=fullfile(ZG.data_dir,filename);
                    elseif exist(filename,'file')
                        fullfilename=filename;
                    else
                        fullfilename=fullfile(ZG.data_dir,['zmapgrid_' filename '.m']);
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