function cllta(var1)
    %cllta.m                             A.Allmann
    %function to calculate the LTA-function of a givenn graph
    %calculates a z-value useing a given window length winlen_days
    %operates on ZG.ttcat
    %
    %
    global xt cumu cumu2 pyy
    global file1 freq_field freq_slider par5
    ZG=ZmapGlobal.Data;
    replaceMainCatalog(ZG.newt2);
    
    % initial values
    %
    max_freq = 20;
    min_freq = days(par5);
    if var1==1                       %default
        winlen_days = 13*par5            % for bin of 28 days, winlen_days = 13 is about 1 year
        
    elseif var1==2
        winlen_days = round(ZG.compare_window_dur_v3/days(par5));
        
        if (winlen_days<min_freq)
            winlen_days=min_freq;
        end
        if (winlen_days>max_freq)
            winlen_days=max_freq;
        end
        pause(0.1)
        set(freq_field,'String',num2str(years(ZG.compare_window_dur_v3)));
        set(freq_slider,'Value',years(ZG.compare_window_dur_v3));
    end
    
    [t0b, teb] = ZG.primeCatalog.DateRange() ;
    n = ZG.primeCatalog.Count;
    tdiff = round((teb - t0b)/days(par5));
    ZG.compare_window_dur_v3 = days(winlen_days*days(par5));
    
    pause(0.1)
    %
    % make the interface
    %
    clf reset
    orient tall
    rect = [0.2,  0.25, 0.65, 0.70];
    axes('position',rect)
    str2 = [file1];
    title(str2)
    set(gcf,'Units','normalized');
    
    freq_field=uicontrol('Style','edit',...
        'Position',[.40 .00 .12 .06],...
        'Units','normalized','String',num2str(years(ZG.compare_window_dur_v3)),...
        'callback',@callbackfun_001);
    
    freq_slider=uicontrol('BackGroundColor',[ 0.8 0.8 0.8],'Style','slider',...
        'Position',[.30 .10 .45 .06],...
        'Units','normalized','Value',years(ZG.compare_window_dur_v3),'Max',max_freq,'Min',min_freq,...
        'callback',@callbackfun_002);
    
    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.9 .30 .10 .05],...
        'Units','normalized','callback',@callbackfun_003,'String','Close');
    
    %uicontrol('Units','normal','Position',[.9 .90 .10 .05],'String','Print ', 'callback',@callbackfun_004)
    
    %uicontrol('Units','normal','Position',[.9 .80 .10 .05],'String','Save', 'callback',@callbackfun_005)
    
    uicontrol('Units','normal','Position',[.9 .70 .10 .05],'String','Back ', 'callback',@callbackfun_006)
    
    uicontrol('Units','normal','Position',[.9 .60 .10 .05],'String','Info ', 'callback',@callbackfun_007)
    
    
    
    %
    % calculate the lta value
    %
    ncu=length(xt);
    lta=zeros(1,ncu);
    winlen_days=round(ZG.compare_window_dur_v3/ZG.bin_dur);
    %
    %  calculated mean, var etc
    %
    for i = 1:tdiff-winlen_days
        mean1 = mean(cumu(1:ncu));
        mean2 = mean(cumu(i:i+winlen_days));
        var1 = cov(cumu(1:ncu));
        var2 = cov(cumu(i:i+winlen_days));
        lta(i+round(winlen_days/2)) = (mean1 - mean2)/(sqrt(var1/ncu+var2/(winlen_days)));
    end     % for i
    
    %
    % plot  the data
    %
    set(gca,'NextPlot','replace')
    pyy = plotyy(xt,cumu2,'ob',xt,lta,'r',[0 0 0 NaN NaN NaN NaN min(lta)*3-1 max(lta*3)+1  ]);
    
    xlabel('Time in [years]')
    ylabel('Cumulative Number')
    str2 = ['LTA of ' file1];
    title(str2)
    
    y2label('z-value')
    grid
    
    
    drawnow;
    
    
    
    function callbackfun_001(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.compare_window_dur_v3=years(str2double(mysrc.String));
        delete(pyy);
        cllta(2);
    end
    
    function callbackfun_002(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.compare_window_dur_v3=years(mysrc.Value);
        delete(pyy);
        cllta(2);
    end
    
    function callbackfun_003(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        pyy=[];
    end
    
    function callbackfun_004(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        print;
    end
    
    function callbackfun_005(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        sav_lta;
    end
    
    function callbackfun_006(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        clf;
        cltiplot(3);
    end
    
    function callbackfun_007(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        clinfo(5);
    end
end
