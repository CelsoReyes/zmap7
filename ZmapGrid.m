classdef ZmapGrid
    %ZmapGrid grid for use in zmap's various calculation routines
    %   Detailed explanation goes here
    
    properties
        Name
        GridXY  % [X1,Y1 ; ... ; Xn,Yn] matrix of positions
        Units % degrees or kilometers
        ActivePoints    % logical mask
        Xvector % vector for column positions
        Yvector % vector for row positions
        Dx
        Dy
    end
    properties(Dependent)
        X % all X positions
        Y % all Y positions
        Xactive % all X positions that are active points
        Yactive % all Y positions that are active points
        ActiveGrid
    end
    
    methods
        function obj=ZmapGrid(name, varargin)
            % obj=ZmapGrid(name, all_points, units)
            % obj=ZmapGrid(name, all_x, all_y, units)
            % obj=ZmapGrid(name, x_start, dx, x_end, y_start, dy, y_end, units)
            obj.Name = name;
            switch nargin
                case 2
                    % name, all_points
                    assert(size(varargin{1},2)==2);
                    obj.GridXY = varargin{1};
                    obj.Units='unk';
                case 3
                    % name, all_points, units
                    assert(size(varargin{1},2)==2);
                    obj.GridXY = varargin{1};
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
        function x=get.Xactive(obj)
            x=obj.GridXY(obj.ActivePoints,1);
        end
        
        function y=get.Yactive(obj)
            y=obj.GridXY(obj.ActivePoints,2);
        end
        
        function xy=get.ActiveGrid(obj)
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
        
        function obj=MaskWithPolygon(obj,polyX, polyY)
            if polyX(1) ~= polyX(end) || polyY(1) ~= polyY(end)
                warning('polygon isn not closed. adding a point to close it.')
                polyX(end+1)=polyX(1);
                polyY(end+1)=polyY(1);
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
        
    end
end
