function mamovie() 
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    figure(cube);
    
    hm = gcf;
    m = moviein(19,hm);
    
    i = 0;
    
    for j=-180:10:0
        i=i+1;
        view([ j 16+i*2])
        m(:,i) = getframe(hm);
    end
    m(:,i+1) = getframe(hm);
    m(:,i+2) = getframe(hm);
    
    figure(gcf);
    clf
    axis off
    fs2 = get(gcf,'pos');
    set(gca,'pos',[0 0 fs2(3) fs2(4)]);
    set(gca,'visible','on')
    
    movie(m,3,12)
    
    mamo = uicontrol('Units','normal',...
        'Position',[.02 .01 .15 .08],'String','Play ',...
        'callback',@callbackfun_001);
    
    uicontrol('Units','normal',...
        'Position',[.20 .01 .15 .10],'String','Back ',...
        'callback',@callbackfun_002);
    
    uicontrol('Units','normal',...
        'Position',[.0 .93 .10 .06],'String','Print ',...
        'callback',@callbackfun_003)
    
    
    uicontrol('Units','normal',...
        'Position',[.2 .93 .10 .06],'String','Close ',...
        'callback',@callbackfun_004)
    
    uicontrol('Units','normal',...
        'Position',[.4 .93 .10 .06],'String','Info ',...
        'callback',@callbackfun_005)
    
    
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        movie(m,3,12);
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close(cube);
        close(vie);
        ;
        plotala();
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        myprint;
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close(cube);
        close(vie);
        clear m;
        ZmapMessageCenter();
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        zmaphelp(ttlStr,hlpStr1);
    end
    
end
