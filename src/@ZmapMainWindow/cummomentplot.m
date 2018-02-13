function cummomentplot(obj,tabgrouptag)
    %CUMMOMENTPLOT plot the Cumulative Moment into the specifed tab group
    myTab = findOrCreateTab(obj.fig, tabgrouptag, 'Moment');
    delete(myTab.Children);
    delete(findobj(obj.fig,'Tag','CumMom bg contextmenu'))
    delete(findobj(obj.fig,'Tag','CumMom line contextmenu'))
    delete(findobj(obj.fig,'Tag','CumMom Yscaling'))
    delete(findobj(obj.fig,'Tag','CumMom xs contextmenu'))
    ax=axes(myTab);
    [~, vCumMoment, ~] = calc_moment(obj.catalog);
    p=plot(ax,obj.catalog.Date,vCumMoment,'linewidth',2.5,'DisplayName','catalog','color','k');
    grid(ax,'on');
    % plot cross sections, too
    k=obj.xsections.keys;
    for j=1:obj.xsections.Count
        hold on
        xs=obj.xsections(k{j});
        xscat = obj.xscats(k{j});
        if isempty(xscat); continue; end
        [~, vCumMoment, ~] = calc_moment(xscat);
        c=uicontextmenu('tag','CumPlot xs contextmenu');
        uimenu(c,'Label','Open in new window','Callback',{@cb_xstimeplot,xs});
        plot(ax,xscat.Date, vCumMoment,'linewidth',1.5,'DisplayName',k{j},'Color',xs.color,...
            'UIContextMenu',c);
    end
        
    yl=ylabel(ax,'Cummulative Moment');
    c=uicontextmenu('Tag','CumMom Yscaling');
    uimenu(c,'Label','Use Log Scale','Callback',{@logtoggle,ax,'Y'});
    yl.UIContextMenu=c;
    
    xlabel(ax,'Time');
    c=uicontextmenu('tag','CumMom line contextmenu');
    uimenu(c,'Label','start here','Callback',@(~,~)obj.cb_starthere(ax));
    uimenu(c,'Label','end here','Callback',@(~,~)obj.cb_endhere(ax));
    uimenu(c, 'Label', 'trim to largest event','Callback',@obj.cb_trim_to_largest);
    p.UIContextMenu=c;
    
    uimenu(p.UIContextMenu,'Label','Open in new window','Callback',@(~,~)timeplot());
    c=uicontextmenu('tag','CumMom bg contextmenu');
    ax.UIContextMenu=c;
    addLegendToggleContextMenuItem(ax,ax,c,'bottom','above');
    uimenu(c,'Label','Open in new window','Callback',@(~,~)timeplot());
    
    function cb_xstimeplot(~,~,xs)
        ZG=ZmapGlobal.Data;
        ZG.newt2=obj.catalog.subset(xs.inside(obj.catalog));
        ZG.newt2.Name=sprintf('Events within %g km of %s - %s',xs.width_km,xs.startlabel,xs.endlabel);
        timeplot();
    end
end
