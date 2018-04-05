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
        h.Tag='cataloghist';
        ax.YGrid='on';
        hold on
        addLegendToggleContextMenuItem(ax,ax,[],'bottom','above');
        
    else
        h=findobj(ax,'Type','histogram');
        h(strcmp({h.Tag},'cataloghist')).Data=values; %TODO move into hisgra
        delete(h(~strcmp({h.Tag},'cataloghist')))%delete(findobj(ax,'Type','line'));
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
                    h=histogram(ax,hours(obj.xscats(k).Date.(name)),edges,'DisplayStyle','stairs',...
                        'DisplayName',k,'Tag',k);
                    %n=histcounts(hours(obj.xscats(k).Date.(name)),edges);
                otherwise
                    h=histogram(ax,obj.xscats(k).(name),edges,'DisplayStyle','stairs',...
                        'DisplayName',k,'Tag',k);
                    %n=histcounts(obj.xscats(k).(name),edges);
            end
            h.EdgeColor=obj.xsections(k).color;
            %line(ax,middles,n,'MarkerEdgeColor',obj.xsections(k).color,...
            %    'LineStyle','none',...
            %    'DisplayName',k,...
            %    'Marker','.');
        end
        hold(ax,'off')
        set(findobj(ax,'Type','histogram'),'linewidth',1.0)
    end
    
end