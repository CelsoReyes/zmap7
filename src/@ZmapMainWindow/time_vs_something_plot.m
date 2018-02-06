function time_vs_something_plot(obj, name, whichplotter, tabgrouptag)
    % TIME_VS_SOMETHING_PLOT
    %
    % whchplotter can be an instance of either TimeMagnitudePLottter or TimeDepthPlotter
    % if tab doesn't exist yet, create it
    
    myTab = findOrCreateTab(obj.fig, tabgrouptag, name);
    
    delete(myTab.Children);
    ax=axes(myTab);
    whichplotter.plot(obj.catalog,ax);
    ax.Title=[];
    c=uicontextmenu('tag',[name ' contextmenu']);
    uimenu(c,'Label','Open in new window','Callback',@(~,~)whichplotter.plot(obj.catalog));
    ax.UIContextMenu=c;
end