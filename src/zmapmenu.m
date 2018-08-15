function zmapmenu() 
    %  zmapmenu allows the user to establish parameters for zmaps
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    %issue a warning if no grid exist
    if ~exist('cumuall', 'var')
        errordlg('You have to create a grid first!');
        return
    end
    
    % This is the info window text
    %
    ttlStr='The various z-value maps             ';
    hlpStr1= ...
        ['                                                          '
        ' This window allows you to calculate various z-value maps:'
        ' Once you have created a grid you can apply               '
        ' several different statistics to it. See the              '
        ' User Guide for additional information                    '
        '                                                          '
        ' Maxz-LTA: Uses the LTA statistic and calculates a LTA    '
        ' z-value map for each time-step. Only the maximum value   '
        ' for all time at each grid point is finally plotted in the'
        ' map. Thsi allows to find the most outstanding decreases  '
        ' in the entire catalog.                                   '
        ' ANIMATION: Will produce a movie of several z-value maps  '
        ' at differnt times. Either the LTA or AS statistic will be'
        ' used. ! Uses large amounts of memory!                    '
        ' TIMECUT: Will display one z-value map for a specified    '
        ' time, using LTA, AS, Rubberband or Percent.              '
        '                                                          '
        ' ALARM: Will calculate an Alarm cube using LTA or         '
        ' Rubberband. If any z-value (all time and space) exceeds a'
        ' threshold an alarm is declared and plotted as a "o" in   '
        ' cube representing time and space. Will first calculate   '
        ' Histogram of all z-value                                 '
        '                                                          '];
    
    hlpStr2= ...
        ['                                                '
        '                                                '];
    
    
    % make the interface
    %
    
    figure(mess);
    report_this_filefun();
    clf
    in2 ='input';
    set(gcf,'Name','ZMAP Parameters');
    set(gca,'visible','off');
    set(gcf,'Units','points','pos',[200 200 220 350 ])
    
    te = text(0.1,1.08,'You can choose from the \newlinefollowing options:');
    set(te,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
    
    te1 = text(0.15,0.92,'MAXZ ') ;
    set(te1,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','r','FontWeight','bold')
    
    te2 = text(0.15,0.75,'Animation') ;
    set(te2,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','r','FontWeight','bold')
    
    te3 = text(0.15,0.38,'Timecuts') ;
    set(te3,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','r','FontWeight','bold')
    
    LTA_button=uicontrol('BackGroundColor',[0.9 0.9 0.9]','Style','Pushbutton',...
        'Position',[.10 .80 .45 .04 ],...
        'Units','normalized',...
        'callback',@(~,~)diag1,...
        'String','Maxz-LTA ');
    
    LTA3_button=uicontrol('BackGroundColor',[0.9 0.9 0.9]','Style','Pushbutton',...
        'Position',[.10 .65 .45 .04 ],...
        'Units','normalized',...
        'callback',@cb_movie_lta,...
        'String','LTA ');
    
    AS_button=uicontrol('BackGroundColor',[0.9 0.9 0.9]','Style','Pushbutton',...
        'Position',[.10 .58 .45 .04 ],...
        'Units','normalized',...
        'callback',@cb_movie_as,...
        'String','AS ');
    
    uicontrol('BackGroundColor',[0.9 0.9 0.9]','Style','Pushbutton',...
        'Position',[.10 .51 .45 .04 ],...
        'Units','normalized',...
        'callback',@cb_movie_rubberband,...
        'String','RUB ');
    
    
    %MAXZLTAl_button=uicontrol('BackGroundColor',[0.9 0.9 0.9]','Style','Pushbutton',...
    %'Position',[.10 .50 .45 .04 ],...
    %'Units','normalized',...
    %'callback',@callbackfun_005,...
    %'String','MAXZ-LTA');
    
    LTA2_button=uicontrol('BackGroundColor',[0.9 0.9 0.9]','Style','Pushbutton',...
        'Position',[.10 .35 .45 .04 ],...
        'Units','normalized',...
        'callback',@cb_lta,...
        'String','LTA ');
    
    AS2_button=uicontrol('BackGroundColor',[0.9 0.9 0.9]','Style','Pushbutton',...
        'Position',[.10 .28 .45 .04 ],...
        'Units','normalized',...
        'callback',@cb_as,...
        'String','AS ');
    
    per_button=uicontrol('BackGroundColor',[0.9 0.9 0.9]','Style','Pushbutton',...
        'Position',[.10 .20 .45 .04 ],...
        'Units','normalized',...
        'callback',@cb_percent,...
        'String','Percent ');
    
    rub_button=uicontrol('BackGroundColor',[0.9 0.9 0.9]','Style','Pushbutton',...
        'Position',[.10 .12 .45 .04 ],...
        'Units','normalized',...
        'callback',@cb_rubberband,...
        'String','Rubberband');
    
    uicontrol('Style','Pushbutton',...
        'Position',[.70 .01 .25 .08 ],...
        'Units','normalized','Callback',@(~,~)ZmapMessageCenter(),'String','Cancel');
    
    uicontrol('Units','normal',...
        'Position',[.1 .01 .25 .08],'String','Info ',...
        'callback',@cb_info)
    
    uicontrol('BackGroundColor',[0.9 0.9 0.9],'Style','Pushbutton',...
        'Position',[.65 .75 .30 .04 ],...
        'Units','normalized','callback',@cb_alarm,'String','Alarm');
    
    uicontrol('BackGroundColor',[0.9 0.9 0.9],'Style','Pushbutton',...
        'Position',[.65 .65 .30 .04 ],...
        'Units','normalized','callback',@cb_loadcube,'String','Load Cube');
    
    watchoff
    
    function cb_movie_lta(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        in2 = 'input';
        in = 'lta';
        show_mov;
    end
    
    function cb_movie_as(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        in2 = 'input';
        in = 'ast';
        show_mov;
    end
    
    function cb_movie_rubberband(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        in2 = 'input';
        in = 'rub';
        show_mov;
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        incimaxz;
    end
    
    function cb_lta(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        show_map('lta',in2);
    end
    
    function cb_as(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.compare_window_dur = years(0.1);
        show_map('ast',in2, ZG.compare_window_dur);
    end
    
    function cb_percent(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.compare_window_dur = years(0.1);
        show_map('per',in2,ZG.compare_window_dur);
    end
    
    function cb_rubberband(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        show_map('rub',in2);
    end
    
    function cb_info(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        zmaphelp(ttlStr,hlpStr1,hlpStr2);
    end
    
    function cb_alarm(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZmapMessageCenter();
        drawnow;
        incube;
    end
    
    function cb_loadcube(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZmapMessageCenter();
        drawnow;
        loadcube;
    end
    
end
