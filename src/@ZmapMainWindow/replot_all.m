function replot_all(obj)
    % REPLOT all the windows
    
    % reevaluate cross section catalogs
    k=obj.xsections.keys;
    for j=1:obj.xsections.Count
        hold on
        xs=obj.xsections(k{j});
        obj.xscats(k{j})=xs.project(obj.catalog);
    end
    
    
    obj.undohandle.Enable=tf2onoff(~isempty(obj.prev_states));
    [obj.catalog,m]=obj.filtered_catalog();
    
    evs=findobj(obj.fig,'Tag','all events');
    evs.XData(m)=nan;
    evs.XData(~m)=obj.rawcatalog.Longitude(~m);

    obj.fig.Name=sprintf('%s [%s - %s]',obj.catalog.Name ,char(min(obj.catalog.Date)),...
        char(max(obj.catalog.Date)));
    figure(obj.fig)
    obj.plotmainmap();
    % Each tab group will have a "SelectionChanghedFcn", "CreateFcn", "DeleteFcn", "UIContextMenu"
    
    obj.plothist('Magnitude',obj.catalog.Magnitude,'UR plots');
    obj.plothist('Depth',obj.catalog.Depth,'UR plots');
    obj.plothist('Date',obj.catalog.Date,'UR plots');
    obj.plothist('Hour',hours(obj.catalog.Date.Hour),'UR plots');
    
    obj.fmdplot('UR plots');
    
    obj.cumplot('LR plots');
    obj.cummomentplot('LR plots');
    obj.time_vs_something_plot('Time-Mag',TimeMagnitudePlotter,'LR plots');
    obj.time_vs_something_plot('Time-Depth',TimeDepthPlotter, 'LR plots');
    if isempty(obj.xsgroup.Children)
        obj.xsgroup.Visible='off';
        set(findobj(obj.fig,'Tag','mainmap_ax'),'Position',obj.MapPos_L);
    end
end