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

function timeplot_create_menu()
    ZG=ZmapGlobal.Data;
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
    uimenu(plotmenu,'Label','Overlay another curve (hold)',...
        'Checked',logical2onoff(ZG.hold_state2),...
        'callback',@cb_hold)
    uimenu(ztoolsmenu,'Label','Compare two rates (fit)',...
        'callback',@cb_comparerates_fit)
    uimenu(ztoolsmenu,'Label','Compare two rates (no fit)',...
        'enable','off',...
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
    
    
    %uimenu(ztoolsmenu,'Label','Save cumulative number curve',...
    %    'Separator','on',...
    %    'Callback',{@calSave1, cumu2}); % not saving xt
    
    %uimenu(ztoolsmenu,'Label','Save cum #  and z value',...
    %    'Callback',{@calSave7,  cumu2, as}) % not saving xt
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
    ZG.hold_state2 = ~ZG.hold_state2;
    mysrc.Checked=(logical2onoff(ZG.hold_state2));
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
    mycat = ZG.newcat;
    close(cum);
    timeplot(mycat);
    zmap_update_displays();
end

function cb_keep(mysrc,myevt)
    % Plots this subset in the map window
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    ZG.newcat = mycat;
    replaceMainCatalog(mycat) ;
    zmap_update_displays();
end

function cb_rename_cat(~,~)
    ZG=ZmapGlobal.Data;
    isGlobalCat = isprop(ZG,catname);
    if isGlobalCat
        myname=ZG.(catname).Name;
        nm=inputdlg('Catalog Name:','Rename',1,{myname});
        if ~isempty(nm)
            ZG.(catname).Name=nm{1};
    zmap_update_displays();
        end
    else
        nm=inputdlg('Catalog Name:','Rename',1,{mycat.Name});
        if ~isempty(nm)
            mycat.Name=nm{1};
    zmap_update_displays();
        end
    end
        
        
end
end