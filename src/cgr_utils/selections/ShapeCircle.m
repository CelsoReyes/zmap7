classdef ShapeCircle < ShapeGeneral
    %ShapeCircle represents a circular geographical selection of events
    %
    % see also ShapeGeneral, ShapePolygon
    
    properties
        Radius=5; % active radius km (if circle)
    end
    
    
    methods
        function obj=ShapeCircle(varargin)
            % SHAPECIRCLE create a circular shape
            %
            % ShapeCircle() :
            % ShapeCircle('dlg') create via a dialg box
            % ?
            % CIRCLE: select using circle with a defined radius. define with 2 clicks or mouseover and press "R"
            
            % UNASSIGNED: clear shape
            %
            % results are stored in ZG.selection_shape
            
            report_this_filefun(mfilename('fullpath'));
            
            axes(mainmap('axes')); % should be the map, with lon/lat
            obj.Type='circle';
            ZG=ZmapGlobal.Data;
            try
                ra=ZG.selection_shape.Radius;
            catch
                ra=nan;
            end
            if nargin==0
                ZG.selection_shape=obj;
            elseif strcmpi(varargin{1},'dlg')
                sdlg.prompt='Radius (km):'; sdlg.value=ra;
                sdlg(2).prompt='Center X (Lon):'; sdlg(2).value=ZG.selection_shape.X0;
                sdlg(3).prompt='Center Y (Lat):'; sdlg(3).value=ZG.selection_shape.Y0;
                [~,cancelled,obj.Radius,obj.Points(1),obj.Points(2)]=smart_inputdlg('Define Circle',sdlg);
                if cancelled
                    beep
                    return
                end
                ZG.selection_shape=obj;
            else
                obj=ShapeCircle.selectUsingMouse();
                ZG.selection_shape=obj;
            end
            
            ZmapMessageCenter.update_catalog();
            obj.plot(gca);
            obj.setVisibility('on');
            
            
        end
        
        function val=Outline(obj,col)
            [lat,lon]=reckon(obj.Y0,obj.X0,km2deg(obj.Radius),(0:.1:360)');
            val=[lon, lat];
            if exist('col','var')
                val=val(:,col);
            end
        end
        
        
        function s=toStruct(obj)
            s=toStruct@ShapeGeneral(obj);
            s.radius_km = obj.Radius;
        end
        
        function s = toStr(obj)
            cardinalDirs=['SNWE'];
            isN=obj.Y0>=0; NS=cardinalDirs(isN+1);
            
            isE=obj.X0>=0; EW=cardinalDirs(isE+3);
            s = sprintf('Circle with R:%s km, centered at ( %s %s, %s %s)',...
                num2str(obj.Radius),...
                num2str(abs(obj.Y0)), NS,...
                num2str(abs(obj.X0)), EW);
        end
        
        function summary(obj)
            helpdlg(obj.toStr,'Circle');
        end
        
        function interactive_edit(obj,src,ev)
            % INTERACTIVE_EDIT callback
            % obj.INTERACTIVE_EDIT(src,ev)
            shout=findobj(gcf,'Tag','shapeoutline');
            if numel(shout)>1
                disp(shout);
            end
            if obj.AUTO_UPDATE_TIMEPLOT
                make_editable(shout,@()update_shape,@()update_shape,'nopoint',obj.ScaleWithLatitude);
            else
                make_editable(shout,@()update_shape,[],'nopoint',obj.ScaleWithLatitude);
            end
            
            function update_shape()
                obj.Points=[shout.XData(:),shout.YData(:)];
                ZG=ZmapGlobal.Data;
                ZG.selection_shape=obj;
                
                if obj.AUTO_UPDATE_TIMEPLOT
                    ShapeGeneral.cb_selectp(src,ev,'inside');
                end
                    
                
            end
        end
        function add_shape_specific_context(obj,c,ax)
            uimenu(c,'label','Choose Radius','Callback',@chooseRadius)
            uimenu(c,'label','Snap To N Events','Callback',@snapToEvents)
            
            function snapToEvents(~,~)
                ZG=ZmapGlobal.Data;
                nc=inputdlg('Number of events to enclose','Edit Circle',1,{num2str(ZG.ni)});
                nc=round(str2double(nc{1}));
                if ~isempty(nc) && ~isnan(nc)
                    ZG.ni=nc;
                    [~,obj.Radius]=ZG.primeCatalog.selectClosestEvents(obj.Y0, obj.X0, [],nc);
                    obj.Radius=obj.Radius;%+0.005;
                    obj.plot(ax); % replot
                    ZG.selection_shape=obj;
                end
            end
            function chooseRadius(~,~)
                ZG=ZmapGlobal.Data;
                nc=inputdlg('Choose Radius (km)','Edit Circle',1,{num2str(obj.Radius)});
                nc=str2double(nc{1});
                if ~isempty(nc) && ~isnan(nc)
                    obj.Radius=nc;
                    obj.plot(ax); % replot
                    ZG.selection_shape=obj;
                end
                
            end
            
        end
        
        function [mask]=isInside(obj,otherLon, otherLat)
            % ISINSIDE true if value is within this circle's radius of center. Radius inclusive.
            %
            % overridden because using polygon approximation is too inaccurate for circles
            %
            % [mask]=obj.ISINSIDE(otherLon, otherLat)
            if isempty(obj.Points)||isnan(obj.Points(1))
                mask = ones(size(otherLon));
            else
                % return a vector of size otherLon that is true where item is inside polygon
                dists=distance(obj.Y0, obj.X0, otherLat, otherLon);
                mask=deg2km(dists) <= obj.Radius;
            end
        end
        
    end
    
    methods(Static)
        
        function obj=selectUsingMouse()
            ABORTKEY=27; % escape;
            ax=gca;
            obj=ShapeCircle;
            
            [x1, y1, x2, y2]=deal(nan);
            sel_start=tic;
            sel_elapse=toc(sel_start);
            
            % select center point, if it isn't provided
            disp('click in center of circle, drag to radius. ESC aborts');
            f=gcf;
            TMP.fWBMF=f.WindowButtonMotionFcn;
            f.WindowButtonMotionFcn=@moveMouse;
            TMP.fWBUF = f.WindowButtonUpFcn;
            f.WindowButtonUpFcn=@endCircle;
            TMP.aBDF = ax.ButtonDownFcn;
            ax.ButtonDownFcn=@startCircle;
            
            x2=nan;
            y2=nan;
            selected=false;
            
            
            % set center using ginput, which reads the button down
            [x1,y1,b] = ginput(1);
            sel_start=tic
            
            
            
            if b==ABORTKEY
                % restore previous window functions
                f.WindowButtonMotionFcn=TMP.fWBMF;
                f.WindowButtonUpFcn=TMP.fWBUF;  
                ax.ButtonDownFcn=TMP.aBDF;
                error('Aborting circle creation'); %to calling routine: catch me!
            end
            
            hold on;
            %% mouse should still be pressed.
            
            % draw line from origin to edge of circle
            h=plot([x1;x1],[y1;y1],'k+:','markersize',10,'linewidth',2);
            % h(3)=plot([x1,x2],[y1,y2],'-o','markersize',10,'linewidth',2,'color',[.4 .4 .4]);
            
            % write the text
            h(2)=text((x1+x2)/2,(y1+y2)/2,['Radius:' num2str(obj.Radius,4) ' km'],'fontsize',12,'Fontweight','bold');
            h(3)=plot(nan,nan,'k.','DisplayName','Rough Outline');
            hold off;
            
            obj.Points=[x1,y1];
            
            % loop waits for mouse button to come back up before continuing
            while ~selected
                pause(.05)
            end
            % by now we have the new points and the radius.
            f.WindowButtonMotionFcn=TMP.fWBMF;
            f.WindowButtonUpFcn=TMP.fWBUF;  
            ax.ButtonDownFcn=TMP.aBDF;
            pause(1)
            delete(h);
            
            function moveMouse(~,~)
                cp=get(gca,'CurrentPoint');
                x2=cp(1,1); 
                y2=cp(1,2);
                h(1).XData(2)=x2;
                h(1).YData(2)=y2;
                obj.Radius=deg2km(distance(y1,x1,y2,x2)); % assuming degrees.
                h(2).Position(1:2)= [(x1+x2)/2,(y1+y2)/2];
                h(2).String=['Radius:' num2str(obj.Radius,4) ' km']
                %update the outline
                [lat,lon]=reckon(obj.Y0,obj.X0,km2deg(obj.Radius),(0:3:359)');
                h(3).XData=lon;
                h(3).YData=lat;
            end
            function startCircle(~,ev)
                disp('start circle!');
                sel_start=tic
            end
            function endCircle(~,ev)
                cp=get(gca,'CurrentPoint');
                sel_elapse=toc(sel_start);
                disp(sel_elapse)
                if sel_elapse >=1 % prevent accidental click.
                    selected=true;
                end
                disp(ev)
            end
            
        end
        function obj=select(varargin)
            % ShapeCircle.select()
            % ShapeCircle.select()
            % ShapeCircle.select(radius)
            % ShapeCircle.select('circle', [x,y], radius)
            
            obj=ShapeCircle;
            if nargin==0
                obj = ShapeCircle.selectUsingMouse();
                return
            end
            % select center point, if it isn't provided
            if numel(varargin)==2
                x1=varargin{2}(1); y1=varargin{2}(2); b=32;
            else
                disp('click in center of circle. ESC aborts');
                [x1,y1,b] = ginput(1);
            end
            if numel(varargin)==2
                varargin=varargin(2);
            end
            
            if b==27 %escape
                error('ESCAPE pressed. aborting circle creation'); %to calling routine: catch me!
            end
            
            obj.Radius=varargin{1};
            obj.Points=[x1,y1];
        end
        
        function submenu=AddCircleMenu(submenu,ZGshape)
            % add menu items specific to circles.
            % ZGshape=ZG.selection_shape; %convenience name
            % this works with the ZG polygon
            
            % get rid of the menu if it already exists,but keep position
            
            menuItems={'circleCreateDlg',...
                'circleCreateMouse'};
            for j=1:numel(menuItems)
                myitem=menuItems{j};
                
                myhandle=findobj(submenu,'Tag',myitem);
                if isempty(myhandle)
                    myhandle=uimenu(submenu,...
                        'Label',myitem,...
                        'Tag',myitem);
                end
                
                switch myitem % based on Tags that should already be assigned to menu items
                    case 'circleCreateDlg'
                        lab='Set Circle: dialog box...';
                        set(myhandle,'Label',lab,'Callback',@(~,~)ShapeCircle('dlg'));
                    case 'circleCreateMouse'
                        lab='Set Circle: mouse click';
                        set(myhandle,'Label',lab,'Callback',@(~,~)ShapeCircle('mouse'));
                    otherwise
                        error('Tried to set a menu item that doesn''t exist');
                end
                if j==1
                    set(myhandle,'Separator','on');
                end
            end
            
        end
    end
    
    methods(Access=protected)
        
        function select_circle_events(obj, catalog)
            selcrit=struct('radius_km',obj.Radius,'useEventsInRadius',true);
            ZG=ZmapGlobal.Data;
            obj.plot()
            ZG.newt2 = catalog.selectCircle(selcrit,obj.X0,obj.Y0,[]);
            ZG.newcat=ZG.newt2;
            timeplot()
        end
    end % protected methods
end
