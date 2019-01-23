function view_rcva_a2(lab1,valueMap)
    % view_rcva_a2 plots ratechanges and p values calculated with rcvalgrid_a2
    % or other similar values as a color map.
    % needs valueMap, gx, gy
    %
    % define size of the plot etc.
    %
    % TODO: recreate adju2 (?) to do a variety of cuts: mag, rmax, gofi, pstdc

    
    report_this_filefun();
    myFigName='rc-value-map';
    myFigFinder=@() findobj('Type','Figure','-and','Name',myFigName);
    
    % This is the info window text
    %
    ttlStr='The b and p -Value Map Window                 ';
    hlpStr1zmap= ...
        ['                                                '
        ' This window displays b-values and p-values     '
        ' using a color code.                            '
        ' Some of the menu-bar options are               '
        ' described below:                               '
        '                                                '
        ' Threshold: You can set the maximum size that   '
        '   a volume is allowed to have in order to be   '
        '   displayed in the map. Therefore, areas with  '
        '   a low seismicity rate are not displayed.     '
        '   edit the size (in km) and click the mouse    '
        '   outside the edit window.                     '
        'FixAx: You can chose the minimum and maximum    '
        '        values of the color-legend used.        '
        'Polygon: You can select earthquakes in a        '
        ' polygon either by entering the coordinates or  '
        ' defining the corners with the mouse            '];
    hlpStr2zmap= ...
        ['                                                '
        'Circle: Select earthquakes in a circular volume:'
        '      Ni, the number of selected earthquakes can'
        '      be edited in the upper right corner of the'
        '      window.                                   '
        ' Refresh Window: Redraws the figure, erases     '
        '       selected events.                         '
        
        ' zoom: Selecting Axis -> zoom on allows you to  '
        '       zoom into a region. Click and drag with  '
        '       the left mouse button. type <help zoom>  '
        '       for details.                             '
        ' Aspect: select one of the aspect ratio options '
        ' Text: You can select text items by clicking.The'
        '       selected text can be rotated, moved, you '
        '       can change the font size etc.            '
        '       Double click on text allows editing it.  '
        '                                                '
        '                                                '];
    
    % Set up the Seismicity Map window Enviroment
    %
    
    % Find out if figure already exists
    %
    rcmap=myFigFinder();
    
    if isempty(rcmap)
        rcmap = figure_w_normalized_uicontrolunits( ...
            'Name',myFigName,...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1)+50, ZG.map_len(2)+50)) ;
        
        %lab1 = 'p-value:';
        create_my_menu();
        
        %valueMap = pvalg;
        ZG.tresh_km = nan; re4 = valueMap;
        
        colormap(jet)
        ZG.tresh_km = nan; minpe = nan; Mmin = nan; minsd = nan;
    end   % This is the end of the figure setup.
    
    % Now lets plot the color-map!
    %
    figure(rcmap);
    delete(findobj(rcmap,'Type','axes'));
    % delete(sizmap);
    reset(gca)
    cla
    watchon;
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','SortMethod','childorder')
    
    rect = [0.18,  0.10, 0.7, 0.75];
    rect1 = rect;
    
    % find max and min of data for automatic scaling
    ZG.maxc = max(valueMap(:));
    ZG.maxc = fix(ZG.maxc)+1;
    ZG.minc = min(valueMap(:));
    ZG.minc = fix(ZG.minc)-1;
    
    % set values greater ZG.tresh_km = nan
    %
    re4 = valueMap;
    % plot image
    %
    orient landscape
    %set(gcf,'PaperPosition', [0.5 1 9.0 4.0])
    
    %Plots re4, which contains the filtered values.
    axes('position',rect)
    set(gca,'NextPlot','add')
    pco1 = pcolor(gx,gy,re4);
    
    axis([ min(gx) max(gx) min(gy) max(gy)])
    axis image
    set(gca,'NextPlot','add')
    
    shading(ZG.shading_style);

    % make the scaling for the recurrence time map reasonable
    if lab1(1) =='T'
        l = isnan(valueMap);
        re = valueMap;
        re(l) = [];
        caxis([min(re) 5*min(re)]);
    end

    fix_caxis.ApplyIfFrozen(gca); 
    
    
    globalcatalog=ZG.primeCatalog;
    xlabel(globalcatalog.XLabelWithUnits,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    ylabel(globalcatalog.YLabelWithUnits,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    
    % plot overlay
    %
    set(gca,'NextPlot','add')
    zmap_update_displays();
    ploeq = plot(globalcatalog.X,globalcatalog.Y,'k.');
    set(ploeq,'Tag','eq_plot''MarkerSize',ZG.ms6,'Marker',ty,'Color',ZG.someColor,'Visible','on')
    
    
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    h1 = gca;
    hzma = gca;
    
    % Create a colorbar
    h5 = colorbar;
    chl = get(h5,'Ylabel');
    set(chl,'String',lab1,'FontS',10,'Rot',270);
    
    rect = [0.00,  0.0, 1 1];
    axes('position',rect)
    axis('off')
    % Make the figure visible
    %
    set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    axes(h1)
    watchoff(rcmap)
    
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        
        add_symbol_menu('eq_plot');
        
        options = uimenu('Label',' Analyze ');
        uimenu(options,'Label','Refresh ',MenuSelectedField(),@callbackfun_001)
        uimenu(options,'Label','Select EQ in Circle - Constant R',...
            MenuSelectedField(),@callbackfun_002)
        uimenu(options,'Label','Select EQ with const. number',...
            MenuSelectedField(),@callbackfun_003)
        
        
        op1 = uimenu('Label',' Maps ');
        
        %Meniu for adjusting several parameters.
        adjmenu =  uimenu(op1,'Label','Adjust Map Display Parameters'),...
            uimenu(adjmenu,'Label','Adjust Mmin cut',...
            MenuSelectedField(),@callbackfun_004)
        uimenu(adjmenu,'Label','Adjust Rmax cut',...
            MenuSelectedField(),@callbackfun_005)
        uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
            MenuSelectedField(),@callbackfun_006)
        uimenu(adjmenu,'Label','Adjust p-value st. dev. cut',...
            MenuSelectedField(),@callbackfun_007)
        
        
        uimenu(op1,'Label','Relative rate change (bootstrap)',...
            MenuSelectedField(),@callbackfun_008)
        uimenu(op1,'Label','Model',...
            MenuSelectedField(),@callbackfun_009)
        uimenu(op1,'Label','KS-Test',...
            MenuSelectedField(),@callbackfun_010)
        uimenu(op1,'Label','KS-Test Statistic',...
            MenuSelectedField(),@callbackfun_011)
        uimenu(op1,'Label','KS-Test p-value',...
            MenuSelectedField(),@callbackfun_012)
        uimenu(op1,'Label','RMS of fit',...
            MenuSelectedField(),@callbackfun_013)
        uimenu(op1,'Label','Resolution Map (Number of events)',...
            MenuSelectedField(),@callbackfun_014)
        uimenu(op1,'Label','Resolution Map (Radii)',...
            MenuSelectedField(),@callbackfun_015)
        uimenu(op1,'Label','p-value',...
            MenuSelectedField(),@callbackfun_016)
        uimenu(op1,'Label','p-value standard deviation',...
            MenuSelectedField(),@callbackfun_017)
        uimenu(op1,'Label','c-value',...
            MenuSelectedField(),@callbackfun_018)
        uimenu(op1,'Label','c-value standard deviation',...
            MenuSelectedField(),@callbackfun_019)
        uimenu(op1,'Label','k-value',...
            MenuSelectedField(),@callbackfun_020)
        uimenu(op1,'Label','k-value standard deviation',...
            MenuSelectedField(),@callbackfun_021)
        uimenu(op1,'Label','p2-value',...
            MenuSelectedField(),@callbackfun_022)
        uimenu(op1,'Label','p-value standard deviation',...
            MenuSelectedField(),@callbackfun_023)
        uimenu(op1,'Label','c2-value',...
            MenuSelectedField(),@callbackfun_024)
        uimenu(op1,'Label','c2-value standard deviation',...
            MenuSelectedField(),@callbackfun_025)
        uimenu(op1,'Label','k2-value',...
            MenuSelectedField(),@callbackfun_026)
        uimenu(op1,'Label','k2-value standard deviation',...
            MenuSelectedField(),@callbackfun_027)
        %    uimenu(op1,'Label','Histogram ',MenuSelectedField(),@(~,~)zhist())
        
        add_display_menu(2);
    end
    
    %% callback functions
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        met = 'ra';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        plot_circbootfit_a2;
        watchoff(rcmap);
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state2=true;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
        plot_constnrbootfit_a2;
        watchoff(rcmap);
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'mag';
        adju2;
        view_rcva_a2(lab1,valueMap) ;
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'rmax';
        adju2;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'gofi';
        adju2;
        view_rcva_a2(lab1,valueMap) ;
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'pstdc';
        adju2;
        view_rcva_a2(lab1,valueMap) ;
    end
    
    function callbackfun_008(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Sigma';
        valueMap = mRelchange;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_009(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Model';
        valueMap = mMod;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_010(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Rejection';
        valueMap = mKstestH;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_011(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='KS distance';
        valueMap = mKsstat;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_012(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='KS-Test p-value';
        valueMap = mKsp;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_013(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='RMS';
        valueMap = mRMS;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_014(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Number of events';
        valueMap = mNumevents;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_015(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Radius / [km]';
        valueMap = vRadiusRes;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_016(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='p-value';
        valueMap = mPval;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_017(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='p-valstd';
        valueMap = mPvalstd;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_018(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='c-value';
        valueMap = mCval;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_019(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='c-valuestd';
        valueMap = mCvalstd;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_020(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='k-value';
        valueMap = mKval;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_021(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='k-valuestd';
        valueMap = mKvalstd;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_022(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='p2-value';
        valueMap = mPval2;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_023(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='p-valstd';
        valueMap = mPvalstd2;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_024(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='c-value';
        valueMap = mCval2;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_025(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='c-valuestd';
        valueMap = mCvalstd2;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_026(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='k-value';
        valueMap = mKval2;
        view_rcva_a2(lab1,valueMap);
    end
    
    function callbackfun_027(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='k-valuestd';
        valueMap = mKvalstd2;
        view_rcva_a2(lab1,valueMap);
    end

end
