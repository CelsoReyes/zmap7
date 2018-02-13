function fmdplot(obj, tabgrouptag)
    
    myTab = findOrCreateTab(obj.fig, tabgrouptag, 'FMD');
    
    delete(myTab.Children);
    ax=axes(myTab);
    ylabel(ax,'Cum # events');
    xlabel(ax,'Magnitude');
    
    %mainax=obj.map_axes;
    bdiff2(obj.catalog,false,ax);
    
    addLegendToggleContextMenuItem(ax,ax,[],'bottom','above')
    %mainax2=obj.map_axes;
    %assert(mainax==mainax2);
end
