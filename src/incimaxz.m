function incimaxz()
    % make another dialog interface and call cin_lta
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    %
    %initial values
    minval = 1.0
    maxval = 4;
    nustep = 10;
    
    
    figure(mess);
    
    set(gcf,'visible','off')
    clf
    
    set(gcf, 'Name','Movie Parameter Input ');
    set(gca,'visible','off');
    set(gcf,'pos',[ZG.welcome_pos 450 250]);
    
    % creates a dialog box to input some parameters
    %
    freq_field2=uicontrol('Style','edit',...
        'Position',[.80 .80 .12 .10],...
        'Units','normalized','String',num2str(minval),...
        'callback',@callbackfun_001);
    
    freq_field=uicontrol('Style','edit',...
        'Position',[.80 .60 .12 .10],...
        'Units','normalized','String',num2str(maxval),...
        'callback',@callbackfun_002);
    
    inp2_field=uicontrol('Style','edit',...
        'Position',[.80 .40 .12 .10],...
        'Units','normalized','String',num2str(nustep),...
        'callback',@callbackfun_003);
    
    close_button=uicontrol('Style','Pushbutton',...
        'Position', [.60 .05 .15 .15 ],...
        'Units','normalized','callback',@callbackfun_004,'String','Cancel');
    
    go_button=uicontrol('Style','Pushbutton',...
        'Position',[.25 .05 .15 .15 ],...
        'Units','normalized',...
        'callback',@callbackfun_005,...
        'String','Go');
    
    txt5 = text(...
        'Position',[0. 0.85 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold' ,...
        'String','Please input minimum LTA window length in years:');
    
    txt1 = text(...
        'Position',[0. 0.65 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold' ,...
        'String','Please input maximum LTA window length in years:');
    
    txt2 = text(...
        'Position',[0. 0.40 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold' ,...
        'String','Please step width in years:');
    
    set(gcf,'visible','on')
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        minval=str2double(freq_field2.String);
        freq_field2.String=num2str(minval);
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        maxval=str2double(freq_field.String);
        freq_field.String=num2str(maxval);
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        nustep=str2double(inp2_field.String);
        inp2_field.String=num2str(nustep);
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        zmapmenu;
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZmapMessageCenter();
        runcimaz;
    end
    
end

function runcimaz() 
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    j = 0;
    it = 20
    minval = minval/days(ZG.bin_dur);
    maxval = maxval/days(ZG.bin_dur);
    [len, ncu] = size(cumuall);
    len = len -2;
    step = nustep;
    
    
    %set up movie axes
    %
    cin_lta
    axes(h1)
    fs_m = get(gcf,'pos');
    
    m = moviein(length(1:step:len-winlen_days));
    
    ma = [];
    mi = [];
    
    
    wai = waitbar(0,'Please wait...')
    set(wai,'Color',[0.8 0.8 0.8],'NumberTitle','off','Name','Movie -Percent done');
    pause(0.1)
    
    for it = minval:step:maxval
        j = j+1;
        cin_maxz
        axes(h1)
        m(:,j) = getframe(h1);
        figure(wai);
        waitbar(it/len)
    end   % for i
    
    close(wai)
    
    % save movie
    %
    clear newmatfile
    
    [newmatfile, newpath] = uiputfile('*.mat', 'Save As');
    
    if length(newpath > 1)
        save([newpath newmatfile])
        showmovi
    else
        showmovi
    end
    
    
end
