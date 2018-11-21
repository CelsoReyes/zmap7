classdef ShapePolygon < ShapeGeneral
    %ShapePolygon represents a geographical selection of events
    %
    % see also ShapeGeneral, ShapeCircle
    
    
    methods
        function obj=ShapePolygon(shapeType, varargin)
            % ShapePolygon create a shape
            % shapeType is one of 'axes', 'box', 'polygon'}
            % AXES: use current main map axes as a box
            % BOX: define using two corners
            % POLYGON: define with lots of clicks. anything except
            %
            % UNASSIGNED: clear shape
            %
            obj@ShapeGeneral;
            report_this_filefun();
            
            if nargin==0
                return
            end
            
            if ~ismember(lower(shapeType),{'axes','box','rectangle','polygon','unassigned'})
                error('unknown polygon type')
            end
            ax=findobj(gcf,'Tag','mainmap_ax');
            if ~exist('ShapeType','var')
                obj.Type='unassigned';
            end

            % assume we are looking at the right figure already
            set(gcf,'CurrentAxes',ax); % bring up axes of interest.  should be the map, with lat/lon
            
            obj.Type=lower(shapeType);
            
            % hide any existing events
            obj.deemphasizeplot(ax);
            % make existing shape less obvious
            
            
            
            switch obj.Type
                case 'axes' % ShapeGeneral('axes' [, axeshandle])
                    if ~isempty(varargin)
                        lrbt=axis(varargin{1});
                    else
                        lrbt=axis; %gca
                    end
                    obj.Points=[lrbt(1),lrbt(3); lrbt(2),lrbt(3);...
                        lrbt(2),lrbt(4);lrbt(1),lrbt(4);...
                        lrbt(1),lrbt(3)];
                    obj.Type='polygon'; % axes isn't really a type. it's a convenience method for creation
                case 'box' % ShapeGeneral('box' [, [minX maxX minY maxY]])
                    if ~isempty(varargin)
                        lrbt=varargin{1};
                        obj.Points=[lrbt(1),lrbt(3); lrbt(2),lrbt(3);...
                            lrbt(2),lrbt(4);lrbt(1),lrbt(4);...
                            lrbt(1),lrbt(3)];
                    else
                        obj=obj.select_box(obj);
                    end
                    if isempty(obj)
                        return
                    end
                    obj.Type='polygon'; % box isn't really a type. it's a convenience method for creation
                case 'polygon' % ShapeGeneral('polygon', [x1,y1;...;xn,yn]);
                    if ~isempty(varargin)
                        obj.Points=varargin{1};
                        if ~isequal(obj.Points(end,:), obj.Points(1,:))
                            % close the polygon
                        	obj.Points(end+1,:)=obj.Points(1,:);
                        end
                    else
                        obj.select_polygon();
                    end
            end
        end
     
        function summary(obj)
            outline=obj.Outline;
            nPts = size(outline,1);
            if isequal(outline(1,:),outline(end,:))
                nPts=nPts-1;
            end
            line1 = sprintf('Polygon with %d points',nPts);
            line2 = sprintf('Extent has center of (%f lat , %f lon)',obj.Y0,obj.X0);
            line3 = sprintf('Area is approximately %.2f %ss^2',obj.Area, obj.RefEllipsoid.LengthUnit);
            helpdlg(sprintf('%s\n%s\n%s',line1,line2,line3),'Polygon');
        end
        
        function add_shape_specific_context(obj,c)
            % would add additional menu items here
        end
        
        %TODO decide where select_polygon and select_box really belong.
        function select_polygon(obj)
            % select_polygon plots a polygon interactively using the mouse on selected axis
            % usage obj.select_polygon()
            set(gca,'NextPlot','add')
            ax=gca;
            mouse_points_overlay = line(ax,nan,nan,'Marker','o','LineStyle','-',...
                'Color','r',...
                'MarkerSize',5,'LineWidth',2.0,...
                'Tag','mouse_points_overlay',...
                'DisplayName','polygon outline');
            mouse_points_overlay_nub = line(ax,nan,nan,'Marker','+','LineStyle',':',...
                'Color','r',...
                'MarkerSize',5,'LineWidth',2.0,...
                'Tag','mouse_points_overlay',...
                'DisplayName','polygon outline');
            set(gca,'NextPlot','replace')
            
            x=[nan];
            y=[nan];
            f= ancestor(ax,'figure');
            mfn = f.WindowButtonMotionFcn;
            bfn = f.WindowButtonUpFcn;
            f.WindowButtonUpFcn=@mup;
            f.WindowButtonMotionFcn=@mmv;
            f.Pointer='cross';
            f.CurrentCharacter=' ';
            cc=f.CurrentCharacter;
            while f.Pointer=="cross" && (isempty(cc) || cc==' ')
                pause(0.1);
                cc = f.CurrentCharacter;
            end
            f.Pointer='arrow';
            f.WindowButtonUpFcn=bfn;
            f.WindowButtonMotionFcn=mfn;
            x = [x ; x(1)];
            y = [y ; y(1)];      %  closes polygon
            obj.Points=[x,y];
            delete(mouse_points_overlay);
            delete(mouse_points_overlay_nub);
            
            
            function mup(~,ev)
                 cp=ax.CurrentPoint(1,1:2);
                if f.SelectionType=="normal"
                    if isnan(x)
                        x=cp(1);
                        y=cp(2);
                    else
                        x=[x; cp(1)];
                        y=[y; cp(2)];
                    end
                    mouse_points_overlay.XData=x;
                    mouse_points_overlay.YData=y;
                else
                    x=[x;cp(1);x(1)];
                    y=[y;cp(2);y(1)];
                    mouse_points_overlay.XData=x;
                    mouse_points_overlay.YData=y;
                    f.Pointer='arrow';
                end
            end
            
            function mmv(~,~)
                cp=ax.CurrentPoint(1,1:2);
                mouse_points_overlay_nub.XData=[mouse_points_overlay.XData(end);cp(1)];
                mouse_points_overlay_nub.YData=[mouse_points_overlay.YData(end);cp(2)];
            end
                
        end
        function finishedMoving(obj, movedObject, deltas)
            obj.Points=[movedObject.XData(:), movedObject.YData(:)];
            
            notify(obj,'ShapeChanged'); % perhaps not totally necessary
        end
        
          
        function save(obj, filelocation, delimiter)
            persistent savepath
            if ~exist('filelocation','var') || isempty(filelocation)
                if isempty(savepath)
                    savepath = ZmapGlobal.Data.Directories.data;
                end
                [filename,pathname,filteridx]=uiputfile({'*.mat','MAT-files (*.mat)';...
                    '*.csv;*.txt;*.dat','ASCII files (*.csv, *.txt, *.dat)'},...
                    'Save Polygon',...
                    fullfile(savepath,'zmap_shape.mat'));
                if filteridx==0
                    msg.dbdisp('user cancelled shape save');
                    return
                end
                filelocation=fullfile(pathname,filename);
            end
            [savepath,~,ext] = fileparts(filelocation); 
            if ext==".mat"
                zmap_shape=obj;
                save(filelocation,'zmap_shape');
            else
                if ~exist('delimiter','var'), delimiter = ',';end
                tb=table(obj.Lat, obj.Lon,'VariableNames',{'Latitude','Longitude'});
                writetable(tb,filelocation,'Delimiter',delimiter);
            end
                
        end
        
    end
    
    methods(Static)
        function obj = selectPolygonUsingMouse(ax)
        end
        function obj = selectBoxUsingMouse(ax)
          
        end
    end
    
    methods(Access=private)
        
        function [obj,ok]=select_box(obj,varargin)
            ax=gca;
            [ss,ok] = selectSegmentUsingMouse(ax,'r', obj.RefEllipsoid, @box_update);
            h=findobj(ax,'Tag','tmp_box_outline');
            if ~isempty(h)
                x=h.XData;
                y=h.YData;
            end
            set(ancestor(ax,'figure'),'CurrentCharacter',' ');
            delete(findobj(ax,'Tag','tmp_box_outline'));
            if ~ok
                obj=[];
            else
                obj.Points=[x(:),y(:)];
            end
            
            
            function box_update(stxy, edxy,~)
                % called while selecting the box
                h=findobj(gca,'Tag','tmp_box_outline');
                if isempty(h)
                    h=line(nan,nan,'LineStyle','--','Color','r','DisplayName','Rough Outline','LineWidth',2,'Tag','tmp_box_outline');
                end
                h.XData=[stxy(1); stxy(1); edxy(1); edxy(1); stxy(1)] ;
                h.YData=[stxy(2); edxy(2); edxy(2); stxy(2); stxy(2)];
            end
            
        end
    end % private methods
end