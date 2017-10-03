classdef ZmapGrid
    %ZmapGrid grid for use in zmap's various calculation routines
    
    properties
        Name % name of this grid
        GridXY  % [X1,Y1 ; ... ; Xn,Yn] matrix of positions
        Units % degrees or kilometers
        ActivePoints    % logical mask
        Xvector % vector for column positions (unique points)
        Yvector % vector for row positions (unique points)
        Dx % delta-X
        Dy % delta-Y
    end
    properties(Dependent)
        X % all X positions (points will repeat, since they represent matrix nodes)
        Y % all Y positions (points will repeat, since they represent matrix nodes)
        Xactive % all X positions for active points
        Yactive % all Y positions for active points
        ActiveGrid % [X Y;...] for active points
    end
    
    methods
        function obj = ZmapGrid(name, varargin)
            % create a ZmapGridStruc
            % obj=ZmapGrid(name, gpc_struct) where gpc_struct has fields dx,dy, dx_units
            % obj=ZmapGrid(name, all_points, units); % NOT RECOMMENDED
            % obj=ZmapGrid(name, all_x, all_y, units); 
            % obj=ZmapGrid(name, x_start, dx, x_end, y_start, dy, y_end, units)
            obj.Name = name;
            switch nargin
                case 2
                    if isnumeric(varargin{1})
                        % name, all_points
                        warning('ZmapGrid works best when provided with Xvector and Yvector of points');
                        assert(size(varargin{1},2)==2);
                        obj.GridXY = varargin{1};
                        obj.Units='unk';
                        obj.Xvector=[];
                        obj.Yvector=[];
                    elseif isstruct(varargin{1})
                        % assume it came from GridParameterChoice
                        g=varargin{1};
                        ax=gca;
                        obj.Dx=g.dx;
                        obj.Dy=g.dy;
                        obj.Units=g.dx_units;
                        axlims=axis(ax);
                        obj.Xvector=axlims(1) : obj.Dx : axlims(2);
                        obj.Yvector=axlims(3) : obj.Dy : axlims(4);
                        [x,y]=meshgrid(obj.Xvector, obj.Yvector);
                        obj.GridXY=[x(:),y(:)];
                        if isfield(g,'GridEntireArea') && ~g.GridEntireArea
                            myshape=ZmapGlobal.Data.selection_shape;
                            if isnan(myshape.Points(1))
                                zmap_message_center.set_warning('Polygon not defined',...
                                    'Requested that grid is limited by the polygon, but no polygon is defined.');
                                myshape=myshape.select_polygon();
                            end
                            obj.MaskWithPolygon(myshape.Points)
                            % choose polygon
                        end 
                        %obj=ZmapGrid(name, v. '
                    else
                        error('unknown');
                    end
                case 3
                    % name, all_points, units
                    warning('ZmapGrid works best when provided with Xvector and Yvector of points');
                    assert(size(varargin{1},2)==2);
                    obj.GridXY = varargin{1};
                    obj.Xvector=[];
                    obj.Yvector=[];
                    assert(ischar(varargin{2}));
                    obj.Units = varargin{2};
                case 4
                    % name, Xvector, Yvector, units
                    obj.Xvector=varargin{1};
                    obj.Yvector=varargin{2};
                    [x,y]=meshgrid(obj.Xvector, obj.Yvector);
                    obj.GridXY=[x(:),y(:)];
                    assert(ischar(varargin{3}));
                    obj.Units = varargin{3};
                    obj.Dx = obj.GridXY(2,1) - obj.GridXY(1,1);
                    obj.Dy = obj.GridXY(2,2) - obj.GridXY(2,2);
                case 8
                    % name, x_start, dx, x_end, y_start, dy, y_end, units
                    obj.Dx = varargin{2};
                    obj.Dy = varargin{5};
                    obj.Xvector = varargin{1} : obj.Dx : varargin{3};
                    obj.Yvector = varargin{4} : obj.Dy : varargin{6};
                    [x,y]=meshgrid(obj.Xvector, obj.Yvector);
                    obj.GridXY=[x(:),y(:)];
                    assert(ischar(varargin{7}));
                    obj.Units = varargin{7};
                otherwise
                    error('incorrect number of arguments');
            end
            if ~isempty(obj.Xvector)
                % ActivePoints is an X x Y array
                obj.ActivePoints=true(numel(obj.Xvector),numel(obj.Yvector));
            else
                % all points are simply in a line
                obj.ActivePoints=true(length(obj.GridXY),1);
            end
            
        end
        
        % basic access routines
        function x = get.X(obj)
            if ~isempty(obj)
                x=obj.GridXY(:,1);
            else
                x = [];
            end
        end
        
        function y = get.Y(obj)
            if ~isempty(obj)
                y=obj.GridXY(:,2);
            else
                y = [];
            end
        end
        
        % masked access routines
        function x = get.Xactive(obj)
            x=obj.GridXY(obj.ActivePoints,1);
        end
        
        function y = get.Yactive(obj)
            y=obj.GridXY(obj.ActivePoints,2);
        end
        
        function xy = get.ActiveGrid(obj)
            xy=obj.GridXY(obj.ActivePoints,:);
        end
        
        function obj = set.ActivePoints(obj, values)
            assert(isempty(values) || isequal(numel(values), length(obj.GridXY))); %#ok<MCSUP>
            obj.ActivePoints = logical(values);
        end
        
        function val = length(obj)
            val = length(obj.GridXY);
        end
        
        function val = isempty(obj)
            val = isempty(obj.GridXY);
        end
        
        function obj = MaskWithPolygon(obj,polyX, polyY)
            % MaskWithPolygon sets the mask according to a polygon
            % obj = obj.MaskWithPolygon() user selects polygon from gca
            % obj = obj.MaskWithPolygon(ax) user selects polygon from axis ax
            % obj = obj.MaskWithPolygon(polyX, polyY) where polyX and polyY define the polygon
            narginchk(1,3);
            switch nargin
                case 1
                    [polyX, polyY, mouse_points_overlay] = select_polygon(gca);
                    pause(1);
                    delete(mouse_points_overlay);
                case 2
                    %ax=polyX; % this param is actually an axis, not x values
                    [polyX, polyY, mouse_points_overlay] = select_polygon(gca);
                    pause(1);
                    delete(mouse_points_overlay);
                otherwise
                    if polyX(1) ~= polyX(end) || polyY(1) ~= polyY(end)
                        warning('polygon is not closed. adding a point to close it.')
                        polyX(end+1)=polyX(1);
                        polyY(end+1)=polyY(1);
                    end
            end
            obj.ActivePoints = polygon_filter(polyX,polyY, obj.X, obj.Y, 'inside');
        end
        
        function plot(obj, ax,varargin)
            % plot the current grid over axes(ax)
            % obj.plot() plots on the current axes
            %  obj.plot(ax) plots on the specified axes. if ax is empty, then the current axes will
            %     be used
            %
            %  obj.plot(ax,'name',value,...) sets the grid's properties after plotting/updating
            %
            %  obj.plot(..., 'ActiveOnly') will only plot the active points. This is useful when
            %   displaying the vertices within a polygon, for example.
            %
            %  if this figure already has a grid with this name, then it will be modified.
            
            if ~exist('ax','var') || isempty(ax)
                ax=gca;
            end
            def_opts={'color',[.7 .7 .7],'displayname','grid points','markersize',3,'marker','.'};
            varargin=[def_opts,varargin];
            useActiveOnly= numel(varargin)>0 && strcmpi(varargin{end},'ActiveOnly');
            if useActiveOnly && ~isempty(obj.ActivePoints)
                varargin{end}=[];
                x='Xactive';
                y='Yactive';
            else
                x='X';
                y='Y';
            end
            if ~all(ishandle(ax))
                error('invalid axes provided. If not specifying axes, but are providing additional options, lead with "[]". ex. obj.plot([],''color'',[ 1 1 0])');
            end
            prev_grid = findobj(ax,'Tag',['grid_' obj.Name]);
            if ~isempty(prev_grid)
                prev_grid.XData=obj.(x);
                prev_grid.YData=obj.(y);
                disp('reusing grid on plot');
            else
                hold(ax,'on');
                prev_grid=plot(ax,obj.(x),obj.(y),'+k','Tag',['grid_' obj.Name]);
                hold(ax,'off');
                disp('created new grid on plot');
            end
            if numel(varargin)>1
                set(prev_grid,varargin{:});
            end
        end
        
        function h=pcolor(obj, ax, values, name)
            % pcolor create a pcolor plot where each point of the grid
            % h = obj.pcolor(ax, values) plos the values as a pcolor plot, where
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
            assert(numel(values)== length(obj.Xvector) * length(obj.Yvector),'expect same number of values');
            if ~isequal(size(values),[length(obj.Xvector),length(obj.Yvector)])
                values = reshape(values,length(obj.Yvector),length(obj.Xvector));
            end
             h=gridpcolor(ax,obj.Xvector, obj.Yvector, values, obj.ActivePoints,name);
        end
        
        function setGlobal(obj)
            % set the globally used grid to this one.
            ZG=ZmapGlobal.Data;
            ZG.grid=obj;
        end
        
        function save(obj, filename, pathname)
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
        
        function [results, nEvents, maxDist] = process(obj, routine, catalog, selcrit)
            % apply a process to every grid point, return the results
            % [results, nEvents, maxDist] = process(obj, routine, catalog, selcrit, varargin)
            % where:
            %    ROUTINE is a function handle that takes a ZmapCatalog and returns a single value
            %    CATALOG is a ZmapCatalog to process
            %    SELCRIT is a structure as returned by EventSelectionChoice.toStruct
            % 
            % Output:
            %    results: an array of values, the same size as this grid
            %
            % this is a convenience wrapper for gridfun. see that function for more details
            %
            % see also gridfun, EventSelectionChoice
            
            [ results, nEvents, maxDist ] = gridfun( routine, catalog, obj, selcrit);
        end
        
        function catPerNode = associateWithEvents(obj, catalog, maxradius, maxnearest, firstlastdate, minmaxmag)
            % returns one catalog per grid-node containing the associated events
            %
            % cats = obj.associateWithEvents(catalog, maxradius, maxnearest, firstlastdate, minmaxmag)
            %
            %    CATALOG: a ZmapCatalog containing events that will be divided up between grid points
            %             note: depending on criteria, events might be associated with multiple grid
            %                   points
            %
            %    MAXRADIUS: All events within maxradius kilometers will be associated with the grid point
            %       example - get events within 5km of each grid point
            %       cats = mygrid.associateWithEvents(mycat, 5, [],[],[],[]);
            %
            %    MAXNEAREST: associate this many closest events with the grid point.
            %       example - get the nearest 50 events to each grid point
            %       cats = mygrid.associateWithEvents(mycat, [], 50,[],[],[]);
            %
            %    If both are used, then both are applied.
            %
            %
            %    The following options limit the catalog under consideration, but are independent
            %    of the grid points.
            %
            %    FIRSTLASTDATE: datetime values that are used to limit the catalog. This can be
            %       either a single value FIRST, or a 1x2 vector of values [FIRST LAST].
            %
            %    MINMAXMAG: magnitude values used to limit the catalog.  They can be either a single
            %      value MINMAG, or a 1x2 vector of values [MINMAG MAXMAG]
            %
            % so that:
            %
            %    catPerGridPt = mygrid.associateWithEvents(catalog, maxradius, maxcount, firstlastdate, minmaxmag)
            %    for gridPt=1:length(mygrid)
            %       process(mygrid, catPerGridPt(gridPt));
            %       ... processs grid point
            %    end
            %
            
            % first, do general cuts to catalog that reduce its size overall.
            catPerNode=true(catalog.Count, length(obj));
            if numel(firstlastdate)==1
                catalog = catalog.subset(catalog.Date >= firstlastdate);
            elseif numel(firstlastdate==2)
                catalog = catalog.subset(catalog.Date >= firstlastdate(1) && catalog.Date <= catalog.firstlastdate(2));
            end
            
            if numel(minmaxmag)==1
                catalog = catalog.subset(catalog.Magnitude >= minmaxmag);
            elseif numel(minmaxmag==2)
                catalog = catalog.subset(catalog.Magnitude >= minmaxmag(1) && catalog.Magnitude <= catalog.minmaxmag(2));
            end
            
            assert(~isempty(maxnearest) || ~isempty(maxradius));
            % now, either get the nearest by distance, or nearest by max #
            if ~isempty(maxnearest)
                for i=1:length(obj)
                    catPerNode(i)=catalog.selectClosestEvents(obj.GridXY(i,1) , obj.GridXY(i,2), maxnearest);
                end
            end
            if ~isempty(maxradius)
                for i=1:length(obj)
                    % TOFIX beware! grid points must be in degrees, radius in kilometers
                    catPerNode(i)=catalog.selectRadius(obj.GridXY(i,1) , obj.GridXY(i,2), maxradius);
                end
            end
        end
     
            
    end
    
    methods(Static)
        function obj=AutoCreateDeg(name, ax, catalog)
            % creates a ZDataGrid based on current Map extent/Catalog extent, whichever is smaller.
            % obj = ZmapGrid.AutoCreate() greates a catalog based on mainmap and primary catalog
            % obj = ZmapGrid.Autocreate(ax, catalog) specifies a map axis handle and a catalog to use.
            
            % obj=ZmapGrid(name, x_start, dx, x_end, y_start, dy, y_end, units)
            XBINS=20;
            YBINS=20;
            %ZBINS=5;
            ZG=ZmapGlobal.Data;
            switch nargin
                case 0
                    name='unnamed';
                    ax=findobj(0,'Tag','mainmap_ax');
                    catalog=ZG.primeCatalog;
                case 1
                    ax=findobj(0,'Tag','mainmap_ax');
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
            %TOFIX map units and this unit might be out of whack.
            obj=ZmapGrid(name,x_start, dx, x_end, y_start, dy, y_end, 'deg');
        end
        
        function obj=load(filename, pathname)
            % mygrid = ZmapGrid.load() prompts user for a zmap grid file
            %
            % mygrid = ZmapGrid.load('grid1') -> attempts to load 'grid1' or 'zmapgrid_grid1.m' from
            % the data directory, and then anywhere the matlab path.
            %
            % mygrid = ZmapGrid.load('grid1', 'mydir') - attempts to load 'grid1' or
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