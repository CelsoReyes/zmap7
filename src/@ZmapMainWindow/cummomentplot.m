function cummomentplot(obj,tabgrouptag)
    %CUMMOMENTPLOT plot the Cumulative Moment into the specified tab group
    
    Tags.xs = 'CumMom xs contextmenu';
    Tags.bg = 'CumMom bg contextmenu';
    Tags.line = 'CumMom line contextmenu';
    
    
    myTab = findOrCreateTab(obj.fig, tabgrouptag, 'Moment');
    
    delete(myTab.Children);
    ax=axes(myTab);
    ax.TickDir='out';
    ax.YMinorTick='on';
    ax.Box='on';
    
    cln=findobj(gcf,'Tag',Tags.line);
    if isempty(cln)
        cln=uicontextmenu('tag',Tags.line);
        uimenu(cln,'Label','start here',Futures.MenuSelectedFcn,@(~,~)obj.cb_starthere(ax));
        uimenu(cln,'Label','end here',Futures.MenuSelectedFcn,@(~,~)obj.cb_endhere(ax));
        uimenu(cln, 'Label', 'trim to largest event',Futures.MenuSelectedFcn,@obj.cb_trim_to_largest);
        uimenu(cln,'Label','Open in new window',Futures.MenuSelectedFcn,@(~,~)obj.cb_timeplot());
    end
    
    
    % plot the main catalog
    Xs=obj.catalog.Date;
    [~, Ys, ~] = calc_moment(obj.catalog);
    p=line(ax,Xs,Ys,'LineWidth',2.5,...
        'Tag','catalog','DisplayName','catalog','color','k');
    p.UIContextMenu=cln;
    grid(ax,'on');
    
    % plot cross sections, too
    cxs=findobj(gcf,'Tag',Tags.xs);
    if isempty(cxs)
        cxs=uicontextmenu('tag',Tags.xs);
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
    
    obj.plot_xsections(@xsplotter, 'Xsection cummomplot');

    yl=ylabel(ax,'Cumulative Moment');
    yl.UIContextMenu=obj.sharedContextMenus.LogLinearYScale;
    
    xlabel(ax,'Time');
    %xl.UIContextMenu=obj.sharedContextMenus.LogLinearXScale;
   
    cbg=findobj(gcf,'Tag',Tags.bg);
    
    if isempty(cbg)
        cbg=uicontextmenu('Tag',Tags.bg);
        addLegendToggleContextMenuItem(cbg,'bottom','above');
        uimenu(cbg,'Label','Open in new window',Futures.MenuSelectedFcn,@(~,~)obj.cb_timeplot());
        ax.UIContextMenu=cbg;
    end
    
    
    bigcat=ZmapGlobal.Data.maepi;
    
    idx = ismember(Xs,bigcat.Date) & obj.catalog.Magnitude >= min(bigcat.Magnitude);
    hold on
    scatter(ax,Xs(idx), Ys(idx), mag2dotsize(bigcat.Magnitude),...
        'Marker','h','MarkerEdgeColor','k','MarkerFaceColor','y',...
        'Tag','big events');
    hold off
    
    
    
    function h = xsplotter(xs, xscat)
        h=findobj(ax,'DisplayName',xs.name,'-and','Type','line');
        if isempty(h)
        [~, vmom, ~] = calc_moment(xscat);
        h=line(ax,xscat.Date, vmom,'LineWidth',1.5,'DisplayName',xs.name,...
            'Tag',['Xsection cummomplot ' xs.name],'Color',xs.color,...
            'UIContextMenu',cxs);
        else
            if ~isequal(xscat.Date,h.XData)
                [~, vmom, ~] = calc_moment(xscat);
                set(h,'XData',xscat.Date, 'YData', vmom,'LineWidth',1.5,'Color',xs.color);
            else
                set(h,'Color',xs.color);
            end
        end
    end
    
    function cb_xstimeplot(~,~)
        myName = get(gco,'DisplayName');
        idx=strcmp(obj.XSectionTitles,myName);
        ZG=ZmapGlobal.Data;
        ZG.newt2=obj.catalog.subset(obj.CrossSections(idx).inside(obj.catalog));
        ZG.newt2.Name=sprintf('Events within %g km of %s',myName);
        timeplot();
    end
end
