classdef GridParameterChoice < handle
    % GridParameterChoice adds control to figure that describes how to choose a grid.
    %
    % Example usage:
    %   obj =  GridParameterChoice(fig, lowerCornerPosition, {dx,'deg'},{dy,'deg'},{dz,'km'})   %dz currently unused
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
    properties(Constant)
        GROUPWIDTH=315;
        GROUPHEIGHT=137;
    end
    
    properties
        dx=[] % horzontal (longitudinal) grid spacing, degrees
        dx_units=''
        dy=[] % vertical (latitudinal) grid spacing, degrees
        dy_units=''
        dz=[] % depth spacing (not functional)
        dz_units=''
        GridEntireArea
        SaveGrid=false; % TODO: move to dependent and add ui widget
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
        hDeltaZ
        RequestZ=false;
        equalXY=false;
    end
    
    methods
        function out=get.LoadGrid(obj)
            out = obj.ubg2.SelectedObject==obj.hLoadGrid;
        end
        function out=get.CreateGrid(obj)
            out = obj.ubg2.SelectedObject==obj.hCreateGrid;
        end
        function out = toStruct(obj)
            % returns structure with fields:
            % dx, dy, dz, dx_units, dy_units, dz_units,
            % gridEntireArea, SaveGrid, LoadGrid, CreateGrid
            
            out=struct(...
                'dx',obj.dx,...
                'dy',obj.dy,...
                'dz',obj.dz,...
                'dx_units',obj.dx_units,...
                'dy_units',obj.dy_units,...
                'dz_units',obj.dz_units,...
                'GridEntireArea',obj.GridEntireArea,...
                'SaveGrid',obj.SaveGrid,...
                'LoadGrid',obj.LoadGrid,...
                'CreateGrid',obj.CreateGrid);
        end
        
        
        function obj=GridParameterChoice(fig,tag,lowerCornerPosition, A, B, C)
            % choose_grid adds controls to describe how to choose a grid.
            % GridParameterChoice(fig, lowerCornerPosition, {dx,'deg'},{dy,'deg'},{dz,'km'})
            %  Parameters A, B, and C are cells containing defualt vaules and units
            %    corresponding to E-W, N-S, and vertical.
            % Grid options
            
            % Create, Load, or use Previous grid choice
            obj.dx=A{1}; obj.dx_units=A{2};
            
            if ~isempty(B)
                obj.dy=B{1}; obj.dy_units=B{2};
                obj.equalXY=isempty(obj.dy);
            else
                obj.equalXY=true;
            end
            
            if exist('C','var') && ~isempty(C)
                obj.dz=C{1}; obj.dz_units=C{2};
                obj.RequestZ=~isempty(obj.dz);
            else
                obj.RequestZ=false;
            end
            
            obj.GridEntireArea=true;
            if isempty(lowerCornerPosition)
                X0 = 351;
                Y0 = 83;
            else
                X0 = lowerCornerPosition(1);
                Y0 = lowerCornerPosition(2);
            end
            
            %deltaRowSpacing=[40,20];
            obj.ubg2=uibuttongroup(fig,'Title','Grid options',...
                'units','pixels',...
                'Tag',tag,...
                'Position',[X0 Y0 GridParameterChoice.GROUPWIDTH GridParameterChoice.GROUPHEIGHT]);
            obj.hCreateGrid =  uicontrol(obj.ubg2,'Style','radiobutton',...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'string','Create grid','Units','pixels','Position',[ 17  90 280  24]);
            
            obj.hLoadGrid =  uicontrol(obj.ubg2,'Style','radiobutton',...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'string','Load grid','Units','pixels','Position',[172  90 280  24]);
            
            ypos=40;
            if obj.equalXY
                spacing=sprintf('Grid Spacing : ∆x==∆y: [%s],   ∆z:[%s]',obj.dx_units, obj.dz_units);
                xTip=sprintf('East-West grid spacing [%s]',obj.dx_units);
            else
                if obj.RequestZ
                    spacing=sprintf('Grid Spacing : ∆x:[%s], ∆y:[%s], ∆z:[%s]',obj.dx_units, obj.dy_units, obj.dz_units);
                else
                    spacing=sprintf('Grid Spacing : ∆x:[%s], ∆y:[%s]',obj.dx_units, obj.dy_units);
                end
                    
                xTip=sprintf('grid spacing [%s]',obj.dx_units);
            end
            FLD1_PIX=31;
            FLD2_PIX=62;
            xpos=17;
            uicontrol(obj.ubg2,'Style','text',...
                'Units','pixels','Position',[ xpos  56  300  24],...
                'HorizontalAlignment','left',...
                'String',spacing);
            % DeltaX
            uicontrol(obj.ubg2,'Style','text',...
                'Units','pixels','Position',[xpos  ypos  28  24],...110
                'HorizontalAlignment','right',...
                'String','∆x:');
            xpos=xpos+FLD1_PIX;
            obj.hDeltaX=uicontrol(obj.ubg2,'Style','edit',...
                'Units','pixels','Position',[xpos  ypos  56  24],...141
                'String',num2str(obj.dx,'%.2f'),...
                'callback',@callbackfun_dx, ...
                'ToolTipString',xTip);
            xpos=xpos+FLD2_PIX;
            %DeltaY
            if ~obj.equalXY
                uicontrol(obj.ubg2,'Style','text',...
                    'Units','pixels','Position',[xpos  ypos  28  24],...
                    'HorizontalAlignment','right',...
                    'String','∆y:');
                xpos=xpos+FLD1_PIX;
                obj.hDeltaY=uicontrol(obj.ubg2,'Style','edit',...
                    'Units','pixels','Position',[xpos  ypos  56  24],...
                    'String',num2str(obj.dy,'%.2f'),...
                    'callback',@callbackfun_dy,...
                    'ToolTipString',sprintf('North-South grid spacing [%s]',obj.dy_units));
                xpos=xpos+FLD2_PIX;
            end
            
            %DeltaZ
            if obj.RequestZ
                uicontrol(obj.ubg2,'Style','text',...
                    'Units','pixels','Position',[xpos  ypos  28  24],...
                    'HorizontalAlignment','right',...
                    'String','∆z:');
                xpos=xpos+FLD1_PIX;
                obj.hDeltaZ=uicontrol(obj.ubg2,'Style','edit',...
                    'Units','pixels','Position',[xpos  ypos  56  24],...
                    'String',num2str(obj.dz,'%.2f'),...
                    'callback',@callbackfun_dz,...
                    'ToolTipString', sprintf('Depth grid spacing (z) [%s]',obj.dz_units));
            end
            
            % prev_grid =  uicontrol('Style','radiobutton','string','Reuse the previous grid','Position',[.65 .55 .2 .080]);
            
            % save_grid =  uicontrol('Style','checkbox','string','Save selected grid to file','Position',[.65 .35 .2 .080]);
            
            uicontrol(obj.ubg2,'Style','checkbox','Units','pixels','Position',[ 17  13 187  18],...
                'HorizontalAlignment','left','String','Select area',...
                'Callback',@callback_gridarea,...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'Value',~obj.GridEntireArea,...
                'ToolTipString','Either Select Polygon or grid entire area');
            
            obj.ubg2.SelectedObject=obj.hCreateGrid;
            obj.ubg2.SelectionChangedFcn=@callback_gridcontrol;
            
            
            function callbackfun_dx(mysrc,~)
                obj.dx=str2double(mysrc.String);
            end
            
            function callbackfun_dy(mysrc,~)
                obj.dy=str2double(mysrc.String);
            end
            
            function callbackfun_dz(mysrc,~)
                obj.dz=str2double(mysrc.String);
            end
            
            function callback_gridcontrol(mysrc,~)
                if obj.RequestZ
                    fldlist = [obj.hDeltaX,obj.hDeltaY, obj.hDeltaZ];
                else
                    fldlist = [obj.hDeltaX,obj.hDeltaY];
                end
                if mysrc.SelectedObject == obj.hCreateGrid
                    set(fldlist,'Enable','on');
                else
                    set(fldlist,'Enable','off');
                end
            end
            
            function callback_gridarea(mysrc,~)
                obj.GridEntireArea= ~mysrc.Value;
            end
        end
    end
end