function view_rcva(lab1,valueMap)
    % view_rcva plots ratechanges and p values calculated with rcvalgrid_a2
    % or other similar values as a color map.
    % needs valueMap, gx, gy
    %
    % define size of the plot etc.
    %

    
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
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        
        %lab1 = 'p-value:';
        create_my_menu();
        
        %valueMap = pvalg;
        ZG.tresh_km = nan; re4 = valueMap;
        oldfig_button = 1;
        
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
    
    %If the colorbar is freezed.

    fix_caxis.ApplyIfFrozen(gca); 
    
    
    title([name ';  '   num2str(t0b) ' to ' num2str(teb) ],'FontSize',ZmapGlobal.Data.fontsz.s,...
        'Color','r','FontWeight','bold')
    
    xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    
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
    figure(rcmap);
    %sizmap = signatur('ZMAP','',[0.01 0.04]);
    %set(sizmap,'Color','k')
    axes(h1)
    watchoff(rcmap)
    %whitebg(gcf,[ 0 0 0 ])
    
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        add_symbol_menu('eq_plot');
        
        options = uimenu('Label',' Analyze ');
        uimenu(options,'Label','Refresh ','MenuSelectedFcn',@callbackfun_001)
        uimenu(options,'Label','Select EQ in Circle - Constant R',...
            'MenuSelectedFcn',@cb_constR)
        uimenu(options,'Label','Select EQ with const. number',...
            'MenuSelectedFcn',@cb_constN)
        
        
        op1 = uimenu('Label',' Maps ');
        
        %Meniu for adjusting several parameters.
        adjmenu =  uimenu(op1,'Label','Adjust Map Display Parameters'),...
            uimenu(adjmenu,'Label','Adjust Mmin cut',...
            'MenuSelectedFcn',@callbackfun_004)
        uimenu(adjmenu,'Label','Adjust Rmax cut',...
            'MenuSelectedFcn',@callbackfun_005)
        uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
            'MenuSelectedFcn',@callbackfun_006)
        uimenu(adjmenu,'Label','Adjust p-value st. dev. cut',...
            'MenuSelectedFcn',@callbackfun_007)
        
        
        %    uimenu(op1,'Label','b-value map (WLS)',...
        %        'MenuSelectedFcn',@callbackfun_008)
        %    uimenu(op1,'Label','b(max likelihood) map',...
        %        'MenuSelectedFcn',@callbackfun_009)
        %    uimenu(op1,'Label','Mag of completness map',...
        %        'MenuSelectedFcn',@callbackfun_010)
        %    uimenu(op1,'Label','max magnitude map',...
        %           'MenuSelectedFcn',@callbackfun_011)
        %    uimenu(op1,'Label','Magnitude range map (Mmax - Mcomp)',...
        %           'MenuSelectedFcn',@callbackfun_012)
        %
        uimenu(op1,'Label','Relative rate change',...
            'MenuSelectedFcn',@callbackfun_013)
        uimenu(op1,'Label','Relative rate change by boostrap',...
            'MenuSelectedFcn',@callbackfun_014)
        uimenu(op1,'Label','Resolution Map (Number of events)',...
            'MenuSelectedFcn',@callbackfun_015)
        uimenu(op1,'Label','Resolution Map (Radii)',...
            'MenuSelectedFcn',@callbackfun_016)
        uimenu(op1,'Label','p-value',...
            'MenuSelectedFcn',@callbackfun_017)
        uimenu(op1,'Label','p-value standard deviation',...
            'MenuSelectedFcn',@callbackfun_018)
        uimenu(op1,'Label','c-value',...
            'MenuSelectedFcn',@callbackfun_019)
        uimenu(op1,'Label','c-value standard deviation',...
            'MenuSelectedFcn',@callbackfun_020)
        uimenu(op1,'Label','k-value',...
            'MenuSelectedFcn',@callbackfun_021)
        uimenu(op1,'Label','k-value standard deviation',...
            'MenuSelectedFcn',@callbackfun_022)
        %    uimenu(op1,'Label','Histogram ','MenuSelectedFcn',@(~,~)zhist())
        
        add_display_menu(1);
    end
    
    %% callback functions
    
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        view_rcva(lab1,valueMap);
    end
    
    function cb_constR(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        met = 'ra';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        plot_circbootfitF;
        watchoff(rcmap);
    end
    
    function cb_constN(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state2=true;
        ZG.hold_state=true;
        plot_constnrbootfitF;
        watchoff(rcmap);
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'mag';
        adju2;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'rmax';
        adju2;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'gofi';
        adju2;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'pstdc';
        adju2;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_008(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 ='b-value';
        valueMap = old;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_009(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='b-value';
        valueMap = meg;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_010(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 = 'Mcomp';
        valueMap = old1;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_011(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Mmax';
        valueMap = maxm;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_012(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='dM ';
        valueMap = maxm-magco;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_013(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Sigma';
        valueMap = mRelchange;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_014(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Sigma';
        valueMap = vRcBst;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_015(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Number of events';
        valueMap = mNumevents;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_016(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Radius / [km]';
        valueMap = vRadiusRes;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_017(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='p-value';
        valueMap = mPval;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_018(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='p-valstd';
        valueMap = mPvalstd;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_019(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='c-value';
        valueMap = mCval;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_020(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='c-valuestd';
        valueMap = mCvalstd;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_021(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='k-value';
        valueMap = mKval;
        view_rcva(lab1,valueMap);
    end
    
    function callbackfun_022(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='k-valuestd';
        valueMap = mKvalstd;
        view_rcva(lab1,valueMap);
    end

end
