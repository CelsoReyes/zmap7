classdef ShapeCircle < ShapeGeneral
    %ShapeCircle represents a circular geographical selection of events
    %
    % see also ShapeGeneral, ShapePolygon
    
    properties (SetObservable = true, AbortSet=true)
        Radius (1,1) double = 5 % active radius in units defined by the RefEllipsoid
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
            
            obj@ShapeGeneral();
            if ~isempty(varargin)
               dosomething
            end
            
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
            if numel(varargin)==0
                do_nothing;
            elseif strcmpi(varargin{1},'dlg')
                stashedshape = ShapeGeneral.ShapeStash;
                sdlg.prompt = ['Choose Radius [',obj.RefEllipsoid.LengthUnit,']:'];
                sdlg.value = ra;
                sdlg(2).prompt = 'Center X :'; sdlg(2).value=stashedshape.X0;
                sdlg(3).prompt = 'Center Y :'; sdlg(3).value=stashedshape.Y0;
                [~,cancelled,obj.Radius,obj.Points(1),obj.Points(2)]=smart_inputdlg('Define Circle',sdlg);
                if cancelled
                    beep
                    disp('Circle creation cancelled by user')
                    return
                end
            else
                oo=ShapeCircle.selectUsingMouse(gca, coordinate_system);
                if ~isempty(oo)
                    obj=oo;
                else
                    return
                end
            end
        end
        
        function val=Outline(obj,col)
            switch obj.CoordinateSystem
                case CoordinateSystems.geodetic
                    [lat,lon]=reckon(obj.Y0,obj.X0,obj.Radius,(0:.1:360)',obj.RefEllipsoid);
                    val=[lon, lat];
                case CoordinateSystems.cartesian
                    pts = exp(1i*pi*linspace(0,2*pi,3600)') .* obj.Radius;
                    x = real(pts)+ obj.X0;
                    y = imag(pts) + obj.Y0;
                    val = [x,y];
                otherwise
                    error('unspecified coordinate system')
            end
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
            s.RadiusKm = obj.Radius;
        end
        
        function s = toStr(obj)
            cardinalDirs='SNWE';
            isN=obj.Y0>=0; NS=cardinalDirs(isN+1);
            
            isE=obj.X0>=0; EW=cardinalDirs(isE+3);
            s = sprintf('Circle with R:%s %s, centered at ( %s %s, %s %s)',...
                num2str(obj.Radius),...
                obj.RefEllipsoid.LengthUnit,...
                num2str(abs(obj.Y0)), NS,...
                num2str(abs(obj.X0)), EW);
        end
        
        function summary(obj)
            helpdlg(obj.toStr,'Circle');
        end

        function add_shape_specific_context(obj,c)
            uimenu(c,'label','Choose Radius',MenuSelectedField(),@chooseRadius)
            uimenu(c,'label','Snap To N Events',MenuSelectedField(),@snapToEvents)
            
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
                radiusInputText = ['Choose Radius [',obj.RefEllipsoid.LengthUnit,']'];
                nc=inputdlg(radiusInputText,'Edit Circle',1,{num2str(obj.Radius)});
                nc=str2double(nc{1});
                if ~isempty(nc) && ~isnan(nc)
                    obj.Radius=nc;
                end
                
            end
            
        end
        
        function [mask]=isinterior(obj,otherX, otherY, include_boundary)
            % isinterior true if value is within this circle's radius of center. Radius inclusive.
            %
            % overridden because using polygon approximation is too inaccurate for circles
            %
            % [mask]=obj.isinterior(otherX, otherY)

            if ~exist('include_boundary','var')
                include_boundary = true;
            end
            if isempty(obj.Points)||isnan(obj.Points(1))
                mask = ones(size(otherX));
            else
                otherX(ismissing(otherY))= missing;
                otherY(ismissing(otherX))= missing;
                % return a vector of size otherX that is true where item is inside polygon
                   
                switch obj.CoordinateSystem
                    case CoordinateSystems.geodetic
                        dists = distance(obj.Y0, obj.X0, otherY, otherX, obj.RefEllipsoid);
                    case CoordinateSystems.cartesian
                        dists = sqrt((otherY-obj.Y0).^2 + (otherX-obj.X0).^2);
                    otherwise
                        error('unknown coordinate system')
                end
                if ~include_boundary
                    mask = dists < obj.Radius;
                else
                    mask = dists <= obj.Radius;
                end
            end
        end
        
        function finishedMoving(obj, movedObject, deltas)
            centerX = mean(bounds2(movedObject.XData));
            centerY = mean(bounds2(movedObject.YData));
            
            obj.Radius=obj.Radius.* abs(deltas(3)); % NO NEGATIVE RADII
            obj.Points=[centerX,centerY];
        end
          
        function save(obj, filelocation, delimiter)
            persistent savepath
            if ~exist('filelocation','var') || isempty(filelocation)
                if isempty(savepath)
                    savepath = ZmapGlobal.Data.Directories.data;
                end
                [filename,pathname,filteridx]=uiputfile(...
                    {'*.mat','MAT-files (*.mat)';...
                    '*.csv;*.txt;*.dat','ASCII files (*.csv, *.txt, *.dat)'},...
                    'Save Circle',...
                    fullfile(savepath,'zmap_shape.mat'));
                if filteridx==0
                    msg.dbdisp('user cancelled shape save');
                    return
                end
                filelocation=fullfile(pathname,filename);
            end
            [savepath,~,ext] = fileparts(filelocation); 
            if ext==".mat"
                zmap_shape = obj; %#ok<NASGU>
                save(filelocation,'zmap_shape');
            else
                if ~exist('delimiter','var'), delimiter = ',';end
                radiusName = ['Radius[',shortenLengthUnit(obj.RefEllipsoid.LengthUnit),']'];
                tb=table(obj.X0, obj.Y0,obj.Radius,'VariableNames',{'Latitude','Longitude',radiusName});
                writetable(tb,filelocation,'Delimiter',delimiter);
            end
                
        end
    end
    
    methods(Static)
        
        function obj=selectUsingMouse(ax, coord_system, ref_ellipsoid)
            if ~exist('ref_ellipsoid','var')
                ref_ellipsoid = referenceEllipsoid('wgs84',ZmapGlobal.Data.primeCatalog.PositionUnits);
            end
            
            [ss,ok] = selectSegmentUsingMouse(ax,'r', @circ_update);
            delete(findobj(gca,'Tag','tmp_circle_outline'));
            if ~ok
                obj=[];
                return
            end
            obj=ShapeCircle();
            obj.Points=ss.xy1;
            obj.Radius=ss.dist;
            
            function circ_update(stxy, ~, d)
                h=findobj(gca,'Tag','tmp_circle_outline');
                if isempty(h)
                    h=line(nan,nan,'Color','r','DisplayName','Rough Outline','LineWidth',2,'Tag','tmp_circle_outline');
                end
                switch coord_system
                    case  CoordinateSystems.geodetic
                        [lat,lon]=reckon(stxy(2),stxy(1),d,(0:3:360)',ref_ellipsoid);
                        h.XData=lon;
                        h.YData=lat;
                    case CoordinateSystems.cartesian
                        pts = exp(1i*pi*linspace(0,2*pi,120)') .* d;
                        h.XData = real(pts)+ stxy(1); 
                        h.YData = imag(pts) + stxy(2);
                    otherwise
                        error('Unknown coordinate system')
                end
            end
        end
    end
    
            
end
