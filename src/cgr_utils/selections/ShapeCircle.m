classdef ShapeCircle < ShapeGeneral
    %ShapeCircle represents a circular geographical selection of events
    %
    % see also ShapeGeneral, ShapePolygon
    
    properties (SetObservable = true, AbortSet=true)
        Radius (1,1) double = 5 % active radius km
    end
    
    
    methods
        function obj=ShapeCircle(varargin)
            % SHAPECIRCLE create a circular shape
            %
            % ShapeCircle() :
            % ShapeCircle('dlg') create via a dialg box
            %
            % CIRCLE: select using circle with a defined radius. define with 2 clicks or mouseover and press "R"
            
            % UNASSIGNED: clear shape
            
            obj@ShapeGeneral;
            
            report_this_filefun();
            
            %axes(findobj(gcf,'Tag','mainmap_ax')); % should be the map, with lon/lat
            obj.Type='circle';
            try
                ra=ShapeGeneral.ShapeStash.Radius;
            catch
                ra=obj.Radius;
            end
            obj.AllowVertexEditing = false;
            addlistener(obj, 'Radius', 'PostSet', @obj.notifyShapeChange);
            if nargin==0
                do_nothing;
            elseif strcmpi(varargin{1},'dlg')
                stashedshape = ShapeGeneral.ShapeStash;
                sdlg.prompt='Radius (km):'; sdlg.value=ra;
                sdlg(2).prompt='Center X (Lon):'; sdlg(2).value=stashedshape.X0;
                sdlg(3).prompt='Center Y (Lat):'; sdlg(3).value=stashedshape.Y0;
                [~,cancelled,obj.Radius,obj.Points(1),obj.Points(2)]=smart_inputdlg('Define Circle',sdlg);
                if cancelled
                    beep
                    disp('Circle creation cancelled by user')
                    return
                end
            else
                oo=ShapeCircle.selectUsingMouse(gca);
                if ~isempty(oo)
                    obj=oo;
                else
                    return
                end
            end
        end
        
        function val=Outline(obj,col)
            % TODO: look into using scircle1 or scircle2
            [lat,lon]=reckon(obj.Y0,obj.X0,km2deg(obj.Radius),(0:.1:360)');
            val=[lon, lat];
            if exist('col','var')
                val=val(:,col);
            end
        end
        
        function moveTo(obj, x, y)
            if isnan(obj.Points)
                obj.Points=[0 0];
            end
            moveTo@ShapeGeneral(obj,x,y)
        end
        
        function s=toStruct(obj)
            s=toStruct@ShapeGeneral(obj);
            s.radius_km = obj.Radius;
        end
        
        function s = toStr(obj)
            cardinalDirs='SNWE';
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

        function add_shape_specific_context(obj,c)
            uimenu(c,'label','Choose Radius',Futures.MenuSelectedFcn,@chooseRadius)
            uimenu(c,'label','Snap To N Events',Futures.MenuSelectedFcn,@snapToEvents)
            
            function snapToEvents(~,~)
                ZG=ZmapGlobal.Data;
                nc=inputdlg('Number of events to enclose','Edit Circle',1,{num2str(ZG.ni)});
                nc=round(str2double(nc{1}));
                if ~isempty(nc) && ~isnan(nc)
                    ZG.ni=nc;
                    [~,obj.Radius]=ZG.primeCatalog.selectClosestEvents(obj.Y0, obj.X0, [],nc);
                    obj.Radius=obj.Radius;%+0.005;
                end
            end
            
            function chooseRadius(~,~)
                nc=inputdlg('Choose Radius (km)','Edit Circle',1,{num2str(obj.Radius)});
                nc=str2double(nc{1});
                if ~isempty(nc) && ~isnan(nc)
                    obj.Radius=nc;
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
        
        function finishedMoving(obj, movedObject, deltas)
            centerX = mean([min(movedObject.XData),max(movedObject.XData)]);
            centerY = mean([min(movedObject.YData),max(movedObject.YData)]);
            
            obj.Radius=obj.Radius.* abs(deltas(3)); % NO NEGATIVE RADII
            obj.Points=[centerX,centerY];
        end
        
    end
    
    methods(Static)
        
        function obj=selectUsingMouse(ax)
            
            [ss,ok] = selectSegmentUsingMouse(ax,'deg','km','r',@circ_update);
            delete(findobj(gca,'Tag','tmp_circle_outline'));
            if ~ok
                obj=[];
                return
            end
            obj=ShapeCircle;
            obj.Points=ss.xy1;
            obj.Radius=ss.dist_km;
            
            function circ_update(stxy, ~, d)
                h=findobj(gca,'Tag','tmp_circle_outline');
                if isempty(h)
                    h=line(nan,nan,'Color','r','DisplayName','Rough Outline','LineWidth',2,'Tag','tmp_circle_outline');
                end
                [lat,lon]=reckon(stxy(2),stxy(1),km2deg(d),(0:3:360)');
                h.XData=lon;
                h.YData=lat;
            end
        end
        function obj=select(varargin)
            % ShapeCircle.select()
            % ShapeCircle.select()
            % ShapeCircle.select(radius)
            % ShapeCircle.select('circle', [x,y], radius)
            
            obj=ShapeCircle;
            if nargin==0
                obj = ShapeCircle.selectUsingMouse(gca);
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
        
    end
    
            
end
