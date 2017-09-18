function timeplot(mycat, nosort)
    % timeplot plots selected events as cummulative # over time
    %
    % Time of events with a Magnitude greater than ZG.big_eq_minmag will
    % be shown on the curve.  Operates on mycat, resets  b  to mycat
    %     ZG.newcat is reset to:
    %                       - "a" if either "Back" button or "Close" button is pressed.
    %  
    % Updates:
    % Added callback in op5 for afterschock sequence rate change detection (07.07.03: J. Woessner)
    
    report_this_filefun(mfilename('fullpath'));
    myFigName='Cumulative Number';
    myFigFinder=@() findobj('Type','Figure','-and','Name',myFigName);
    
    global statime
    global selt
    t0b=min(mycat.Date);
    teb=max(mycat.Date);
    ZG = ZmapGlobal.Data;
    if ~exist('xt','var')
        xt=[]; % time series that will be used
    end
    if ~exist('as','var')
        as=[]; % z values, maybe? used by the save callback.
    end
    
    if isempty(ZG.bin_dur) %binning
        ZG.bin_dur = days(1);
    end
    
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
            
        uicontrol('Units','normal','Position',[.0 .0 .1 .05],...
            'String','Reset',...
            'callback',@cb_resetcat,...
            'tooltip','Resets the catalog to the original selection')
        
        uicontrol('Units','normal','Position',[.65 .0 .35 .05],...
            'String','Set as main catalog',...
            'callback',@cb_keep,...
            'tooltip','Plots this subset in the map window')
        
        ZG.hold_state2=false;
        
    end
    figure(cum);
    ht=gca;
    if ZG.hold_state2
        tdiff=max(mycat.Date) - min(mycat.Date); % added by CR
        cumu = 0:1:(tdiff/days(ZG.bin_dur))+2;
        cumu2 = 0:1:(tdiff/days(ZG.bin_dur))-1;
        cumu = cumu * 0;
        cumu2 = cumu2 * 0;
        [cumu, xt] = histcounts(mycat.Date, t0b: ZG.bin_dur :teb);
        %xt = xt + (xt(2)-xt(1))/2; xt(end)=[]; % convert from edges to centers!
        cumu2 = cumsum(cumu);
        
        
        hold on
        axes(ht)
        tiplot2 = plot(ht,mycat.Date,(1:mycat.Count),'r');
        set(tiplot2,'LineWidth',2.0)
        
        ds=dbstack;
        if numel(ds)>1
            tiplot2.DisplayName=['from ' ds(2).name];
        end
        
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
    l = mycat.Magnitude >= ZG.big_eq_minmag;
    big = mycat.subset(l);
    %calculate start -end time of overall catalog
    statime=[];
    par2=ZG.bin_dur;
    t0b = min(ZG.a.Date);
    teb = max(ZG.a.Date);
    
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
    if ZG.bin_dur>=days(1)
        if ~isempty(big)
            l = mycat.Magnitude >= ZG.big_eq_minmag;
            f = find(l);
            hold(ax,'on')
            bigplo = plot(ax,big.Date,f,'hm');
            set(bigplo,'LineWidth',1.0,'MarkerSize',10,...
                'MarkerFaceColor','y','MarkerEdgeColor','k')
            stri4 = [];
            [le1] = big.Count;
            for i = 1:le1
                s = sprintf('  M=%3.1f',big.Magnitude(i));
                stri4 = [stri4 ; s];
            end   % for i
            hold(ax,'off')
        end
    end %if big
    
    if ZG.bin_dur>=days(1)
        xlabel(ax,'Time in years ','FontSize',ZmapGlobal.Data.fontsz.s)
    else
        statime=mycat.Date(1) - ZG.bin_dur;
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
        catmenu=uimenu('Label','Catalog');
        
        
        uimenu(catmenu,'Label','Rename Catalog (this subset)',...
            'callback',@cb_rename_cat);
        
        uimenu(catmenu,'Label','Set as main catalog',...
            'callback',@cb_keep); % Replaces the primary catalog, and replots this subset in the map window
        uimenu(catmenu,'Separator','on','Label','Reset',...
            'callback',@cb_resetcat); % Resets the catalog to the original selection
        
        uimenu(ztoolsmenu,'Label','Cuts in time, magnitude and depth',...
            'Callback',@cut_tmd_callback);
        uimenu(ztoolsmenu,'Label','Cut in Time (cursor) ',...
            'Callback',@cursor_timecut_callback);
        uimenu(plotmenu,'Label','Date Ticks in different format',...
            'callback',@(~,~)newtimetick,'Enable','off');
        
        uimenu (analyzemenu,'Label','Decluster the catalog',...
            'callback',@(~,~)inpudenew())
        winlen_days = days(ZG.compare_window_dur / ZG.bin_dur);
        uimenu(plotmenu,'Label','Overlay another curve (hold)',...
            'Checked',check2onoff(ZG.hold_state2),...
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
        if ZG.hold_state2
            ZG.hold_state2=false;
            mysrc.Checked='off';
        else
            ZG.hold_state2=true;
            mysrc.Checked='on';
        end
    end
    function ans=check2onoff(var)
        if var
            ans='on';
        else
            ans='off';
        end
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
    
    function cb_betaTriangle(~, ~, catname)
        betatriangle(ZG.(catname),t0b:ZG.bin_dur:teb);
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
        pvalcat();
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
        % error ZG.newcat = ZG.mycat;
        mycat = ZG.newcat;
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
    function cb_rename_cat(~,~)
        nm=inputdlg('Catalog Name:','Rename',1,{mycat.Name});
        if ~isempty(nm)
            mycat.Name=nm{1};
        end
    end
end
