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
    %     cb_clear
    %     
    %
    %     callbacks that affect the current figure/menu
    %     cb_outlinetoggle
    %     cb_crop - crop the primary catalog based on the shape, and current view then resets views
    %     cb_selectp - analyze EQ inside/outside shape works from view in current figure
    
    properties(SetObservable = true)
        Points (:,2) double = [nan nan] % points within polygon [X1,Y1;...;Xn,Yn] circles have one value, so safest to use Outline
        Units = 'degrees'; % either 'degrees' or 'kilometers'
    end
    
    properties(SetAccess = protected)
        Type (1,:) char = 'unassigned' % shape type
        AllowVertexEditing = true;
    end
    
    properties
        ApplyGrid logical = true % apply grid options to the selected shape.
        ScaleWithLatitude logical = false
    end
    
    properties (NonCopyable = true)
        DeleteFcn = [] % this function will be run when the shape is deleted
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
    end
    
    methods
        
        function obj=ShapeGeneral()
            % ShapeGeneral create a shape
            report_this_filefun();
            addlistener(obj, 'Points', 'PostSet', @obj.notifyShapeChange);
            addlistener(obj, 'Units', 'PostSet',@(A,B)warning('changing shape units'));
        end
        
        function notifyShapeChange(obj,metaprop, evt)
            notify(obj, 'ShapeChanged');
        end
        
        function moveTo(obj, x , y)
            % MOVETO moves theshape to a new point.  assumes the same units as points
            delta = [x , y] - obj.Center;
            if ~obj.ScaleWithLatitude
                obj.Points = obj.Points + delta;
            else
                % TODO: deferred math
            end
        end
            
            
        function val=Outline(obj,col)
            % get shape outline. like Points, except guaranteed to give outline instead of centerpoints
            if exist('col','var')
                val=obj.Points(:,col);
            else
                val=obj.Points;
            end
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
        
        function [h, myListener]=plot(obj,ax, myListener)
            
            % changedFcn is called with (oldshape, newshape) when the shape is changed.
            if (isempty(ax) || ~isvalid(ax)) && exist('myListener','var')
                delete(myListener); % no point in plotting to an axis that no longer exists!
                return
            end
            shout=findobj(ax,'Tag','shapeoutline');
            if ~isempty(shout)
                if ~strcmp(shout.UserData, obj.Type)
                    delete(shout);
                    shout=[];
                end
            end
            
            assert(numel(shout)<2,'should only have one shape outline')

            f=ancestor(ax,'figure');
            %shapegencontext=findobj(f,'Tag','ShapeGenContext');
            %delete(shapegencontext)
            
            if isempty(shout)
                set(gca,'NextPlot','add');
                shout=line(ax, obj.Lon,obj.Lat,'Color','k','LineWidth',2.0,...
                    'LineStyle','-',...
                    'Color','r',...
                    'Tag','shapeoutline',...
                    'DisplayName','Selection Outline');
                shout.UIContextMenu=makeuicontext();
                shout.UserData=obj.Type;
                %moveable_item(p,[],@(moved,deltas)obj.finishedMoving(moved,deltas),...
                %    'movepoints',obj.AllowVertexEditing,'xtol',.05,'ytol',0.05,...
                %    'delpoints',obj.AllowVertexEditing,'addpoints',obj.AllowVertexEditing);
                set(gca,'NextPlot','replace');
            else
                set(shout,'XData',obj.Lon,'YData',obj.Lat,...
                    'LineStyle','-',...
                    'Color','r');
                %shout.UIContextMenu=makeuicontext();
            end
            % do this each time, to make sure it stays updated
            moveable_item(shout,[],@obj.finishedMoving,...
            'movepoints',obj.AllowVertexEditing,'xtol',.05,'ytol',0.05,...
            'delpoints',obj.AllowVertexEditing,'addpoints',obj.AllowVertexEditing);

            %default behavior is to refresh any plots associated with this shape
            if ~exist('myListener','var')
                
                % first create a listener with a bogus function, so we can get its handle.
                myListener=addlistener(obj,'ShapeChanged',@(~,~)disp('unset!'));
                
                % now set the callback to this function again, but pass this handle along.
                % this is to ensure that the handle is managed by the plot routine.
                myListener.Callback = @(~,~)plot(obj,ax,myListener); 
                
                % delete the listener when the outline is deleted, otherwise it will simply be
                % recreated when the shape properties change
                shout.DeleteFcn=@(~,~)delete(myListener);
            end
            
            function c=makeuicontext()
                c=uicontextmenu(f,'Tag','ShapeGenContext');
                uimenu(c,...
                    'Label','info...',...
                    MenuSelectedField(),@(src,ev) obj.summary());
                
                % add analysis functions
                for i=1:size(obj.AnalysisFunctions,1)
                    fn=obj.AnalysisFunctions{i,1};
                    nm=obj.AnalysisFunctions{i,2};
                    uimenu(c,'Label',sprintf('Analyze EQ inside Shape (%s)',nm),...
                        'separator','on',...
                        MenuSelectedField(),{@obj.cb_selectp,fn,'inside'}); %@cb_analyze
                    uimenu(c,'Label',sprintf('Analyze EQ outside Shape (%s)',nm),...
                        MenuSelectedField(),{@obj.cb_selectp,fn,'outside'});
                    uimenu(c,'Label',sprintf('Compare Inside vs Outside (%s)',nm),...
                        MenuSelectedField(),{@compare_in_out, fn});
                end
                
                uimenu(c,...
                    'Label','Change shape with latitude?',...
                    MenuSelectedField(),@latscale);
                obj.add_shape_specific_context(c);
                
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
        
        function add_shape_specific_context(obj,c)
            % would add additional menu items here
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
        
        function save(obj, data_dir)
            zmap_shape=obj;
            error('should not be in this save')
            uisave('zmap_shape',fullfile(data_dir, 'zmap_shape.mat'));
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
        
        function delete(obj)
            if ~isempty(obj.DeleteFcn)
                obj.DeleteFcn();
            end
        end
        
        function cb_selectp(obj,~,~,analysis_fn, in_or_out)
            % analyze EQ inside/outside shape works from view in current figure
            
            ZG = ZmapGlobal.Data;
            
            % apply shape to current figure's view (inverting if necessary)
            fig = gcf;
            if isfield(fig.UserData,'View')
                myview=fig.UserData.View.PolygonApply(obj.Outline);
            else
                myview=ZG.Views.primary.PolygonApply(obj.Outline);
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
        
        function finishedMoving(obj, movedObject, movedDelta)
            error('this should be implemented in the specific shape');
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
        
        function obj = load(varargin)
            obj=load_shape();
        end
        
        
        function clearplot(ax)
            %clear the shape from the plot
            if ~exist('ax','var') || isempty(ax)
                ax=findobj(gcf,'Tag','mainmap_ax');
            end
            delete(findobj(ax,'Tag','shapeoutline'));
        end
        
        function obj = ShapeStash(obj)
            % persistent storage that holds one shape
            persistent stashed_shape
            if nargin==1 
                assert(isa(obj,'ShapeGeneral'),'Cannot stash something that is not a shape');
                stashed_shape = copy(obj);
            end
            
            if isnumeric(stashed_shape)
                stashed_shape = ShapeGeneral;
            end
            
            if nargin==0
                obj=copy(stashed_shape);
            end
        end
        
    end % static methods
    
    
end

