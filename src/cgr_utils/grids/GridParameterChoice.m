classdef GridParameterChoice < handle
    % GridParameterChoice adds control to figure that describes how to choose a grid.
    %
    % Example usage:
    %   obj =  GridParameterChoice(fig, lowerCornerPosition, {dx,'degrees'},{dy,'degrees'},{dz,'kilometer'})   %dz currently unused
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
    % see also EventSelectionChoice
    properties(Constant)
        GROUPWIDTH=315;
        GROUPHEIGHT=137;
    end
    
    properties
        dx=[] % horzontal (longitudinal) grid spacing, degrees
        dy=[] % vertical (latitudinal) grid spacing, degrees
        dz=[] % depth spacing (not functional)
        dy_units=''
        dx_units=''
        dz_units=''
        GridEntireArea
        SaveGrid=false; % TODO: move to dependent and add ui widget
        UseExisting=true;
    end
    properties(Dependent)
        LoadGrid
        CreateGrid
        UseGlobalGrid
    end
    properties(Access=private)
        hLoadGrid %handle to the load_grid button
        hCreateGrid % handle to the create_grid button
        ubg2 % ui button group containing radio buttons
        hDeltaX
        hDeltaY
        hDeltaZ
        hUseGlobalGrid
        RequestZ=false;
        equalXY=false;
    end
    
    methods
        function out=get.LoadGrid(obj)
            if ~isstruct(obj.ubg2)
                out=false; % using ZG
            else
                out = obj.ubg2.SelectedObject==obj.hLoadGrid;
            end
        end
        function out=get.UseGlobalGrid(obj)
            if ~isstruct(obj.ubg2)
                out=true; % using ZG
            else
                out = obj.ubg2.SelectedObject==obj.hUseGlobalGrid;
            end
        end

        function out=get.CreateGrid(obj)
            if ~isstruct(obj.ubg2)
                out=false; % using ZG
            else
                out = obj.ubg2.SelectedObject==obj.hCreateGrid;
            end
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
                'UseGlobalGrid',obj.UseGlobalGrid,...
                'CreateGrid',obj.CreateGrid);
        end
        
        
        function obj=GridParameterChoice(fig,tag,lowerCornerPosition, A, B, C)
            % choose_grid adds controls to describe how to choose a grid.
            % GridParameterChoice(fig, lowerCornerPosition, {dx,'degrees'},{dy,'degrees'},{dz,'kilometer'})
            %  Parameters A, B, and C are cells containing default vaules and units
            %    corresponding to E-W, N-S, and vertical.
            % Grid options
            
            % Create, Load, or use Previous grid choice
                ZG=ZmapGlobal.Data;
            if nargin==0
                obj=from_global(obj);
                return
            end
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
                ...'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'string','Create grid','Units','pixels','Position',[ 17  90 280  24]);
            
            obj.hUseGlobalGrid =  uicontrol(obj.ubg2,'Style','radiobutton',...
                ...'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'string','Use Existing grid','Units','pixels','Position',[105  90 280  24],...
                'Enable',tf2onoff(isa(ZG.Grid,'ZmapGrid')));
            obj.hLoadGrid =  uicontrol(obj.ubg2,'Style','radiobutton',...
                ...'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'string','Load grid','Units','pixels','Position',[220  90 280  24]);
            
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
                'String',num2str(obj.dx,'%.3f'),...
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
                    'String',num2str(obj.dy,'%.3f'),...
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
                    'String',num2str(obj.dz,'%.3f'),...
                    'callback',@callbackfun_dz,...
                    'ToolTipString', sprintf('Depth grid spacing (z) [%s]',obj.dz_units));
            end
            
            % prev_grid =  uicontrol('Style','radiobutton','string','Reuse the previous grid','Position',[.65 .55 .2 .080]);
            
            % save_grid =  uicontrol('Style','checkbox','string','Save selected grid to file','Position',[.65 .35 .2 .080]);
            
            hGridarea=uicontrol(obj.ubg2,'Style','checkbox','Units','pixels','Position',[ 17  13 150  18],...
                'HorizontalAlignment','left','String','Select area',...
                'Callback',@callback_gridarea,...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'Value',~obj.GridEntireArea,...
                'ToolTipString','Either Select Polygon or grid entire area');
            
            % if a grid exists, use it
            if ~isempty(ZG.Grid)
                obj.ubg2.SelectedObject=obj.hUseGlobalGrid;
            else
                obj.ubg2.SelectedObject=obj.hCreateGrid;
            end
            obj.ubg2.SelectionChangedFcn=@callback_gridcontrol;
            
            uicontrol(obj.ubg2,'Style','pushbutton',...
            'Units','pixels','Position',[ 180  10 120  20],...
            'String','Reset (to global)',...
            'callback',@cb_set_to_global);
            
            
            function cb_set_to_global(mysrc,~)
                obj=from_global(obj);
                obj.hDeltaX.String=num2str(ZG.gridopt.dx);
                obj.hDeltaX.Callback(obj.hDeltaX,[]);
                if ~obj.equalXY
                    obj.hDeltaY.String=num2str(ZG.gridopt.dy);
                    %cb=obj.hDeltaY.Callback;
                    obj.hDeltaY.Callback(obj.hDeltaY,[]);
                end
                
                if obj.RequestZ
                    obj.hDeltaZ.String=num2str(ZG.gridopt.dz);
                    obj.hDeltaZ.Callback(obj.hDeltaZ,[]);
                end
                hGridarea.Value=~ZG.gridopt.GridEntireArea;
                hGridarea.Callback(hGridarea,[]);
            end
            
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
            
            function obj=from_global(obj)
                %ZG=ZmapGlobal.Data;
                % fill parameters from ZG
                obj.dx=ZG.gridopt.dx;
                obj.dy=ZG.gridopt.dy;
                obj.dz=ZG.gridopt.dz;
                obj.dx_units=ZG.gridopt.dx_units;
                obj.dy_units=ZG.gridopt.dy_units;
                obj.dz_units=ZG.gridopt.dz_units;
                obj.GridEntireArea=ZG.gridopt.GridEntireArea;
                obj.SaveGrid=ZG.gridopt.SaveGrid;
            end
        end
    end
    
    methods(Static)
        function [gpc_out, okPressed] = quickshow()
            %quickly test  the ZmapDialog
            f=figure('Name','GridParameterChoice example',...
                'Menubar','none',...
                'InnerPosition',position_in_current_monitor(GridParameterChoice.GROUPWIDTH+5, GridParameterChoice.GROUPHEIGHT+50),...
                'Numbertitle','off'...
                );
            t='gpc'; 
            lcp=[5 50]; 
            A={2.3,standardizeDistanceUnits('degrees')}; 
            B={-1.5,standardizeDistanceUnits('degrees')}; 
            Z={.1,standardizeDistanceUnits('kilometer')};
            gpc=GridParameterChoice(f,t,lcp,A,B,Z);
            
            inwidth=f.Position(3);
            uicontrol('style','pushbutton','string','OK','callback',@ok_cb,'Position',[inwidth-140 10 60 25]);
            
            uicontrol('style','pushbutton','string','Cancel','callback',@cancel_cb,'Position',[inwidth-70 10 60 25]);
            uiwait(f);
            
            %uicontrol('style','pushbutton','string','show','callback',@(~,~)disp(gpc.toStruct()));
            
            function ok_cb(src,~)
                gpc_out=gpc;
                %disp(gpc.toStruct);
                okPressed=true;
                delete(f)
            end
            
            function cancel_cb(src,~)
                okPressed=false;
                delete(f);
            end
            
        end
        
        function h=helper(parent, position, defaultsXYZ, units)
            x=position(1);
            y=position(2);
            
            unitnames.kilometer={'dx','dy'};
            unitnames.degrees={'dLon','dLat'};
            unitlookup=fieldnames(unitnames);
            
            switch numel(defaultsXYZ)
                case 0
                    % donno.
                case 1
                    hInitial=defaultsXYZ;
                    vInitial=defaultsXYZ;
                    zInitial=[];
                case 2
                    hInitial=defaultsXYZ(1);
                    vInitial=defaultsXYZ(2);
                    zInitial=[];
                case 3
                    hInitial=defaultsXYZ(1);
                    vInitial=defaultsXYZ(2);
                    zInitial=defaultsXYZ(3);
            end
                    
            % conversion routines
            hUnits=@(u)unitnames.(u){1}; %  kilometer or degrees -> dx or dlon
            vUnits=@(u)unitnames.(u){2}; %  kilometer or degrees -> dy or dlat
            fn=@(u)unitlookup{u}; % # -> kilometer or degrees 
            uname = @(u) find(strcmpi(unitlookup,u)); % kilometer or degrees  -> #
            
            
            LabelWidth=30;
            EditWidth=45;
            PopupXYWidth=70;
            PopupZWidth=90;
            Hspacing=3;
            
            txX=uicontrol(parent,'Style','text',...
                'String',vUnits(units),...
                'Units','pixels','Position',[x,y,LabelWidth,60]);
            
            ex=txX.Extent;
            exV=ex(4);
            txX.Position(4)=exV;
            
            uicontrol(parent,'Style','edit',...
                'String',num2str(hInitial),...
                'Position',[x+LabelWidth+Hspacing, y, EditWidth,exV]);
            
            txY=uicontrol(parent,'Style','text',...
                'String',hUnits(units),...
                'Units','pixels','Position',[x,exV+y+5,LabelWidth,exV]);
            
            uicontrol(parent,'Style','edit',...
                'String',num2str(vInitial),...
                'Position',[x+LabelWidth+Hspacing, y+exV+5, EditWidth,exV]);
            
            uicontrol(parent,'Style','popupmenu',...
                'String',unitlookup,'Value',uname(units),...
                'Units','pixels','Position',[x+LabelWidth+EditWidth+2*Hspacing,y+(exV/2),PopupXYWidth,exV],...
                'Callback',@unitchange);
            
            
            
            % dz
            posY=y+(exV/2);
            usingZ=~isempty(zInitial);
            x = x + LabelWidth + EditWidth + 3*Hspacing + PopupXYWidth;
            
            txZ=uicontrol(parent,'Style','text','String','dz',...
                'Units','pixels','Position',[x,posY,LabelWidth,exV],...
                'Enable',tf2onoff(usingZ));
            
            edZ=uicontrol(parent,'Style','edit','String',num2str(zInitial),...
                'Position',[x+LabelWidth+Hspacing, posY, EditWidth,exV]);
            
            uicontrol(parent,'Style','popupmenu',...
                'String',{'unused','kilometer'},'Value',usingZ+1,...
                'Units','pixels','Position',[x+LabelWidth+EditWidth+2*Hspacing,posY,PopupZWidth,exV],...
                'Callback',@zunit);
            
            
            function unitchange(src,~)
                newUnits=src.String{src.Value};
                txX.String=hUnits(newUnits);
                txY.String=vUnits(newUnits);
            end
            
            function zunit(src,~)
                shouldBeEnabled = tf2onoff(src.Value-1);
                txZ.Enable=shouldBeEnabled;
                edZ.Enable=shouldBeEnabled;
            end
            
        end
        
        
    end
end

