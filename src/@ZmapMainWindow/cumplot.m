function cumplot(obj, tabgrouptag)
    % Cumulative Event Plot
    
    Tags.xs = 'CumPlot xs contextmenu';
    Tags.bg = 'CumPlot bg contextmenu';
    Tags.line = 'CumPlot line contextmenu';
    
    
    myTab = findOrCreateTab(obj.fig, tabgrouptag, 'cumplot');
    
    delete(myTab.Children);
    
    ax=axes(myTab);
    ax.TickDir='out';
    ax.YMinorTick='on';
    ax.Box='on';
    
    cln=findobj(obj.fig,'Tag',Tags.line);
    if isempty(cln)
        cln=uicontextmenu(obj.fig,'tag',Tags.line);
        uimenu(cln,'Label','start here',Futures.MenuSelectedFcn,@(~,~)obj.cb_starthere(ax));
        uimenu(cln,'Label','end here',Futures.MenuSelectedFcn,@(~,~)obj.cb_endhere(ax));
        uimenu(cln, 'Label', 'trim to largest event',Futures.MenuSelectedFcn,@obj.cb_trim_to_largest);
        uimenu(cln,'Label','Open in new window',Futures.MenuSelectedFcn,@(~,~)obj.cb_timeplot());
    else
        % update the referenced axes
        set(findobj(cln,'Label','start here'),Futures.MenuSelectedFcn,@(~,~)obj.cb_starthere(ax));
        set(findobj(cln,'Label','end here'),Futures.MenuSelectedFcn,@(~,~)obj.cb_endhere(ax));
    end
    
    % plot the main catalog
    Ys=1:obj.catalog.Count;
    Xs=obj.catalog.Date;
    line(ax,Xs,Ys,'LineWidth',2.5,'DisplayName','catalog',...
        'Tag','catalog','color','k', 'UIContextMenu',cln);
    grid(ax,'on');
    
    
    % plot cross sections, too
    cxs=findobj(obj.fig,'Tag',Tags.xs);
    if isempty(cxs)
        cxs=uicontextmenu(obj.fig,'tag',Tags.xs);
        uimenu(cxs,'Label','Open in new window',Futures.MenuSelectedFcn,@cb_xstimeplot);
    end
    
    % remove any cross-sections that are no longer exist
    k = obj.XSectionTitles;
    m=findobj(ax,'Type','line','-and','-not','Tag','catalog'); % plotted cross sections
    if ~isempty(m)
        notrep = ~ismember({m.DisplayName},k);
        if any(notrep)
            delete(m(notrep));
        end
    end
        
    obj.plot_xsections(@xsplotter, 'Xsection cumplot');
    
    ax.YLabel.String='Cummulative Number of events';
    ax.YLabel.UIContextMenu=obj.sharedContextMenus.LogLinearYScale;
    
    ax.XLabel.String='Time';
    %ax.XLabel.UIContextMenu=obj.sharedContextMenus.LogLinearXScale;
    
    bigcat=ZmapGlobal.Data.maepi;
    if ~isempty(bigcat)
        idx = ismember(Xs,bigcat.Date) & obj.catalog.Magnitude >= min(bigcat.Magnitude);
        Sz=mag2dotsize(bigcat.Magnitude);
    else
        idx=[];
        Sz=[];
    end
    set(gca,'NextPlot','add')

    scatter(ax,Xs(idx), Ys(idx), Sz,...
        'Marker','h','MarkerEdgeColor','k','MarkerFaceColor','y',...
        'Tag','big events');
    set(gca,'NextPlot','replace')
    
    cbg=findobj(obj.fig,'Tag',Tags.bg);
    
    if isempty(cbg)
        cbg=uicontextmenu(obj.fig,'Tag',Tags.bg);
        addLegendToggleContextMenuItem(cbg,'bottom','above');
        uimenu(cbg,'Label','Open in new window',Futures.MenuSelectedFcn,@(~,~)obj.cb_timeplot());
        ax.UIContextMenu=cbg;
    end
    
    
    
    
    function h = xsplotter(xs, xscat)
        h=findobj(ax,'DisplayName',xs.name,'-and','Type','line');
        if isempty(h)
            h=line(ax,xscat.Date, 1:xscat.Count,...
                'LineWidth',1.5,'DisplayName',xs.name,'Color',xs.color,...
                'Tag',['Xsection cumplot ' xs.name]);
            h.UIContextMenu = cxs;
        else
            if ~isequal(xscat.Date, h.XData)
                set(h,'XData',xscat.Date, 'YData', 1:xscat.Count,'LineWidth',1.5,'Color',xs.color);
            else
                set(h,'Color',xs.color);
            end
        end
    end
    
    function cb_xstimeplot(~,~)
        % CB_XSTIMEPLOT shows the TIMEPLOT for the currently selected cross-section
        myName = get(gco,'DisplayName');
        idx = strcmp(obj.XSectionTitles,myName);
        ZG=ZmapGlobal.Data;
        ZG.newt2=obj.catalog.subset(obj.CrossSections(idx).inside(obj.catalog));
        ZG.newt2.Name=sprintf('Events within %g km of %s',obj.CrossSections(idx).name);
        CumTimePlot(ZG.newt2);
    end
    
end
