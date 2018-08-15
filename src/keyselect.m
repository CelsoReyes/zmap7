function keyselect() 
    %  This .m file selects the earthquakes within a polygon
    %  and plots them. Sets "primeCatalog" equal to the catalogue produced after the
    %  general parameter selection. Operates on "storedcat", replaces "primeCatalog"
    %  with new data and makes "primeCatalog" equal to ZG.newcat
    %                                           Alexander Allmann
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    
    ZG.newt2 = ZmapCatalog();   % reset catalogue variables
    %a=storedcat;              % uses the catalogue with the pre-selected main
    % general parameters
    ZG.newcat = ZG.primeCatalog;
    
    xcordinate=0;
    ycordinate=0;
    %axes(h1)
    x = [];
    y = [];
    
    n = 0;
    
    
    keysel_fig = figure;
    set(keysel_fig,'Tag','keysel_fig','Visible','off',...
        'Name','Polygon Input Parameters','Position', [500 400 230 200],...
        'Menu','none','DefaultUiControlunits','normalized','NumberTitle','off');
    keysel_ax=axes('Parent',keysel_fig,'Visible','off','tag','keysel_ax');
    keysel_fig.Visible='on'
    %creates dialog box to input some parameters
    %
    
    % x coord edit field
    inp1_field=uicontrol('Style','edit',...
        'Position',[.60 .60 .25 .10],...
        'Units','normalized',...
        'String',num2str(xcordinate),...
        'callback',@callbackfun_001);
    % y coord edit field
    inp2_field=uicontrol('Style','edit',...
        'Position',[.60 .40 .25 .10],...
        'Units','normalized','String',num2str(ycordinate),...
        'callback',@callbackfun_002);
    
    % more button
    more_button=uicontrol('Style','Pushbutton',...
        'Position', [.54 .04 .22 .20],...
        'Units','normalized',...
        'callback',@callbackfun_003,...
        'String','More');
    % last button
    last_button=uicontrol('Style','Pushbutton',...
        'Position',[.33 .04 .22 .20],...
        'Units','normalized',...
        'callback',@callbackfun_004,...
        'String','Last');
    
    % mouse button
    mouse_button=uicontrol('Style','Pushbutton',...
        'Position',[.03 .04 .30 .20],...
        'Units','normalized',...
        'callback',@callbackfun_005,...
        'String','Mouse');
    
    % load button
    load_button=uicontrol('Style','Pushbutton',...
        'Position',[.75 .04 .22 .20],...
        'Units','normalized',...
        'callback',@callbackfun_006,...
        'String','Load');
    
    %cancel button
    cancel_button=uicontrol('Style','Pushbutton',...
        'Position',[.05 .78 .30 .20],...
        'Units','normalized',...
        'callback',@callbackfun_007,...
        'String','Cancel');
    
    txt1 = text(...
        'Position',[0. 0.65 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m,...
        'FontWeight','bold',...
        'String','Longitude:');
    txt2 = text(...
        'Position',[0. 0.45 0 ],...
        'FontWeight','bold',...
        'FontSize',ZmapGlobal.Data.fontsz.m,...
        'String','Latitude:');
    
    
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        xcordinate=str2double(inp1_field.String);
        inp1_field.String=num2str(xcordinate);
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ycordinate=str2double(inp2_field.String);
        inp2_field.String=num2str(ycordinate);
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        set(mouse_button,'visible','off');
        but = 1;
        pickpo;
        set(load_button,'visible','off');
        delete(keysel_fig);
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        but = 2;
        pickpo;
        delete(keysel_fig);
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        selectp;
        delete(keysel_fig);
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        but=3;
        pickpo;
        delete(keysel_fig);
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZmapMessageCenter();
        
        delete(keysel_fig);
    end
    
end
