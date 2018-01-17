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
        Points=[nan nan] % points within polygon [X1,Y1;...;Xn,Yn] circles have one value, so safest to use Outline
        Type='unassigned' % shape type
        Radius=5; % active radius km (if circle)
        ApplyGrid=true; %apply grid options to the selected shape.
    end
    
    properties(Dependent)
        Center % geographic center of shape
        X0 % center X coordinate
        Y0 % center Y coordinate
        Lat
        Lon
        Area %area of shape. not available if shape is defined by # of events it encloses
        Outline % get shape outline. like Points, except guaranteed to give outline instead of centerpoints
    end
    
    methods
        function obj=ShapeSelection(type, varargin)
            % ShapeSelection create a shape
            % type is one of 'circle', 'axes', 'box', 'polygon'}
            % CIRCLE: select using circle with a defined radius. define with 2 clicks or mouseover and press "R"
            % AXES: use current main map axes as a box
            % BOX: define using two corners
            % POLYGON: define with lots of clicks. anything except
            %
            % UNASSIGNED: clear shape
            %
            % results are stored in ZG.selection_shape
            
            report_this_filefun(mfilename('fullpath'));
            if nargin==0
                return
            end
            
            if ~ismember(lower(type),{'circle','axes','box','rectangle','polygon','unassigned'})
                error('unknown polygon type')
            end
            ax=mainmap('axes')
            if ~exist('type','var')
                obj.Type='unassigned';
            end
            axes(ax); % bring up axes of interest.  should be the map, with lat/lon
            obj.Type=lower(type);
            ZG=ZmapGlobal.Data;
            
            % hide any existing events
            obj.deemphasizeplot(ax);
            % make existing shape less obvious
            switch obj.Type
                case 'circle'
                    d=circle_select_dlg();
                    uiwait(d);
                    pause(1);
                    obj=ZG.selection_shape;
                    obj.plot(ax);
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
                    ZG.selection_shape=obj;
                    % crop catalog? probably not yet!
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
                    ZG.selection_shape=obj;
                    % crop catalog? probably not yet!
                case 'polygon' % ShapeSelection('polygon', [x1,y1;...;xn,yn]);
                    if ~isempty(varargin)
                        obj.Points=varargin{1};
                        %TODO check integerity, and make sure last point matches first
                    else
                        obj=select_polygon(obj);
                    end
                    ZG.selection_shape=obj;
                    % crop catalog? probably not yet!
                case 'unassigned'
                    obj.Points=[nan nan];
            end
            ZmapMessageCenter.update_catalog()
        end
        
        function val=get.Lat(obj)
            val= obj.Points(:,2);
        end
        function val=get.Lon(obj)
            val=obj.Points(:,1);
        end
        function val=get.Outline(obj)
            switch obj.Type
                case 'circle'
                    [lat,lon]=reckon(obj.Y0,obj.X0,km2deg(obj.Radius),(0:.25:360)');
                    val=[lon, lat];
                otherwise
                    val = obj.Points;
            end
        end
        function [mask]=InsideEvents(obj,catalog)
            % INSIDEEVENTS return a logical index for a catalog, true for events inside polygon
            mask = polygon_filter(obj.Outline(:,1), obj.Outline(:,2), catalog.Longitude, catalog.Latitude, 'inside');
        end
        
        function mask=OutsideEvents(obj,catalog)
            % OUTSIDEENVENTS return a logical index for a catalog, true for events outside polygon
            mask = polygon_filter(obj.Outline(:,1), obj.Outline(:,2), catalog.Longitude, catalog.Latitude, 'outside');
        end
        
        function plot(obj,ax, catalog, in_or_out, varargin)
            % plot the selection
            % will default to plotting on main map
            if ~exist('ax','var')||isempty(ax)
                ax=mainmap('axes');
            end
            if ~exist('in_or_out','var') || isempty(in_or_out)
                in_or_out='inside';
            end
            if ~exist('catalog','var')
                ZG=ZmapGlobal.Data;
                catalog=ZG.primeCatalog;
            end
            axes(ax);
            hold on
            
            delete(findobj(gcf,'Tag','shapeoutline'));
            delete(findobj(gcf,'Tag','selectedevents'));
            
            switch obj.Type
                case 'polygon'
                    plot(obj.Lon,obj.Lat,'k','LineWidth',2.0,...
                        'Tag','shapeoutline',...
                        'DisplayName','Selection Outline');
                    switch in_or_out
                        case 'outside'
                            msk=obj.InsideEvents(catalog);
                        otherwise
                            msk=obj.InsideEvents(catalog);
                    end
                    if exist('catalog','var')
                        plot(catalog.Longitude(msk), catalog.Latitude(msk),'g+',...
                            'Tag','selectedevents',...
                            'DisplayName','selected events');
                    end
                case 'circle'
                    [ minicat, max_km ] = catalog.selectCircle(obj.toStruct(), obj.X0, obj.Y0,[] );
                    [lat,lon]=reckon(obj.Y0,obj.X0,km2deg(max_km),(0:.25:360)');
                    
                    plot(lon,lat,'k','LineWidth',2.0,'Tag','shapeoutline',...
                        'DisplayName','Selection Outline');
                    plot(minicat.Longitude, minicat.Latitude,'g+',...
                        'Tag','selectedevents',...
                        'DisplayName','selected events');
                    
            end
        end
        function clearplot(obj,ax)
            %clear the shape from the plot
            if ~exist('ax','var') || isempty(ax)
                ax=mainmap('axes');
            end
            delete(findobj(ax,'Tag','shapeoutline'));
            delete(findobj(ax,'Tag','selectedevents'));
        end
        
        function deemphasizeplot(obj,ax)
            %clear the shape from the plot
            if ~exist('ax','var') || isempty(ax)
                ax=mainmap('axes')
            end
            shout = findobj(ax,'Tag','shapeoutline');
            set(shout,'color',[.8 .8 .8],'linestyle',':');
            set(findobj(ax,'Tag','selectedevents'),'Visible','off');
        end
        
        
        function coords = get.Center(obj)
            coords = (max(obj.Points,[],1)+min(obj.Points,[],1))./2;
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
        function tf=isempty(obj)
            tf=isequal(size(obj.Points),[1,2]) && all(isnan(obj.Points));
        end
        function s=toStruct(obj)
            s.Points=obj.Points;
            s.Type=obj.Type;
            s.ApplyGrid=obj.ApplyGrid;
            s.Center=obj.Center;
            s.X0=obj.X0;
            s.Y0=obj.Y0;
            x.Lat=obj.Lat;
            x.Lon=obj.Lon;
            % s=struct(obj);
            s.radius_km = obj.Radius;
            s.useNumNearbyEvents=false;
            s.useEventsInRadius=true;
        end
        
        function save(obj)
            ZG=ZmapGlobal.Data;
            zmap_shape=obj;
            uisave('zmap_shape',fullfile(ZG.data_dir,'zmap_shape.mat'));
        end
    end
    
    methods(Static)
        
        function submenu=AddMenu(fig,ax)
            %
            % should write changes to ZG.selection_shape (?)
            ZG=ZmapGlobal.Data;
            ZGshape=ZG.selection_shape; %convenience name
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
            
            
            uimenu(submenu,'Label',['Current Shape:' ZGshape.Type],'Tag','shapetype','Enable','off');
            uimenu(submenu,'Label','summary goes here','Tag','shapesummary','Enable','off'); %modify this
            
            
            uimenu(submenu,'Label','Display Shape Outline','Checked','on','Callback',@cb_outlinetoggle);
            uimenu(submenu,'Label','Apply grid','Callback',@cb_applygrid);
            uimenu(submenu,'Label','Change grid parameters','Callback',@(~,~)cb_changegridopts);
            uimenu(submenu,'Label','Create Auto-Grid','Callback',@(~,~)cb_autogrid);
            uimenu(submenu,'Label','Create Auto-Radius','Callback',@(~,~)cb_autoradius);
            % % menu items that change the main catalog % %
            if strcmp(ZGshape.Type,'unassigned')
                isenabled='off';
            else
                isenabled='on';
            end
            uimenu(submenu,'separator','on',...
                'Enable',isenabled,...
                'Label','crop Main Catalog (keep INSIDE)','Callback',{@cb_crop,'inside'})
            uimenu(submenu,'Enable',isenabled,...
                'Label','crop Main Catalog (keep OUTSIDE)','Callback',{@cb_crop,'outside'})
            
            isvis= ~ismember(ZGshape.Type, {'unassigned','circle'});
            if isvis
                vis='on';
            else
                vis='off';
            end
            uimenu(submenu,'Label','Analyze EQ inside Shape (timeplot)',...
                'separator','on',...
                'Visible',vis,...
                'Callback',{@cb_selectp,'inside'}); %@cb_analyze
            
            uimenu(submenu,'Label','Analyze EQ outside Shape (timeplot)','Visible',vis,...
                'Callback',{@cb_selectp,'outside'});
            
            isvis=strcmp(ZGshape.Type, 'unassigned');
            if isvis
                vis='on';
            else
                vis='off';
            end
            uimenu(submenu,'separator','on','Enable','off','Visible',vis,'Label','[cannot select earthquakes, no active shape]');
            
            
            isvis= strcmp(ZGshape.Type, 'circle');
            if isvis
                vis='on';
            else
                vis='off';
            end
            % only active when choosing a circle
            uimenu(submenu,'Label',sprintf('Select EQ in Radius %.3f km',ZGshape.Radius),...
                'separator','on',...
                'Visible',vis,'Callback',{@cb_selectp,'inside'});%@(~,~)ZGshape.select_circle_events(ZG.primeCatalog,'radius'));
            
            uimenu(submenu,'Label',sprintf('Select EQ beyond Radius %.3f km',ZGshape.Radius),...
                'Visible',vis,'Callback',{@cb_selectp,'outside'});
            % options for choosing a shape
            usebox=uimenu(submenu,'Separator','on','Label','Set Polygon: Box...','Callback',{@cb_createshape,'box'});
            useaxes=uimenu(submenu,'Label','Set Polygon: Current Axes','Callback',{@cb_createshape,'axes'});
            usepoly=uimenu(submenu,'Label','Set Polygon: Irregular shape...','Callback',{@cb_createshape,'polygon'});
            usecirc=uimenu(submenu,'Label','Use Circle...','Callback',{@cb_createshape,'circle'});
            usecirc=uimenu(submenu,'Label','Set Circle: mouse click','Callback',@cb_select_c_and_r);
            %usecirc=uimenu(submenu,'Label','Use Circle...','Callback',{@cb_createshape,'circle'});
            %switch ZGshape.Type
            %    case 'circle'
             %       usecirc.Checked='on';
             %   case 'polygon'
             %       usepoly.Checked='on';
             %   case 'axes'
             %       useaxes.Checked='on';
             %   case 'box'
             %       usebox.Checked='on';
            %end
            
            uimenu(submenu,'Separator','on',...
                'Label','Load shape','Callback',@cb_load);
            uimenu(submenu,'Label','Save shape','Callback',@cb_save);
            uimenu(submenu,'Label','Clear shape','Callback',@cb_clear);
            
            uimenu(submenu,'Label','refresh menu','Separator','on','Callback',@(~,~)ShapeSelection.AddMenu(gcf),'Visible',ZG.debug);
            
            
        end
    end
    
    methods(Access=private)
        
        function select_circle_events(obj, catalog)
            selcrit=struct('radius_km',obj.Radius,...
                'useEventsInRadius',true);
            ZG=ZmapGlobal.Data;
            obj.plot()
            ZG.newt2 = catalog.selectCircle(selcrit,obj.X0,obj.Y0,[]);
            ZG.newcat=ZG.newt2;
            timeplot()
            %circle
        end

        
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

function cb_outlinetoggle(src,~)
    sh=findobj(gcf,'Tag','shapeoutline');
    ev=findobj(gcf,'Tag','selectedevents');
    curstat=src.Checked;
    if ~strcmpi(curstat,'on')
        v='on';
        src.Checked='on';
    else
        v='off';
        src.Checked='off';
    end
    
    set([sh ev],'Visible',v);
    %delete(findobj(gcf,'Tag','shapeoutline'));
    %delete(findobj(gcf,'Tag','selectedevents'));
end

function cb_crop(src,~,in_or_out)
    cb_selectp(src,[],in_or_out)
    curfig=gcf;
    tmpcat= curfig.UserData.View.Catalog();
    if isempty(tmpcat) || ~isa(tmpcat,'ZmapCatalog')
        error('could not crop. this figure''s catalog (view) is empty');
    end
    ZG=ZmapGlobal.Data;
    ZG.primeCatalog=tmpcat;
    
    switch in_or_out
        case 'inside'
            mask=ZG.selection_shape.InsideEvents(ZG.primeCatalog);
        case 'outside'
            mask=ZG.selection_shape.OutsideEvents(ZG.primeCatalog);
        otherwise
            mask=true(ZG.primeCatalog.Count,1);
    end
    ZG.newt2=ZG.primeCatalog.subset(mask);
    ZG.newcat=ZG.newt2;
end
%{
function cb_analyze(src,~)
    ZG=ZmapGlobal.Data;
    ZG.newt2 = ZG.primeCatalog;
    ZG.newcat = ZG.primeCatalog;
    timeplot();
end
%}
function cb_createshape(src,~,type)
    ZG=ZmapGlobal.Data;
    %try
        f=gcf;
        ZG.selection_shape=ShapeSelection(type);
        
        % clear any checkmark for a previous shape
        parent=findobj(f,'Type','uimenu','-and','Label','Selection');
        if isempty(parent)
            warning('wrong figure')
            return
        end
        allmenus=findobj(parent,'Type','uimenu');
        shapeMenus=startsWith({allmenus.Label},'Set Polygon');
        shapeMenus=startsWith({allmenus.Label},'Use Circle') | shapeMenus;
        checkedMenus=strcmp({allmenus.Checked},'on');
        set(allmenus(shapeMenus&checkedMenus),'Checked','off');
        %activate crop menu items
        cropMenus=startsWith({allmenus.Label},'crop ');
        set(allmenus(cropMenus),'Enable','on');
        % set this one on
        src.Checked='on';
    %catch ME
    %    errordlg(ME.message);
    %end
    ShapeSelection.AddMenu(gcf); %also refreshes menu
    ZG.selection_shape.plot()
    %{
    %activate analyze menu items
    cropMenus=startsWith({allmenus.Label},'Analyze EQ ');
    set(allmenus(cropMenus),'Enable','on');
        
    curshapeh = findobj(gcf,'Tag','shapetype');
    set(curshapeh,'Label',['Current Shape:',upper(type)]);
    ZG.selection_shape.clearplot();
    if strcmp(get(findobj(allmenus,'Label','Display Shape Outline'),'Checked'),'on')
        ZG.selection_shape.plot();
    end
    Analyze EQ
    %}
end

function cb_select_c_and_r(src,~)
    ZG=ZmapGlobal.Data;
    ZG.selection_shape=ZG.selection_shape.select_circle();
    ZG.selection_shape.Type='circle';
    ZG.selection_shape.plot();
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
    % 
    ZG=ZmapGlobal.Data;
    ZG.selection_shape.save();
end

function cb_clear(src,~)
    % callback to clear the plot and reset the menus
    ZG=ZmapGlobal.Data;
    type='unassigned';
    ZG.selection_shape=ShapeSelection(type);
    % deactivate crop menu items
    parent=findobj(gcf,'Type','uimenu','-and','Label','Selection');
    allmenus=findobj(parent,'Type','uimenu');
    cropMenus=startsWith({allmenus.Label},'crop ');
    set(allmenus(cropMenus),'Enable','off');
    curshapeh = findobj(gcf,'Tag','shapetype');
    set(curshapeh,'Label',['Current Shape:',upper(type)]);
    ZG.selection_shape.clearplot();
end

function cb_applygrid(src,~)
    % cb_applygrid sets the grid according to the selected shape
    ZG=ZmapGlobal.Data;
    obj=ZG.selection_shape;
    gopt=ZG.gridopt; %get grid options
    if gopt.GridEntireArea || (isempty(obj.Lon)||isnan(obj.Lon(1)))% use catalog
        xmin=min(ZG.primeCatalog.Longitude);
        xmax=max(ZG.primeCatalog.Longitude);
        ymin=min(ZG.primeCatalog.Latitude);
        ymax=max(ZG.primeCatalog.Latitude);
    else %use shape
        xmin=min(obj.Lon);
        xmax=max(obj.Lon);
        ymin=min(obj.Lat);
        ymax=max(obj.Lat);
    end
    ZG.Grid=ZmapGrid.FromVectors('grid',xmin:gopt.dx:xmax, ymin:gopt.dy:ymax, gopt.dx_units);
    ZG.Grid=ZG.Grid.MaskWithShape(obj);
    ZG.Grid.plot();
end

function cb_selectp(src,~,in_or_out)  
    % works from view in current figure
    thisfig=gcf;
    ZG=ZmapGlobal.Data;
    try
    myview=thisfig.UserData.View;
    catch
        warning('figure doesn''t have UserData.View ')
        myview=ZG.Views.primary; %
    end
    
    myview=myview.PolygonApply(ZG.selection_shape.Outline);
    if strcmp(in_or_out,'outside')
        myview=myview.PolygonInvert;
    end
    thisfig.UserData.View=myview;
    ZG.newt2=thisfig.UserData.View.Catalog; %ZG.primeCatalog.subset(mask);
    ZG.newcat=ZG.newt2;
    timeplot();
    
end

function cb_autogrid(~,~)
    ZG=ZmapGlobal.Data;
    [ZG.Grid,ZG.gridopt]=autogrid(ZG.primeCatalog,true,true);
end

function cb_autoradius(~,~)
    ZG=ZmapGlobal.Data;
    minNum=ZG.ni;
    reach=1.5;
    pct=50; 
    prompt={'Required Number of Events:', ...
        'Percentile:',...
        'reach:'};
    defans={num2str(minNum), num2str(pct), num2str(reach)};
    sdlg.prompt='Required Number of Events:';sdlg.value=minNum;
    sdlg(2).prompt='Percentile:';sdlg(2).value=pct;
    sdlg(3).prompt='reach:';sdlg(3).value=reach;
    [~,cancelled,minNum,pct,reach]=smart_inputdlg('automatic radius',sdlg);
    if cancelled
        beep
        return
    end
    [r, evselch] = autoradius(ZG.primeCatalog, ZG.Grid, minNum, pct, reach);
    ZG.ra=r;
    ZG.ni=minNum;
    ZG.GridSelector=evselch;
end

function cb_changegridopts(~,~)
    error('unimplemented')
    ZG=ZmapGlobal.Data;
    GridParameterChoice();
end