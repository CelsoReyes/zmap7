function returnstate = make_editable(f,ax, p)
    % makeEditable
    % create a figure with a line that allows one to add, move, and delete points, as well as translate line
    % and scale.
    %
    % To scale: use mouse wheel
    % To delete a vertex : right click on vertex, and choose "delete point"
    % To add a new vertex : right click on line segment, and choose "add point"
    % To move a vertex : drag the vertex using the left mouse button
    % To move the entire line : drag a segment using the left mouse button.
    %
    % this will modify the figure, axes, and line/scatter callback functions
    %
    %
    % example usage:
    % f=figure
    % ax=axes
    % plot(-10:.5:10,-10:.5:10,'.','color',[.5 .5 .5])
    % hold on
    % p=plot([3;4],[2;3],'-*')
    % make_editable(f,ax,p);
    %  now, scale, translate, add, remove points.
    
    
    dragging=false;
    lastIntersect=[];
    %f=figure;
    %ax=axes;
    %x=[0;1];
    %y=[0;1];
    %p=plot(x,y,'*-');
    p.ButtonDownFcn=@bdown;
    p.UIContextMenu=pointcontext(p);
    f.WindowScrollWheelFcn={@scale,p};
    %f.WindowButtonUpFcn=@mouseup;
    
    function bdown(src,ev)
        
        activepoint=find(abs(src.XData-ev.IntersectionPoint(1)) <0.001 &...
            abs(src.YData-ev.IntersectionPoint(2))<0.001);
        
        f.WindowButtonUpFcn={@mouseup,src,activepoint}; %attach mouseup function to THIS item
        
        if ev.Button==1
            dragging=true;
            if ~isempty(activepoint)
                % drag one point
                f.WindowButtonMotionFcn={@updatePoint,src,activepoint};
            else
                % drag entire series
                xs=[ev.IntersectionPoint(1);ev.IntersectionPoint(1)];
                ys=[ev.IntersectionPoint(2);ev.IntersectionPoint(2)];
                hold on;
                h=plot(xs,ys,'ko:');
                f.WindowButtonMotionFcn={@translateSeries,h};
                f.WindowButtonUpFcn={@endTranslation,src,h}; %attach mouseup function to THIS item
            end
        else
            lastIntersect=ev.IntersectionPoint;
        end
        
        if ev.Button==3 %RIGHT CLICK / CONTEXT
            if ~isempty(activepoint)
                % clicked on actual point
                dph=findobj(src.UIContextMenu,'Label','delete point');
                dph.Callback(3)={activepoint};
                set(findobj(src.UIContextMenu,'Label','add point'),'enable','off')
                set(findobj(src.UIContextMenu,'Label','delete point'),'enable','on')
            else
                % clicked on line segment
                set(findobj(src.UIContextMenu,'Label','add point'),'enable','on')
                set(findobj(src.UIContextMenu,'Label','delete point'),'enable','off')
            end
        end
        
    end
    
    function updatePoint(~,~,target,activepoint)
        cp=ax.CurrentPoint;
        % move this one point
        target.XData(activepoint)=cp(1,1);
        target.YData(activepoint)=cp(1,2);
    end
    
    function translateSeries(~,~,h)
        % move entire line
        cp=ax.CurrentPoint;
        h.XData(end)=cp(1,1);
        h.YData(end)=cp(1,2);
    end
    
    function mouseup(~,~,target,activepoint)
        if ~isempty(target) && dragging
            if isempty(activepoint)
                % move entire line
                %target.XData=target.XData - (lastIntersect(1) - cp(1,1));
                %target.YData=target.YData - (lastIntersect(2) - cp(1,2));
            else
                
            cp=ax.CurrentPoint;
            target.XData(activepoint)=cp(1,1);
            target.YData(activepoint)=cp(1,2);
            dragging=false;
            %activepoint=[];
            f.WindowButtonMotionFcn='';
            end
        end
    end
    
    function endTranslation(~,~,target,h)
        prevax=axis;
        target.XData=target.XData + (diff(h.XData));
        target.YData=target.YData + (diff(h.YData));
        delete(h);
        axis(prevax)
        f.WindowButtonMotionFcn='';
        f.WindowButtonUpFcn='';%{@endTranslation,target,h}; %attach mouseup function to THIS item
    end
    
    function delpoint(~,~, target, activepoint)
        target.XData(activepoint)=[];
        target.YData(activepoint)=[];
    end
    
    function addpoint(~,~,target,activepoint)
        if ~exist('activepoint','var') || isempty(activepoint)
            ds=@(A,B) sqrt((A(:,1)-B(:,1)).^2 + (A(:,2) - B(:,2)).^2);
            isOnLine=@(A,C) abs(ds(A(1:end-1,:),C) + ds(A(2:end,:),C) - ds(A(1:end-1,:),A(2:end,:)))<.001;
            pointBefore=find(isOnLine([target.XData(:) target.YData(:)],lastIntersect(1:2)));
            if ~isempty(pointBefore)
                if numel(pointBefore)>1
                    warning('multiple segments go through this line')
                    return
                end
                newPtX=lastIntersect(1);
                newPtY=lastIntersect(2);
                xbefore=target.XData(1:pointBefore);
                xafter=target.XData(pointBefore+1:end);
                ybefore=target.YData(1:pointBefore);
                yafter= target.YData(pointBefore+1:end);
                target.XData=[xbefore(:); newPtX; xafter(:)];
                target.YData=[ybefore(:); newPtY; yafter(:)];
            else
                disp('didn''t find it')
            end
                
        else
            warning('To add a point, click on a line segment, not a node.')
        end
        % figure out which point!
        
    end
    
    
    function scale(~,ev,targ)
        extent=[min(targ.XData) max(targ.XData) min(targ.YData) max(targ.XData)];
        center=[mean(extent(1:2)), mean(extent(3:4))];
        relX=targ.XData-center(1);
        relY=targ.YData-center(2);
        factor=1.1;
        if ev.VerticalScrollCount>0
            relX=relX .* factor;
            relY=relY .* factor;
        else
            relX=relX ./ factor;
            relY=relY ./ factor;
        end
        prevax=axis;
        targ.XData=relX+center(1);
        targ.YData=relY+center(2);
        axis(prevax);
    end
        
    function c=pointcontext(p)
        c=uicontextmenu;
        uimenu(c,'Label','delete point', 'callback',{@delpoint,p});
        uimenu(c,'Label','add point', 'callback',{@addpoint,p});
    end
    
    function return_state(WBMF)
        % put all the callbacks back!
    end
end
        