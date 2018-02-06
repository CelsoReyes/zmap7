function plothist(obj, name, values, tabgrouptag)
    % PLOTHIST plot a histogram in the Upper Right plot area
    
    myTab = findOrCreateTab(obj.fig, tabgrouptag, name);
    
    %if axes doesn't exist, create it and plot
    ax=findobj(myTab,'Type','axes');
    if isempty(ax)
        ax=axes(myTab);
        hisgra(obj.catalog,name,ax)
    else
        ax.Children.Data=values; %TODO move into hisgra
    end
end
