function cumplot(obj, tabgrouptag)
    % Cumulative Event Plot
    myTab = findOrCreateTab(obj.fig, tabgrouptag, 'cumplot');
    
    delete(myTab.Children);
    delete(findobj(obj.fig,'Tag','CumPlot bg contextmenu'))
    delete(findobj(obj.fig,'Tag','CumPlot line contextmenu'))
    delete(findobj(obj.fig,'Tag','CumPlot xs contextmenu'))
    delete(findobj(obj.fig,'Tag','CumPlot Yscaling'))
    delete(findobj(obj.fig,'Tag','CumPlot Xscaling'))
    ax=axes(myTab);
    ax.TickDir='out';
    
    c=uicontextmenu('tag','CumPlot line contextmenu');
    uimenu(c,'Label','start here',Futures.MenuSelectedFcn,@(~,~)obj.cb_starthere(ax));
    uimenu(c,'Label','end here',Futures.MenuSelectedFcn,@(~,~)obj.cb_endhere(ax));
    uimenu(c, 'Label', 'trim to largest event',Futures.MenuSelectedFcn,@obj.cb_trim_to_largest);
    uimenu(c,'Label','Open in new window',Futures.MenuSelectedFcn,@(~,~)obj.cb_timeplot());
    
    p=line(ax,obj.catalog.Date,1:obj.catalog.Count,...
        'linewidth',2.5,'DisplayName','catalog',...
        'color','k');
    p.UIContextMenu=c;
    grid(ax,'on');
    
    
    
    % plot cross sections, too
    k=obj.xsections.keys;
    for j=1:obj.xsections.Count
        hold on
        tit=k{j};
        xs=obj.xsections(tit);
        xscat = obj.xscats(tit);
    c=uicontextmenu('tag','CumPlot xs contextmenu');
    uimenu(c,'Label','Open in new window',Futures.MenuSelectedFcn,{@cb_xstimeplot,xs});
        line(ax,xscat.Date, 1:xscat.Count,...
            'linewidth',1.5,'DisplayName',tit,'Color',xs.color,...
            'UIContextMenu',c);
    end
    
    yl=ylabel(ax,'Cummulative Number of events');
    c=uicontextmenu('Tag','CumPlot Yscaling');
    uimenu(c,'Label','Use Log Scale',Futures.MenuSelectedFcn,{@logtoggle,ax,'Y'});
    yl.UIContextMenu=c;
    
    xl=xlabel(ax,'Time');
    c=uicontextmenu('Tag','CumPlot Xscaling');
    uimenu(c,'Label','Split View on largest event(s)',Futures.MenuSelectedFcn,{@splittimeslargest,ax,'X'});
    uimenu(c,'Label','Split View (Fixed Durations)',Futures.MenuSelectedFcn,{@splittimesduration,ax,'X'});
    xl.UIContextMenu=c;
    
    
    
    c=uicontextmenu('tag','CumPlot bg contextmenu');
    ax.UIContextMenu=c;
    addLegendToggleContextMenuItem(ax,ax,c,'bottom','above');
    uimenu(c,'Label','Open in new window',Futures.MenuSelectedFcn,@(~,~)obj.cb_timeplot());
    
    function cb_xstimeplot(~,~,xs)
            ZG=ZmapGlobal.Data;
            ZG.newt2=obj.catalog.subset(xs.inside(obj.catalog))
            ZG.newt2.Name=sprintf('Events within %g km of %s - %s',xs.width_km,xs.startlabel,xs.endlabel);
            timeplot();
    end
end
