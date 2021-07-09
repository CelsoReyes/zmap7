function timedepthplot(obj, tabgrouptag)
    % Cumulative Event Plot
    
    Tags.xs = 'TDPlot xs contextmenu';
    Tags.bg = 'TDPlot bg contextmenu';
    Tags.line = 'TDPlot line contextmenu';
    Tags.ax = 'TDPlot axes';
    
    % set up the axes
    myTab = findOrCreateTab(obj.fig, obj.fig, tabgrouptag, 'Time-Depth');
    ax=findobj(myTab.Children,'flat','Tag',Tags.ax);
    if isempty(ax)
        ax            = axes(myTab);
        ax.TickDir    = 'out';
        ax.YMinorTick = 'on';
        ax.Box        = 'on';
        ax.Tag        = Tags.ax;
        ax.UserData   = TimeDepthAnalysisWindow(ax);
        grid(ax, 'on');
    end
    analy_win = ax.UserData; % craw is the timedepthplot analysisWindow
    
    %% plot the main series
    lineProps.Color         = [0 0 0];
    lineProps.Marker        = 's';
    lineProps.MarkerEdgeAlpha = 0.5;
    % lineProps.LineWidth     = 2.5;
    lineProps.UIContextMenu = line_plot_context_menu();
    lineProps.MinBigMag     = ZmapGlobal.Data.CatalogOpts.BigEvents.MinMag;
    lineProps.DisplayName   = obj.catalog.Name;
    lineProps.SizeFcn       = @(c)(rescale(c.Magnitude)*5+0.5).^3;
    %lineProps.SizeFcn       = @(c)mag2dotsize(c.Magnitude);
    
    analy_win.add_series(obj.catalog, 'catalog', lineProps);
    
    
    %% plot & synchronize cross sections
    
    plotted_xs = get(ax.Children,'Tag');
    plotted_xs = plotted_xs(startsWith(plotted_xs, 'Xsection'));
    
    if ~isempty(plotted_xs)
     existing_xs = obj.XSectionTitles;
        % delete cross sections that shouldn't exist
        todel = plotted_xs(~ismember(plotted_xs,existing_xs));
        analy_win.remove_series(todel);
    end
    %% if necessary, add context menu to figure
    cxs=findobj(obj.fig,'Tag',Tags.xs);
    if isempty(cxs)
        cxs=uicontextmenu(obj.fig,'tag',Tags.xs);
        uimenu(cxs,'Label','Open in new window','MenuSelectedFcn',@cb_xstimedepthplot);
    end
    
    obj.plot_xsections(@xsplotter, 'Xsection timdepthplot');
    
    ax.YLabel.UIContextMenu=obj.sharedContextMenus.LogLinearYScale;
    
    %% add context menu to the axes
    cbg=findobj(obj.fig,'Tag',Tags.bg);
    
    if isempty(cbg)
        cbg=uicontextmenu(obj.fig, 'Tag', Tags.bg);
        addLegendToggleContextMenuItem(cbg, 'bottom', 'above');
        uimenu(cbg, 'Label', 'Open in new window', 'MenuSelectedFcn',@obj.cb_timedepthplot);
    end
    
    if isempty(ax.UIContextMenu)
        ax.UIContextMenu=cbg;
    end
    
    function cln = line_plot_context_menu()
        % set up the context menu for these line plots
        cln=findobj(obj.fig,'Tag',Tags.line);
        if isempty(cln)
            cln=uicontextmenu(obj.fig,'tag',Tags.line);
            uimenu(cln, 'Label', 'start here',              'MenuSelectedFcn', @(~,~)obj.cb_starthere(ax));
            uimenu(cln, 'Label', 'end here',                'MenuSelectedFcn', @(~,~)obj.cb_endhere(ax));
            uimenu(cln, 'Label', 'trim to largest event',   'MenuSelectedFcn', @obj.cb_trim_to_largest);
            uimenu(cln, 'Label', 'Open in new window',      'MenuSelectedFcn', @obj.cb_timedepthplot);
        end
    end
        
    function h = xsplotter(xs, xscat)
        xsProps.LineWidth   = 1.5;
        xsProps.DisplayName = xs.Name;
        xsProps.Marker      = 's';
        xsProps.Color       = xs.Color;
        xsProps.MarkerEdgeAlpha = 0.5;
        xsProps.SizeFcn     = @(c)(rescale(c.Magnitude)*5+0.5).^3;
        mytag               = ['Xsection timedepthplot ' xs.Name];
        h = analy_win.add_series(xscat, mytag, xsProps);
    end
    
    function cb_xstimedepthplot(~,~)
        % CB_XSTIMEDEPTHPLOT shows the TIMEDEPTHPLOT for the currently selected cross-section
        myName = get(gco,'DisplayName');
        idx = strcmp(obj.XSectionTitles,myName);
        ZG = ZmapGlobal.Data;
        ZG.newt2 = obj.catalog.subset(obj.CrossSections(idx).inside(obj.catalog));
        ZG.newt2.Name = sprintf('Events within %g km of %s',obj.CrossSections(idx).name);
        error('TODO: decide how to replot this')
        %ctp = CumTimePlot(ZG.newt2);
        %ctp.plot();
    end
    
end
