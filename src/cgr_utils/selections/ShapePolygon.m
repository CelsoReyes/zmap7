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
            
            report_this_filefun(mfilename('fullpath'));
            if nargin==0
                return
            end
            
            if ~ismember(lower(type),{'circle','axes','box','rectangle','polygon','unassigned'})
                error('unknown polygon type')
            end
            ax=mainmap('axes');
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
            line1= sprintf('Polygon with %d points',size(obj.Outline,1));
            line2= sprintf('Extent has center of (%f lat , %f lon)',obj.Y0,obj.X0);
            line3= sprintf('Area is approximately %.2f km^2',obj.Area);
            helpdlg(sprintf('%s\n%s\n%s',line1,line2,line3),'Polygon');
        end
        
        function add_shape_specific_context(obj,c,ax)
            % would add additional menu items here
        end
        
        %TODO decide where select_polygon and select_box really belong.
        function select_polygon(obj)
            % select_polygon plots a polygon interactively using the mouse on selected axis
            % usage obj.select_polygon()
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
                    changedFcn(initialShape,obj.copy());
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
                        set(myhandle,'Label',lab,'Callback',@(~,~)ShapePolygon('box'));
                    case 'polyCreateIrregular'
                        lab='Set Polygon: Irregular shape...';
                        set(myhandle,'Label',lab,'Callback',@(~,~)ShapePolygon('polygon'));
                    otherwise
                        error('Tried to set a menu item that doesn''t exist');
                end
                
                if j==1
                    set(myhandle,'Separator','on');
                end
            end
        end
    end
    
    methods(Access=private)
        
        function obj=select_box(obj,varargin)
            
            disp('enter first corner, or click on desired center and press "S" for square. ESC aborts');
            % MOUSEDOWN: select first corner
            % DRAG: extend rectangle
            
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