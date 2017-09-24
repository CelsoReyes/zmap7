function view_bvtmap(lab1,valueMap)
    % This .m file plots the differential b values calculated
    % with bvalmapt.m or other similar values as a color map
    % needs valueMap, gx, gy, stri
    %
    % define size of the plot etc.
    %

    
    report_this_filefun(mfilename('fullpath'));
    ZG=ZmapGlobal.Data;
    % Find out if figure already exists
    %
    bmap=findobj('Type','Figure','-and','Name','differential b-value-map');
    
    % Set up the Seismicity Map window Enviroment
    %
    if isempty(bmap)
        bmap = figure_w_normalized_uicontrolunits( ...
            'Name','differential b-value-map',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',[ (ZG.fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
        % make menu bar
        
        
        lab1 = 'Db';
        
        
        uicontrol('Units','normal',...
            'Position',[.0 .93 .08 .06],'String','Info ',...
            'callback',@callbackfun_001);
        
        create_my_menu();
        
        
        ZG.tresh_km = nan; re4 = valueMap;
        nilabel2 = uicontrol('style','text','units','norm','pos',[.60 .92 .25 .04],'backgroundcolor','w');
        set(nilabel2,'string','Min Probability:');
        set_ni2 = uicontrol('style','edit','value',ZG.tresh_km,'string',num2str(ZG.tresh_km),...
            'background','y');
        set(set_ni2,'callback',@callbackfun_021)
        set(set_ni2,'units','norm','pos',[.85 .92 .08 .04],'min',0.01,'max',10000);
        
        uicontrol('Units','normal',...
            'Position',[.95 .93 .05 .05],'String','Go ',...
            'callback',@callbackfun_022)
        
        colormap(jet)
        
    end   % This is the end of the figure setup
    
    % Now lets plot the color-map of the z-value
    %
    figure(bmap)
    delete(findobj(bmap,'Type','axes'));
    % delete(sizmap);
    reset(gca)
    cla
    hold off
    watchon;
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
        'LineWidth',1.,...
        'Box','on','SortMethod','childorder')
    
    rect = [0.18,  0.10, 0.7, 0.75];
    rect1 = rect;
    
    % find max and min of data for automatic scaling
    %
    ZG.maxc = max(valueMap(:));
    ZG.maxc = fix(ZG.maxc)+1;
    ZG.minc = min(valueMap(:));
    ZG.minc = fix(ZG.minc)-1;
    
    % set values gretaer ZG.tresh_km = nan
    %
    re4 = valueMap;
    l = pro < ZG.tresh_km;
    re4(l) = nan(1,length(find(l)));
    
    % plot image
    %
    orient landscape
    %set(gcf,'PaperPosition', [0.5 1 9.0 4.0])
    
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
        'Color','k','FontWeight','normal')
    
    xlabel('Longitude [deg]','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
    ylabel('Latitude [deg]','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
    
    % plot overlay
    %
    hold on
    update(mainmap())
    ploeq = plot(ZG.a.Longitude,ZG.a.Latitude,'k.');
    set(ploeq,'Tag','eq_plot','MarkerSize',ZG.ms6,'Marker',ty,'Color',ZG.someColor,'Visible','on')
    
    
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
        'LineWidth',1.,...
        'Box','on','TickDir','out')
    h1 = gca;
    hzma = gca;
    
    % Create a colorbar
    %
    h5 = colorbar('horiz');
    set(h5,'Pos',[0.35 0.05 0.4 0.02],...
        'TickDir','out','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
    
    rect = [0.00,  0.0, 1 1];
    axes('position',rect)
    axis('off')
    %  Text Object Creation
    txt1 = text(...
        'Units','normalized',...
        'Position',[ 0.33 0.07 0 ],...
        'HorizontalAlignment','right',...
        'FontSize',ZmapGlobal.Data.fontsz.s,....
        'FontWeight','normal',...
        'String',lab1);
    
    %RZ make  reset button
    %    uicontrol('Units','normal','Position',...
    %  [.85 .10 .15 .05],'String','Reset Catalog', 'callback',@callbackfun_023);
    
    %resets catalog  (useful for the random b map)
    %clear plos1 mark1 conca ; replaceMainCatalog(storedcat); ZG.newcat=storedcat; ZG.newt2=storedcat; stri = ['' '']; stri1 = ['' ''];
    
    % Make the figure visible
    %
    set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
        'FontWeight','normal','LineWidth',1.,...
        'Box','on','TickDir','out','Ticklength',[0.02 0.02])
    figure(bmap);
    %sizmap = signatur('ZMAP','',[0.01 0.04]);
    %set(sizmap,'Color','k')
    axes(h1)
    watchoff(bmap)
    %whitebg(gcf,[ 0 0 0 ])
    set(gcf,'Color','w')
    
    
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
        uimenu(options,'Label','Select EQ in Circle - Time split',...
            'callback',@callbackfun_005)
        uimenu(options,'Label','Select EQ in Circle - Overlay existing plot',...
            'callback',@callbackfun_006)
        
        uimenu(options,'Label','Select EQ in Polygon -new ',...
            'callback',@callbackfun_007)
        uimenu(options,'Label','Select EQ in Polygon - hold ',...
            'callback',@callbackfun_008)
        
        
        op1 = uimenu('Label',' Maps ');
        uimenu(op1,'Label','Differential b-value map ',...
            'callback',@callbackfun_009)
        uimenu(op1,'Label','b change in percent map  ',...
            'callback',@callbackfun_010)
        uimenu(op1,'Label','b-value map first period',...
            'callback',@callbackfun_011)
        uimenu(op1,'Label','b-value map second period',...
            'callback',@callbackfun_012)
        uimenu(op1,'Label','Probability Map (Utsus test for b1 and b2) ',...
            'callback',@callbackfun_013)
        uimenu(op1,'Label','Earthquake probability change map (M5) ',...
            'callback',@callbackfun_014)
        uimenu(op1,'Label','standard error map',...
            'callback',@callbackfun_015)
        
        uimenu(op1,'Label','mag of completeness map - period 1',...
            'callback',@callbackfun_016)
        uimenu(op1,'Label','mag of completeness map - period 2',...
            'callback',@callbackfun_017)
        uimenu(op1,'Label','differential completeness map ',...
            'callback',@callbackfun_018)
        uimenu(op1,'Label','resolution Map - number of events ',...
            'callback',@callbackfun_019)
        uimenu(op1,'Label','Histogram ', 'callback',@(~,~)zhist())
        
        add_display_menu(1)
    end
    
    %% callback functions
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        web(['file:' hodi '/zmapwww/chp11.htm#996756']) ;
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        view_bvtmap(lab1,valueMap);
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        met = 'ni';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cirbva;
        watchoff(bmap);
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        met = 'ra';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cirbva;
        watchoff(bmap);
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        met = 'ti';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cirbvat;
        watchoff(bmap);
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
        cirbva;
        watchoff(bmap);
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        cufi = gcf;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        selectp;
    end
    
    function callbackfun_008(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        cufi = gcf;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
        selectp;
    end
    
    function callbackfun_009(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 ='b-value';
        valueMap = db12;
        view_bvtmap(lab1,valueMap);
    end
    
    function callbackfun_010(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 ='b-value change';
        valueMap = dbperc;
        view_bvtmap(lab1,valueMap);
    end
    
    function callbackfun_011(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 ='b-value';
        valueMap = bm1;
        view_bvtmap(lab1,valueMap);
    end
    
    function callbackfun_012(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 ='b-value';
        valueMap = bm2;
        view_bvtmap(lab1,valueMap);
    end
    
    function callbackfun_013(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 ='P';
        valueMap = pro;
        view_bvtmap(lab1,valueMap);
    end
    
    function callbackfun_014(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 ='dP';
        valueMap = log10(maxm);
        view_bvtmap(lab1,valueMap);
    end
    
    function callbackfun_015(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='error in b';
        valueMap = stanm;
        view_bvtmap(lab1,valueMap);
    end
    
    function callbackfun_016(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 = 'Mcomp1';
        valueMap = magco1;
        view_bvtmap(lab1,valueMap);
    end
    
    function callbackfun_017(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 = 'Mcomp2';
        valueMap = magco2;
        view_bvtmap(lab1,valueMap);
    end
    
    function callbackfun_018(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 = 'DMc';
        valueMap = dmag;
        view_bvtmap(lab1,valueMap);
    end
    
    function callbackfun_019(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='# of events';
        valueMap = r;
        view_bvtmap(lab1,valueMap);
    end

    
    function callbackfun_021(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.tresh_km=str2double(set_ni2.String);
        set_ni2.String=num2str(ZG.tresh_km);
    end
    
    function callbackfun_022(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        
        pause(1);
        re4 =valueMap;
        view_bvtmap(lab1,valueMap);
    end
    
    function callbackfun_023(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        
        clear plos1 mark1 conca ;
        replaceMainCatalog(storedcat);
        ZG.newcat=storedcat;
        ZG.newt2=storedcat;
        stri = [' '];
        stri1 = [' '];
    end
end

