function plothist(obj, name, tabgrouptag)
    % PLOTHIST plot a histogram in the Upper Right plot area
    
    Tags.ax = 'histograms';
    Tags.xs = 'hist xs contextmenu';
    Tags.bg = 'hist bg contextmenu';
    Tags.line = 'hist line contextmenu';
    
    myTab = findOrCreateTab(obj.fig, tabgrouptag, 'histograms');
    
    
     %% set up the axes
    ax=findobj(myTab.Children,'flat','Tag',Tags.ax);
    if isempty(ax)
        ax            = axes(myTab);
        ax.TickDir    = 'out';
        ax.YMinorTick = 'on';
        ax.Box        = 'on';
        ax.Tag        = Tags.ax;
        ax.UserData   = HistAnalysisWindow(ax, name, @obj.cb_updateSelections);
        grid(ax, 'on');
    end
    craw = ax.UserData; % craw is the cumplot analysisWindow
    
    %% plot the main series
    lineProps.FaceColor         = [0.4 0.4 0.4];
    lineProps.EdgeColor     = [0.4 0.4 0.4];
    lineProps.LineWidth     = 1;
    lineProps.DisplayName   = obj.catalog.Name;
    lineProps.DisplayStyle   = 'bar';
    
    craw.add_series(obj.catalog, 'catalog', lineProps);
    
    
    %% plot & synchronize cross sections
    
    plotted_xs = get(ax.Children,'Tag');
    plotted_xs = plotted_xs(startsWith(plotted_xs, 'Xsection'));
    
    if ~isempty(plotted_xs)
        existing_xs = obj.XSectionTitles;
        % delete cross sections that shouldn't exist
        todel = plotted_xs(~ismember(plotted_xs,existing_xs));
        craw.remove_series(todel);
    end
    
     %% if necessary, add context menu to figure
    cxs=findobj(obj.fig,'Tag',Tags.xs);
    if isempty(cxs)
        cxs=uicontextmenu(obj.fig,'tag',Tags.xs);
        %uimenu(cxs,'Label','Open in new window',MenuSelectedField(),@cb_xstimeplot);
    end
    
    obj.plot_xsections(@xsplotter, 'Xsection hist');
    
    ax.YLabel.UIContextMenu=obj.sharedContextMenus.LogLinearYScale;
    
    
    %% %% %%
    return
    %% %% %%
    
    
    
    %if axes doesn't exist, create it and plot
    ax=findobj(myTab,'Type','axes');
    if isempty(ax)
        %ax=axes(myTab, 'Tag', ');
        ax=axes(myTab);
        h=hisgra(obj.catalog,name,ax);
        %h=findobj(ax,'Type','histogram');
        if ~isempty(h)
            h.DisplayName='catalog';
            h.Tag='cataloghist';
            h.FaceColor = [0.4 0.4 0.4];
            ax.YGrid='on';
            set(gca,'NextPlot','add')
            c=ax.UIContextMenu;
            addLegendToggleContextMenuItem(c,'bottom','above');
            set(findobj(ax.Children,'Type','histogram'),'UIContextMenu',c);
        end
        
    else
        h=findobj(ax,'Type','histogram');
        if ~isempty(h)
            h({h.Tag} == "cataloghist").Data=values; %TODO move into hisgra
            delete(h({h.Tag} ~= "cataloghist"))
            if ~isempty(obj.xscats)
                doit(ax)
            end
        else
            disp('no histogram exists in axes');
        end
    end
    
    ax.YMinorTick='on';

    function h = xsplotter(xs, xscat)
        xsProps.LineWidth   = 2;
        xsProps.DisplayName = xs.name;
        xsProps.EdgeColor       = xs.color;
        xsProps.DisplayStyle = 'stair';
        mytag               = ['Xsection hist ' xs.name];
        h = craw.add_series(xscat, mytag, xsProps);
    end
    

    
end