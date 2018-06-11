function time_vs_something_plot(obj, name, whichplotter, tabgrouptag)
    % TIME_VS_SOMETHING_PLOT
    %
    % WhichPlotter can be an instance of either TimeMagnitudePlotter or TimeDepthPlotter
    % if tab doesn't exist yet, create it
    
    
    myTab = findOrCreateTab(obj.fig, tabgrouptag, name);
    
    
    ax=findobj(myTab.Children,'flat','Type','axes');
    if isempty(ax) || ~isstruct(ax.UserData) || ~isfield(ax.UserData,'TimeSomethingPlotter')
        ax=axes(myTab);
        whichplotter.plot(ax, obj.catalog, obj.bigEvents);
        ax.Title=[];
        ax.UserData.TimeSomethingPlotter=whichplotter;
    else
        whichplotter=ax.UserData.TimeSomethingPlotter;
        whichplotter.update(obj.catalog, obj.bigEvents);
    end
    
    contextTag =[name ' contextmenu'];
    c=findobj(obj.fig.Children,'flat','Tag',contextTag);
    
    if isempty(c)
        c=uicontextmenu(obj.fig,'Tag', contextTag);
        uimenu(c, 'Label', 'Open in new window',...
            Futures.MenuSelectedFcn, @cb_context);
        addLegendToggleContextMenuItem(c,'bottom','above');
    end
    ax.UIContextMenu=c;
    
    switch name
        case 'Time-Mag'
            fld='Magnitude';
        case 'Time-Depth'
            fld='Depth';
        otherwise
            fld='';
    end
    
    xsplotter=@(xs, xscat) line(ax, xscat.Date, xscat.(fld),...
            'Marker', '.', 'LineStyle','none',...
            'LineWidth', 1.5, 'Color', xs.color,...
            'DisplayName', xs.name);
        
    
    obj.plot_xsections(xsplotter,'Xsection timeplot')
    
    function cb_context(~,~)
        whichplotter.plot([],obj.catalog, obj.bigEvents)
    end
    
end