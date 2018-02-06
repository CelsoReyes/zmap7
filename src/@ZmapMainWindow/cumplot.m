function cumplot(obj, tabgrouptag)
    % Cumulative Event Plot
    myTab = findOrCreateTab(obj.fig, tabgrouptag, 'cumplot');
    
    delete(myTab.Children);
    ax=axes(myTab);
    ax.TickDir='out';
    p=plot(ax,obj.catalog.Date,1:obj.catalog.Count,'r','linewidth',2);
    ylabel(ax,'Cummulative Number of events');xlabel(ax,'Time');
    c=uicontextmenu('tag','CumPlot line contextmenu');
    uimenu(c,'Label','start here','Callback',@(~,~)obj.cb_starthere(ax));
    uimenu(c,'Label','end here','Callback',@(~,~)obj.cb_endhere(ax));
    uimenu(c, 'Label', 'trim to largest event','Callback',@obj.cb_trim_to_largest);
    p.UIContextMenu=c;
    
    uimenu(p.UIContextMenu,'Label','Open in new window','Callback',@(~,~)obj.cb_timeplot());
    c=uicontextmenu('tag','CumPlot bg contextmenu');
    ax.UIContextMenu=c;
    uimenu(c,'Label','Open in new window','Callback',@(~,~)obj.cb_timeplot());
end
