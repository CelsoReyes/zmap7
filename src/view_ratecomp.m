function view_ratecomp(det,valueMap)
    % view_maxz plots the maxz LTA values calculated
    % with maxzlta.m or other similar values as a color map
    % needs valueMap, gx, gy, stri
    %
    % define size of the plot etc.
    %
    % INPUT VARIABLES: det, valueMap
    
    %%
    % TODO: delete this file, it is no longer neccessary
    %%
    
    
    report_this_filefun(mfilename('fullpath'));
    ZG=ZmapGlobal.Data;
    ZG.someColor = 'w';
    clear title;
    
    % Find out if figure already exists
    %
    zmap=findobj('Type','Figure','-and','Name','Z-Value-Map');
    
    
    % Set up the Seismicity Map window Enviroment
    %
    if isempty(zmap)
        zmap = figure_w_normalized_uicontrolunits( ...
            'Name','Z-Value-Map',...
            'NumberTitle','off', ...
            'NextPlot','replace', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        create_my_menu();
        
        
        colormap(jet);
        
    end   % This is the end of the figure setup
    
    % Now lets plot the color-map of the z-value
    %
    figure(zmap);
    delete(findobj(zmap,'Type','axes'));
    % delete(sizmap);
    reset(gca)
    cla
    hold off
    watchon;
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,...
        'FontWeight','bold','LineWidth',1,...
        'Box','on','SortMethod','childorder')
    
    rect = [0.18,  0.10, 0.7, 0.75];
    
    % find max and min of data for automatic scaling
    %
    ZG.maxc = max(valueMap(:));
    ZG.maxc = fix(ZG.maxc)+1;
    ZG.minc = min(valueMap(:));
    ZG.minc = fix(ZG.minc)-1;
    
    
    % plot image
    %
    orient landscape
    set(gcf,'PaperPosition',[ 0.1 0.1 8 6])
    axes('position',rect)
    hold on
    pcolor(gx,gy,valueMap);
    axis([ s2 s1 s4 s3])
    
    shading(ZG.shading_style);

    fix_caxis.ApplyIfFrozen(gca); 
    
    if  det == 'per'
        coma = jet;
        coma = coma(64:-1:1,:);
        colormap(coma)
    end
    
    title([  num2str(t1,6) ' - ' num2str(t2,6) ' - compared with ' num2str(t3,6) ' - ' num2str(t4,6) ],'FontSize',ZmapGlobal.Data.fontsz.m,...
        'Color','k','FontWeight','normal')
    
    xlabel('Longitude [deg]','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel('Latitude [deg]','FontSize',ZmapGlobal.Data.fontsz.m)
    
    % plot overlay
    %
    zmap_update_displays();
    %set(ploeq,'MarkerSize',ZG.ms6,'Marker',ty,'Color',ZG.someColor,'visible','on');
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    h1 = gca;
    hzma = gca;
    
    % Create a colobar
    %
    h5 = colorbar('horiz');
    set(h5,'Pos',[0.35 0.05 0.4 0.02],...
        'FontSize',ZmapGlobal.Data.fontsz.m,'TickDir','out')
    
    %  Text Object Creation
    txt1 = text(...
        'Units','normalized',...
        'Position',[ 0.05 -0.27 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m,...
        'String','z-value ');
    if det =='per'
        set(txt1,'String','% change')
    end
    if det =='pro'
        set(txt1,'String','Probability')
    end
    if det =='res'
        set(txt1,'String','Radius  [km]')
    end
    if det =='bet'
        set(txt1,'String','beta ')
    end
    % Make the figure visible
    %
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
        'LineWidth',1.0,'Color','w',...
        'Box','on','TickDir','out','Ticklength',[0.02 0.02])
    set(gcf,'color','w');
    
    figure(zmap);
    %sizmap = signatur('ZMAP','',[0.01 0.04]);
    %set(sizmap,'Color','k')
    axes(h1)
    watchoff(zmap)
    
    
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        
        add_symbol_menu()
        
        options = uimenu('Label',' Select ');
        uimenu(options,'Label','Refresh ', 'callback',@callbackfun_001)
        uimenu(options,'Label','Select EQ in Circle - const Ni', 'callback',@callbackfun_002)
        uimenu(options,'Label','Select EQ in Circle - const R2', 'callback',@callbackfun_003)
        
        uimenu(options,'Label','Select EQ in Polygon ', 'callback',@callbackfun_004)
        
        
        op1 = uimenu('Label',' Maps ');
        
        uimenu(op1,'Label','z-value map ','callback',@callbackfun_005) % ('z value',old) 'ast'
        uimenu(op1,'Label','Percent change map','callback',@callbackfun_006) % ('% change',per)
        uimenu(op1,'Label','Beta value map','callback',@callbackfun_007) % ('beta',beta_map) [sic]
        
        uimenu(op1,'Label','Significance based on beta map','callback',@callbackfun_008) %('beta',betamap) [sic]
        
        uimenu(op1,'Label','Resolution Map',...
            'callback',@callbackfun_009) %('Radius [km]',reso);
        
        op1 = uimenu('Label','  Display ');
        uimenu(op1,'Label','Plot Map in Lambert projection', 'callback',@callbackfun_010)
        uimenu(op1,'Label','Fix color (z) scale', 'callback',@(~,~)fix_caxis(ZGvalueMap,'horz') )
        uimenu(op1,'Label','Plot map on top of topography (white background)',...
            'callback',@(~,~)dramap_z(1,valueMap))
        uimenu(op1,'Label','Plot map on top of topography (black background)',...
            'callback',@(~,~)dramap_z(2,valueMap))
        uimenu(op1,'Label','Histogram of map-values', 'callback',@(~,~)zhist())
        uimenu(op1,'Label','Colormap InvertGray', 'callback',@callbackfun_015)
        uimenu(op1,'Label','Colormap Invertjet',...
            'callback',@callbackfun_016)
        
        uimenu(op1,'Label','shading flat', 'callback',{@cb_shading,'flat'})
        uimenu(op1,'Label','shading interpolated','callback',{@cb_shading,'interp'})
        uimenu(op1,'Label','Brigten +0.4','callback', {@cb_brighten, 0.4})
        uimenu(op1,'Label','Brigten -0.4','callback', {@cb_brighten, -0.4})
        
        uimenu(op1,'Label','Redraw overlay','callback',@callbackfun_022)
    end
    
    %% callback functions
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        delete(findobj(xmsp,'Type','axes'));
        view_ratecomp(det,valueMap);
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        nosort = 'on';
        h1 = gca;
        circle;
        watchoff(zmap);
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        nosort = 'on';
        h1 = gca;
        circle_constR;
        watchoff(zmap);
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        nosort = 'on';
        stri = 'Polygon';
        h1 = gca;
        cufi = gcf;
        selectp;
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        det ='ast';
        valueMap = old;
        view_ratecomp(det,valueMap);
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        det='per';
        valueMap = per;
        view_ratecomp(det,valueMap);
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        det='bet';
        valueMap = beta_map;
        view_ratecomp(det,valueMap);
    end
    
    function callbackfun_008(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        det='bet';
        valueMap = betamap;
        view_ratecomp(det,valueMap);
    end
    
    function callbackfun_009(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Radius in [km]';
        valueMap = reso;
        view_ratecomp(det,valueMap);
    end
    
    function callbackfun_010(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        re4 = valueMap;
        plotmap ;
    end
    

    function callbackfun_015(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        g=gray;
        g = g(64:-1:1,:);
        colormap(g);
        brighten(.4);
    end
    
    function callbackfun_016(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        g=jet;
        g = g(64:-1:1,:);
        colormap(g);
    end
    
    function cb_shading(mysrc,myevt,shading_style)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.shading_style=shading_style;
        axes(hzma);
        shading(shading_style);
    end
    
    function cb_brighten(mysrc,myevt,val)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        axes(hzma);
        brighten(val);
    end
    
    
    function callbackfun_022(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        hold on;
        zmap_update_displays();
    end
end
