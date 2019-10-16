function fmdplot(obj, tabgrouptag)
    % control the FMD plot in the main window
    
    
    Tags.xs = 'fmd xs contextmenu';
    
    % the fmd object is actually stored in the axes into which it plots
    myTab = findOrCreateTab(obj.fig, obj.fig, tabgrouptag, 'FMD');
    ax=findobj(myTab,'Type','axes');
    if isempty(ax)
        ax=axes(myTab);
        ylabel(ax,'Cum # events > M(x)');
        xlabel(ax,'Magnitude');
        if ~isempty(obj.catalog)
            bdiffobj=bdiff2(obj.getCurrentCatalog,'ax',ax,'InteractiveMode',false); 
            bAnalysisWin = AnalysisBvalues(ax,bdiffobj);
            ax.UserData = bAnalysisWin;
            % ax.UserData=bdiffobj; %stash this, but keep it with the ZMapMainWindow.
            uimenu(ax.UIContextMenu,'Label','Cut catalog at Mc',MenuSelectedField(), @(s,v)crop_to_mc(s, v, bdiffobj) );
        end
        
    elseif isempty(obj.catalog)
        cla(ax);
        ylabel(ax,'Cum # events > M(x)');
        xlabel(ax,'Magnitude');
    else
        % axes exists, and the catalog is not empty
        
        bAnalysisWin = ax.UserData;
        if isempty(bAnalysisWin)
            bdiffobj=bdiff2(obj.getCurrentCatalog,'ax',ax,'InteractiveMode',false);
            bAnalysisWin = AnalysisBvalues(ax,bdiffobj);
            ax.UserData = bAnalysisWin;
            % ax.UserData=bdiffobj;
        else
            bAnalysisWin.bobj.RawCatalog = obj.catalog;
            bAnalysisWin.bobj.Calculate();
            bAnalysisWin.bobj.updatePlot();
        end
        
        if isempty(ax.UIContextMenu)
            c = uicontextmenu(obj.fig);
            ax.UIContextMenu = c;
        end
        addLegendToggleContextMenuItem(ax.UIContextMenu,'bottom','above');
    end
    
    analy_win = ax.UserData;
    
    
    %% plot & synchronize cross sections
    
    plotted_xs = get(ax.Children,'Tag');
    if ~isempty(plotted_xs)
        plotted_xs = plotted_xs(startsWith(plotted_xs, 'Xsection fmd'));
    end
    if ~isempty(plotted_xs)
        existing_xs = obj.XSectionTitles;
        plotted_xs2 = extractAfter(plotted_xs,'Xsection fmd ');
        
        toDelIdx = ~startsWith(plotted_xs2,existing_xs); % all tags
        todel = string(plotted_xs(toDelIdx));
        todel = todel(~endsWith(todel,'line') & ~endsWith(todel,'Mc'));
        
        
        % delete cross sections that shouldn't exist
        %todel = plotted_xs(~startsWith(plotted_xs,existing_xs));
        %todel = plotted_xs(~ismember(plotted_xs,existing_xs));
        analy_win.remove_series(todel);
    end
    
    %% if necessary, add context menu to figure
    cxs=findobj(obj.fig,'Tag',Tags.xs);
    if isempty(cxs)
        cxs=uicontextmenu(obj.fig,'tag',Tags.xs);
        uimenu(cxs,'Label','Open in new window',MenuSelectedField(),@cb_xstimeplot);
    end
    
    obj.plot_xsections(@xsplotter, 'Xsection fmd');
    clear_empty_legend_entries(obj.fig);
    
    %% 
    function h = xsplotter(xs, xscat)
        xsProps.LineWidth   = 1.5;
        xsProps.DisplayName = xs.Name;
        xsProps.Color       = xs.Color;
        xsProps.Marker = 'x';
        mytag               = ['Xsection fmd ' xs.Name];
        h = analy_win.add_series(xscat, mytag, xsProps);
        
    end
    
    function cb_xstimeplot(~,~)
        % CB_XSTIMEPLOT shows the TIMEPLOT for the currently selected cross-section
        myName = get(gco,'DisplayName');
        idx = strcmp(obj.XSectionTitles,myName);
        ZG=ZmapGlobal.Data;
        ZG.newt2=obj.catalog.subset(obj.CrossSections(idx).inside(obj.catalog));
        ZG.newt2.Name=sprintf('Events within %g km of %s',obj.CrossSections(idx).name);
    end
    
    
    
    function crop_to_mc(~,~, bdiffobj)
        % should this crop the raw catalog?
        zdlg = ZmapDialog();
        zdlg.AddEdit('mc', "Cut Magnitude [Mc:" + bdiffobj.Result.Mc_value + "]", bdiffobj.Result.Mc_value,...
            'Choose magnitude to cut the catalog');
        [res,okpressed] = zdlg.Create('Name', 'Choose Cut Magnitude');
        if okpressed
            obj.rawcatalog = obj.rawcatalog.subset(res.mc <= obj.rawcatalog.Magnitude);
            obj.CatalogManager.RawCatalog = obj.rawcatalog;
            obj.replot_all;
        end
    end
end
