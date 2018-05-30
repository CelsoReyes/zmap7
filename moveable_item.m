function moveable_item(h, updateFcn, doneFcn, varargin)
    % MOVEABLE_ITEM makes a graphical item (line) draggable
    %
    % MOVEABLE_ITEM( h , updateFcn , doneFcn );  makes the graphics object h draggable, by checking
    % for when it gets a mousedown.  Then, it makes a copy of h, with some aesthetic modifications
    % which is directly moved around the axes while the mouse is down.  As the item is moved around
    % UPDATEFCN will be repeatedly called. It will be provided the handle for the copy and a [x y]
    % delta array.  Upon finishing, the DONEFCN will be called, with the handle to the copy. The
    % copy is then deleted.
    %
    % If the escape key is pressed, then the DONEFCN will not be  called, and the copy will simply
    % be deleted.
    %
    % UPDATEFCN and DONEFCN should should accept two values, like:  
    %
    %    function  myFcn ( handleToCopy , deltas) 
    %        ...
    %    end
    %
    %   where HANDLETOCOPY can be used to access the new x and y positions.  DELTAS is an triple:
    %   [x y s] that contains the offset between the original figure and the copy. S is the scaling
    %   change
    %    
    %
    % MOVEABLE_ITEM(..., name, value [,etc]) allows you to name additional properties for the copy. 
    %   That is, you can specify any of the graphical properties, such as Makrer, LineWidth, etc.
    %
    % MOVEABLE_ITEM('demo') will run a basic example with a couple items on a plot that can be moved
    %	around
    %
    % MOVEABLE_ITEM('noscale',true) disables the scaling abilities
    %
    % example:
    %
    %     h = plot([1;2;3],[2; 1; 3],'o-');
    %     hold on;
    %
    %     % this will be used to show how far we dragged the item
    %     txt = text(2, 2,'','Tag','description');
    %
    %     % this will show how far we dragged the item, and is called as we drag around
    %     updateFcn=@(x,delta) set(txt,'String', sprintf('deltas: [ %g , %g] scale: %g',delta));
    %
    %     % this will move our original plot to the new location, once we let up on the mouse button.
    %     doneFcn=@(x,~)set(h,'XData',x.XData,'YData',x.YData);
    %
    %     MOVEABLE_ITEM(h,updateFcn,doneFcn, 'Marker','+');
    %
    % By Celso G Reyes, PhD  2018
    
    if nargin==1 && (ischar(h) || isstring(h)) && h=="demo"
        demo();
        return
    end
    
    p=inputParser;
    p.addParameter('noscale',false);
    p.addParameter('latitudeaware',false);
    p.addParameter('movepoints',false);
    p.addParameter('addpoints',false);
    p.addParameter('delpoints',false);
    p.addParameter('xtol',0.01);
    p.addParameter('ytol',0.01);
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    
    
    doScaling= ~p.Results.noscale;
    latitudeAware=p.Results.latitudeaware;
    doMovePoints = p.Results.movepoints;
    
    % these will be the attributes for the COPY. 
    % They can be augmented or overridden by providing name,value arguments to this function
    COPY.Tag='itemBeingMoved';
    switch(h.Type)
        case 'line'
            COPY.MarkerEdgeColor = 'r';
            COPY.MarkerFaceColor = 'y';
            COPY.LineWidth = 2;
            COPY.Color = 'g';
            COPY.LineStyle = '--';
        case 'scatter'
            COPY.MarkerEdgeColor = 'r';
            COPY.MarkerFaceColor = 'y';
            COPY.LineWidth = 2;
            COPY.CData= [0 0 1];
        case 'text'
            COPY.color=mean([h.Color;[1 1 1]]);
    end
    
    % modify based on unmatched varargin values
    fn=fieldnames(p.Unmatched);
    for i=1:numel(fn)
        COPY.(fn{i})=p.Unmatched.(fn{i});
    end
    
    ARCLEN=nan; % used when latitude aware
    AZ=nan; %used when latitude aware
    
    % define quick functions that will be used elsewhere
    do_nothing = @(~,~)[];
    if doMovePoints
        getactivepoint=@(src,ev)find(abs(src.XData-ev.IntersectionPoint(1)) <p.Results.xtol &...
            abs(src.YData-ev.IntersectionPoint(2)) < p.Results.ytol);
        if ~isempty(h.UIContextMenu)
            menu_addpoint = findobj(h.UIContextMenu.Children,'Label','add point');
            if isempty(menu_addpoint) && p.Results.addpoints
                uimenu(h.UIContextMenu,'Label','add point',...
                    'callback',@add_point,...
                    'enable','off');
            end
            menu_delpoint = findobj(h.UIContextMenu.Children,'Label','delete point');
            if isempty(menu_delpoint) && p.Results.delpoints
                uimenu(h.UIContextMenu,'Label','delete point',...
                    'callback',{@delete_point,[]},...
                    'enable','off');
            end
        end
    else
        getactivepoint=@(src,ev)[];
    end
    
    % stash the callbacks that we intend to modify
    prev_WindowButtonUpFcn = do_nothing;
    prev_WindowButtonMotionFcn = do_nothing;
    prev_KeyPressFcn = do_nothing;
    prev_WindowScrollWheelFcn = do_nothing;
    
    prev_Marker = h.Marker;
    
    prev_Pointer = 'arrow';
    origin=[nan nan];
    newpos=[nan nan];
    deltas=[0 0];
    scale=1.0;
    pointToMove=[];
    [hX,hY,hMidpt]=deal(nan);
    ax=ancestor(h,'axes');
    fig=ancestor(h,'figure');
    
    if isempty(updateFcn)
        updateFcn=do_nothing;
    end
    
    if isempty(doneFcn)
        doneFcn=do_nothing;
    end
    
    c=gobjects(1);
    prev_axesMode={ax.XLimMode, ax.YLimMode};
    
    % now, the trigger is set. while the Mouse is down (on this item), this item will be interactive
    h.ButtonDownFcn = @startmove;
    
    %% STARTMOVE is activated when the mouse button is held down on the plotted item of interest
    %  while the mouse is down, the item can be:
    %    - moved around (when mouse moves)
    %    - scaled (either by scroll-wheel or by pressing assigned keys.
    
    function startmove(src,ev)
        % create a copy of the item, and move that whenever the mouse moves
        
        pointToMove=getactivepoint(src,ev);
        
        if (fig.SelectionType) ~= "normal"
            %no, don't actually start the move. we're asking for something else
            % here we can modify the UIContext menu before it appears
            if ~ doMovePoints
                set(findobj(h.UIContextMenu.Children,'Label','add point'),'enable','off');
                set(findobj(h.UIContextMenu.Children,'Label','delete point'),'enable','off');
                return;
            end
            if isempty(pointToMove)
                ap = findobj(h.UIContextMenu.Children,'Label','add point');
                set(ap,'enable','on');
                ap.Callback=@(~,~)add_point(ev.IntersectionPoint);
                set(findobj(h.UIContextMenu.Children,'Label','delete point'),'enable','off');
                
            else
                dp = findobj(h.UIContextMenu.Children,'Label','delete point');
                set(findobj(h.UIContextMenu.Children,'Label','add point'),'enable','off');
                set(dp,'enable','on');
                dp.Callback={@delete_point,pointToMove};
            end
            return 
        end
        
        
        scale=1.0;
        deltas=[0 0];
        c=copyobj(h,ax); 
        set(c,COPY);
        prev_Pointer=fig.Pointer;
        fig.Pointer='cross';
        
        origin = ax.CurrentPoint(1,[1 2]);
        newpos = origin;
        prev_WindowButtonUpFcn=fig.WindowButtonUpFcn;
        prev_WindowButtonMotionFcn=fig.WindowButtonMotionFcn;
        
        ax.XLimMode='manual'; 
        ax.YLimMode='manual';
        
        % these values will not change during a move, so set them now.
        hX = h.XData(:);
        hY = h.YData(:);
        hMidpt = middle(h);
        
        % now, deal with context specific stuff.
        if doMovePoints || p.Results.addpoints || p.Results.movepoints
            h.Marker='s';
        end
        
        fig.WindowButtonUpFcn=@endmove;
            
        if ~isempty(pointToMove)
            % we are only moving one point. no translations. no scaling.
            c.Marker='o';
            c.MarkerIndices=pointToMove;
            fig.WindowButtonMotionFcn=@shiftPoint;
            
        else
            if latitudeAware
                % find position of all points relative to center
                [ARCLEN, AZ] = distance([hMidpt(2),hMidpt(1)],[hY,hX]);
            end
            
            fig.WindowButtonMotionFcn=@shiftItem;
            
            if doScaling
                prev_KeyPressFcn=fig.KeyPressFcn;
                fig.KeyPressFcn=@scaleItem;
                prev_WindowScrollWheelFcn=fig.WindowScrollWheelFcn;
                fig.WindowScrollWheelFcn=@scaleItem;
            end
        end
    end
    
  
    %% ENDMOVE is called when the mouse button is released
    % it will:
    %  - restore the axes and figure properties
    %  - activate the doneFcn, with a handle to the copy, along with [ deltas,  scale]
    %  - delete the copy
    %
    % if the ESC key has been pressed, then changes are discarded and doneFcn is not called
    
    function endmove(~,~)
        fig.WindowButtonMotionFcn=prev_WindowButtonMotionFcn;
        fig.WindowButtonUpFcn=prev_WindowButtonUpFcn;
        h.Marker=prev_Marker;
        if doScaling
            fig.KeyPressFcn = prev_KeyPressFcn;
            fig.WindowScrollWheelFcn=prev_WindowScrollWheelFcn;
        end
        
        if fig.CurrentCharacter==char(27) %escape
            % don't update it!
            fig.CurrentCharacter=' ';
        else
            newpos=ax.CurrentPoint(1,[1 2]);
            deltas=newpos - origin;
            doneFcn(c, [deltas,scale]);
        end
        delete(c);
        fig.Pointer=prev_Pointer;
        ax.XLimMode=prev_axesMode{1};
        ax.YLimMode=prev_axesMode{2};
    end
    
    function do_update()
        % this activates the provided update function, which lets the caller deal with changes as
        % they are happening
        updateFcn(c,[deltas,scale]);
    end
    
    %% redrawing routines
    %  these are active only while the mousebutton is held down.
    function do_redraw(n,ps)
        % this recalculates and changes the points for our copied figure.
        if nargin==0
            if latitudeAware
                % to keep same shape, have to use distances & reckoning
                %move center, then recalculate all points.
                [c.YData, c.XData] = reckon(hY + deltas(2),hX + deltas(1), ARCLEN .* scale, AZ);
            else
                
                c.XData = (hX - hMidpt(1)) .* scale + hMidpt(1) + deltas(1);
                c.YData = (hY- hMidpt(2)) .* scale + hMidpt(2) + deltas(2);
            end
        else
            c.YData(n)=ps(2);
            c.XData(n)=ps(1);
        end
        
    end
    
    function update_copy(changeType)
        switch c.Type
            case 'text'
                switch changeType
                    case 'position'
                        c.Position=h.Position + [deltas(1), deltas(2), 0];
                    case 'scale'
                        c.FontSize=h.FontSize .* scale;
                end
            otherwise
                do_redraw();
        end
        
    end
    
    function shiftPoint(~,~)
        newpos=ax.CurrentPoint(1,[1 2]);
        do_redraw(pointToMove,newpos);
    end
        
    function shiftItem(~,~)
        newpos=ax.CurrentPoint(1,[1 2]);
        deltas=newpos - origin;
        update_copy('position');
        do_update();
    end
    
    function scaleItem(~,ev)
        switch ev.EventName
            case 'KeyPress'
                uparrow = char(30);
                dnarrow = char(31);
                esc = char(27);
                switch fig.CurrentCharacter
                    case {'+', uparrow}
                        scale=scale+0.1;
                    case {'-', dnarrow}
                        scale=scale-0.1;
                    case {'1',esc}
                        scale=1;
                    case '2'
                        scale=2;
                    case '*'
                        scale=scale.*1.1;
                    case '/'
                        scale=scale./1.1;
                    case {'h'}
                        scale = scale/2;
                    case {'d'}
                        scale = scale * 2;
                end
            case 'WindowScrollWheel'
                scale = scale - (ev.VerticalScrollCount/20); %reverse scrolling?
        end
        update_copy('scale');
        do_update();
        
    end
        
    function delete_point(~,~,pointToDelete)
        if pointToDelete(1)==1 && numel(pointToDelete)>1
            h.XData(end)=h.XData(2);
            h.XData(1)=[];
        else
            h.XData(pointToDelete)=[];
            h.YData(pointToDelete)=[];
        end
        do_update();
    end
    
    function add_point(intersectionPoint)
        % controlled by RT CLICK choice at PLOT level
        %ds=@(A,B) sqrt((A(:,1)-B(:,1)).^2 + (A(:,2) - B(:,2)).^2);
        %isOnLine=@(A,C) abs(ds(A(1:end-1,:),C) + ds(A(2:end,:),C) - ds(A(1:end-1,:),A(2:end,:)))<.005;
        pointBefore=find(isOnLine([h.XData(:) h.YData(:)], intersectionPoint(1:2)));
        if ~isempty(pointBefore)
            if numel(pointBefore)>1
                warning('multiple segments go through this line')
                return
            end
            newPtX=intersectionPoint(1);
            newPtY=intersectionPoint(2);
            xbefore=h.XData(1:pointBefore);
            xafter=h.XData(pointBefore+1:end);
            ybefore=h.YData(1:pointBefore);
            yafter= h.YData(pointBefore+1:end);
            h.XData=[xbefore(:); newPtX; xafter(:)];
            h.YData=[ybefore(:); newPtY; yafter(:)];
        else
            disp('didn''t find it')
        end
        
        function tf= isOnLine(A, targetPoint)
            % distance calculation
            ds=@(A,B) sqrt((A(:,1)-B(:,1)).^2 + (A(:,2) - B(:,2)).^2);
            
            pt1 = ds(A(1:end-1,:),targetPoint);
            pt2 = ds(A(2:end,:),targetPoint);
            pt3 = ds(A(1:end-1,:),A(2:end,:));
            vals = pt1 + pt2 - pt3;
            disp(vals(:));
            tf=abs(vals)<.005;
        end
    end
    
    %% misc routines
    function midpt = middle(h)
        [Xmin, Xmax]=bounds(h.XData);
        [Ymin, Ymax]=bounds(h.YData);
        midpt = [mean([Xmin, Xmax]), mean([Ymin, Ymax])];
    end
    
    function demo()
        % demonstrate how the movable_item works
        f=figure('Name','moveable_item demo');
        ax = axes(f);
        h = plot(ax, [1;2;3],[2; 1; 3],'o-');
        hold on;
        h2 = plot(ax, [0;4;2],[1.5; 1; 2.5],'o-');
        ax.XLim=[-10 10];
        ax.YLim=[-10 10];
        % this will be used to show how far we dragged the item
        txt = text(mean(ax.XLim), mean(ax.YLim),'unmoved','Tag','description');
    
        % this will show how far we dragged the item, and is called as we drag around
        updateFcn=@(x,delta) set(txt,'String', sprintf('deltas: [ %g , %g] scale[%g]',delta));
    
        % this will move our original plot to the new location, once we let up on the mouse button.
        doneFcn=@(x,~)set(h,'XData',x.XData,'YData',x.YData);
    
        % change the fist plot will also update the deltas message
        moveable_item(h,updateFcn,doneFcn, 'Marker','+');
        
        moveable_item(h2, [], @donedragging, 'noscale',true);
        
        % make the text movable too. and change color. why not?
        moveable_item(txt,[],@(x,delta)set(txt,'Position',x.Position,'Color',rand(1,3),'FontSize',txt.FontSize.*delta(3)));

        function donedragging(movedObj, ~)
            h2.XData=movedObj.XData;
            h2.YData=movedObj.YData;
        end
        
        
        
    end
end
        
    