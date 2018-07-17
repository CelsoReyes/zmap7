function view_rccross_a2(lab1,valueMap)
    % view_rccross_a2 plots ratechanges and p values calculated
    % derived with rc_cross_a2.m or other similar values as a color map.
    % needs valueMap, gx, gy
    %
    % define size of the plot etc.
    
    
    report_this_filefun();

    myFigName='RC-Cross-section';
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
    hRccross=myFigFinder();
    
    
    if isempty(hRccross)
        hRccross = figure_w_normalized_uicontrolunits( ...
            'Name',myFigName,...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        
        %lab1 = 'p-value:';
        create_my_menu();
        
        %valueMap = pvalg;
        ZG.tresh_km = nan; re4 = valueMap;
        
        colormap(jet)
        ZG.tresh_km = nan; minpe = nan; Mmin = nan; minsd = nan;
    end   % This is the end of the figure setup.
    
    % Now lets plot the color-map!
    %
    figure(hRccross);
    delete(findobj(hOmoricross,'Type','axes'))
    %delete(sizmap)
    ax=gca;
    reset(ax) % automatically sets NextPlot to replace
    watchon;
    set(ax,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','SortMethod','childorder')
    
    rect = [0.18,  0.10, 0.7, 0.75];
    rect1 = rect;
    
    % find max and min of data for automatic scaling
    ZG.maxc = max(valueMap(:));
    ZG.maxc = fix(ZG.maxc)+1;
    ZG.minc = min(valueMap(:));
    ZG.minc = fix(ZG.minc)-1;
    
    re4 = valueMap;
    
    
    % plot image
    orient landscape
    
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
    
    
    title([name ';  '   num2str(t0b) ' to ' num2str(teb) ],'FontSize',ZmapGlobal.Data.fontsz.s,...
        'Color','r','FontWeight','bold')
    
    xlabel('Distance [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    ylabel('Depth [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    
    % plot overlay
    %
    set(gca,'NextPlot','add')
    zmap_update_displays();
    ploeq = plot(ZG.primeCatalog.Longitude,ZG.primeCatalog.Latitude,'k.');
    set(ploeq,'Tag','eq_plot','MarkerSize',ZG.ms6,'Marker',ty,'Color',ZG.someColor,'Visible','on')
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    h1 = gca;
    hzma = gca;
    
    % Create a colorbar
    %
    h5 = colorbar('horiz');
    set(h5,'Pos',[0.35 0.05 0.4 0.02],...
        'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s,'TickDir','out')
    
    rect = [0.00,  0.0, 1 1];
    axes('position',rect)
    axis('off')
    %  Text Object Creation
    txt1 = text(...
        'Units','normalized',...
        'Position',[ 0.33 0.06 0 ],...
        'HorizontalAlignment','right',...
        'FontSize',ZmapGlobal.Data.fontsz.s,....
        'FontWeight','bold',...
        'String',lab1);
    
    % Make the figure visible
    %
    set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    figure(hRccross);
    axes(h1)
    watchoff(hRccross)
    
    
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
            MenuSelectedField(),{@cb_viewagain,'mag'})
        uimenu(adjmenu,'Label','Adjust Rmax cut',...
            MenuSelectedField(),{@cb_viewagain,'rmax'})
        uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
            MenuSelectedField(),{@cb_viewagain,'gofi'})
        uimenu(adjmenu,'Label','Adjust p-value st. dev. cut',...
            MenuSelectedField(),{@cb_viewagain,'pstdc'})
        
        
        uimenu(op1,'Label','Relative rate change (bootstrap)',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'Sigma'})
        uimenu(op1,'Label','Model',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'Model'})
        uimenu(op1,'Label','KS-Test',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'Rejection'})
        uimenu(op1,'Label','KS-Test Statistic',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'KS distance'})
        uimenu(op1,'Label','KS-Test p-value',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'KS-Test p-value'})
        uimenu(op1,'Label','RMS of fit',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'RMS'})
        uimenu(op1,'Label','Resolution Map (Number of events)',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'Number of events'})
        uimenu(op1,'Label','Resolution Map (Radii)',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'Radius / [km]'})
        uimenu(op1,'Label','p-value',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'p-value'})
        uimenu(op1,'Label','p-value standard deviation',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'p-valstd'})
        uimenu(op1,'Label','c-value',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'c-value'})
        uimenu(op1,'Label','c-value standard deviation',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'c-valuestd'})
        uimenu(op1,'Label','k-value',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'k-value'})
        uimenu(op1,'Label','k-value standard deviation',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'k-valuestd'})
        uimenu(op1,'Label','p2-value',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'p2-value'})
        uimenu(op1,'Label','p-value standard deviation',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'p2-valuestd'})
        uimenu(op1,'Label','c2-value',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'c2-value'})
        uimenu(op1,'Label','c2-value standard deviation',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'c2-valuestd'})
        uimenu(op1,'Label','k2-value',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'k2-value'})
        uimenu(op1,'Label','k2-value standard deviation',...
            MenuSelectedField(),{@cb_viewagainOtherdata,'k2-valuestd'})
        
        add_display_menu(1);
    end
    
    %% callback functions
    
    function callbackfun_001(mysrc,myevt)
        view_rccross_a2(lab1,valueMap);
    end
    
    function callbackfun_002(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        met = 'ra';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        plot_circbootfit_a2;
        watchoff(hRccross);
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state2=true;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
        plot_constnrbootfit_a2;
        watchoff(hRccross);
    end
    
    function cb_viewagain(mysrc,myevt,asel)
        % set asel, adju2, then view
        ZG=ZmapGlobal.Data;
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        adju2;
        view_rccross_a2(lab1,ZG.valueMap);
    end
    
    function cb_viewagainOtherdata(mysrc,myevt, label)
        % set asel, adju2, then view
        ZG=ZmapGlobal.Data;
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        switch label
            case 'Sigma'
                valueMap=mRelchange; %8
            case 'Model'
                valueMap=mMod; %9
            case 'Rejection'
                valueMap=mKstestH; %10
            case 'KS distance'
                valueMap=mKsstat; %11
            case 'KS-Test p-value'
                valueMap=mKsp; %12
            case 'RMS'
                valueMap=mRMS; %13
            case 'Number of events'
                valueMap=mNumevents; %14
            case 'Radius / [km]'
                valueMap=vRadiusRes; %15
            case 'p-value'
                valueMap=mPval;
            case 'p-valstd'
                valueMap=mPvalstd;
            case 'c-value'
                valueMap=mCval;
            case 'c-valstd'
                valueMap=mCvalstd;
            case 'k-value'
                valueMap=mKval;
            case 'k-valstd'
                valueMap=mKvalstd;
            case 'p2-value'
                valueMap=mPval2;
            case 'p2-valstd'
                valueMap=mPvalstd2;
            case 'c2-value'
                valueMap=mCval2;
            case 'c2-valstd'
                valueMap=mCvalstd2;
            case 'k2-value'
                valueMap=mKval2;
            case 'k2-valstd'
                valueMap=mKvalstd2;
            otherwise
                error('unknown choice');
        end
        ZG.valueMap=valueMap;
        view_rccross_a2(label,ZG.valueMap);
    end

end

