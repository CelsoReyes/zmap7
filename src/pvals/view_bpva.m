function view_bpva(lab1,valueMap)
    % view_bpva plots the b and p values calculated with bpvalgrid.m or other similar values as a color map.
    % needs valueMap, gx, gy, stri
    %
    % define size of the plot etc.
    %
    
    %TODO fix this, it broke when turned into a function.

    
    report_this_filefun(mfilename('fullpath'));
    
    
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
    bmap=findobj('Type','Figure','-and','Name','bp-value-map');
    
    
    if isempty(bmap)
        oldfig_button = false;
    end
    
    if oldfig_button == false
        bpmap = figure_w_normalized_uicontrolunits( ...
            'Name','bp-value-map',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',[ (ZG.fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
        % make menu bar
        create_my_menu();
        
        %lab1 = 'p-value:';
        
        
        uicontrol('Units','normal',...
            'Position',[.0 .93 .08 .06],'String','Info ',...
            'callback',@callbackfun_001);
        
        
        
        %valueMap = pvalg;
        ZG.tresh_km = nan; re4 = valueMap;
        oldfig_button = true;
        
        colormap(jet)
        ZG.tresh_km = nan; minpe = nan; Mmin = nan; minsd = nan;
        
    end   % This is the end of the figure setup.
    
    % Now lets plot the color-map!
    %
    figure(bpmap);
    delete(findobj(bpmap,'Type','axes'));
    %delete(sizmap)
    reset(gca)
    cla
    hold off
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
    l = r > ZG.tresh_km;
    re4(l) = nan(1,length(find(l)));
    l = Prmap < minpe;
    re4(l) = nan(1,length(find(l)));
    l = old1 <  Mmin;
    re4(l) = nan(1,length(find(l)));
    l = pvstd >  minsd;
    re4(l) = nan(1,length(find(l)));
    
    
    % plot image
    %
    orient landscape
    %set(gcf,'PaperPosition', [0.5 1 9.0 4.0])
    
    %Plots re4, which contains the filtered values.
    axes('position',rect)
    hold on
    pco1 = pcolor(gx,gy,re4);
    
    axis([ min(gx) max(gx) min(gy) max(gy)])
    axis image
    hold on
    
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
    
    xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    
    % plot overlay
    %
    hold on
    update(mainmap())
    ploeq = plot(ZG.a.Longitude,ZG.a.Latitude,'k.');
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
    figure(bpmap);
    axes(h1)
    watchoff(bpmap)
    
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        add_symbol_menu('eq_plot');
        options = uimenu('Label',' Select ');
        uimenu(options,'Label','Refresh ', 'callback',@callbackfun_002)
        uimenu(options,'Label','Select EQ in Circle',...
            'callback',@callbackfun_003)
        uimenu(options,'Label','Select EQ in Circle - Constant R',...
            'callback',@callbackfun_004)
        uimenu(options,'Label','Select EQ in Circle - Overlay existing plot',...
            'callback',@callbackfun_005)
        
        uimenu(options,'Label','Select EQ in Polygon -new ',...
            'callback',@callbackfun_006)
        uimenu(options,'Label','Select EQ in Polygon - hold ',...
            'callback',@callbackfun_007)
        
        op1 = uimenu('Label',' Maps ');
        
        %Meniu for adjusting several parameters.
        adjmenu =  uimenu(op1,'Label','Adjust Map Display Parameters'),...
            uimenu(adjmenu,'Label','Adjust Mmin cut',...
            'callback',@callbackfun_008)
        uimenu(adjmenu,'Label','Adjust Rmax cut',...
            'callback',@callbackfun_009)
        uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
            'callback',@callbackfun_010)
        uimenu(adjmenu,'Label','Adjust p-value st. dev. cut',...
            'callback',@callbackfun_011)
        
        
        uimenu(op1,'Label','b-value map (WLS)',...
            'callback',@callbackfun_012)
        uimenu(op1,'Label','b(max likelihood) map',...
            'callback',@callbackfun_013)
        uimenu(op1,'Label','Mag of completness map',...
            'callback',@callbackfun_014)
        uimenu(op1,'Label','max magnitude map',...
            'callback',@callbackfun_015)
        uimenu(op1,'Label','Magnitude range map (Mmax - Mcomp)',...
            'callback',@callbackfun_016)
        
        uimenu(op1,'Label','p-value',...
            'callback',@callbackfun_017)
        uimenu(op1,'Label','p-value standard deviation',...
            'callback',@callbackfun_018)
        
        uimenu(op1,'Label','a-value map',...
            'callback',@callbackfun_019)
        uimenu(op1,'Label','Standard error map',...
            'callback',@callbackfun_020)
        uimenu(op1,'Label','(WLS-Max like) map',...
            'callback',@callbackfun_021)
        
        uimenu(op1,'Label','Resolution Map',...
            'callback',@callbackfun_022)
        uimenu(op1,'Label','c map',...
            'callback',@callbackfun_023)
        
        uimenu(op1,'Label','Histogram ', 'callback',@(~,~)zhist())
        
        add_display_menu(1);
    end
    
    %% callback functions
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        web(['file:' hodi '/zmapwww/chp11.htm#996756']) ;
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        view_bpva;
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        met = 'ni';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cirpva;
        watchoff(bpmap);
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        met = 'ra';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cirpva;
        watchoff(bpmap);
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state2=true;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
        cirpva;
        watchoff(bpmap);
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        cufi = gcf;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        selectp;
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        cufi = gcf;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
        selectp;
    end
    
    function callbackfun_008(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'mag';
        adju2;
        view_bpva(lab1,valueMap) ;
    end
    
    function callbackfun_009(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'rmax';
        adju2;
        view_bpva(lab1,valueMap);
    end
    
    function callbackfun_010(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'gofi';
        adju2;
        view_bpva(lab1,valueMap) ;
    end
    
    function callbackfun_011(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'pstdc';
        adju2;
        view_bpva(lab1,valueMap) ;
    end
    
    function callbackfun_012(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 ='b-value';
        valueMap = old;
        view_bpva(lab1,valueMap);
    end
    
    function callbackfun_013(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='b-value';
        valueMap = meg;
        view_bpva(lab1,valueMap);
    end
    
    function callbackfun_014(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 = 'Mcomp';
        valueMap = old1;
        view_bpva(lab1,valueMap);
    end
    
    function callbackfun_015(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Mmax';
        valueMap = maxm;
        view_bpva(lab1,valueMap);
    end
    
    function callbackfun_016(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='dM ';
        valueMap = maxm-magco;
        view_bpva(lab1,valueMap);
    end
    
    function callbackfun_017(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='p-value';
        valueMap = pvalg;
        view_bpva(lab1,valueMap);
    end
    
    function callbackfun_018(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='p-valstd';
        valueMap = pvstd;
        view_bpva(lab1,valueMap);
    end
    
    function callbackfun_019(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='a-value';
        valueMap = avm;
        view_bpva(lab1,valueMap);
    end
    
    function callbackfun_020(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Error in b';
        valueMap = pro;
        view_bpva(lab1,valueMap);
    end
    
    function callbackfun_021(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='difference in b';
        valueMap = old-meg;
        view_bpva(lab1,valueMap);
    end
    
    function callbackfun_022(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Radius in [km]';
        valueMap = rama;
        view_bpva(lab1,valueMap);
    end
    
    function callbackfun_023(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='c in days';
        valueMap = cmap2;
        view_bpva(lab1,valueMap);
    end
    
end
