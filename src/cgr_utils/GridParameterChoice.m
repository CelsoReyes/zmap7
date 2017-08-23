classdef GridParameterChoice < handle
    % GridParameterChoice adds control to figure that describes how to choose a grid.
    %
    % Example usage:
    %   obj = GridParameterChoice(parentFigure, dx, dy[, dz]);   %dz currently unused
    %     ... mess with controls...
    %   dx=obj.dx
    %   dy=obj.dy
    %
    %   if obj.LoadGrid
    %       % load the grid
    %   elseif obj.CreateGrid
    %       if obj.GridEntireArea
    %          % get grid from window
    %       else
    %          % get grids from polygon
    %       end
    %       % create the grid
    %   end
    %
    
    properties
        dx % horzontal (longitudinal) grid spacing, degrees
        dy % vertical (latitudinal) grid spacing, degrees
        dz % depth spacing (not functional)
        GridEntireArea
    end
    properties(Dependent)
        LoadGrid
        CreateGrid
    end
    properties(Access=private)
        hLoadGrid %handle to the load_grid button
        hCreateGrid % handle to the create_grid button
        ubg2
        hDeltaX
        hDeltaY
    end
    
    methods
        function out=get.LoadGrid(obj)
            out = obj.ubg2.SelectedObject==obj.hLoadGrid;
        end
        function out=get.CreateGrid(obj)
            out = obj.ubg2.SelectedObject==obj.hCreateGrid;
        end
        %{
        function set.dx(obj,val)
            warning('should not set dx outside figure')
            obj.hDeltaX.String=num2str(val);
        end
        function set.dy(obj,val)
            warning('should not set dy outside figure')
            obj.hDeltaY.String=num2str(val);
        end
        %}
        
        
        function obj=GridParameterChoice(fig,lowerCornerPosition, dx,dy, dz)
            % choose_grid adds controls to describe how to choose a grid.
            
            % Grid options
            
            % Create, Load, or use Previous grid choice
            obj.dx=dx;
            obj.dy=dy;
            obj.dz=[]; %unused
            obj.GridEntireArea=true;
            if isempty(lowerCornerPosition)
                X0 = 351;
                Y0 = 83;
            else
                X0 = lowerCornerPosition(1);
                Y0 = lowerCornerPosition(2);
            end
            
            obj.ubg2=uibuttongroup(fig,'Title','Grid options', 'units','pixels','Position',[X0 Y0 315 137]);
            obj.hCreateGrid =  uicontrol(obj.ubg2,'Style','radiobutton',...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'string','Create grid','Units','pixels','Position',[ 17  90 280  24]);
            
            obj.hLoadGrid =  uicontrol(obj.ubg2,'Style','radiobutton',...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'string','Load grid','Units','pixels','Position',[172  90 280  24]);
            
            
            uicontrol(obj.ubg2,'Style','text',...
                'Units','pixels','Position',[ 17  56  93  24],...
                'HorizontalAlignment','left',...
                'String','Spacing (degrees)');
            
            uicontrol(obj.ubg2,'Style','text',...
                'Units','pixels','Position',[110  56  28  24],...
                'HorizontalAlignment','right',...
                'String','∆x:');
            
            obj.hDeltaX=uicontrol(obj.ubg2,'Style','edit',...
                'Units','pixels','Position',[141  56  56  24],'String',num2str(dx,'%.2f'),...
                'callback',@callbackfun_dx, 'ToolTipString','grid spacing (x)');
            
            uicontrol(obj.ubg2,'Style','text',...
                'Units','pixels','Position',[203  56  28  24],...
                'HorizontalAlignment','right',...
                'String','∆y:');
            
            obj.hDeltaY=uicontrol(obj.ubg2,'Style','edit',...
                'Units','pixels','Position',[234  56  56  24],'String',num2str(dy,'%.2f'),...
                'callback',@callbackfun_dy,'ToolTipString','grid spacing (y)');
            
            % prev_grid =  uicontrol('Style','radiobutton','string','Reuse the previous grid','Position',[.65 .55 .2 .080]);
            % save_grid =  uicontrol('Style','checkbox','string','Save selected grid to file','Position',[.65 .35 .2 .080]);
            
            uicontrol(obj.ubg2,'Style','checkbox','Units','pixels','Position',[ 17  13 187  18],...
                'HorizontalAlignment','left','String','Select area',...
                'Callback',@callback_gridarea,...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'Value',obj.GridEntireArea,...
                'ToolTipString','Either Select Polygon or grid entire area');
            
            obj.ubg2.SelectedObject=obj.hCreateGrid;
            obj.ubg2.SelectionChangedFcn=@callback_gridcontrol;
            
            
            function callbackfun_dx(mysrc,~)
                obj.dx=str2double(mysrc.String);
            end
            
            function callbackfun_dy(mysrc,~)
                obj.dy=str2double(mysrc.String);
            end
            
            function callback_gridcontrol(mysrc,~)
                if mysrc.SelectedObject == obj.hCreateGrid
                    set([obj.hDeltaX,obj.hDeltaY],'Enable','on');
                else
                    set([obj.hDeltaX,obj.hDeltaY],'Enable','off');
                end
            end
            
            function callback_gridarea(mysrc,~)
                obj.GridEntireArea= ~mysrc.Value;
            end
        end
    end
end