function view_varmap(lab1,valueMap, newgri, sor)
    % view_maxz plots the maxz LTA values calculated
    % with maxzlta.m or other similar values as a color map
    % needs valueMap, gx, gy, stri
    %
    % define size of the plot etc.
    %
    ZG=ZmapGlobal.Data;
    % Prmap = nan(size(valueMap));
    
    % Find out if figure already exists
    %
    bmap=findobj('Type','Figure','-and','Name','variance-value-map');
    
    
    % Set up the Seismicity Map window Enviroment
    %
    if isempty(bmap)
        bmap = figure_w_normalized_uicontrolunits( ...
            'Name','variance-value-map',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        
        lab1 = 'b-value:';
        
        create_my_menu();
        
        re4 = valueMap;
        
        colormap(jet)
        ZG.tresh_km = nan; 
        minpe = nan; 
        Mmin = nan;
        
    end   % This is the end of the figure setup
    
    % Now lets plot the color-map of the z-value
    %
    figure(bmap);
    delete(findobj(bmap,'Type','axes'));
    % delete(sizmap);
    ax = reset(gca);
    cla(ax)
    set(ax,'NextPlot','replace')
    watchon;
    set(ax,'visible','off',...
        'FontSize',ZmapGlobal.Data.fontsz.s,...
        'FontWeight','normal',...
        'LineWidth',1,...
        'Box','on','SortMethod','childorder')
        
    % find max and min of data for automatic scaling
    ZG.maxc = fix(max(valueMap(:))+1);
    ZG.minc = fix(min(valueMap(:)))-1;
    
    % set values gretaer ZG.tresh_km = nan
    %
    re4 = valueMap;
    
    % plot image
    %
    orient(ax,'landscape')
    
    ax.Position = [0.12,  0.10, 0.8, 0.8];
    set(gca,'NextPlot','add')
    pcolor(ax, gx,gy,re4);
    
    axis(ax, [min(gx) max(gx) min(gy) max(gy)])
    axis(ax,'image')
    set(gca,'NextPlot','add')
    
    shading(ax, ZG.shading_style);

    % make the scaling for the recurrence time map reasonable

    fix_caxis.ApplyIfFrozen(ax); 
    
    title(ax, sprintf('%s ;  %g to %g',name, t0b, teb),...
        'FontSize',ZmapGlobal.Data.fontsz.s,...
        'Color','k',...
        'FontWeight','normal')
    
    xlabel(ax, 'Longitude [deg]','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
    ylabel(ax, 'Latitude [deg]','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
    
    % plot overlay
    %
    set(ax,'NextPlot','add')
    zmap_update_displays();
    
    set(ax,'NextPlot','add')
    quiver(ax, newgri(:,1),newgri(:,2), -cos(sor(:,SA*2)*pi/180), sin(sor(:,SA*2)*pi/180),0.8,'.', ...
        'LineWidth',1, 'Color','k')
    
    set(ax,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,...
        'FontWeight','normal',...
        'LineWidth',1,...
        'Box','on',...
        'TickDir','out');
    
    h1 = ax;
    hzma = ax;
    
    % Create a colorbar
    %
    h5 = colorbar('horiz');
    set(h5,'Pos',[0.35 0.06 0.4 0.02],...
        'FontWeight','normal',...
        'FontSize',ZmapGlobal.Data.fontsz.s,...
        'TickDir','out')
    
    
    axes('position', [0.00,  0.0, 1 1])
    axis('off')
    %  Text Object Creation
    text(...
        'Units','normalized',...
        'Position',[ 0.33 0.06 0 ],...
        'HorizontalAlignment','right',...
        'FontSize',ZmapGlobal.Data.fontsz.s,....
        'FontWeight','normal',...
        'String','Variance');
    
    % Make the figure visible
    %
    set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,...
        'FontWeight','normal','LineWidth',1,...
        'Box','on','TickDir','out');
    set(gcf,'color','w');
    figure(bmap);
    axes(h1)
    watchoff(bmap)
    
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        
        options = uimenu('Label',' Select ');
        uimenu(options,'Label','Refresh ','MenuSelectedFcn',@cb_refresh)
        uimenu(options,'Label','Select EQ in Circle',...
            'MenuSelectedFcn',@select_in_circle)
        uimenu(options,'Label','Select EQ in Circle - Constant R',...
            'MenuSelectedFcn',@cb_select_in_constr)
        
        uimenu(options,'Label','Select EQ in Polygon -new ',...
            'MenuSelectedFcn',@cb_select_in_polygon_new)
        
        op1 = uimenu('Label',' Maps ');
        
        uimenu(op1,'Label','Variance map',...
            'MenuSelectedFcn',@cb_variancemap)
        uimenu(op1,'Label','Resolution map',...
            'MenuSelectedFcn',@cb_resolutionmap)
        uimenu(op1,'Label','Plot map on top of topography ',...
            'MenuSelectedFcn',@cb_plot_on_topography)
        
        uimenu(op1,'Label','Histogram ','MenuSelectedFcn',@(~,~)zhist())
        
        add_display_menu(1)
    end
    
    %% callback functions
    
    function cb_refresh(~,~)
        view_varmap(lab1, re4);
    end
    
    function select_in_circle(~,~)
        h1 = gca;
        met = 'ni';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        circle;
        watchon;
        doinvers_michael;
        watchoff;
    end
    
    function cb_select_in_constr(~,~)
        h1 = gca;
        met = 'ra';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        circle;
        watchon;
        doinvers_michael;
        watchoff;
    end
    
    function cb_select_in_polygon_new(~,~)
        cufi = gcf;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        selectp;
        watchon;
        doinvers_michael;
        watchoff;
    end
    
    function cb_variancemap(~,~)
        view_varmap('b-value',r);
    end
    
    function cb_resolutionmap(~,~)
        view_varmap('Radius', rama);
    end
    
    function cb_plot_on_topography(~,~)
        dramap_z('stress2','w',valueMap);
    end

end
