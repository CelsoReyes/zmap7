classdef ShapePolygon < ShapeGeneral
    %ShapePolygon represents a geographical selection of events
    %
    % see also ShapeGeneral, ShapeCircle
    
    
    methods
        function obj=ShapePolygon(type, varargin)
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
            
            report_this_filefun();
            if nargin==0
                return
            end
            
            if ~ismember(lower(type),{'circle','axes','box','rectangle','polygon','unassigned'})
                error('unknown polygon type')
            end
            ax=findobj(gcf,'Tag','mainmap_ax');
            if ~exist('type','var')
                obj.Type='unassigned';
            end

            % assume we are looking at the right figure already
            set(gcf,'CurrentAxes',ax); % bring up axes of interest.  should be the map, with lat/lon
            
            obj.Type=lower(type);
            ZG=ZmapGlobal.Data;
            
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
                    ZG.selection_shape=obj;
                case 'box' % ShapeGeneral('box' [, [minX maxX minY maxY]])
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
                case 'polygon' % ShapeGeneral('polygon', [x1,y1;...;xn,yn]);
                    if ~isempty(varargin)
                        obj.Points=varargin{1};
                        %TODO check integerity, and make sure last point matches first
                    else
                        obj.select_polygon();
                    end
                    ZG.selection_shape=obj;
            end
            ZmapMessageCenter.update_catalog();
            obj.plot(gca);
            obj.setVisibility('on');
        end
     
        function summary(obj)
            outline=obj.Outline;
            nPts = size(outline,1);
            if isequal(outline(1,:),outline(end,:))
                nPts=nPts-1;
            end
            line1= sprintf('Polygon with %d points',nPts);
            line2= sprintf('Extent has center of (%f lat , %f lon)',obj.Y0,obj.X0);
            line3= sprintf('Area is approximately %.2f km^2',obj.Area);
            helpdlg(sprintf('%s\n%s\n%s',line1,line2,line3),'Polygon');
        end
        
        function add_shape_specific_context(obj,c,ax,changedFcn)
            % would add additional menu items here
        end
        
        %TODO decide where select_polygon and select_box really belong.
        function select_polygon(obj)
            % select_polygon plots a polygon interactively using the mouse on selected axis
            % usage obj.select_polygon()
            hold on
            mouse_points_overlay = line(gca,0,0,'Marker','o','LineStyle','-',...
                'Color','k',...
                'MarkerSize',5,'LineWidth',2.0,...
                'Tag','mouse_points_overlay',...
                'DisplayName','polygon outline');
            hold off
            
            but=1;
            x=[];
            y=[];
            
            while but == 1 || but == 112
                [xi,yi,but] = ginput(1);
                x = [x; xi]; %#ok<AGROW>
                y = [y; yi]; %#ok<AGROW>
                mouse_points_overlay.XData=x;
                mouse_points_overlay.YData=y;
            end
            
            x = [x ; x(1)];
            y = [y ; y(1)];      %  closes polygon
            obj.Points=[x,y];
            delete(mouse_points_overlay);

        end

        function interactive_edit(obj,src,ev,changedFcn)
            % INTERACTIVE_EDIT callback
            % obj.INTERACTIVE_EDIT(src,ev)
            
            shout=findobj(src.Parent.Parent,'Tag','shapeoutline');
            initialShape=copy(obj);
            if obj.AUTO_UPDATE_TIMEPLOT
                make_editable(shout,@()update_shape,@()update_shape,'normal',obj.ScaleWithLatitude);
            else
                make_editable(shout,@()update_shape,[],'normal',obj.ScaleWithLatitude);
            end
            
            %make_editable(shout,@()update_shape);
            function update_shape()
                obj.Points=[shout.XData(:),shout.YData(:)];
                ZG=ZmapGlobal.Data;
                ZG.selection_shape=obj;
                
                if obj.AUTO_UPDATE_TIMEPLOT
                    ShapeGeneral.cb_selectp(src,ev,'inside');
                end
                    
                
                if ~isequal(initialShape,obj)
                    changedFcn(initialShape);
                end
            end
        end
    end
    
    methods(Static)
        
        function submenu=AddPolyMenu(submenu,ZGshape)
            %
            % should write changes to ZG.selection_shape (?)
            %polygonTypes={'axes','box','rectangle','polygon'};
            menuItems={'polyCreateBox',...
                'polyCreateIrregular'};
            
            for j=1:numel(menuItems)
                myitem=menuItems{j};
                
                myhandle=findobj(submenu,'Tag',myitem);
                if isempty(myhandle)
                    myhandle=uimenu(submenu,...
                        'Label',myitem,...
                        'Tag',myitem);
                end
                
                switch myitem % based on Tags that should already be assigned to menu items
                    case 'polyCreateBox'
                        lab='Set Polygon: Box...';
                        set(myhandle,'Label',lab,Futures.MenuSelectedFcn,@(~,~)ShapePolygon('box'));
                    case 'polyCreateIrregular'
                        lab='Set Polygon: Irregular shape...';
                        set(myhandle,'Label',lab,Futures.MenuSelectedFcn,@(~,~)ShapePolygon('polygon'));
                    otherwise
                        error('Tried to set a menu item that doesn''t exist');
                end
                
            end
        end
    end
    
    methods(Access=private)
        
        function obj=select_box(obj,varargin)
            
            disp('enter first corner, or click on desired center and press "S" for square. ESC aborts');
            % MOUSEDOWN: select first corner
            % DRAG: extend rectangle
            fig=gcf;
            ax=gca;
            fWBU=fig.WindowButtonUpFcn;
            fWBM=fig.WindowButtonMotionFcn;
            aBD=ax.ButtonDownFcn;
            
            mpo=[]; 
            boxpoints=[];
            active=false;
            fig.Pointer='Cross';
            [x,y,x2,y2]=deal(nan);
            ax.ButtonDownFcn=@startbox;
            drawnow
            while ~active
                pause(0.01);
            end
            while active
                pause(0.01);
            end
            fig.Pointer='Arrow';
            function startbox(src,ev)
                cp=ax.CurrentPoint(1,[1,2]);
                x=cp(1);y=cp(2);
                key=fig.CurrentCharacter;
                if key==char(27)
                    ax.ButtonDownFcn=abD;
                else
                    mpo=line(gca,[x, x, nan, xlim],[ylim,nan,y,y],'LineStyle','--','Color',[.6 .6 .6],'LineWidth',2.0);
                end
                fig.WindowButtonMotionFcn=@updateBox;
                ax.ButtonDownFcn=@endbox;
                active=true;
            end
                   
            function updateBox(src,ev)
                fig.WindowButtonUpFcn=@endbox;
                if fig.CurrentCharacter==char(27)
                    ax.ButtonDownFcn=aBD;
                    fig.WindowButtonUpFcn=fWBU;
                    fig.WindowButtonMotionFcn=fWBM;
                    active=false;
                    return
                end
                cp=ax.CurrentPoint(1,[1,2]);
                x2=cp(1); y2=cp(2);
                boxpoints=[x,y; x,y2; x2, y2; x2, y; x,y];
                mpo.XData=boxpoints(:,1);
                mpo.YData=boxpoints(:,2);
            end
            
            function endbox(src,ev)
                if strcmp(fig.SelectionType,'open')
                    return
                end
                ax.ButtonDownFcn=aBD;
                fig.WindowButtonUpFcn=fWBU;
                fig.WindowButtonMotionFcn=fWBM;
                if fig.CurrentCharacter==char(27)
                    % escape
                else
                   obj.Points=boxpoints;
                end
                delete(mpo)
                active=false;
            end
        end
    end % private methods
    
end