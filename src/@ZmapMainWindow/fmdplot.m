function fmdplot(obj, tabgrouptag)
    
    myTab = findOrCreateTab(obj.fig, tabgrouptag, 'FMD');
    ax=findobj(myTab,'Type','axes');
    if isempty(ax)
        ax=axes(myTab);
        ylabel(ax,'Cum # events');
        xlabel(ax,'Magnitude');
        if ~isempty(obj.catalog)
            bdiffobj=bdiff2(@obj.getCurrentCatalog,'ax',ax); 
            ax.UserData=bdiffobj; %stash this, but keep it with the ZMapMainWindow.
        end
        
    elseif isempty(obj.catalog)
        cla(ax);
        ylabel(ax,'Cum # events');
        xlabel(ax,'Magnitude');
    else
        bdiffobj=ax.UserData;
        if isempty(bdiffobj)
            bdiffobj=bdiff2(@obj.getCurrentCatalog,'ax',ax);
            ax.UserData=bdiffobj;
        else
            bdiffobj=bdiffobj.calculate(obj.catalog);
            bdiffobj.updatePlottedCumSum(ax);
            bdiffobj.updatePlottedDiscreteValues(ax);
            bdiffobj.updatePlottedMc(ax);
            bdiffobj.updatePlottedBvalLine(ax);
        end
        ax.XLimMode='auto';
        ax.YLimMode='auto';
        if isempty(ax.UIContextMenu)
            c = uicontextmenu(obj.fig);
            ax.UIContextMenu = c;
        end
        addLegendToggleContextMenuItem(ax.UIContextMenu,'bottom','above');
    end
end
