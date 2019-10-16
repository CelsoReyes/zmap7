function view_Dv(valueMap, lab1, Da) 
    % plots the maxz LTA values calculated
    % with maxzlta.m or other similar values as a color map
    % needs valueMap, gx, gy, stri
    % Called from Dcross.m
    %
    % define size of the plot etc.
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals

    
    report_this_filefun();
    myFigName='D-value cross-section';
    myFigFinder=@() findobj('Type','Figure','-and','Name',myFigName);
    ZG.someColor = 'w';
    
    bmapc = myFigFinder();
    
    
    % Set up the Seismicity Map window Enviroment
    %
    if isempty(bmapc)
        bmapc = figure_w_normalized_uicontrolunits( ...
            'Name',myFigName',...
            'NumberTitle','off', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        % make menu bar
        
        lab1 = 'D-value';
        
        uicontrol('Units','normal',...
            'Position',[.0 .95 .08 .06],'String','Info ',...
            'callback',@callbackfun_001)
        
        colormap(jet)
    end   % This is the end of the figure setup
    
    % Now lets plot the color-map of the D-value
    %
    figure(bmapc);
    delete(findobj(bmapc,'Type','axes'));
    reset(gca)
    cla
    watchon;
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1,...
        'Box','on','SortMethod','childorder')
    
    rect = [0.10,  0.10, 0.8, 0.75];
    rect1 = rect;
    
    % set values greater ZG.tresh_km = nan
    %
    re4 = valueMap;
    re4(r > ZG.tresh_km) = nan;
    
    % plot image
    %
    orient portrait
    
    ax = axes('position',rect);
    set(gca,'NextPlot','add');
    % Here is the important  line ...
    pco1 = pcolor(gx,gy,re4);
    
    axis(ax, [ min(gx) max(gx) min(gy) max(gy)]);
    axis(ax,'image');
    set(ax,'NextPlot','add');
    
    shading(ax, ZG.shading_style);
        

    fix_caxis.ApplyIfFrozen(ax); 
    
    title(ax, name,'FontSize',12,'Color','w','FontWeight','bold')
    xlabel(ax, 'Distance in [km]','FontWeight','bold','FontSize',12)
    ylabel(ax, 'Depth in [km]','FontWeight','bold','FontSize',12)
    
    % plot overlay
    ploeqc = plot(ax, Da(:,1),-Da(:,7),'.k');
    set(ploeq,'Tag', 'eqc_plot''MarkerSize',ZG.ms6,'Marker',ty,'Color',ZG.someColor,'Visible','on')
    
    
    set(ax,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    hzma = gca;
    
    % Create a colorbar
    %
    h5 = colorbar('horz');
    set(h5,'Pos',[0.3 0.1 0.4 0.02],...
        'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'TickDir','out')
    
    rect = [0.00,  0.0, 1 1];
    axes('position',rect)
    axis('off')
    
    %  Text Object Creation
    
    txt1 = text(...
        'Color',[ 1 1 1 ],...
        'Position',[0.55 0.03],...
        'HorizontalAlignment','right',...
        'FontSize',ZmapGlobal.Data.fontsz.m,....
        'FontWeight','bold',...
        'String',lab1);
    
    % Make the figure visible
    
    axes(h1)
    set(ax,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    whitebg(gcf,[0 0 0])
    set(gcf,'Color',[ 0 0 0 ])
    figure(bmapc);
    watchoff(bmapc)
    
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        
        add_symbol_menu('eqc_plot');
        create_my_menu();
        
        
        options = uimenu('Label',' Select ');
        uimenu(options,'Label','Refresh ',MenuSelectedField(), @cb_refresh)
        
        uimenu(options,'Label','Select EQ in Sphere (const N)',...
            MenuSelectedField(),@cb_select_eq_sphere)
        uimenu(options,'Label','Select EQ in Sphere (const R)',...
            MenuSelectedField(),@cb_select_eq_constr)
        uimenu(options,'Label','Select EQ in Sphere (N) - Overlay existing plot',...
            MenuSelectedField(),@cb_select_eq_spheren)
        %
        %
        
        op1 = uimenu('Label',' Maps ');
        
        uimenu(op1,'Label','D-value Map (weighted LS)',...
            MenuSelectedField(),@cb_dvalue);
        
        %  uimenu(op1,'Label','Goodness of fit  map',...
        %      MenuSelectedField(),@callbackfun_007);
        
        uimenu(op1,'Label','b-value Map',...
            MenuSelectedField(),@cb_bval);
        
        uimenu(op1,'Label','resolution Map',...
            MenuSelectedField(),@cb_resolution);
        
        uimenu(op1,'Label','Histogram ',MenuSelectedField(),@cb_hist);
        
        uimenu(op1,'Label','D versus b',...
            MenuSelectedField(),@cb_d_vs_b);
        
        uimenu(op1,'Label','D versus Resolution',...
            MenuSelectedField(),@cb_d_vs_resolution)
        %
        add_display_menu(3);
    end
    
    %% callback functions
    
    function cb_hist(~,~)
        zhist(re4)
    end
    
    function callbackfun_001(~,~)
        zmaphelp(ttlStr,hlpStr1zmap,hlpStr2zmap);
    end
    
    function cb_refresh(~,~)
        view_Dv(re4, lab1, Da);
    end
    
    function cb_select_eq_sphere(~,~)
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        ic = 1;
        org = [5];
        startfd(5);
    end
    
    function cb_select_eq_constr(~,~)
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        icCircl = 2;
        org = [5];
        startfd(5);
    end
    
    function cb_select_eq_spheren(~,~)
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
        ic = 1;
        org = [5];
        startfd(5);
    end
    
    function cb_dvalue(~,~)
        view_Dv(old, 'D-value', Da);
    end
    
    function cb_pct(~,~)
        view_Dv(Prmap, '%', Da);
    end
    
    function cb_bval(~,~)
        view_Dv(BM, 'b-value', Da);
    end
    
    function cb_resolution(~,~)
        view_Dv(reso, 'Radius in [km]',Da);
    end
    
    function cb_d_vs_b(~,~)
        Dvbspat;
    end
    
    function cb_d_vs_resolution(~,~)
        Dvresfig;
    end
    
end
