function plothist(obj, name, values, tabgrouptag)
    % PLOTHIST plot a histogram in the Upper Right plot area
    
    myTab = findOrCreateTab(obj.fig, tabgrouptag, name);
    
    %if axes doesn't exist, create it and plot
    ax=findobj(myTab,'Type','axes');
    if isempty(ax)
        ax=axes(myTab);
        hisgra(obj.catalog,name,ax)
        h=findobj(ax,'Type','histogram');
        h.DisplayName='catalog';
        hold on
        
    else
        h=findobj(ax,'Type','histogram');
        h.Data=values; %TODO move into hisgra
        delete(findobj(ax,'Type','scatter'));
        if ~isempty(obj.xscats)
            doit(ax)
        end
    end
    
    
    function doit(ax)
        h= findobj(ax,'Type','histogram');
        keys=obj.xscats.keys;
        edges=  h.BinEdges;
        middles = edges(1:end-1) + diff(edges)/2;
        hold(ax,'on')
        for j=1:numel(keys)
            k=keys{j};
            switch name
                case 'Hour'
                    n=histcounts(hours(obj.xscats(k).Date.(name)),edges);
                otherwise
                    n=histcounts(obj.xscats(k).(name),edges);
            end
            scatter(ax,middles,n,[],obj.xsections(k).color,'DisplayName',k,'Marker','.');
        end
        hold(ax,'off')
    end
    
end