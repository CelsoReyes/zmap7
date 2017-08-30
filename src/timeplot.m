function timeplot(mycat, nosort)
    % This .m file "timeplot" plots the events select by "circle"
    % or by other selection button as a cummultive number versus
    % time plot in window 2.
    % Time of events with a Magnitude greater than ZG.big_eq_minmag will
    % be shown on the curve.  Operates on mycat, resets  b  to mycat
    %     ZG.newcat is reset to:
    %                       - "a" if either "Back" button or "Close" button is pressed.
    %                       - mycat if "Save as Newcat" button is pressed.
    %
    
    
    % Updates:
    % Added callback in op5 for afterschock sequence rate change detection (07.07.03: J. Woessner)
    
    report_this_filefun(mfilename('fullpath'));
    myFigName='Cumulative Number';
    myFigFinder=@() findobj('Type','Figure','-and','Name',myFigName);
    
    global statime
    global selt
    
    ZG = ZmapGlobal.Data;
    if ~exist('xt','var')
        xt=[]; % time series that will be used
    end
    if ~exist('as','var')
        as=[]; % z values, maybe? used by the save callback.
    end
    
    if isempty(ZG.bin_days) %binning
        ZG.bin_days = days(1);
    end
    bin_days = days(ZG.bin_days);
    assert(isnumeric(bin_days));
    
    zmap_message_center.set_info(' ','Plotting cumulative number plot...');
    
    if ~exist('nosort','var')
        nosort = 'of'  ;
    end
    
    if strcmpi(nosort,'of')
        mycat.sort('Date');
    else  % f
        if t3>t2
            % logic does not make sense within ZmapCatalog.
            error('this doesn''t make sense');
        end
        
    end
    
    cumu2=[]; %predeclare this thing for the callback function
    
    think
    
    % This is the info window text
    %
    ttlStr='The Cumulative Number Window                  ';
    hlpStr1= ...
        ['                                                     '
        ' This window displays the seismicity in the sel-     '
        ' ected area as a cumulative number plot.             '
        ' Options from the Tools menu:                        '
        ' Cuts in magnitude and  depth: Opens input para-     '
        '    meter window                                     '
        ' Decluster the catalog: Will ask for declustering    '
        '     input parameter and decluster the catalog.      '
        ' AS(t): Evaluates significance of seismicity rate    '
        '      changes using the AS(t) function. See the      '
        '      Users Guide for details                        '
        ' LTA(t), Rubberband: dito                            '
        ' Overlay another curve (hold): Allows you to plot    '
        '       one or several more curves in the same plot.  '
        '       select "Overlay..." and then selext a new     '
        '       subset of data in the map window              '
        ' Compare two rates: start a comparison and moddeling '
        '       of two seimicity rates based on the assumption'
        '       of a constant b-value. Will calculate         '
        '       Magnitude Signature. Will ask you for four    '
        '       times.                                        '
        '                                                     '];
    hlpStr2= ...
        ['                                                      '
        ' b-value estimation:    just that                     '
        ' p-value plot: Lets you estimate the p-value of an    '
        ' aftershock sequence.                                 '
        ' Save cumulative number cure: Will save the curve in  '
        '        an ASCII file                                 '
        '                                                      '
        ' The "Keep as newcat" button in the lower right corner'
        ' will make the currently selected subset of eartquakes'
        ' in space, magnitude and depth the current one. This  '
        ' will also redraw the Map window!                     '
        '                                                      '
        ' The "Back" button will plot the original cumulative  '
        ' number curve without statistics again.               '
        '                                                      '];
    
    
    % Find out if figure already exists
    
    cum = myFigFinder();
    % Set up the Cumulative Number window
    
    if isempty(cum)
        cum = figure_w_normalized_uicontrolunits( ...
            'Name','Cumulative Number',...
            'NumberTitle','off', ...
            'NextPlot','replace', ...
            'backingstore','on',...
            'Visible','off', ...
            'Tag','cum',...
            'Position',[ 100 100 (ZmapGlobal.Data.map_len - [100 20]) ]);
        
        
        
        selt='in';
        create_my_menu();
        
        pstring=['global freq_field1 freq_field2 freq_field3 freq_field4 freq_field5 tmp1 tmp2 tmp3 tmp4 tmm magn hpndl1 ctiplo mtpl ttcat;ttcat=mycat;'];
        ptstring=[pstring ' cltipval(2);'];
        pmstring=[pstring ' cltipval(1);'];
        
        uicontrol('Units','normal','Position',[.0 .0 .1 .05],...
            'String','Reset',...
            'callback',@cb_resetcat,...
            'tooltip','Resets the catalog to the original selection')
        
        uicontrol('Units','normal','Position',[.70 .0 .3 .05],...
            'String','Keep as newcat',...
            'callback',@cb_keep,...
            'tooltip','Plots this subset in the map window')
        
        ZG.hold_state2=false;
        
    end
    
    if ZG.hold_state2
        tdiff=max(mycat.Date) - min(mycat.Date); % added by CR
        cumu = 0:1:(tdiff/days(ZG.bin_days))+2;
        cumu2 = 0:1:(tdiff/days(ZG.bin_days))-1;
        cumu = cumu * 0;
        cumu2 = cumu2 * 0;
        [cumu, xt] = hist(mycat.Date,(ZG.t0b:days(ZG.bin_days):ZG.teb));
        cumu2 = cumsum(cumu);
        
        
        hold on
        axes(ht)
        tiplot2 = plot(mycat.Date,(1:mycat.Count),'r');
        set(tiplot2,'LineWidth',2.0)
        
        
        ZG.hold_state2=false;
        return
    end
    
    fig=figure(cum);
    delete(findobj(cum,'Type','Axes'));
    % delete(sicum)
    ax=axes(fig);
    hold off
    watchon;
    
    set(ax,'visible','off',...
        'FontSize',ZmapGlobal.Data.fontsz.s,...
        'FontWeight','normal',...
        'LineWidth',1.5,...
        'Box','on',...
        'SortMethod','childorder')
    
    if isempty(ZG.newcat)
        ZG.newcat =ZG.a;
    end
    
    % select big events ( > ZG.big_eq_minmag)
    %
    l = mycat.Magnitude > ZG.big_eq_minmag;
    big = mycat.subset(l);
    %calculate start -end time of overall catalog
    statime=[];
    par2=bin_days;
    t0b = min(ZG.a.Date);
    teb = max(ZG.a.Date);
    ttdif=(teb - t0b); % days
    if ttdif>10                 %select bin length respective to time in catalog
        %bin_days = ceil(ttdif/300);
    elseif ttdif<=10  &&  ttdif>1
        %bin_days = 0.1;
    elseif ttdif<=1
        %bin_days = 0.01;
    end
    
    
    if bin_days>=1
        tdiff = round(days(teb-t0b)/bin_days);
        %tdiff = round(teb - t0b);
    else
        tdiff = (teb-t0b)/bin_days;
    end
    
    % calculate cumulative number versus time and bin it
    if bin_days >=1
        [cumu, xt] = histcounts(mycat.Date,t0b:days(bin_days):teb);
    else
        [cumu, xt] = histcounts((mycat.Date-mycat.Date(1))+bin_days*365, (0:bin_days:(tdiff+2*bin_days)));
    end
    cumu2=cumsum(cumu);
    % plot time series
    %
    set(fig,'PaperPosition',[0.5 0.5 5.5 8.5])
    rect = [0.25,  0.18, 0.60, 0.70];
    axes(fig,'position',rect)
    hold(ax,'on');
    set(ax,'visible','off')
    
    nu = (1:mycat.Count);
    %nu(mycat.Count) = mycat.Count;  %crash if the count is zero
    
    tiplot2 = plot(ax, mycat.Date, nu, 'b', 'LineWidth', 2.0);
    
    % plot end of data
    pl = plot(ax,teb,mycat.Count,'rs');
    set(pl,'LineWidth',1.0,'MarkerSize',4,...
        'MarkerFaceColor','w','MarkerEdgeColor','r');
    
    pl = plot(ax,[max(mycat.Date),teb],[mycat.Count, mycat.Count],'k:');
    set(pl,'LineWidth',2.0);
    
    set(ax,'Ylim',[0 mycat.Count*1.05]);
    
    % plot big events on curve
    %
    if bin_days>=1
        if ~isempty(big)
            l = mycat.Magnitude > ZG.big_eq_minmag;
            f = find( l  == 1);
            bigplo = plot(big.Date,f,'hm');
            set(bigplo,'LineWidth',1.0,'MarkerSize',10,...
                'MarkerFaceColor','y','MarkerEdgeColor','k')
            stri4 = [];
            [le1] = big.Count;
            for i = 1:le1
                s = sprintf('  M=%3.1f',big.Magnitude(i));
                stri4 = [stri4 ; s];
            end   % for i
            
        end
    end %if big
    
    if bin_days>=1
        xlabel(ax,'Time in years ','FontSize',ZmapGlobal.Data.fontsz.s)
    else
        statime=mycat.Date(1) - ZG.bin_days;
        xlabel(ax,['Time in days relative to ',char(statime)],...
            'FontWeight','bold','FontSize',ZG.fontsz.m)
    end
    ylabel(ax,'Cumulative Number ','FontSize',ZG.fontsz.s)
    
    title(ax,['"', mycat.Name, '": Cumulative Earthquakes over time ' newline],'Interpreter','none'); %TOFIX I shouldn't need to use a newline here
    
    % Make the figure visible
    %
    set(ax,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,...
        'LineWidth',1.0,'TickDir','out','Ticklength',[0.02 0.02],...
        'Box','on')
    figure(cum);
    axes(ax);
    set(cum,'Visible','on');
    watchoff(cum)
    zmap_message_center.clear_message();
    done()
    
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        ztoolsmenu = uimenu('Label','ZTools');
        analyzemenu=uimenu('Label','Analyze');
        plotmenu=uimenu('Label','Plot');
        
        uimenu(ztoolsmenu,'Label','Cuts in time, magnitude and depth',...
            'Callback',@cut_tmd_callback)
        uimenu(ztoolsmenu,'Label','Cut in Time (cursor) ',...
            'Callback',@cursor_timecut_callback);
        uimenu(plotmenu,'Label','Date Ticks in different format',...
            'callback',@(~,~)newtimetick,'Enable','off');
        
        uimenu (analyzemenu,'Label','Decluster the catalog',...
            'callback',@(~,~)inpudenew())
        winlen_days = days(ZG.compare_window_yrs/days(ZG.bin_days));
        uimenu(plotmenu,'Label','Overlay another curve (hold)',...
            'callback',@cb_hold)
        uimenu(ztoolsmenu,'Label','Compare two rates (fit)',...
            'callback',@cb_comparerates_fit)
        uimenu(ztoolsmenu,'Label','Compare two rates ( No fit)',...
            'callback',@cb_comparerates_nofit)
        %uimenu(ztoolsmenu,'Label','Day/Night split ', 'callback',@cb_006)
        
        op3D  =   uimenu(plotmenu,'Label','Time series ');
        uimenu(op3D,'Label','Time-depth plot ',...
            'Callback',@(~,~)TimeDepthPlotter.plot(mycat));
        uimenu(op3D,'Label','Time-magnitude plot ',...
            'Callback',@(~,~)TimeMagnitudePlotter.plot(mycat));
        
        
        
        
        op4B = uimenu(analyzemenu,'Label','Rate changes (beta and z-values) ');
        
        uimenu(op4B, 'Label', 'beta values: LTA(t) function',...
            'Callback',{@cb_z_beta_ratechanges,'bet'});
        uimenu(op4B, 'Label', 'beta values: "Triangle" Plot',...
            'Callback', {@cb_betaTriangle,'newcat'})
        uimenu(op4B,'Label','z-values: AS(t)function',...
            'callback',{@cb_z_beta_ratechanges,'ast'})
        uimenu(op4B,'Label','z-values: Rubberband function',...
            'callback',{@cb_z_beta_ratechanges,'rub'})
        uimenu(op4B,'Label','z-values: LTA(t) function ',...
            'callback',{@cb_z_beta_ratechanges,'lta'});
        
        
        op4 = uimenu(analyzemenu,'Label','Mc and b-value estimation');
        uimenu(op4,'Label','automatic', 'callback',@cb_010)
        uimenu(op4,'label','Mc with time ', 'callback',{@plotwithtime,'mc'});
        uimenu(op4,'Label','b with depth', 'callback',@(~,~)bwithde2())
        uimenu(op4,'label','b with magnitude', 'callback',@(~,~)bwithmag);
        uimenu(op4,'label','b with time', 'callback',{@plotwithtime,'b'});
        
        op5 = uimenu(analyzemenu,'Label','p-value estimation');
        
        %The following instruction calls a program for the computation of the parameters in Omori formula, for the catalog of which the cumulative number graph" is
        %displayed (the catalog mycat).
        uimenu(op5,'Label','Completeness in days after mainshock', 'callback',@(~,~)mcwtidays)
        uimenu(op5,'Label','Define mainshock',...
            'Enable','off', 'callback',@cb_016);
        uimenu(op5,'Label','Estimate p', 'callback',@cb_pestimate);
        %In the following instruction the program pvalcat2.m is called. This program computes a map of p in function of the chosen values for the minimum magnitude and
        %initial time.
        uimenu(op5,'Label','p as a function of time and magnitude', 'callback',@(~,~)pvalcat2())
        uimenu(op5,'Label','Cut catalog at mainshock time',...
            'callback',@cb_cut_mainshock)
        
        op6 = uimenu(analyzemenu,'Label','Fractal dimension estimation');
        uimenu(op6,'Label','Compute the fractal dimension D', 'callback',{@cb_computefractal,2});
        uimenu(op6,'Label','Compute D for random catalog', 'callback',{@cb_computefractal,5});
        uimenu(op6,'Label','Compute D with time', 'callback',{@cb_computefractal,6});
        uimenu(op6,'Label',' Help/Info on  fractal dimension', 'callback',@(~,~)showweb('fractal'))
        
        uimenu(ztoolsmenu,'Label','Cumlative Moment Release ', 'callback',@(~,~)morel())
        
        op7 = uimenu(analyzemenu,'Label','Stress Tensor Inversion Tools');
        uimenu(op7,'Label','Invert for stress-tensor - Michael''s Method ', 'callback',@(~,~)doinverse_michael())
        uimenu(op7,'Label','Invert for stress-tensor - Gephart''s Method ', 'callback',@(~,~)doinversgep_pc())
        uimenu(op7,'Label','Stress tensor with time', 'callback',@(~,~)stresswtime())
        uimenu(op7,'Label','Stress tensor with depth', 'callback',@(~,~)stresswdepth())
        uimenu(op7,'Label',' Help/Info on  stress tensor inversions', 'callback',@(~,~)showweb('stress'))
        op5C = uimenu(plotmenu,'Label','Histograms');
        
        uimenu(op5C,'Label','Magnitude',...
            'callback',{@cb_histogram,'Magnitude'});
        uimenu(op5C,'Label','Depth',...
            'callback',{@cb_histogram,'Depth'});
        uimenu(op5C,'Label','Time',...
            'callback',{@cb_histogram,'Date'});
        uimenu(op5C,'Label','Hr of the day',...
            'callback',{@cb_histogram,'Hour'});
        
        
        uimenu(ztoolsmenu,'Label','Save cumulative number curve',...
            'Separator','on',...
            'Callback',{@calSave1, xt, cumu2});
        
        uimenu(ztoolsmenu,'Label','Save cum #  and z value',...
            'Callback',{@calSave7, xt, cumu2, as})
    end
    
    %% callback functions
    
    
    function cut_tmd_callback(~,~)
        ZG.newt2 = catalog_overview(ZG.newt2);
        timeplot(ZG.newt2)
    end
    
    function cursor_timecut_callback(~,~)
        % will change ZG.newt2
        [tt1,tt2]=timesel(4);
        ZG.newt2=ZG.newt2.subset(ZG.newt2.Date>=tt1&ZG.newt2.Date<=tt2);
        timeplot(ZG.newt2);
    end
    
    function cb_hold(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.hold_state2=true;
    end
    
    function cb_comparerates_fit(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dispma2(ic);
    end
    
    function cb_comparerates_nofit(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ic=0;
        dispma3;
    end
    
    function cb_z_beta_ratechanges(mysrc,myevt,sta)
        % beta values:
        %   'bet' : LTA(t) function
        %   'ast' : AS(t) function
        %   'rub' : Rubberband function
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        set(gcf,'Pointer','watch');
        newsta(sta);
    end
    
    function cb_betaTriangle(mysrc, myevt, catname)
        betatriangle(ZG.(catname),t0b:ZG.bin_days:teb);
    end
    function cb_010(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.hold_state=false;
        bdiff2();
    end
    
    function plotwithtime(mysrc,myevt,sPar)
        %sPar tells what to plot.  'mc', 'b'
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        plot_McBwtime(sPar);
    end
    
    
    function cb_016(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        error('not implemented: define mainshock.  Original input_main.m function broken;')
    end
    
    function cb_pestimate(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.hold_state=false;
        pvalcat;
    end
    
    function cb_cut_mainshock(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        l = min(find( mycat.Magnitude == max(mycat.Magnitude) ));
        mycat = mycat(l+1:mycat.Count,:);
        timeplot(mycat) ;
    end
    
    function cb_computefractal(mysrc,myevt, org)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        if org==2
            E = mycat; 
        end % TOFIX this is probably unneccessary, but would need to be traced in startfd before deleted
        startfd;
    end
    
    function cb_histogram(mysrc,myevt,hist_type)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        hisgra(mycat, hist_type);
    end
    
    function cb_resetcat(mysrc,myevt)
        % Resets the catalog to the original selection
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        nosort = 'of';
        error ZG.newcat = ZG.mycat;
        mycat = ZG.newcat;
        stri = [' '];
        stri1 = [' '];
        close(cum);
        timeplot(mycat,nosort);
    end
    
    function cb_keep(mysrc,myevt)
        % Plots this subset in the map window
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.newcat = mycat;
        replaceMainCatalog(mycat) ;
        zmap_message_center.update_catalog();
        update(mainmap());
    end
end
