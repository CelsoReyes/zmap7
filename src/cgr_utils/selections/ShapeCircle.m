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
                obj=ShapeCircle.select();
                ZG.selection_shape=obj;
            end
            
            ZmapMessageCenter.update_catalog();
            obj.plot(gca);
            obj.setVisibility('on');
            
            
        end
        
        function val=Outline(obj,col)
            [lat,lon]=reckon(obj.Y0,obj.X0,km2deg(obj.Radius),(0:.25:360)');
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
            cardinalDirs=['NSEW'];
            isN=obj.Y0>=0; NS=cardinalDirs(isN+1);
            
            isE=obj.X0>=0; EW=cardinalDirs(isE+3);
            s = sprintf('Circle with R:%s km, centered at ( %s %s, %s %s)',...
                num2str(obj.Radius),...
                num2str(abs(obj.Y0)), NS,...
                num2str(abs(obj.X0)), EW);
        end
        
        function [obj] = interactive_edit(obj,src,ev)
            shout=findobj(src.Parent.Parent,'Tag','shapeoutline');
            
            if obj.AUTO_UPDATE_TIMEPLOT
                make_editable(shout,@()update_shape,@()update_shape,'nopoint');
            else
                make_editable(shout,@()update_shape,[],'nopoint');
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
    end
    
    methods(Static)
        
        function obj=select(varargin)
            % ShapeCircle.select()
            % ShapeCircle.select()
            % ShapeCircle.select(radius)
            % ShapeCircle.select('circle', [x,y], radius)
            % ShapeCircle.select(catalog [,radius])
            
            obj=ShapeCircle;
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
            
            if ~isempty(varargin)
                obj.Radius=varargin{1};
                obj.Points=[x1,y1];
            else
                hold on;
                h=plot(x1,y1,'ko','markersize',10);
                h(2)=plot(x1,y1,'k+','markersize',15);
                hold off;
                disp('click at the desired distance from the center');
                [x2,y2,b]=ginput(1);
                if b==27 %escape
                    delete(h)
                    error('ESCAPE pressed. aborting polygon creation')
                else
                    obj.Points=[x1,y1];
                    obj.Radius=deg2km(distance(y1,x1,y2,x2)); % assuming degrees.
                    hold on
                    h(3)=plot([x1,x2],[y1,y2],'-o','markersize',10,'linewidth',2,'color',[.4 .4 .4]);
                    h(4)=text((x1+x2)/2,(y1+y2)/2,['Radius:' num2str(obj.Radius,4) ' km'],'fontsize',12);
                    hold off;
                    pause(1)
                    delete(h);
                end
            end
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
