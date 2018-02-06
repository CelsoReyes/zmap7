function fmdplot(obj, tabgrouptag)
    
    myTab = findOrCreateTab(obj.fig, tabgrouptag, 'FMD');
    
    delete(myTab.Children);
    ax=axes(myTab);
    ylabel(ax,'Cum # events');
    xlabel(ax,'Magnitude');
    
    %mainax=findobj(obj.fig,'Tag','mainmap_ax');
    bdiff2(obj.catalog,false,ax);
    
    %mainax2=findobj(obj.fig,'Tag','mainmap_ax');
    %assert(mainax==mainax2);
end
