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
    %   where HANDLETOCOPY can be used to access the new x and y positions.  DELTAS is an [x y] pair
    %   that contains the offset between the original figure and the copy.
    %    
    %
    % MOVEABLE_ITEM(..., name, value [,etc]) allows you to name additional properties for the copy. 
    %   That is, you can specify any of the graphical properties, such as Makrer, LineWidth, etc.
    %
    % MOVEABLE_ITEM('demo') will run a basic example with a couple items on a plot that can be moved
    %	around
    %
    % example:
    %
    %     ax = gca;
    %     h = plot(ax, [1;2;3],[2; 1; 3],'o-');
    %     hold on;
    %
    %     % this will be used to show how far we dragged the item
    %     txt = text(mean(ax.XLim), mean(ax.YLim),'','Tag','description');
    %
    %     % this will show how far we dragged the item, and is called as we drag around
    %     updateFcn=@(x,delta) set(txt,'String', sprintf('deltas: [ %g , %g]',delta));
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
    
    COPY.Tag='itemBeingMoved';
    switch(h.Type)
        case 'line'
            COPY.Marker    = 'o';
            COPY.MarkerEdgeColor = 'r';
            COPY.MarkerFaceColor = 'y';
            COPY.LineWidth = 2;
            COPY.Color = 'g';
            COPY.LineStyle = '--';
        case 'scatter'
            COPY.Marker    = 'o';
            COPY.MarkerEdgeColor = 'r';
            COPY.MarkerFaceColor = 'y';
            COPY.LineWidth = 2;
            COPY.CData= [0 0 1];
        case 'text'
            COPY.color=mean([h.Color;[1 1 1]]);
    end
    
    if ~isempty(varargin)
        p=inputParser;
        p.KeepUnmatched = true;
        p.parse(varargin{:});
        fn=fieldnames(p.Unmatched);
        for i=1:numel(fn)
            COPY.(fn{i})=p.Unmatched.(fn{i});
        end
    end
    
    prev_WindowButtonUpFcn = @do_nothing;
    prev_WindowButtonMotionFcn = @do_nothing;
    prev_Pointer = 'arrow';
    origin=[nan nan];
    newpos=[nan nan];
    ax=ancestor(h,'axes');
    fig=ancestor(h,'figure');
    
    if isempty(updateFcn)
        updateFcn=@do_nothing;
    end
    
    if isempty(doneFcn)
        doneFcn=@do_nothing;
    end
    h.ButtonDownFcn = @startmove;
    c=gobjects(1);
    prev_axesMode={ax.XLimMode, ax.YLimMode};
    
    function startmove(src,ev)
        % create a copy of the item, and move that whenever the mouse moves
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
        
        fig.WindowButtonUpFcn=@endmove;
        fig.WindowButtonMotionFcn=@shiftItem;
    end
    
    function endmove(~,~)
        fig.WindowButtonMotionFcn=prev_WindowButtonMotionFcn;
        fig.WindowButtonUpFcn=prev_WindowButtonUpFcn;
        if fig.CurrentCharacter==char(27) %escape
            % don't update it!
            fig.CurrentCharacter=' ';
        else
            newpos=ax.CurrentPoint(1,[1 2]);
            deltas=newpos - origin;
            doneFcn(c, deltas);
        end
        delete(c);
        fig.Pointer=prev_Pointer;
        ax.XLimMode=prev_axesMode{1};
        ax.YLimMode=prev_axesMode{2};
    end
    
    function shiftItem(src,ev)
        newpos=ax.CurrentPoint(1,[1 2]);
        deltas=newpos - origin;
        switch c.Type
            case 'text'
                c.Position=h.Position + [deltas(1), deltas(2), 0];
            otherwise
                c.XData=h.XData+deltas(1);
                c.YData=h.YData+deltas(2);
        end
        updateFcn(c,deltas)
    end
    
    function do_nothing(~,~)
    end
    
    function demo()
        % demonstrate how the movable_item works
        f=figure('Name','moveable_item demo');
        ax = gca;
        h = plot(ax, [1;2;3],[2; 1; 3],'o-');
        hold on;
        h2 = plot(ax, [0;4;2],[1.5; 1; 2.5],'o-');
        
        % this will be used to show how far we dragged the item
        txt = text(mean(ax.XLim), mean(ax.YLim),'unmoved','Tag','description');
    
        % this will show how far we dragged the item, and is called as we drag around
        updateFcn=@(x,delta) set(txt,'String', sprintf('deltas: [ %g , %g]',delta));
    
        % this will move our original plot to the new location, once we let up on the mouse button.
        doneFcn=@(x,~)set(h,'XData',x.XData,'YData',x.YData);
    
        % change the fist plot will also update the deltas message
        moveable_item(h,updateFcn,doneFcn, 'Marker','+');
        
        moveable_item(h2, [], @donedragging);
        
        % make the text movable too. and change color. why not?
        moveable_item(txt,[],@(x,~)set(txt,'Position',x.Position,'Color',rand(1,3)));
        function donedragging(movedObj, ~)
            h2.XData=movedObj.XData;
            h2.YData=movedObj.YData;
        end
        
        
        
    end
end
        
    