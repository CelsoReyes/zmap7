function timeplot(catname)
    % timeplot plots selected events as cummulative # over time
    %
    % Time of events with a Magnitude greater than ZG.big_eq_minmag will
    % be shown on the curve.  Operates on mycat, resets  b  to mycat
    %     ZG.newcat is reset to:
    %                       - "primeCatalog" if either "Back" button or "Close" button is pressed.
    %  
    % Updates:
    % Added callback in op5 for afterschock sequence rate change detection (07.07.03: J. Woessner)
    
    %TOFIX this is affecting the primaryCatalog, instead of the other catalogs.
    
    global statime

    report_this_filefun(mfilename('fullpath'));


    ZG = ZmapGlobal.Data;
    
    
    myFigName='Cumulative Number';
    if isa(catname,'ZmapCatalog')
        mycat=catname;
    else
        mycat=ZG.(catname);
    end
    
    if isempty(mycat)
        zmap_message_center.set_error('No Catalog','timeplot was passed an empty catalog');
        return
    end
    [t0b, teb] = mycat.DateRange() ;
    
    xt=[]; % time series that will be used
    as=[]; % z values, maybe? used by the save callback.
    
    if isempty(ZG.bin_dur) %binning
        ZG.bin_dur = days(1);
    end
    
    cumu2=[]; %predeclare this thing for the callback function
    
    
    % Find out if figure already exists
    
    myfig = findobj('Type','Figure','-and','Name',myFigName);
    % Set up the Cumulative Number window
    
    if isempty(myfig)
        myfig = figure_w_normalized_uicontrolunits( ...
            'Name',myFigName,...
            'NumberTitle','off', ...
            'NextPlot','replace', ...
            'backingstore','on',...
            ...'Visible','off', ...
            'Tag','myfig',...
            'Position',[ 100 100 (ZmapGlobal.Data.map_len - [100 20]) ]);
        
        timeplot_create_menu();
        ZG.hold_state2=false;
        
    end
    fig=figure(myfig);
    
    if ZG.hold_state2
        ht=gca;
        % tdiff=mycat.DateSpan; % added by CR
        [cumu, xt] = histcounts(mycat.Date, t0b: ZG.bin_dur :teb);
        %xt = xt + (xt(2)-xt(1))/2; xt(end)=[]; % convert from edges to centers!
        cumu2 = cumsum(cumu);
        
        
        hold on
        axes(ht)
        tiplot2 = plot(ht,mycat.Date,(1:mycat.Count),'r','LineWidth',2.0);
        
        ds=dbstack;
        if numel(ds)>1
            tiplot2.DisplayName=['from ' ds(2).name];
        end
        
        ZG.hold_state2=false;
        return
    end
    
    delete(findobj(myfig,'Type','Axes'));
    watchon;
    ax=axes(fig);
    
    set(ax,...
        ...'visible','off',...
        'FontSize',ZmapGlobal.Data.fontsz.s,...
        'FontWeight','normal',...
        'LineWidth',1.5,...
        'Box','on',...
        'SortMethod','childorder')
    
    % select big events ( > ZG.big_eq_minmag)
    %
    big = mycat.subset( mycat.Magnitude >= ZG.big_eq_minmag);
    
    %calculate start -end time of overall catalog
    statime=[];
    %[t0b, teb] = ZG.primeCatalog.DateRange() ; % by commenting out , now using passed catalog
    
    tdiff = (teb-t0b)/ZG.bin_dur;
    
    if ZG.bin_dur >= days(1)
        tdiff = round(tdiff);
    end
    
    % calculate cumulative number versus time and bin it
    if ZG.bin_dur >=days(1)
        [cumu, xt] = histcounts(mycat.Date, t0b:ZG.bin_dur:teb);
    else
        [cumu, xt] = histcounts(...
            (mycat.Date-min(mycat.Date)) + ZG.bin_dur,...
            (0: ZG.bin_dur :(tdiff + 2*ZG.bin_dur)));
    end
    cumu2=cumsum(cumu);
    % plot time series
    %
    %set(fig,'PaperPosition',[0.5 0.5 5.5 8.5])
    %rect = [0.25,  0.18, 0.60, 0.70];
    %axes(fig,'position',rect)
    %hold(ax,'on');
    %set(ax,'visible','off')
    
    nu = (1:mycat.Count);
    %nu(mycat.Count) = mycat.Count;  %crash if the count is zero
    
    hold(ax,'on')
    tiplot2 = plot(ax, mycat.Date, nu, 'b', 'LineWidth', 2.0);
    % plot end of data
    pl = plot(ax,teb,mycat.Count,'rs');
    set(pl,'LineWidth',1.0,'MarkerSize',4,...
        'MarkerFaceColor','w','MarkerEdgeColor','r');
    
    pl = plot(ax,[max(mycat.Date),teb],[mycat.Count, mycat.Count],'k:');
    set(pl,'LineWidth',2.0);
    set(ax,'Ylim',[0 mycat.Count*1.05]);
    
    plot_big_events();
    
    add_labels();
    
    % Make the figure visible
    %
    set(ax,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,...
        'LineWidth',1.0,'TickDir','out','Ticklength',[0.02 0.02],...
        'Box','on')
    figure(myfig);
    axes(ax);
    set(myfig,'Visible','on');
    watchoff(myfig);
    
    function plot_big_events()
        % plot big events on curve
        if ZG.bin_dur>=days(1) && ~isempty(big)
            bigQuakeIdx = find(mycat.Magnitude >= ZG.big_eq_minmag);
            hold(ax,'on')
            plot(ax,big.Date, bigQuakeIdx,'hm',...
                'LineWidth',1.0,'MarkerSize',10,...
                'MarkerFaceColor','y','MarkerEdgeColor','k','visible','on')
            stri4 = [];
            for i = 1: big.Count
                s = sprintf('  M=%3.1f',big.Magnitude(i));
                stri4 = [stri4 ; s];
            end
            text(ax,big.Date,bigQuakeIdx,stri4)
            hold(ax,'off')
        end
    end
    
    function add_labels()
        if ZG.bin_dur >= days(1)
            xlabel(ax,'Time in years ','FontSize',ZmapGlobal.Data.fontsz.s)
        else
            statime=mycat.Date(1) - ZG.bin_dur;
            xlabel(ax,['Time in days relative to ',char(statime)],...
                'FontWeight','bold','FontSize',ZG.fontsz.m)
        end
        ylabel(ax,'Cumulative Number ','FontSize',ZG.fontsz.s)
        
        title(ax,['"', mycat.Name, '": Cumulative Earthquakes over time ' newline],'Interpreter','none'); %TOFIX I shouldn't need to use a newline here
        
    end
end
