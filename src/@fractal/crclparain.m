function crclparain() 
    % Creates the input window for the parameters of the factal dimension calculation.
    % Called from circlefd.m.
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    figure_w_normalized_uicontrolunits('Units','pixel','pos',[200 400 550 210 ],'Name','Parameters','visible','off',...
        'NumberTitle','off','Color',color_fbg,'NextPlot','new');
    axis off;
    
    
    input1 = uicontrol('Style','popupmenu','Position',[.75 .77 .23 .09],...
        'Units','normalized','String','Automatic Range|Manual Fixed Range',...
        'Value',1,'callback',@callbackfun_001);
    
    input2 = uicontrol('Style','edit','Position',[.34 .51 .10 .09],...
        'Units','normalized','String',num2str(radm), 'enable', 'off',...
        'Value',1,'callback',@callbackfun_002);
    
    input3 = uicontrol('Style','edit','Position',[.75 .51 .10 .09],...
        'Units','normalized','String',num2str(rasm), 'enable', 'off',...
        'Value',1,'callback',@callbackfun_003);
    
    input4 = uicontrol('Style','edit','Position',[.75 .34 .10 .09],...
        'Units','normalized','String',num2str(ra),'enable', 'off',...
        'Value',1,'callback',@callbackfun_004);
    
    
    
    tx1 = text('Position',[0 .87 0 ], ...
        'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String',' Distance range within which D is computed: ');
    
    tx2 = text('Position',[0 .55 0], ...
        'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String','Minimum value: ', 'color', 'w');
    
    tx3 = text('Position',[.52 .55 0], ...
        'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String','Maximum value: ', 'color', 'w');
    
    tx4 = text('Position',[.41 .55 0], ...
        'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String','km', 'color', 'w');
    
    tx5 = text('Position',[.94 .55 0], ...
        'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String','km', 'color', 'w');
    
    tx6 = text('Position',[0 .34 0], ...
        'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String','Radius of the sampling sphere:', 'color', 'w');
    
    actradi;
    
    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .20 .15 ],...
        'Units','normalized','callback',@callbackfun_005,'String','Cancel');
    
    go_button=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .20 .15 ],...
        'Units','normalized',...
        'callback',@callbackfun_006,...
        'String','Go');
    
    
    set(gcf,'visible','on');
    watchoff;
    
    function callbackfun_001(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        range=(get(input1,'Value'));
        input1.Value=range;
        actrange(range);
    end
    
    function callbackfun_002(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        radm=str2double(input2.String);
        input2.String= num2str(radm);
    end
    
    function callbackfun_003(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        rasm=str2double(input3.String);
        input3.String= num2str(rasm);
    end
    
    function callbackfun_004(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ra=str2double(input4.String);
        input4.String= num2str(ra);
    end
    
    function callbackfun_005(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        ZmapMessageCenter.set_info(' ',' ');
        
    end
    
    function callbackfun_006(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        
        circlefd;
    end
    
end
