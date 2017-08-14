function animatorms2(action)

    animator(action,[]);
    global ps1 % first point (one end of transit)
    global ps2 % second point (other end of transit)
    global plin % both points, in 2x2 array
    global pli % plot of line between the two points
    
    switch(action)
        case 'start'
            [ps1, ps2, plin, pli] = animator_start(@animatorms2);% ButtonMotion, ButtonUp
            %{
            disp('waiting for button press')
            axis manual; hold on
            set(gcf,'Pointer','cross');
            waitforbuttonpress
            point1 = get(gca,'CurrentPoint'); % button down detected
            ps1 = plot(point1(1,1),point1(1,2),'ws');
            
            set(gcf,'WindowButtonMotionFcn',@(~,~)animatorms2('move'));
            set(gcf,'WindowButtonUpFcn',@(~,~)animatorms2('stop'));
            
            point2 = get(gca,'CurrentPoint');
            ps2 = plot(point2(1,1),point2(1,2),'w^','era','xor');
            plin = [point1(1,1) point1(1,2) ; point2(2,1) point2(2,2)];
            pli = plot(plin(:,1),plin(:,2),'w-','era','xor');
            set(pli,'LineWidth',2)
            %}
        case 'move'
            animator_move(ps2, pli, plin)
        case 'stop'
            animator_stop(gcf);
    end
    
end