function animator2(action)
    global ps1 ps2 plin pli
    % combined and turned into function by Celso G Reyes 2017
    animator(action, @slicemap);
    
    report_this_filefun(mfilename('fullpath'));
    
    switch(action)
        case 'start'
            [ps1, ps2, plin, pli] = animator_start(@animator2);% ButtonMotion, ButtonUp
            
        case 'move'
            animator_move(ps2, pli, plin)
        case 'stop'
            animator_stop(gcf);
            slicemap('newslice');
            
    end
    
end
