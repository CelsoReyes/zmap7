classdef ShapeSelection
    %ShapeSelection represents a geographical selection of events
    %
    %
    % obj=ShapeSelection() no shape. initialization
    %
    % ShapeSelection.AddMenu(fig , ax) creates a selection menu on specified figure that provides
    % methods to:
    %     A. specify the shape.
    %     B. Apply shape to catalog
    %
    %     C. load / save shape
    % If the selection menu already exists, the submenu will be deleted and recreated.
    %
    % replaces selectp and perhaps ex_select and (?)
    %
    %
    %  pg = ShapeSelection(ax,'box')
    %  % user is prompted for two points
    %
    
    properties
        Points=[nan nan] % points within polygon [X1,Y1;...;Xn,Yn]
        Type='unassigned' % shape type
        Radius=5; % active radius km (if circle) -- updated if ni
        CircleBehavior='radius' % one of {'radius', 'nevents', 'both'}
        NEventsToEnclose=100; % radius is defined by the minimum radius that encloses this many events
        
    end
    
    properties(Dependent)
        Center % geographic center of shape
        X0 % center X coordinate
        Y0 % center Y coordinate
        Lat
        Lon
        Area %area of shape. not available if shape is defined by # of events it encloses
    end
    
    methods
        function obj=ShapeSelection(type, varargin)
            % ShapeSelection create a shape
            % type is one of 'circle', 'axes', 'box', 'polygon', 'rectangle'
            % CIRCLE: select using circle with a defined radius. define with 2 clicks or mouseover and press "R"
            % AXES: use current main map axes as a box
            % BOX: define using two corners
            % (UNIMPLEMENTED)RECTANGLE: Define using 3 corners. used for rotated rectangle
            % POLYGON: define with lots of clicks. anything except
            
            % UNASSIGNED: clear shape
            ZG=ZmapGlobal.Data;
            
            report_this_filefun(mfilename('fullpath'));
            if nargin==0
                return
            end
            
            if ~ismember(lower(type),{'circle','axes','box','rectangle','polygon','unassigned'})
                error('unknown polygon type')
            end
            mm=mainmap;
            ax=mm.mainAxes();
            if ~exist('type','var')
                obj.Type='unassigned';
            end
            axes(ax); % bring up axes of interest.  should be the map, with lat/lon
            obj.Type=lower(type);
            switch obj.Type
                case 'circle'
                    d=circle_select_dlg();
                    uiwait(d);
                    obj=ZG.selection_shape;
                    %obj=obj.select_circle(obj,varargin{:})
                case 'axes' % ShapeSelection('axes' [, axeshandle])
                    if ~isempty(varargin)
                        lrbt=axis(varargin{1});
                    else
                        lrbt=axis; %gca
                    end
                    obj.Points=[lrbt(1),lrbt(3); lrbt(2),lrbt(3);...
                        lrbt(2),lrbt(4);lrbt(1),lrbt(4);...
                        lrbt(1),lrbt(3)];
                    obj.Type='polygon'; % axes isn't really a type. it's a convenience method for creation
                case 'box' % ShapeSelection('box' [, [minX maxX minY maxY]])
                    if ~isempty(varargin)
                        lrbt=varargin{1};
                        obj.Points=[lrbt(1),lrbt(3); lrbt(2),lrbt(3);...
                            lrbt(2),lrbt(4);lrbt(1),lrbt(4);...
                            lrbt(1),lrbt(3)];
                    else
                        obj=obj.select_box(obj);
                    end
                    obj.Type='polygon'; % box isn't really a type. it's a convenience method for creation
                case 'polygon' % ShapeSelection('polygon', [x1,y1;...;xn,yn]);
                    if ~isempty(varargin)
                        obj.Points=varargin{1};
                        %TODO check integerity, and make sure last point matches first
                    else
                        obj=select_polygon(obj);
                    end
                case 'rectangle'
                    error('unimplemented');
                case 'unassigned'
                    obj.Points='';
                    obj.Radius=[];
            end
        end
        
        function val=get.Lat(obj)
            val= obj(:,1);
        end
        function val=get.Lon(obj)
            val=obj(:,2);
        end
        function [mask]=InsideEvents(obj,catalog)
            % INSIDEEVENTS return a logical index for a catalog, true for events inside polygon
            switch obj.Type
                case 'circle'
                    % find by distance
                    error('unimplemented');
                otherwise
                    mask = polygon_filter(obj.Points(:,1), obj.Points(:,2), catalog.Longitude, catalog.Latitude, 'inside');
            end
        end
        
        function mask=OutsideEvents(obj,catalog)
            % OUTSIDEENVENTS return a logical index for a catalog, true for events outside polygon
            switch obj.Type
                case 'circle'
                    % find by distance
                    error('unimplemented');
                otherwise
                    mask = polygon_filter(obj.Points(:,1), obj.Points(:,2), catalog.Longitude, catalog.Latitude, 'outside');
            end
        end
        
        function plot(obj,ax, catalog, in_or_out, varargin)
            % plot the selection
            if ~exist('ax','var')||isempty(ax)
                mm=mainmap();
                ax=mm.mainAxes;
            end
            if ~exist('in_or_out','var') || isempty(in_or_out)
                in_or_out='inside';
            end
            if ~exist('catalog','var')
                ZG=ZmapGlobal.Data;
                catalog=ZG.a;
            end
            axes(ax);
            hold on
            switch obj.Type
                case 'polygon'
                    h(1)=plot(obj.Lon,obj.Lat,'k','LineWidth',2.0,'Tag','shapeoutline');
                    switch in_or_out
                        case 'outside'
                            msk=obj.InsideEvents(catalog);
                        otherwise
                            msk=obj.InsideEvents(catalog);
                    end
                    if exist('catalog','var')
                        h(2)=plot(catalog.Longitude(msk), catalog.Latitude(msk),'g+','Tag','selectedevents');
                    end
                case 'circle'
                    switch obj.CircleBehavior
                        case 'radius'
                            [msk, km]=eventsInRadius(catalog, obj.Y0, obj.X0, obj.Radius); %lat,lon,radius
                        case 'nevents'
                            [msk, km]=closestEvents(catalog,obj.Y0, obj.X0, [],obj.NEventsToEnclose);%lat,lon,depth,radius
                        case 'both'
                            [msk, km]=closestEvents(catalog,obj.Y0, obj.X0, [],obj.NEventsToEnclose);%lat,lon,depth,radius
                            if km > obj.Radius
                                [msk2, km]=eventsInRadius(catalog,obj.Y0, obj.X0, obj.Radius); %lat,lon,radius
                                msk=msk & msk2;
                            end
                        otherwise
                            error('undefined circle behavior')
                    end
                    if isempty(km)
                        km=obj.Radius;
                    end
                    [lat,lon]=reckon(obj.Y0,obj.X0,km2deg(km),(0:.25:360)');
                    h(1)=plot(lon,lat,'k','LineWidth',2.0,'Tag','shapeoutline');
                    h(2)=plot(catalog.Longitude(msk), catalog.Latitude(msk),'g+','Tag','selectedevents');

            end
        end
        function clearplot(obj,ax)
            if ~exist('ax','var') || isempty(ax)
                mm=mainmap();
                ax=mm.mainAxes;
            end
            delete(findobj(ax,'Tag','shapeoutline'));
            delete(findobj(ax,'Tag','selectedevents'));
        end
        
        
        function coords = get.Center(obj)
            coords = (max(obj.Points)+min(obj.Points))/2;
        end
        function  x0 = get.X0(obj)
            x0=max((obj.Points(:,1))+min(obj.Points(:,1)))/2;
        end
        function  y0 = get.Y0(obj)
            y0=max((obj.Points(:,2))+min(obj.Points(:,2)))/2;
        end
        function area = get.Area(obj)
            polyArea(obj.Points(:,1),obj.Points(:,2));
        end
        
        
        function [obj] = select_polygon(obj)
            % select_polygon plots a polygon interactively using the mouse on selected axis
            % usage [ x, y, mask, mouse_overlay] = select_polygon(ax)
            %
            % returns [x, y, lineobject]
            %
            % lineobject has tag 'mouse_points_overlay'
            hold on
            mouse_points_overlay = plot(gca,0,0,'o-k',...
                'MarkerSize',5,'LineWidth',2.0,...
                'Tag','mouse_points_overlay',...
                'DisplayName','polygon outline');
            hold off
            
            but=1;
            x=[];
            y=[];
            
            while but == 1 || but == 112
                [xi,yi,but] = ginput(1);
                x = [x; xi];
                y = [y; yi];
                mouse_points_overlay.XData=x;
                mouse_points_overlay.YData=y;
            end
            
            x = [x ; x(1)];
            y = [y ; y(1)];      %  closes polygon
            obj.Points=[x,y];
            delete(mouse_points_overlay);
            %{
            mouse_points_overlay.XData=x;
            mouse_points_overlay.YData=y;
            mouse_points_overlay.LineStyle='-';
            mouse_points_overlay.Color='k';
            mouse_points_overlay.MarkerEdgeColor='k';
            %}
        end
        
        function obj=select_circle(obj,varargin)
            % also ShapeSelection('circle', radius) OR ('circle', [x,y], radius)
            % OR ShapeSelection('circle', catalog [,radius])
            
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
                error('ESCAPE pressed. aborting polygon creation'); %to calling routine: catch me!
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
        
        function save(obj)
            ZG=ZmapGlobal.Data;
            zmap_shape=obj;
            uisave('zmap_shape',fullfile(ZG.data_dir,'zmap_shape.mat'));
        end
    end
    
    methods(Static)
        
        function AddMenu(fig,ax)
            ZG=ZmapGlobal.Data;
            % this works with the ZG polygon
            figure(fig);
            if ~exist('ax','var')
                ax=gca;
            end
            
            % get rid of the menu if it already exists,but keep position
            submenu=findobj(gcf,'Type','uimenu','-and','Tag','shape_select');
            % add a selection menu to a figure
            if isempty(submenu)
                submenu = uimenu('Label','Selection','Tag','shape_select');
            end
            delete(submenu.Children);
            
            
            uimenu(submenu,'Label',['Current Shape:' ZG.selection_shape.Type],'Tag','shapetype','Enable','off');
            uimenu(submenu,'Label','summary goes here','Tag','shapesummary','Enable','off'); %modify this
            
            
            uimenu(submenu,'Label','Display Shape Outline','Checked','on','Callback',@cb_outlinetoggle);
            uimenu(submenu,'separator','on','Label','crop Main Catalog (keep INSIDE)','Callback',{@cb_crop,'inside'})
            uimenu(submenu,'Label','crop Main Catalog (keep OUTSIDE)','Callback',{@cb_crop,'outside'})
            
            isvis= ~ismember(ZG.selection_shape.Type, {'unassigned','circle'});
            if isvis
                vis='on';
            else
                vis='off';
            end
            uimenu(submenu,'Label','Analyze EQ inside Shape (timeplot)',...
                'separator','on',...
                'Visible',vis,...
                'Callback',@(~,~) selectp('inside')); %@cb_analyze
            
            uimenu(submenu,'Label','Analyze EQ outside Shape (timeplot)','Visible',vis,...
                'Callback',@(~,~) selectp('outside'));
            
            isvis=strcmp(ZG.selection_shape.Type, 'unassigned');
            if isvis
                vis='on';
            else
                vis='off';
            end
            uimenu(submenu,'separator','on','Enable','off','Visible',vis,'Label','[cannot select earthquakes, no active shape]');
            
            
            isvis= strcmp(ZG.selection_shape.Type, 'circle');
            if isvis
                vis='on';
            else
                vis='off';
            end
            % only active when choosing a circle
            uimenu(submenu,'Label',sprintf('Select EQ in Radius %f',ZG.selection_shape.Radius),...
                'separator','on',...
                'Visible',vis,'Callback',@mycb02);
            uimenu(submenu,'Label',...
                sprintf('Select EQ in Circle (closest %d events)',ZG.selection_shape.NEventsToEnclose),'Visible',vis,'Callback',@mycb02);
            uimenu(submenu,'Label',sprintf('Select EQ in Circle (closest %d events) ',ZG.selection_shape.NEventsToEnclose),'Visible',vis,'Callback',@mycb02);
            
            
            % options for choosing a shape
            polymenu=uimenu(submenu,'Separator','on','Label','Use polygon');
            uimenu(polymenu,'Label','Set Polygon: Box...','Callback',{@cb_createshape,'box'},...
                'Separator','on');
            uimenu(polymenu,'Label','Set Polygon: Current Axes','Callback',{@cb_createshape,'axes'});
            uimenu(polymenu,'Label','Set Polygon: Irregular shape...','Callback',{@cb_createshape,'polygon'});
            usecirc=uimenu(submenu,'Label','Use Circle...','Callback',{@cb_createshape,'circle'});
            switch ZG.selection_shape.Type
                case 'circle'
                    usecirc.Checked='on';
                case {'polygon','axes','box'}
                    polymenu.Checked='on';
            end
            
            % only active otherwise
            
            
            % uimenu(shmenu,'Label','Select EQ in Circle (Menu)','Callback',@mycb03);
            
            %uimenu(submenu,'Label','Select EQ in Polygon (Menu)','Callback',@mycb01);
            %uimenu(submenu,'Label','Select EQ inside Polygon','Callback',@(~,~) selectp('inside'));
            %uimenu(submenu,'Label','Select EQ outside Polygon','Callback',@(~,~) selectp('outside'));
            
            uimenu(submenu,'Separator','on',...
                'Label','Load shape','Callback',@cb_load);
            uimenu(submenu,'Label','Save shape','Callback',@cb_save);
            uimenu(submenu,'Label','Clear shape','Callback',@cb_clear);
            
            
            function mycb01(mysrc,~)
                global noh1;
                ZG=ZmapGlobal.Data;
                noh1 = gca;
                ZG.newt2 = ZG.a;
                stri = 'Polygon';
                keyselect
            end
            
            function mycb02(mysrc,~)
                h1 = gca;set(gcf,'Pointer','watch');
                stri = ' ';
                stri1 = ' ';
                circle
            end
            
            function mycb03(mysrc,~)
                h1 = gca;
                set(gcf,'Pointer','watch');
                stri =' ';
                stri1 = ' ';
                incircle
            end
        end
    end
    
    methods(Access=private)
        
        
        
        function obj=select_box(obj,varargin)
            
            disp('enter first corner, or click on desired center and press "S" for square. ESC aborts');
            [x,y,b] = ginput(1);
            if b==27 %escape
                error('ESCAPE pressed. aborting polygon creation'); %catch me!
            else
                hold on
                mpo=plot(gca,[x, x, nan, xlim],[ylim,nan,y,y],'--','color',[.6 .6 .6],'LineWidth',2.0);
                pt1=plot(gca,x,y,'ko','markersize',2');
                disp('enter second corner. ESC aborts')
                [x2,y2,b]=ginput(1);
                if b==27 %escape
                    delete([mpo, plt1])
                    error('ESCAPE pressed. aborting polygon creation')
                else
                    delete(pt1);
                    obj.Points=[x,y; x,y2; x2, y2; x2, y; x,y];
                    mpo.XData=obj.Points(:,1);
                    mpo.YData=obj.Points(:,2);
                    mpo.Color='k';
                    pause(.5);
                    delete(mpo);
                end
            end
        end
    end % private methods
    
end

function cb_crop(src,~,in_or_out)
    ZG=ZmapGlobal.Data;
    switch in_or_out
        case 'inside'
            mask=ZG.selection_shape.InsideEvents(ZG.a);
        case 'outside'
            mask=ZG.selection_shape.OutsideEvents(ZG.a);
        otherwise
            mask=true(ZG.a.Count,1);
    end
end

function cb_analyze(src,~)
    ZG=ZmapGlobal.Data;
    ZG.newt2 = ZG.a;
    ZG.newcat = ZG.a;
    timeplot(ZG.newt2);
end

function cb_createshape(src,~,type)
    ZG=ZmapGlobal.Data;
    try
        ZG.selection_shape=ShapeSelection(type);
        
        % clear any checkmark for a previous shape
        allmenus=findobj(src.Parent','Type','uimenu');
        shapeMenus=startsWith({allmenus.Label},'Use');
        checkedMenus=strcmp({allmenus.Checked},'on');
        set(allmenus(shapeMenus&checkedMenus),'Checked','off');
        
        % set this one on
        src.Checked='on';
    catch ME
        errordlg(ME.message);
    end
    curshapeh = findobj(gcf,'Tag','shapetype');
    set(curshapeh,'Label',['Current Shape:',upper(type)]);
    ZG.selection_shape.clearplot();
    if strcmp(get(findobj(allmenus,'Label','Display Shape Outline'),'Checked'),'on')
        ZG.selection_shape.plot();
    end
end

function cb_load(src,~)
    ZG=ZmapGlobal.Data;
    [f,p]=uigetfile('*.mat','Load Zmap Shape file',fullfile(ZG.data_dir, 'zmap_shape.mat'));
    if ~isempty(f)
        tmp=load(fullfile(p,f),'zmap_shape');
        ZG.selection_shape=tmp.zmap_shape;
    end
end

function cb_save(src,~)
    ZG=ZmapGlobal.Data;
    ZG.selection_shape.save();
end

function cb_clear(src,~)
    ZG=ZmapGlobal.Data;
    ZG.selection_shape=ShapeSelection('unassigned');
end