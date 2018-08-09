function cummomentplot(obj,tabgrouptag)
    %CUMMOMENTPLOT plot the Cumulative Moment into the specified tab group
    
    Tags.xs = 'CumMom xs contextmenu';
    Tags.bg = 'CumMom bg contextmenu';
    Tags.line = 'CumMom line contextmenu';
    Tags.ax = 'CumMom axes';
    
    
    myTab = findOrCreateTab(obj.fig, tabgrouptag, 'Moment');
    ax=findobj(myTab.Children,'flat','Tag',Tags.ax);
    if isempty(ax)
        ax              = axes(myTab);
        ax.TickDir      = 'out';
        ax.YMinorTick   = 'on';
        ax.Box          = 'on';
        ax.Tag          = Tags.ax;
        ax.UserData     = CumMomentAnalysisWindow(ax);
        grid(ax, 'on');
    end
    craw = ax.UserData;
    
    
    %% plot the main series
    lineProps.Color         = [0 0 0];
    lineProps.LineWidth     = 2.5;
    lineProps.UIContextMenu = line_plot_context_menu();
    lineProps.MinBigMag     = ZmapGlobal.Data.CatalogOpts.BigEvents.MinMag;
    lineProps.DisplayName   = obj.catalog.Name;
    
    craw.add_series(obj.catalog, 'catalog', lineProps);
    
    %% plot & synchronize cross sections
    
    
    plotted_xs = get(ax.Children,'Tag');
    plotted_xs = plotted_xs(startsWith(plotted_xs, 'Xsection'));
    
    if ~isempty(plotted_xs)
     existing_xs = obj.XSectionTitles;
        % delete cross sections that shouldn't exist
        todel = plotted_xs(~ismember(plotted_xs,existing_xs));
        craw.remove_series(todel);
    end
    %% if necessary, add context menu to figure
    cxs=findobj(obj.fig,'Tag',Tags.xs);
    if isempty(cxs)
        cxs=uicontextmenu(obj.fig,'tag',Tags.xs);
        uimenu(cxs,'Label','Open in new window',MenuSelectedField(),@cb_xstimeplot);
    end
    
    obj.plot_xsections(@xsplotter, 'Xsection cummomplot');
    
    ax.YLabel.UIContextMenu=obj.sharedContextMenus.LogLinearYScale;
    
    %% add context menu to the axes
    cbg=findobj(obj.fig,'Tag',Tags.bg);
    
    if isempty(cbg)
        cbg=uicontextmenu(obj.fig,'Tag',Tags.bg);
        addLegendToggleContextMenuItem(cbg,'bottom','above');
        uimenu(cbg,'Label','Open in new window',MenuSelectedField(),@obj.cb_timeplot);
    end
    
    if isempty(ax.UIContextMenu)
        ax.UIContextMenu=cbg;
    end
      
    function cln = line_plot_context_menu()
        % set up the context menu for these line plots
        cln=findobj(obj.fig,'Tag',Tags.line);
        if isempty(cln)
            cln=uicontextmenu(obj.fig,'tag',Tags.line);
            uimenu(cln, 'Label', 'start here',              MenuSelectedField(), @(~,~)obj.cb_starthere(ax));
            uimenu(cln, 'Label', 'end here',                MenuSelectedField(), @(~,~)obj.cb_endhere(ax));
            uimenu(cln, 'Label', 'trim to largest event',   MenuSelectedField(), @obj.cb_trim_to_largest);
            uimenu(cln, 'Label', 'Open in new window',      MenuSelectedField(), @obj.cb_timeplot);
        end
    end
    
    function h = xsplotter(xs, xscat)
        xsProps.LineWidth   = 1.5;
        xsProps.DisplayName = xs.name;
        xsProps.Color       = xs.color;
        mytag               = ['Xsection cummomplot ' xs.name];
        h = craw.add_series(xscat, mytag, xsProps);
       
    end
    
    function cb_xstimeplot(~,~)
        myName = get(gco,'DisplayName');
        idx=strcmp(obj.XSectionTitles,myName);
        ZG=ZmapGlobal.Data;
        ZG.newt2=obj.catalog.subset(obj.CrossSections(idx).inside(obj.catalog));
        ZG.newt2.Name=sprintf('Events within %g km of %s',myName);
        ctp=CumTimePlot(ZG.newt2);
        ctp.plot();
    end
end
