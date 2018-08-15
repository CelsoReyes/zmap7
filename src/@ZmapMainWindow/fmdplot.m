function fmdplot(obj, tabgrouptag)
    % control the FMD plot in the main window
    
    % the fmd object is actually stored in the axes into which it plots
    myTab = findOrCreateTab(obj.fig, tabgrouptag, 'FMD');
    ax=findobj(myTab,'Type','axes');
    if isempty(ax)
        ax=axes(myTab);
        ylabel(ax,'Cum # events');
        xlabel(ax,'Magnitude');
        if ~isempty(obj.catalog)
            bdiffobj=bdiff2(obj.getCurrentCatalog,'ax',ax,'InteractiveMode',false); 
            ax.UserData=bdiffobj; %stash this, but keep it with the ZMapMainWindow.
            uimenu(ax.UIContextMenu,'Label','Cut catalog at Mc',MenuSelectedField(),{@crop_to_mc,bdiffobj});
        end
        
    elseif isempty(obj.catalog)
        cla(ax);
        ylabel(ax,'Cum # events');
        xlabel(ax,'Magnitude');
    else
        bdiffobj=ax.UserData;
        if isempty(bdiffobj)
            bdiffobj=bdiff2(bj.getCurrentCatalog,'ax',ax,'InteractiveMode',false);
            ax.UserData=bdiffobj;
        else
            bdiffobj.RawCatalog = obj.catalog;
            bdiffobj.Calculate();
            bdiffobj.updatePlot();
        end
        %ax.XLimMode='auto';
        %ax.YLimMode='auto';
        if isempty(ax.UIContextMenu)
            c = uicontextmenu(obj.fig);
            ax.UIContextMenu = c;
        end
        addLegendToggleContextMenuItem(ax.UIContextMenu,'bottom','above');
    end
    
    function crop_to_mc(src,ev, bdiffobj)
        % should this crop the raw catalog?
        zdlg = ZmapDialog();
        zdlg.AddEdit('mc', "Cut Magnitude [Mc:" + bdiffobj.Result.Mc_value + "]", bdiffobj.Result.Mc_value,...
            'Choose magnitude to cut the catalog');
        [res,okpressed] = zdlg.Create('Choose Cut Magnitude');
        if okpressed
            obj.rawcatalog = obj.rawcatalog.subset(obj.rawcatalog.Magnitude>= res.mc);
            obj.replot_all;
        end
    end
end
