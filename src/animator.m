function animator(action, function_on_stop)
    global ps1 ps2 plin pli
    % combined and turned into function by Celso G Reyes 2017
    
    report_this_filefun(mfilename('fullpath'));
    
    switch(action)
        case 'start'
            [ps1, ps2, plin, pli] = animator_start(@animator);% ButtonMotion, ButtonUp
            
        case 'move'
            animator_move(ps2, pli, plin)
        case 'stop'
            animator_stop(gcf);
            if ~isempty(function_on_stop)
                function_on_stop('newslice');
            end
    end
    
end

function [ps1, ps2, plin, pli] = animator_start(animatorFun)
    
    % works with current figure
    disp('waiting for button press')
    axis manual;
    hold on
    set(gcf,'Pointer','cross');
    waitforbuttonpress
    point1 = get(gca,'CurrentPoint'); % button down detected
    ps1 = plot(point1(1,1),point1(1,2),'ws');
    
    set(gcf,'WindowButtonMotionFcn',@(~,~) animatorFun('move'));
    set(gcf,'WindowButtonUpFcn',@(~,~) animatorFun('stop'));
    
    point2 = get(gca,'CurrentPoint');
    ps2 = plot(point2(1,1),point2(1,2),'w^');
    plin = [point1(1,1) point1(1,2) ; point2(2,1) point2(2,2)];
    pli = plot(plin(:,1),plin(:,2),'w-');
    set(pli,'LineWidth',2)
end

function animator_move(ps2, pli, plin)
    % animator_move move a point
    currPt=get(gca,'CurrentPoint');
    set(ps2,'XData',currPt(1,1))
    set(ps2,'YData',currPt(1,2))
    set(pli,'XData',[ plin(1,1) currPt(1,1)]);
    set(pli,'YData',[ plin(1,2) currPt(1,2)]);
end
function animator_stop(fig)
    set(fig,'Pointer','arrow');
    set(gcbf,'WindowButtonMotionFcn','')
    set(gcbf,'WindowButtonUpFcn','')
end