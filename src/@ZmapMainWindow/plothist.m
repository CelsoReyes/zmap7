function plothist(obj, name, values, tabgrouptag)
    % PLOTHIST plot a histogram in the Upper Right plot area
    
    myTab = findOrCreateTab(obj.fig, tabgrouptag, name);
    
    %if axes doesn't exist, create it and plot
    ax=findobj(myTab,'Type','axes');
    if isempty(ax)
        ax=axes(myTab);
        hisgra(obj.catalog,name,ax)
        h=findobj(ax,'Type','histogram');
        if ~isempty(h)
            h.DisplayName='catalog';
            h.Tag='cataloghist';
            h.FaceColor = [0.4 0.4 0.4];
            ax.YGrid='on';
            hold on
            c=ax.UIContextMenu;
            addLegendToggleContextMenuItem(c,'bottom','above');
            set(findobj(ax.Children,'Type','histogram'),'UIContextMenu',c);
        end
        
    else
        h=findobj(ax,'Type','histogram');
        if ~isempty(h)
            h({h.Tag} == cataloghist).Data=values; %TODO move into hisgra
            delete(h({h.Tag} ~= "cataloghist"))
            if ~isempty(obj.xscats)
                doit(ax)
            end
        else
            disp('no histogram exists in axes');
        end
    end
    
    ax.YMinorTick='on';
    
    function doit(ax)
        h= findobj(ax,'Type','histogram');
        edges=  h.BinEdges;
        
        %keys=obj.xscats.keys;
        
        switch name
            case 'Hour'
                xsplotter=@(xs,xscat)histogram(ax,hours(xscat.Date.(name)),edges,...
                        'DisplayStyle','stairs',...
                        'DisplayName',xs.name,'EdgeColor',xs.color,'LineWidth',1.0);
                
            otherwise
                xsplotter=@(xs,xscat)histogram(ax,xscat.(name),edges,...
                        'DisplayStyle','stairs',...
                        'DisplayName',xs.name,'EdgeColor',xs.color,'LineWidth',1.0);
        end
        
        obj.plot_xsections(xsplotter, 'Xsection');
        
    end
    
end