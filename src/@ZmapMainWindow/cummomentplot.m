function cummomentplot(obj,tabgrouptag)
    %CUMMOMENTPLOT plot the Cumulative Moment into the specifed tab group
    myTab = findOrCreateTab(obj.fig, tabgrouptag, 'Moment');
    delete(myTab.Children);
    ax=axes(myTab);
    [fCumMoment, vCumMoment, vMoment] = calc_moment(obj.catalog);
    p=plot(ax,obj.catalog.Date,vCumMoment,'b','linewidth',2);
    ylabel(ax,'Cummulative Moment');
    xlabel(ax,'Time');
    c=uicontextmenu('tag','CumMom line contextmenu');
    uimenu(c,'Label','start here','Callback',@(~,~)obj.cb_starthere(ax));
    uimenu(c,'Label','end here','Callback',@(~,~)obj.cb_endhere(ax));
    uimenu(c, 'Label', 'trim to largest event','Callback',@obj.cb_trim_to_largest);
    p.UIContextMenu=c;
    
    uimenu(p.UIContextMenu,'Label','Open in new window','Callback',@(~,~)timeplot());
    c=uicontextmenu('tag','CumMom bg contextmenu');
    ax.UIContextMenu=c;
    uimenu(c,'Label','Open in new window','Callback',@(~,~)timeplot());
    
end
