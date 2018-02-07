function cumplot(obj, tabgrouptag)
    % Cumulative Event Plot
    myTab = findOrCreateTab(obj.fig, tabgrouptag, 'cumplot');
    
    delete(myTab.Children);
    delete(findobj(obj.fig,'Tag','CumPlot bg contextmenu'))
    delete(findobj(obj.fig,'Tag','CumPlot line contextmenu'))
    delete(findobj(obj.fig,'Tag','CumPlot Yscaling'))
    ax=axes(myTab);
    ax.TickDir='out';
    p=plot(ax,obj.catalog.Date,1:obj.catalog.Count,'linewidth',2.5,'DisplayName','catalog','color','k');
    grid(ax,'on');
    
    % plot crosss sections, too
    k=obj.xsections.keys;
    for j=1:obj.xsections.Count
        hold on
        xs=obj.xsections(k{j});
        xscat = obj.xscats(k{j});
        plot(ax,xscat.Date, 1:xscat.Count,'linewidth',1.5,'DisplayName',k{j},'Color',xs.color);
    end
    
    yl=ylabel(ax,'Cummulative Number of events');
    c=uicontextmenu('Tag','CumPlot Yscaling');
    uimenu(c,'Label','Use Log Scale','Callback',{@logtoggle,ax,'Y'});
    yl.UIContextMenu=c;
    
    xlabel(ax,'Time');
    c=uicontextmenu('tag','CumPlot line contextmenu');
    uimenu(c,'Label','start here','Callback',@(~,~)obj.cb_starthere(ax));
    uimenu(c,'Label','end here','Callback',@(~,~)obj.cb_endhere(ax));
    uimenu(c, 'Label', 'trim to largest event','Callback',@obj.cb_trim_to_largest);
    p.UIContextMenu=c;
    
    uimenu(p.UIContextMenu,'Label','Open in new window','Callback',@(~,~)obj.cb_timeplot());
    c=uicontextmenu('tag','CumPlot bg contextmenu');
    ax.UIContextMenu=c;
    uimenu(c,'Label','Toggle Legend','Callback',@(~,~)legend(ax,'toggle'));
    uimenu(c,'Label','Open in new window','Callback',@(~,~)obj.cb_timeplot());
end
