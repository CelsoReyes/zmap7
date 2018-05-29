classdef ShapeGeneral < matlab.mixin.Copyable
    %ShapeGeneral represents a geographical selection of events
    %
    %
    % obj=SHAPEGENERAL() no shape. initialization
    %
    % SHAPEGENERAL.AddMenu(fig , ax) creates a selection menu on specified figure that provides
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
    %  pg = SHAPEGENERAL(ax,'box')
    %  % user is prompted for two points
    %
    %  SHAPEGENERAL properties:
    %     Points - points within polygon [X1,Y1;...;Xn,Yn] circles have one value, so safest to use Outline
    %              prefer using the "Outline" method
    %     Type - shape shapeType
    %     ApplyGrid - apply grid options to the selected shape.
    %     Center - geographic center of shape
    %     X0 - center X coordinate (center of shape extent)
    %     Y0 - center Y coordinate (center of shape extent)
    %     Lat - Y coordinate for the shape outline
    %     Lon - X coordinate for the shape outline
    %     Area - approximate area of shape (km^2)
    %
    %  SHAPEGENERAL methods:
    %     SHAPEGENERAL -
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
    %  SHAPEGENERAL static methods:
    %     AddMenu
    %
    %  SHAPEGENERAL callbacks:
    %     callbacks that affect the global shape variable
    %     cb_load
    %     cb_save
    %     cb_clear
    %     
    %
    %     callbacks that affect the current figure/menu
    %     cb_outlinetoggle
    %     cb_crop - crop the primary catalog based on the shape, and current view then resets views
    %     cb_selectp - analyze EQ inside/outside shape works from view in current figure
    
    properties
        Points (:,2) double = [nan nan] % points within polygon [X1,Y1;...;Xn,Yn] circles have one value, so safest to use Outline
        Type (1,:) char = 'unassigned' % shape type
        ApplyGrid logical = true %apply grid options to the selected shape.
        ScaleWithLatitude logical = false
        Units = 'degrees'; % either 'degrees' or 'kilometers'
    end
    
    properties(Dependent)
        Center % geographic center of shape
        X0 % center X coordinate (center of shape extent)
        Y0 % center Y coordinate (center of shape extent)
        Lat % Y coordinate for the shape outline
        Lon % X coordinate for the shape outline
        Area % approximate area of shape (km^2)
    end
    
    properties(Constant)
        AnalysisFunctions = {@CumTimePlot,'timeplot'}
    end
    
    events
        ShapeChanging % deemphasizes existing plots of this shape
        ShapeChanged
        ShapeDestroyed 
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
        
        function obj=ShapeGeneral()
            % ShapeGeneral create a shape
            % shapeType is one of 'circle', 'axes', 'box', 'polygon'}
            % CIRCLE: select using circle with a defined radius. define with 2 clicks or mouseover and press "R"
            % AXES: use current main map axes as a box
            % BOX: define using two corners
            % POLYGON: define with lots of clicks. anything except
            %
            % UNASSIGNED: clear shape
            report_this_filefun();
            obj.subscribe('ShapeChanged',@(~,~)warning('Shape changed'));
            obj.subscribe('ShapeChanged',@(A,~)disp(A));
            obj.subscribe('ShapeChanged',@(~,B)disp(B));
            
            %{
            ax=findobj(gcf,'Tag','mainmap_ax');
            % assumption: we the current figure contains the axes of interest
            set(gcf,'CurrentAxes',ax) % bring up axes of interest.  should be the map, with lat/lon

            % hide any existing events
            obj.deemphasizeplot(ax);
            % make existing shape less obvious
            obj.Points=[nan nan];
            %}
        end
        
        function subscribe(obj, evt, fcn)
            addlistener(obj, evt, fcn);
        end
        
        function val=get.Lat(obj)
            val= obj.Outline(2);
        end
        
        function val=get.Lon(obj)
            val=obj.Outline(1);
        end
        
        function val=get.Area(obj)
            % Area attempts to scale according to lat/lon
            lats=obj.Lat;
            lons=obj.Lon;
            ys=deg2km(lats);
            latscale=cosd(lats);
            xs= deg2km(latscale .* lons);
            
            val = polyarea(xs,ys);
        end
        
        function [mask]=isInside(obj,otherLon, otherLat)
            % [mask]=isInside(obj,otherLon, otherLat)
            if isempty(obj.Points)||isnan(obj.Points(1))
                mask = ones(size(otherLon));
            else
                % return a vector of size otherLon that is true where item is inside polygon
                mask = polygon_filter(obj.Lon, obj.Lat, otherLon, otherLat, 'inside');
            end
        end
        
        function plot(obj,ax)
            % changedFcn is called with (oldshape, newshape) when the shape is changed.
            shout=findobj(ax,'Tag','shapeoutline');
            assert(numel(shout)<2,'should only have one shape outline')

            f=ancestor(ax,'figure');
            delete(findobj(f,'Tag','ShapeGenContext'));
            
            if isempty(shout)
                hold on;
                p=line(ax, obj.Lon,obj.Lat,'Color','k','LineWidth',2.0,...
                    'LineStyle','-',...
                    'Color','r',...
                    'Tag','shapeoutline',...
                    'DisplayName','Selection Outline');
                p.UIContextMenu=makeuicontext();
                %moveable_item(p,[],@(moved,deltas)obj.finishedMoving(moved,deltas));
                hold off;
            else
                set(shout,'XData',obj.Lon,'YData',obj.Lat,...
                    'LineStyle','-',...
                    'Color','r');
                shout.UIContextMenu=makeuicontext();
            end
            
            
            function c=makeuicontext()
                c=uicontextmenu(f,'Tag','ShapeGenContext');
                uimenu(c,...
                    'Label','info...',...
                    Futures.MenuSelectedFcn,@(src,ev) obj.summary());
                
                % add analysis functions
                for i=1:size(obj.AnalysisFunctions,1)
                    fn=obj.AnalysisFunctions{i,1};
                    nm=obj.AnalysisFunctions{i,2};
                    uimenu(c,'Label',sprintf('Analyze EQ inside Shape (%s)',nm),...
                        'separator','on',...
                        Futures.MenuSelectedFcn,{@ShapeGeneral.cb_selectp,fn,'inside'}); %@cb_analyze
                    uimenu(c,'Label',sprintf('Analyze EQ outside Shape (%s)',nm),...
                        Futures.MenuSelectedFcn,{@ShapeGeneral.cb_selectp,fn,'outside'});
                    uimenu(c,'Label',sprintf('Compare Inside vs Outside (%s)',nm),...
                        Futures.MenuSelectedFcn,{@compare_in_out, fn});
                end
                
                uimenu(c,...
                    'Label','edit shape (mouse)',...
                    'separator','on',...
                    Futures.MenuSelectedFcn,{@obj.interactive_edit});
                uimenu(c,...
                    'Label','Change shape with latitude?',...
                    Futures.MenuSelectedFcn,@latscale);
                obj.add_shape_specific_context(c,ax);
                %uimenu(c,'Label','Clear shape','separator','on',Futures.MenuSelectedFcn,@(~,~)ShapeGeneral.cb_clear);
                
                function compare_in_out(src,ev)
                    beep;
                    error('not implemented');
                end
                
                function latscale(src,ev)
                    obj.ScaleWithLatitude=~obj.ScaleWithLatitude;
                    src.Checked=tf2onoff(obj.ScaleWithLatitude);
                end
            end
        end
        function add_shape_specific_context(obj,c,ax)
            % would add additional menu items here
        end
        function clearplot(obj,ax)
            %clear the shape from the plot
            if ~exist('ax','var') || isempty(ax)
                ax=findobj(gcf,'Tag','mainmap_ax');
            end
            delete(findobj(ax,'Tag','shapeoutline'));
        end
        
        function deemphasizeplot(obj,ax)
            %clear the shape from the plot
            if ~exist('ax','var') || isempty(ax)
                ax=findobj(gcf,'Tag','mainmap_ax');
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
            s = sprintf('%s Shape, with %d points.',obj.Type,size(obj.Outline,1)-1);
        end
        function s=toStruct(obj)
            s.Points=obj.Points;
            s.Type=obj.Type;
            s.ApplyGrid=obj.ApplyGrid;
            s.Center=obj.Center;
            s.X0=obj.X0;
            s.Y0=obj.Y0;
            s.Lat=obj.Outline(:,2);
            s.Lon=obj.Outline(:,1);
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
            set(sh,'Visible',tf2onoff(isVisible));
        end
        function setVisibility(obj,val)
            % set the visibility of this shape
            isVisible=set(findobj('Tag','shapeoutlinetoggle'),'Checked',val);
            sh=findobj(gcf,'Tag','shapeoutline');
            set(sh,'Visible',val);
        end
        
        function summary(obj)
            helpdlg('no shape','Unassigned shape');
        end
        
        function interactive_edit(obj,ax)
        end
        
        function delete(obj)
            notify(obj,'ShapeDestroyed');
        end
    end
    
    methods(Static)
        
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
            shapeType='unassigned';
            ZG.selection_shape=ShapeGeneral();
            % deactivate crop menu items
            parent=findobj(gcf,'Type','uimenu','-and','Label','Selection');
            allmenus=findobj(parent,'Type','uimenu');
            if ~isempty(allmenus)
                cropMenus=startsWith({get(allmenus,'Label')},'crop ');
                set(allmenus(cropMenus),'Enable','off');
            end
            curshapeh = findobj(gcf,'Tag','shapetype');
            set(curshapeh,'Label',['Current Shape:',upper(shapeType)]);
            ZG.selection_shape.clearplot();
        end
        
        function cb_selectp(~,~,analysis_fn, in_or_out)
            % analyze EQ inside/outside shape works from view in current figure
            
            ZG = ZmapGlobal.Data;
            
            % apply shape to current figure's view (inverting if necessary)
            fig = gcf;
            if isfield(fig.UserData,'View')
                myview=fig.UserData.View.PolygonApply(ZG.selection_shape.Outline);
            else
                myview=ZG.Views.primary.PolygonApply(ZG.selection_shape.Outline);
            end
            if in_or_out == "outside"
                myview=myview.PolygonInvert();
            end
            
            ZG.newt2=myview.Catalog();
            if isfield(ZG.Views,'timeplot')
                ZG.Views.timeplot = ZG.Views.timeplot.reset();
            end
            
            ZG.newcat=ZG.newt2;
            analysis_fn();
            
        end
        
    end % static methods
    methods(Access=protected)
        function finishedMoving(obj, updateShapeFcn, movedObject, movedDelta)
            error('this should be implemented in the specific shape');
        end
    end
    
end

