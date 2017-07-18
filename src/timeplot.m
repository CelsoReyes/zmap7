function timeplot(mycat, nosort)
    % This .m file "timeplot" plots the events select by "circle"
    % or by other selection button as a cummultive number versus
    % time plot in window 2.
    % Time of events with a Magnitude greater than ZG.big_eq_minmag will
    % be shown on the curve.  Operates on mycat, resets  b  to mycat
    %     ZG.newcat is reset to:
    %                       - "a" if either "Back" button or "Close" button is         %                          pressed.
    %                       - mycat if "Save as Newcat" button is pressed.
    %
    
    % Updates:
    % Added callback in op5 for afterschock sequence rate change detection (07.07.03: J. Woessner)
    
    report_this_filefun(mfilename('fullpath'));
    global par1 iwl2
   global  cum statime 
    global selt
    
    ZG = ZmapGlobal.Data;
    if ~exist('xt','var')
        xt=[]; % time series that will be used
    end
    if ~exist('as','var')
        as=[]; % z values, maybe? used by the save callback.
    end
    
    if isempty(par1) %binning
        par1=1;
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
    
    
    % Find out of figure already exists
    %
    [existFlag,figNumber]=figure_exists('Cumulative Number',1);
    newCumWindowFlag=~existFlag;
    cum = figNumber;
    
    % Set up the Cumulative Number window
    
    if newCumWindowFlag
        cum = figure_w_normalized_uicontrolunits( ...
            'Name','Cumulative Number',...
            'NumberTitle','off', ...
            'NextPlot','replace', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',[ 100 100 (ZmapGlobal.Data.map_len - [100 20]) ]);
        
        matdraw
        
        selt='in';
        uimenu('Label','|','Enable','off')
        ztoolsmenu = uimenu('Label','ZTools');
        analyzemenu=uimenu('Label','Analyze');
        plotmenu=uimenu('Label','Plot');
        
        uimenu(ztoolsmenu,'Label','Cuts in time, magnitude and depth',...
            'Callback',@cut_tmd_callback)
        uimenu(ztoolsmenu,'Label','Cut in Time (cursor) ',...
          'Callback',@cursor_timecut_callback);
        uimenu(plotmenu,'Label','Date Ticks in different format',...
            'Callback','newtimetick','Enable','off');
        
        uimenu (analyzemenu,'Label','Decluster the catalog',...
            'Callback','inpudenew;')
        iwl = days(iwl2/par1);
        uimenu(plotmenu,'Label','Overlay another curve (hold)',...
            'Callback','ZG=ZmapGlobal.Data;ZG.hold_state2=true; ')
        uimenu(ztoolsmenu,'Label','Compare two rates (fit)',...
            'Callback','dispma2')
        uimenu(ztoolsmenu,'Label','Compare two rates ( No fit)',...
            'Callback','ic=0;dispma3')
        %uimenu(ztoolsmenu,'Label','Day/Night split ', 'Callback','daynigt')
        
        op3D  =   uimenu(plotmenu,'Label','Time series ');
        uimenu(op3D,'Label','Time-depth plot ',...
            'Callback',@(~,~)TimeDepthPlotter.plot(mycat));
        uimenu(op3D,'Label','Time magnitude plot ',...
            'Callback',@(~,~)TimeMagnitudePlotter.plot(mycat));
        
        
        
        
        op4B = uimenu(analyzemenu,'Label','Rate changes (beta and z-values) ');
        
        uimenu(op4B, 'Label', 'beta values: LTA(t) function',...
            'Callback', 'sta = ''bet'',newsta')
        uimenu(op4B, 'Label', 'beta values: "Triangle" Plot',...
            'Callback', ';betatriangle')
        uimenu(op4B,'Label','z-values: AS(t)function',...
            'Callback','set(gcf,''Pointer'',''watch'');sta = ''ast'';newsta')
        uimenu(op4B,'Label','z-values: Rubberband function',...
            'Callback','set(gcf,''Pointer'',''watch'');sta = ''rub'';newsta')
        uimenu(op4B,'Label','z-values: LTA(t) function ',...
            'Callback','set(gcf,''Pointer'',''watch'');sta = ''lta'';newsta')
        
        
        op4 = uimenu(analyzemenu,'Label','Mc and b-value estimation');
        uimenu(op4,'Label','automatic', 'Callback','ZG=ZmapGlobal.Data;ZG.hold_state=false,selt = ''in'',; bdiff2')
        uimenu(op4,'label','Mc with time ', 'Callback','selt = ''in''; sPar = ''mc''; plot_McBwtime');
        uimenu(op4,'Label','b with depth', 'Callback','bwithde2')
        uimenu(op4,'label','b with magnitude', 'Callback','bwithmag');
        uimenu(op4,'label','b with time', 'Callback','selt = ''in''; sPar = ''b''; plot_McBwtime');
        
        
        pstring=['global freq_field1 freq_field2 freq_field3 freq_field4 freq_field5 tmp1 tmp2 tmp3 tmp4 tmm magn hpndl1 ctiplo mtpl ttcat;ttcat=mycat;'];
        ptstring=[pstring ' cltipval(2);'];
        pmstring=[pstring ' cltipval(1);'];
        
        op5 = uimenu(analyzemenu,'Label','p-value estimation');
        
        %The following instruction calls a program for the computation of the parameters in Omori formula, for the catalog of which the cumulative number graph" is
        %displayed (the catalog mycat).
        uimenu(op5,'Label','Completeness in days after mainshock', 'Callback','mcwtidays')
        uimenu(op5,'Label','Define mainshock and estimate p', 'Callback','ZG=ZmapGlobal.Data;ZG.hold_state=false;inpu_main')
        %In the following instruction the program pvalcat2.m is called. This program computes a map of p in function of the chosen values for the minimum magnitude and
        %initial time.
        uimenu(op5,'Label','p as a function of time and magnitude', 'Callback','pvalcat2')
        uimenu(op5,'Label','Cut catalog at mainshock time',...
            'Callback','l = min(find( mycat.Magnitude == max(mycat.Magnitude) ));mycat = mycat(l+1:mycat.Count,:);timeplot(mycat) ')
        
        op6 = uimenu(analyzemenu,'Label','Fractal dimension estimation');
        uimenu(op6,'Label','Compute the fractal dimension D', 'Callback',' E = mycat; org = 2; startfd');
        uimenu(op6,'Label','Compute D for random catalog', 'Callback',' org = 5; startfd;');
        uimenu(op6,'Label','Compute D with time', 'Callback',' org = 6; startfd;');
        uimenu(op6,'Label',' Help/Info on  fractal dimension', 'Callback',' showweb(''fractal''); ')
        
        uimenu(ztoolsmenu,'Label','Cumlative Moment Release ', 'Callback','morel')
        
        op7 = uimenu(analyzemenu,'Label','Stress Tensor Inversion Tools');
        uimenu(op7,'Label','Invert for stress-tensor - Michael''s Method ', 'Callback','doinvers_michael')
        uimenu(op7,'Label','Invert for stress-tensor - Gephart''s Method ', 'Callback','doinversgep_pc')
        uimenu(op7,'Label','Stress tensor with time', 'Callback','stresswtime')
        uimenu(op7,'Label','Stress tensor with depth', 'Callback','stresswdepth')
        uimenu(op7,'Label',' Help/Info on  stress tensor inversions', 'Callback','  showweb(''stress'') ')
        op5C = uimenu(plotmenu,'Label','Histograms');
        
        uimenu(op5C,'Label','Magnitude',...
            'Callback','global histo;hisgra(mycat.Magnitude,''Magnitude '',mycat.Name);');
        uimenu(op5C,'Label','Depth',...
            'Callback','global histo;hisgra(mycat.Depth,''Depth '',mycat.Name);');
        uimenu(op5C,'Label','Time',...
            'Callback','global histo;hisgra(mycat.Date,''Time '',mycat.Name);');
        uimenu(op5C,'Label','Hr of the day',...
            'Callback','global histo;hisgra(mycat.Date.Hour,''Hr '',mycat.Name);');
        
        
        uimenu(ztoolsmenu,'Label','Save cumulative number curve',...
            'Separator','on',...
            'Callback',{@calSave1, xt, cumu2});
        
        uimenu(ztoolsmenu,'Label','Save cum #  and z value',...
             'Callback',{@calSave7, xt, cumu2, as})
        
        %
        
        uicontrol('Units','normal','Position',[.0 .0 .1 .05],...
             'String','Reset',...
             'Callback','nosort = ''of'';global ZG; error ZG.newcat = ZG.mycat; mycat = ZG.newcat; stri = ['' '']; stri1 = ['' '']; close(cum); timeplot(mycat,nosort)',...
            'tooltip','Resets the catalog to the original selection')

        uicontrol('Units','normal','Position',[.70 .0 .3 .05],...
            'String','Keep as newcat',...
            'Callback','global ZG; ZG.newcat = mycat; replaceMainCatalog(mycat) ;zmap_message_center.update_catalog();update(mainmap())',...
            'tooltip','Plots this subset in the map window')
        
        ZG.hold_state2=false;
        
    end
    %end;    if figure exist
    
    if ZG.hold_state2
        cumu = 0:1:(tdiff/days(par1))+2;
        cumu2 = 0:1:(tdiff/days(par1))-1;
        cumu = cumu * 0;
        cumu2 = cumu2 * 0;
        n = mycat.Count;
        [cumu, xt] = hist(mycat.Date,(t0b:days(par1):teb));
        cumu2 = cumsum(cumu);
        
        
        hold on
        axes(ht)
        tiplot2 = plot(mycat.Date,(1:mycat.Count),'r');
        set(tiplot2,'LineWidth',2.0)
        
        
        ZG.hold_state2=false;
        return
    end
    
    fig=figure_w_normalized_uicontrolunits(cum);
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
    par2=par1;
    t0b = min(ZG.a.Date);
    n = mycat.Count;
    teb = max(ZG.a.Date);
    ttdif=(teb - t0b); % days
    if ttdif>10                 %select bin length respective to time in catalog
        %par1 = ceil(ttdif/300);
    elseif ttdif<=10  &&  ttdif>1
        %par1 = 0.1;
    elseif ttdif<=1
        %par1 = 0.01;
    end
    
    
    if par1>=1
        tdiff = round(days(teb-t0b)/par1);
        %tdiff = round(teb - t0b);
    else
        tdiff = (teb-t0b)/days(par1);
    end
    % set arrays to zero
    cumu = 0:1:((teb-t0b)/days(par1))+2;
    cumu2 = 0:1:((teb-t0b)/days(par1))-1;
    % calculate cumulative number versus time and bin it
    n = mycat.Count;
    if par1 >=1
        [cumu, xt] = histcounts(mycat.Date,(t0b:days(par1):teb));
    else
        [cumu, xt] = histcounts((mycat.Date-mycat.Date(1)+days(par1))*365,(0:par1:(tdiff+2*par1)));
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
    nu(mycat.Count) = mycat.Count;
    
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
    if par1>=1
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
    
    if par1>=1
        xlabel(ax,'Time in years ','FontSize',ZmapGlobal.Data.fontsz.s)
    else
        statime=mycat.Date(1) - days(par1);
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
    
    function cut_tmd_callback(~,~)
        ZG=ZmapGlobal.Data;
        inpu2; %changes ZG.newt2
        timeplot(ZG.newt2)
    end

    function cursor_timecut_callback(~,~)
    % will change ZG.newt2
        ZG=ZmapGlobal.Data;
        [tt1,tt2]=timesel(4);
        ZG.newt2=ZG.newt2.subset(ZG.newt2.Date>=tt1&ZG.newt2.Date<=tt2);
        timeplot(ZG.newt2);
    end
    
end