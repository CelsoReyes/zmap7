classdef ShapeGeneral
    %ShapeGeneral represents a geographical selection of events
    %
    %
    % obj=ShapeGeneral() no shape. initialization
    %
    % ShapeGeneral.AddMenu(fig , ax) creates a selection menu on specified figure that provides
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
    %  pg = ShapeGeneral(ax,'box')
    %  % user is prompted for two points
    %
    %  ShapeGeneral properties:
    %     Points - points within polygon [X1,Y1;...;Xn,Yn] circles have one value, so safest to use Outline
    %              prefer using the "Outline" method
    %     Type - shape type
    %     ApplyGrid - apply grid options to the selected shape.
    %     Center - geographic center of shape
    %     X0 - center X coordinate (center of shape extent)
    %     Y0 - center Y coordinate (center of shape extent)
    %     Lat -
    %     Lon -
    %     Area - approximate area of shape (km^2)
    %
    %  ShapeGeneral methods:
    %     ShapeGeneral -
    %     Outline - get shape outline. like Points, except guaranteed to give outline instead of centerpoints
    %     isInside - return a vector of size otherLon that is true where item is inside polygon
    %     plot
    %     clearplot
    %     deemphasizeplot
    %       
    %     isempty -
    %     toStr -
    %     toStruct
    %
    %     save -
    %
    %  ShapeGeneral static methods:
    %     AddMenu
    %
    %  ShapeGeneral callbacks:
    %     callbacks that affect the global shape variable
    %     cb_load
    %     cb_save
    %     cb_clear
    %     cb_createshape
    %
    %     callbacks that affect the current figure/menu
    %     cb_outlinetoggle
    %     cb_crop - crop the primary catalog based on the shape, and current view then resets views
    %     cb_selectp - analyze EQ inside/outside shape works from view in current figure
    
    properties
        Points=[nan nan] % points within polygon [X1,Y1;...;Xn,Yn] circles have one value, so safest to use Outline
        Type='unassigned' % shape type
        ApplyGrid=true; %apply grid options to the selected shape.
    end
    
    properties(Dependent)
        Center % geographic center of shape
        X0 % center X coordinate (center of shape extent)
        Y0 % center Y coordinate (center of shape extent)
        Lat
        Lon
        Area % approximate area of shape (km^2)
    end
    
    methods
        function val=Outline(obj,col)
            % get shape outline. like Points, except guaranteed to give outline instead of centerpoints
            if exist('col','var')
                val=obj.Points(:,col);
            else
                val=obj.Points;
            end
        end
        function obj=ShapeGeneral(type)
            % ShapeGeneral create a shape
            % type is one of 'circle', 'axes', 'box', 'polygon'}
            % CIRCLE: select using circle with a defined radius. define with 2 clicks or mouseover and press "R"
            % AXES: use current main map axes as a box
            % BOX: define using two corners
            % POLYGON: define with lots of clicks. anything except
            %
            % UNASSIGNED: clear shape
            %
            % results are stored in ZG.selection_shape
            %
            %TOFIX this should dispatch, or there should be a factory
            report_this_filefun(mfilename('fullpath'));
            if nargin==0
                return
            end
            
            %if ~ismember(lower(type),{'circle','axes','box','rectangle','polygon','unassigned'})
            %    error('unknown polygon type')
            %end
            mm=mainmap;
            ax=mm.mainAxes();
            axes(ax); % bring up axes of interest.  should be the map, with lat/lon
            obj.Type=lower(type);
            
            if ~exist('type','var')
                obj.Type='unassigned';
            end
            
            % hide any existing events
            obj.deemphasizeplot(ax);
            % make existing shape less obvious
                    obj.Points=[nan nan];
                    
            ZmapMessageCenter.update_catalog()
        end
        
        function val=get.Lat(obj)
            val= obj.Outline(2);
        end
        
        function val=get.Lon(obj)
            val=obj.Outline(1);
        end
        
        function val=get.Area(obj)
            % Area tries to scale according to lat/lon
            lats=obj.Lat;
            lons=obj.Lon;
            ys=deg2km(lats);
            latscale=cosd(lats);
            xs= deg2km(latscale .* lons);
            
            val = polyarea(xs,ys);
        end
        
        function [mask]=isInside(obj,otherLon, otherLat)
            % return a vector of size otherLon that is true where item is inside polygon
            mask = polygon_filter(obj.Lon, obj.Lat, otherLon, otherLat, 'inside');
        end
        
        function plot(obj,ax)
            shout=findobj(ax,'Tag','shapeoutline');
            assert(numel(shout)<2,'should only have one shape outline')
            if isempty(shout)
                hold on;
                plot(ax, obj.Lon,obj.Lat,'k','LineWidth',2.0,...
                    'LineStyle','-',...
                    'Color','k',...
                    'Tag','shapeoutline',...
                    'DisplayName','Selection Outline');
                hold off;
            else
                set(shout,'XData',obj.Lon,'YData',obj.Lat,...
                    'LineStyle','-',...
                    'Color','k');
            end
        end
        
        function clearplot(obj,ax)
            %clear the shape from the plot
            if ~exist('ax','var') || isempty(ax)
                mm=mainmap();
                ax=mm.mainAxes;
            end
            delete(findobj(ax,'Tag','shapeoutline'));
        end
        
        function deemphasizeplot(obj,ax)
            %clear the shape from the plot
            if ~exist('ax','var') || isempty(ax)
                mm=mainmap();
                ax=mm.mainAxes;
            end
            shout = findobj(ax,'Tag','shapeoutline');
            set(shout,'color',[.8 .8 .8],'linestyle',':');
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
        
        function tf=isempty(obj)
            tf=isequal(size(obj.Points),[1,2]) && all(isnan(obj.Points));
        end
        function s=toStr(obj)
            s = sprintf('%s Shape, with %d points.',obj.Type,size(obj.Outline,1));
            %Extent: Lon: [ %s to %s ], Lat: [ %s to %s]'
        end
        function s=toStruct(obj)
            s.Points=obj.Points;
            s.Type=obj.Type;
            s.ApplyGrid=obj.ApplyGrid;
            s.Center=obj.Center;
            s.X0=obj.X0;
            s.Y0=obj.Y0;
            x.Lat=obj.Outline(:,2);
            x.Lon=obj.Outline(:,1);
        end
        
        function save(obj)
            ZG=ZmapGlobal.Data;
            zmap_shape=obj;
            uisave('zmap_shape',fullfile(ZG.data_dir,'zmap_shape.mat'));
        end
        
        function applyVisibility(obj)
            % hide or show shape based on menu item
            isVisible=get(findobj('Tag','shapeoutlinetoggle'),'Checked');
            sh=findobj(gcf,'Tag','shapeoutline');
            set(sh,'Visible',logical2onoff(isVisible));
        end
        function setVisibility(obj,val)
            % set the visibility of this shape
            isVisible=set(findobj('Tag','shapeoutlinetoggle'),'Checked',val);
            sh=findobj(gcf,'Tag','shapeoutline');
            set(sh,'Visible',val);
        end
    end
    
    methods(Static)
        
        function submenu=AddMenu(fig)
            %
            % should write changes to ZG.selection_shape (?)
            ZG=ZmapGlobal.Data;
            ZGshape=ZG.selection_shape; %convenience name
            % this works with the ZG polygon
            
            % get rid of the menu if it already exists,but keep position
            submenu=findobj(fig,'Type','uimenu','-and','Tag','shape_select');
            % add a selection menu to a figure
            if isempty(submenu)
                submenu = uimenu('Label','Selection','Tag','shape_select');
            end
            delete(submenu.Children);
            
            
            uimenu(submenu,'Label',['Current Shape:' ZGshape.Type],'Tag','shapetype','Enable','off');
            uimenu(submenu,'Label',ZGshape.toStr,'Tag','shapesummary','Enable','off'); %modify this
            
            
            uimenu(submenu,'Label','Display Shape Outline','Checked','on',...
                'Tag','shapeoutlinetoggle','Callback',@ShapeGeneral.cb_outlinetoggle);
            
            
            add_grid_menu(submenu)
            % % menu items that change the main catalog % %
            isenabled = logical2onoff( ~strcmp(ZGshape.Type,'unassigned') );
            
            
            uimenu(submenu,'separator','on',...
                'Enable',isenabled,...
                'Label','crop Main Catalog (keep INSIDE)','Callback',{@ShapeGeneral.cb_crop,'inside'})
            uimenu(submenu,'Enable',isenabled,...
                'Label','crop Main Catalog (keep OUTSIDE)','Callback',{@ShapeGeneral.cb_crop,'outside'})
      
            uimenu(submenu,'Label','Analyze EQ inside Shape (timeplot)',...
                'separator','on',...
                'Callback',{@ShapeGeneral.cb_selectp,'inside'}); %@cb_analyze
            
            uimenu(submenu,'Label','Analyze EQ outside Shape (timeplot)',...
                'Callback',{@ShapeGeneral.cb_selectp,'outside'});
            
            vis= logical2onoff( strcmp(ZGshape.Type, 'unassigned') );
            uimenu(submenu,'separator','on',...
                'Enable','off','Visible',vis,...
                'Label','[cannot select earthquakes, no active shape]');
            
            
            % options for choosing a shape
            ShapePolygon.AddPolyMenu(submenu,ZGshape);
            ShapeCircle.AddCircleMenu(submenu, ZGshape);
            
            uimenu(submenu,'Separator','on',...
                'Label','Load shape','Callback',@ShapeGeneral.cb_load);
            uimenu(submenu,'Label','Save shape','Callback',@ShapeGeneral.cb_save);
            uimenu(submenu,'Label','Clear shape','Callback',@ShapeGeneral.cb_clear);
            
            uimenu(submenu,'Label','refresh menu','Separator','on','Callback',@(~,~)ShapeGeneral.AddMenu(gcf),'Visible',ZG.debug);
            
            
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
        end
        
        function cb_crop(~,~,in_or_out)
            % crop the primary catalog based on the shape, and current view then resets views
            %
            % precondition: this figure has a view stored in UserData.View
            
            ZG = ZmapGlobal.Data;
            
            fig = gcf;
            if isfield(fig.UserData,'View')
                myview=fig.UserData.View.PolygonApply(ZG.selection_shape.Outline);
            else
                myview=ZG.Views.primary.PolygonApply(ZG.selection_shape.Outline);
            end
            if strcmp(in_or_out,'outside')
                myview=myview.PolygonInvert();
            end
            
            % set the catalogs and their views
            ZG.primeCatalog=myview.Catalog();
            ZG.Views.primary = ZG.Views.primary.reset();
            
            ZG.newt2=ZG.primeCatalog;
            if isfield(ZG.Views,'timeplot')
                ZG.Views.timeplot = ZG.Views.timeplot.reset();
            else
                ZG.Views.timeplot = ZG.Views.primary;
            end
            
            ZG.newcat=ZG.newt2;
            
            % show the timeseries
            timeplot();
        end
        
        function cb_createshape(src,~,type)
            ZG=ZmapGlobal.Data;
            %try
            f=gcf;
            ZG.selection_shape=ShapeGeneral(type);
            
            % clear any checkmark for a previous shape
            parent=findobj(f,'Type','uimenu','-and','Label','Selection');
            if isempty(parent)
                warning('wrong figure')
                return
            end
            allmenus=findobj(parent,'Type','uimenu');
            shapeMenus=startsWith({allmenus.Label},'Set Polygon');
            shapeMenus=startsWith({allmenus.Label},'Set Circle') | shapeMenus;
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
            ShapeGeneral.AddMenu(gcf); %also refreshes menu
            ZG.selection_shape.plot(gca)
        end
        
        function cb_load(~,~)
            ZG=ZmapGlobal.Data;
            [f,p]=uigetfile('*.mat','Load Zmap Shape file',fullfile(ZG.data_dir, 'zmap_shape.mat'));
            if ~isempty(f)
                tmp=load(fullfile(p,f),'zmap_shape');
                ZG.selection_shape=tmp.zmap_shape;
            end
        end
        
        function cb_save(~,~)
            %
            ZG=ZmapGlobal.Data;
            ZG.selection_shape.save();
        end
        
        function cb_clear(~,~)
            % callback to clear the plot and reset the menus
            ZG=ZmapGlobal.Data;
            type='unassigned';
            ZG.selection_shape=ShapeGeneral(type);
            % deactivate crop menu items
            parent=findobj(gcf,'Type','uimenu','-and','Label','Selection');
            allmenus=findobj(parent,'Type','uimenu');
            cropMenus=startsWith({allmenus.Label},'crop ');
            set(allmenus(cropMenus),'Enable','off');
            curshapeh = findobj(gcf,'Tag','shapetype');
            set(curshapeh,'Label',['Current Shape:',upper(type)]);
            ZG.selection_shape.clearplot();
        end
        
        function cb_selectp(~,~,in_or_out)
            % analyze EQ inside/outside shape works from view in current figure
            
            ZG = ZmapGlobal.Data;
            
            % apply shape to current figure's view (inverting if necessary)
            fig = gcf;
            if isfield(fig.UserData,'View')
                myview=fig.UserData.View.PolygonApply(ZG.selection_shape.Outline);
            else
                myview=ZG.Views.primary.PolygonApply(ZG.selection_shape.Outline);
            end
            if strcmp(in_or_out,'outside')
                myview=myview.PolygonInvert();
            end
            
            ZG.newt2=myview.Catalog();
            if isfield(ZG.Views,'timeplot')
                ZG.Views.timeplot = ZG.Views.timeplot.reset();
            end
            
            ZG.newcat=ZG.newt2;
            timeplot();
            
        end

    end
    
end

