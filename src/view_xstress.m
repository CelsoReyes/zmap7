function view_xstress(lab1,valueMap)
    % Script to display results creates with cross_stress.m
    %
    % Needs valueMap, gx, gy, stri
    %
    % last modified: J. Woessner, 02.2004
    if isempty(lab1); lab1='';end; %CR
    ZG=ZmapGlobal.Data;
    report_this_filefun(mfilename('fullpath'));
    % Color shortcut
    ZG.someColor = 'w';
    
    % Find out if figure already exists
    stressmap=findobj('Type','Figure','-and','Name','Stress-section');
    
    
    % Set up the Seismicity Map window Enviroment
    if isempty(stressmap)
        stressmap = figure_w_normalized_uicontrolunits( ...
            'Name','Stress-section',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        create_my_menu();
        
        re4 = valueMap;

        colormap(jet)
        ZG.tresh_km = nan; minpe = nan; Mmin = nan;
        
    end   % This is the end of the figure setup
    
    % Now lets plot the color-maps
    figure(stressmap);
    delete(findobj(stressmap,'Type','axes'));
    reset(gca)
    cla
    hold off
    watchon;
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','SortMethod','childorder')
    
    % Figure position
    rect = [0.18,  0.10, 0.7, 0.75];
    
    % Find max and min of data for automatic scaling
    ZG.maxc = max(valueMap(:));
    ZG.maxc = fix(ZG.maxc)+1;
    ZG.minc = min(valueMap(:));
    ZG.minc = fix(ZG.minc)-1;
    
    % Plot image
    orient landscape
    
    axes('position',rect)
    hold on
    pco1 = pcolor(gx,gy,valueMap);
    
    axis([ min(gx) max(gx) min(gy) max(gy)])
    axis image
    hold on

    shading(ZG.shading_style);

    fix_caxis.ApplyIfFrozen(gca); 

    xlabel('Distance in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel('Depth in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    
    % plot overlay
    %
    ploeqc = plot(newa(:,end),-newa(:,7),'.k');
    set(ploeqc,'Tag','eqc_plot','MarkerSize',ZG.ms6,'Marker',ty,'Color',ZG.someColor,'Visible','on')
    
    if exist('vox', 'var')
        plovo = plot(vox,voy,'*b');
        set(plovo,'MarkerSize',6,'LineWidth',1)
    end
    
    if exist('maix', 'var')
        pl = plot(maix,maiy,'*k');
        set(pl,'MarkerSize',12,'LineWidth',2)
    end
    
    if exist('maex', 'var')
        pl = plot(maex,-maey,'hm');
        set(pl,'LineWidth',1.5,'MarkerSize',12,...
            'MarkerFaceColor','w','MarkerEdgeColor','k')
        
    end
    
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    h1 = gca;
    hzma = gca;
    
    % Create a colorbar
    %
    h5 = colorbar('horiz');
    set(h5,'Pos',[0.35 0.2 0.4 0.02],...
        'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s,'TickDir','out')
    
    rect = [0.00,  0.0, 1 1];
    axes('position',rect)
    axis('off')
    %  Text Object Creation
    txt1 = text(...
        'Units','normalized',...
        'Position',[ 0.33 0.21 0 ],...
        'HorizontalAlignment','right',...
        'FontSize',ZmapGlobal.Data.fontsz.s,....
        'FontWeight','bold',...
        'String',lab1);
    
    % Make the figure visible
    set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    % Print orientation
    orient portrait
    figure(stressmap);
    axes(h1)
    watchoff(stressmap)
    
    
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        
        add_symbol_menu('eqc_plot');
        
        % Menu Select
        options = uimenu('Label',' Select ');
        uimenu(options,'Label','Refresh ',MenuSelectedFcnName(),@callbackfun_001)
        uimenu(options,'Label','Select N closest EQs',...
            MenuSelectedFcnName(),@callbackfun_002)
        uimenu(options,'Label','Select EQ in Circle - Constant R',...
            MenuSelectedFcnName(),@callbackfun_003)
        uimenu(options,'Label','Select EQ in Polygon',...
            MenuSelectedFcnName(),@callbackfun_004)
        
        % Menu Maps
        op1 = uimenu('Label',' Maps ');
        uimenu(op1,'Label','Variance',...
            MenuSelectedFcnName(),@callbackfun_005)
        uimenu(op1,'Label','Phi',...
            MenuSelectedFcnName(),@callbackfun_006)
        uimenu(op1,'Label','Trend S1',...
            MenuSelectedFcnName(),@callbackfun_007)
        uimenu(op1,'Label','Plunge S1',...
            MenuSelectedFcnName(),@callbackfun_008)
        uimenu(op1,'Label','Trend S2',...
            MenuSelectedFcnName(),@callbackfun_009)
        uimenu(op1,'Label','Plunge S2',...
            MenuSelectedFcnName(),@callbackfun_010)
        uimenu(op1,'Label','Trend S3',...
            MenuSelectedFcnName(),@callbackfun_011)
        uimenu(op1,'Label','Plunge S3',...
            MenuSelectedFcnName(),@callbackfun_012)
        uimenu(op1,'Label','Angular misfit',...
            MenuSelectedFcnName(),@callbackfun_013)
        uimenu(op1,'Label','\tau spread',...
            MenuSelectedFcnName(),@callbackfun_014)
        uimenu(op1,'Label','Resolution map (const. Radius)',...
            MenuSelectedFcnName(),@callbackfun_015)
        uimenu(op1,'Label','Resolution map',...
            MenuSelectedFcnName(),@callbackfun_016)
        uimenu(op1,'Label','Trend S1 relative to fault strike',...
            MenuSelectedFcnName(),@callbackfun_017)
        %uimenu(op1,'Label','Histogram ',MenuSelectedFcnName(),@(~,~)zhist())
        
        % Menu Display
        add_display_menu(1);
    end
    
    %% callback functions
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        valueMap = r;
        view_xstress(lab1,valueMap);
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cicros(1);
        watchon;
        doinvers_michael;
        watchoff;
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cicros(2);
        watchon;
        doinvers_michael;
        watchoff;
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1=gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cicros(3);
        watchon;
        doinvers_michael;
        watchoff;
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='\sigma';
        valueMap = mVariance;
        view_xstress(lab1,valueMap);
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='\Phi';
        valueMap = mPhi;
        view_xstress(lab1,valueMap);
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='S1 trend [deg]';
        valueMap = mTS1;
        view_xstress(lab1,valueMap);
    end
    
    function callbackfun_008(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='S1 plunge [deg]';
        valueMap = mPS1;
        view_xstress(lab1,valueMap);
    end
    
    function callbackfun_009(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='S2 trend [deg]';
        valueMap = mTS2;
        view_xstress(lab1,valueMap);
    end
    
    function callbackfun_010(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='S2 plunge [deg]';
        valueMap = mPS2;
        view_xstress(lab1,valueMap);
    end
    
    function callbackfun_011(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='S3 trend [deg]';
        valueMap = mTS3;
        view_xstress(lab1,valueMap);
    end
    
    function callbackfun_012(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='S3 plunge [deg]';
        valueMap = mPS3;
        view_xstress(lab1,valueMap);
    end
    
    function callbackfun_013(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='\beta [deg]';
        valueMap = mBeta;
        view_xstress(lab1,valueMap);
    end
    
    function callbackfun_014(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='\tau [deg]';
        valueMap = mTau;
        view_xstress(lab1,valueMap);
    end
    
    function callbackfun_015(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Radius in [km]';
        valueMap = mResolution;
        view_xstress(lab1,valueMap);
    end
    
    function callbackfun_016(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Number of events';
        valueMap = mNumber;
        view_xstress(lab1,valueMap);
    end
    
    function callbackfun_017(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='S1 trend to strike [deg]';
        valueMap = mTS1Rel;
        view_xstress(lab1,valueMap);
    end
    
end
