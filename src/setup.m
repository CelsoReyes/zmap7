function setup()
    %  This subroutine "setup.m" allows the user to setup
    %  the earthquake datafile, overlaying faults, mainshocks
    % turned into function by Celso G Reyes 2017
    
    report_this_filefun(mfilename('fullpath'));
    ZG=ZmapGlobal.Data;
    % make the interface
    %
    
    if ~exist('ZG.bin_days', 'var')
        ZG.bin_days = days(14);
    end
    
    % This is the info window text
    %
    ttlStr='ZMAP Data Import                               ';
    hlpStr1= ...
        ['                                                '
        'For fast and easy data access ZMAP uses the     '
        'internal matlab data format (*.mat) data files).'
        'Earthquakes catalogs as well as additional      '
        'information must first be loaded as and ASCII   '
        'file. Once this data is saved as a matlab *.mat '
        'file it can be reloaded directly into ZMAP.     '
        '                                                '
        'Several Data types can be integrated:           '
        ' EARTHQUAKE CATALOGS: You will need to supply   '
        ' formated ASCII file (e.g hypoellispe format) or'
        ' an ASCII files with the following information  '
        ' in columns sperated by at least one blanck:    '
        '                                                '
        '  lon lat year month day mag depth hour min     '
        '                                                '
        'Example: (California)                           '
        '-116.86 34.35 86 03 27 4.2 15.0 10 25           '
        'Please note the minus sign for W longitudes!    '
        'You chose the magnitude that you would like to  '
        'work with. Zmap works with decimales (0-100) in '
        'the minute position, not with degrees (0-60)!   '];
    hlpStr2= ...
        ['COASTLINE DATA: ZMAP will plot coastlines and/or'
        'state borders on maps. You need to supply an    '
        'ascii datafile with columns seperated by at     '
        'least one blanck:                               '
        'lon  lat  (e.g. -116.86  34.34)                 '
        'A "lift pen" command can be initiade by the line'
        'Inf  Inf (Therefore you avoid connecting islands'
        ' etc.)                                          '
        '                                                '
        'FAULTS DATA: Faults data is imported in the same'
        'way as coastlines.                              '
        'SYMBOLS: Two type of symbols can be displayed on'
        'the seismicity maps: (1) Epicenters of large    '
        'earthquakes as + signs and (2) main faults as   '
        'thick lines. The input format is identical to   '
        'the above - note that you can seperate multiple '
        'main faults by "Inf Inf".                       ' ];
    hlpStr3= ...
        ['The Clear button will remove existing data      '
        'or overlay symbols.                             '
        '                                                ' ];
    % Find out of figure already exists
    %
    [existFlag,figNumber]=figure_exists('Import Data into ZMAP',1);
    newMapWindowFlag=~existFlag;
    
    
    % Set up the setup window Enviroment
    %
    if newMapWindowFlag
        loda = figure_w_normalized_uicontrolunits( ...
            'Name','Import Data into ZMAP',...
            'NumberTitle','off', ...
            'MenuBar','none', ...
            'NextPlot','new', ...
            'Visible','off', ...
            'Position',[ (ZG.fipo(3:4) - [500 400]) (ZG.map_len - [100 100]) ]);
        
        te = text(0.1,0.99,'Load all the available data as ASCII files.\newlinePress <Save> to save the new catalog \newlineafter you have loaded all ASCII files!');
        set(te,'FontSize',ZG.fontsz.m);
        
        te1 = text(0.40,0.80,'Data ') ;
        set(te1,'FontSize',ZG.fontsz.m,'Color','r','FontWeight','bold')
        
        te2 = text(0.25,0.58,'Overlay Symbols') ;
        set(te2,'FontSize',ZG.fontsz.m,'Color','r','FontWeight','bold');
        
        uicontrol('BackGroundColor',[0.8 0.8 0.8]','Style','Pushbutton',...
            'Position',[.01 .65 .30 .08 ],...
            'Units','normalized',...
            'callback',@loaddb_callback,...
            'String','EQ Datafile');
        
        uicontrol('BackGroundColor',[0.8 0.8 0.8]','Style','Pushbutton',...
            'Position',[.35 .65 .35 .08 ],...
            'Units','normalized',...
            'callback',@loaddb_focal_callback,...
            'String','EQ Datafile (+focal)');
        
        uicontrol('BackGroundColor',[0.8 0.8 0.8]','Style','Pushbutton',...
            'Position',[.80 .65 .15 .08 ],...
            'Units','normalized',...
            'callback',@clearevents_callback,...
            'String','Clear ');
        
        
        uicontrol('BackGroundColor',[0.8 0.8 0.8]','Style','Pushbutton',...
            'Position',[.25 .45 .45 .08 ],...
            'Units','normalized',...
            'callback',@loadmainshocks_callback,...
            'String','Mainshocks ');
        uicontrol('BackGroundColor',[0.8 0.8 0.8]','Style','Pushbutton',...
            'Position',[.75 .45 .15 .08 ],...
            'Units','normalized',...
            'callback',@clearmainshocks_callback,...
            'String','Clear ');
        
        
        uicontrol('BackGroundColor',[0.8 0.8 0.8]','Style','Pushbutton',...
            'Position',[.25 .35 .45 .08 ],...
            'Units','normalized',...
            'callback',@loadfaults_callback,...
            'String','Faults ');
        uicontrol('BackGroundColor',[0.8 0.8 0.8]','Style','Pushbutton',...
            'Position',[.75 .35 .15 .08 ],...
            'Units','normalized',...
            'callback',@clearfaults_callback,...
            'String','Clear ');
        
        
        uicontrol('BackGroundColor',[0.8 0.8 0.8]','Style','Pushbutton',...
            'Position',[.25 .25 .45 .08 ],...
            'Units','normalized',...
            'callback',@load_mainrupt_callback,...
            'String','Mainrupture');
        uicontrol('BackGroundColor',[0.8 0.8 0.8]','Style','Pushbutton',...
            'Position',[.75 .25 .15 .08 ],...
            'Units','normalized',...
            'callback',@clear_mainrupt_callback,...
            'String','Clear ');
        
        
        uicontrol('BackGroundColor',[0.8 0.8 0.8]','Style','Pushbutton',...
            'Position',[.25 .15 .45 .08 ],...
            'Units','normalized',...
            'callback',@loadcoast_callback,...
            'String','Coastline/Borders');
        uicontrol('BackGroundColor',[0.8 0.8 0.8]','Style','Pushbutton',...
            'Position',[.75 .15 .15 .08 ],...
            'Units','normalized',...
            'callback',@clearcoast_callback,...
            'String','Clear ');
        
        
        uicontrol('Style','Pushbutton',...
            'Position',[.75 .03 .15 .08 ],...
            'Units','normalized','callback',@close_callback,'String','cancel');
        
        uicontrol('Style','Pushbutton',...
            'Position',[.05 .03 .25 .08 ],...
            'Units','normalized',...
            'callback',@save_callback,...
            'String','Save as *.mat');
        
      
        uicontrol('Style','Pushbutton',...
            'Position',[.45 .03 .15 .08 ],...
            'Units','normalized',...
            'callback',@info_callback,...
            'String','Info');
        
        watchoff
        
    end   %if figure exist
    figure(loda)
    set(gca,'box','off',...
        'SortMethod','childorder','TickDir','out','FontWeight','bold',...
        'visible','off','FontSize',ZG.fontsz.m,'Linewidth',1.2)
    
    set(loda,'Visible','on');
    
    function loaddb_callback(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        in = 'noini';
        in2 = 1;
        dataimpo;
    end
    
    function loaddb_focal_callback(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        loadasci('fo','of');
    end
    
    function clearevents_callback(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        a = [];
        update(mainmap());
    end
    
    function loadmainshocks_callback(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        loadasci('ma','of');
    end
    
    function clearmainshocks_callback(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        main  = [];
        update(mainmap());
    end
    
    function loadfaults_callback(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        loadasci('fa','of');
    end
    
    function clearfaults_callback(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        faults  = [];
        update(mainmap());
    end
    
    function load_mainrupt_callback(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        loadasci('mf','of');
    end
    
    function clear_mainrupt_callback(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        mainfault  = [];
        update(mainmap());
    end
    
    function loadcoast_callback(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        loadasci('co','of');
    end
    
    function clearcoast_callback(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        coastline  = [];
        update(mainmap());
    end
    
    function close_callback(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        zmap_message_center();
    end
    
    function save_callback(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        zmap_message_center.set_info('Save Data','  ');
        think;
        [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.data_dir, '*.mat'), 'Filename?');
        save(fullfile(path1, file1),'a','faults','mainfault','coastline','main','infstri');
        eval(sapa) ;
        close(loda);
        update(mainmap());
        done
    end
    
    function info_callback(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        zmaphelp(ttlStr,hlpStr1,hlpStr2,hlpStr3);
    end
    
end
