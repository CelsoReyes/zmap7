classdef ZmapGrid3 < ZmapGrid
    % ZMAPGRID3 evenly-spaced X,Y,Z grid with ability to be masked
    %
    % GridPoints - [X1, Y1, Z1] ; ... ; Xn, Ym, Zp] matrix of positions
    %
    % ZMAPGRID3 create a 3-d grid
    % obj = ZMAPGRID3(name, gridOptions,[minz maxz])
    % obj = ZMAPGRID3(name, xyz, xyUnits, zUnits)
    % obj = ZMAPGRID3(name, x, y, z, xyunits, zunits)
            
    properties
        Zvector
        Zunits
        
    end
    properties(Dependent)
        Z
        Zactive
    end
    
    methods
        function obj = ZmapGrid3(name, varargin)
            % ZMAPGRID3 create a 3-d grid
            % obj = ZMAPGRID3(name, gridOptions,[minz maxz])
            % obj = ZMAPGRID3(name, xyz, xyUnits, zUnits)
            % obj = ZMAPGRID3(name, x, y, z, xyunits, zunits)
            
            % pass only the appropriate arguments to super constructor
            switch nargin
                case 3
                    % ZMAPGRID3(name, gridOptions,[minz maxz])
                    zg2_opts=varargin(1);
                case 4
                    % ZMAPGRID3(name, xyz, xyUnits, zUnits)
                    zg2_opts=[{varargin{1}(:,1:2)}, varargin(2)];
                case 6
                    % ZMAPGRID3(name, x, y, z, xyunits, zunits)
                    zg2_opts=varargin([1 2 4]);
                otherwise
                    error('unknown options')
            end
            obj=obj@ZmapGrid(name, zg2_opts{:});
            
            switch nargin
                case 3
                    % ZMAPGRID3(name, gridOptions,[minz maxz])
                    % varargin pos:   1            2 
                    gOpt=varargin{1};
                    minz=varargin{1}(1);
                    maxz=varargin{1}(2);
                    obj.Zvector=minz:gOpt.dz:maxz;
                    obj.Zunits=gOpt.dz_units;
                    nOrigPts=size(obj.GridPoints,1);
                    % repeat xy grid points for every z
                    obj.GridPoints=repmat(obj.GridPoints,numel(obj.Zvector),1);
                    z=repmat(obj.Zvector(:),1,nOrigPts); % [z1 z1...;z2 z2...]
                    z=z'; % [z1 z2...; z1 z2...]
                    obj.GridPoints(:,3)=z(:);
                    obj.ActivePoints=true(size(obj.X),numel(obj.Zvector));
                    
                case 4
                    % ZMAPGRID3(name, xyz, xyUnits, zUnits)
                    % varargin pos:   1      2       3 
                    obj.Zvector=[];
                    obj.GridPoints=varargin{1};
                    obj.Units=varargin{2};
                    obj.ActivePoints=true(length(obj.GridPoints));
                    
                case 6
                    % ZMAPGRID3(name, x, y, z, xyunits, zunits)
                    % varargin pos:   1  2  3      4       5
                    obj.Zunits=varargin{5};
                    obj.Zvector=varargin{3};
                    x=varargin{1};
                    y=varargin{2};
                    z=varargin{3};
                    
                    totpoints=numel(x)*numel(y)*numel(z);
                    if totpoints > ZmapGrid.POSSIBLY_TOO_MANY_POINTS
                        ZmapMessageCenter.set_warning(sprintf('Possibly too many points: %d',totpoints'));
                    end
                    
                    [x,y,z]=meshgrid(x,y,z);
                    obj.GridPoints=[x(:),y(:),z(:)];
                    obj.ActivePoints=true(size(obj.X),numel(obj.Zvector));
            end
        end
        
        function prev_grid=plot(obj, ax,varargin)
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
            def_opts={'color',[.7 .7 .7],'displayname','grid points','MarkerSize',5,'Marker','.'};
            varargin=[def_opts,varargin];
            useActiveOnly= numel(varargin)>0 && strcmpi(varargin{end},'ActiveOnly');
            if useActiveOnly && ~isempty(obj.ActivePoints)
                varargin(end)=[];
                x='Xactive';
                y='Yactive';
                z='Zactive';
            else
                x='X';
                y='Y';
                z='Z';
            end
            if ~all(ishandle(ax))
                error('invalid axes provided. If not specifying axes, but are providing additional options, lead with "[]". ex. obj.plot([],''color'',[ 1 1 0])');
            end
            prev_grid = findobj(ax,'Tag',['grid_' obj.Name]);
            if ~isempty(prev_grid)
                prev_grid.XData=obj.(x);
                prev_grid.YData=obj.(y);
                prev_grid.ZData=obj.(z);
                disp('reusing grid on plot');
            else
                ax.NextPlot='add';
                prev_grid=plot3(ax,obj.(x),obj.(y),obj.(z),'+k','Tag',['grid_' obj.Name]);
                ax.NextPlot='replace';
                disp('created new grid3 on plot');
            end
            if ~isempty(varargin)
                set(prev_grid,varargin{:});
            end
        end
        
        function val=mesh_size(obj)
            val=[size(obj.X), numel(obj.Zvector)];
        end
        
        function z=get.Zactive(obj)
            z=obj.GridPoints(obj.ActivePoints,3);
        end
        
        function z=get.Z(obj)
            if ~isempty(obj)
                z=obj.GridPoints(:,3);
            else
                z = [];
            end
        end
        
        function xyz=ActiveGrid(obj)
            xyz=obj.GridPoints(obj.ActivePoints,:);
        end
        
        function obj = MaskWithShape(obj,myshape,minDepth,maxDepth)
            % MaskWithShape sets the mask according to a polygon
            obj=MaskWithShape@ZmapGrid(obj,myshape);
            obj.ActivePoints(obj.Z>maxDepth)=false;
            obj.ActivePoints(obj.Z<minDepth)=false;
        end

        
    end
end