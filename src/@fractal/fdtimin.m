function fdtimin()
    % Creates the input window for the time parameters needed for the temporal factal dimension calculation.
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    figure_w_normalized_uicontrolunits('Units','pixel','pos',[200 400 550 150 ],'Name',' Time Parameters','visible','off',...
        'NumberTitle','off','Color',color_fbg,'NextPlot','new');
    axis off;
    
    input1 = uicontrol('Style','edit','Position',[.75 .80 .20 .12],...
        'Units','normalized','String',num2str(nev),...
        'callback',@callbackfun_001);
    
    input2 = uicontrol('Style','edit','Position',[.75 .50 .20 .12],...
        'Units','normalized','String',num2str(inc),...
        'Value',1, 'Callback', @callbackfun_002);
    
    
    tx1 = text('Position',[0 .90 0 ], ...
        'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String',' Nb of events in the time window: ');
    
    tx2 = text('Position',[0 .55 0 ], ...
        'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String',' Incrementation step in nb of events: ');
    
    
    
    close_button = uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .20 .20 ],...
        'Units','normalized', 'Callback', @callbackfun_003,'String','Cancel');
    
    go_button = uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .20 .20 ],...
        'Units','normalized',...
        'callback',@callbackfun_004,...
        'String','Go');
    
    
    set(gcf,'visible','on');
    watchoff;
    
    function callbackfun_001(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        nev=str2double(input1.String);
        input1.String=num2str(nev);
    end
    
    function callbackfun_002(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        inc=str2double(input2.String);
        input2.String=num2str(inc);
    end
    
    function callbackfun_003(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        
    end
    
    function callbackfun_004(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        
        gobut = [2];
        org = [1];
        startfd(1,gobut);
    end
    
end
