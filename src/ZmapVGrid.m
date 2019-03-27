classdef ZmapVGrid < ZmapGrid
    % ZMAPVGRID meant for cross sections
    %
    % overrides some important drawing functions
    
    properties (Dependent)
        d_km            double % distance in km along strike to grid point
        d_km_active     double
    end
    
    properties
        offset double % distance in km along strike to first grid point
    end
    
    methods
        function v = get.d_km(obj)
            v = deg2km(distance([obj.Y(1) obj.X(1)],[obj.Y obj.X]));
        end
        function v = get.d_km_active(obj)
            v = obj.d_km(obj.ActivePoints);
        end
        
        function obj = ZmapVGrid(distanceFromSectionStart, varargin)
            % ZmapVGrid is used by cross-sections and is defined by a series of points in 3d space
            % keep track of distanceFromSectionStart so that grids can be aligned with
            % the cross-sections. (The first grid point is not at the cross-section's 0 distance.
            
            obj@ZmapGrid(varargin{:});
            obj.offset = distanceFromSectionStart;
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
            def_opts={'color',[.5 .5 .5],'displayname','grid points','MarkerSize',4,'Marker','+'};
            varargin=[def_opts,varargin];
            useActiveOnly= numel(varargin)>0 && strcmpi(varargin{end},'ActiveOnly');
            if useActiveOnly && ~isempty(obj.ActivePoints)
                varargin(end)=[];
                x='d_km_active';
                y='Zactive';
            else
                x='d_km';
                y='Z';
            end
            if ~all(ishandle(ax))
                error(['invalid axes provided. If not specifying axes, but are providing ',...
                    'additional options, lead with "[]". ex. obj.plot([],''color'',[ 1 1 0])']);
            end
            grid_tag = ['grid_' obj.Name];
            prev_grid = findobj(ax,'Tag',grid_tag);
            if ~isempty(prev_grid)
                prev_grid.XData=obj.(x)(:);
                prev_grid.YData=obj.(y)(:);
                % disp('reusing grid on plot');
            else
                ax.NextPlot='add';
                prev_grid=line(ax,obj.(x)(:),obj.(y)(1:end-1),...
                    'Marker','+','Color','k','LineStyle','none','Tag',grid_tag);
                ax.NextPlot='replace';
                %disp('created new grid on plot');
            end
            % make sure that grid is on the bottom layer
            chh=ax.Children;
            ax.Children=[ax.Children(chh~=prev_grid); ax.Children(chh==prev_grid)];
             
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
            
            values=reshape(values(1:end-1) , numel(unique(obj.d_km)),[]);
            d_km_m=reshape(obj.d_km,size(values));
            z=reshape(obj.Z(1:end-1),size(d_km_m));
            h= gridpcolor(ax,d_km_m',z',values',obj.ActivePoints, name);
            set(gca,'YDir','reverse')
        end
        
    end
end