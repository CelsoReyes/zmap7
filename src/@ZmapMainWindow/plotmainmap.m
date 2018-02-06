function plotmainmap(obj)
    % PLOTMAINMAP set up main map window
    
    axm=findobj(obj.fig,'Tag','mainmap_ax');
    
    eq=findobj(axm,'Tag','active quakes');
    
    
    if isempty(eq)
        hold(axm,'on');
        eq=scatter(axm, obj.catalog.Longitude, obj.catalog.Latitude, ...
            mag2dotsize(obj.catalog.Magnitude),datenum(obj.catalog.Date),...
            'Tag','active quakes');
        eq.ZData=obj.catalog.Depth;
        eq.Marker='s';
        hold(axm,'off');
    else
        eq.XData=obj.catalog.Longitude;
        eq.YData=obj.catalog.Latitude;
        eq.ZData=obj.catalog.Depth;
        eq.SizeData=mag2dotsize(obj.catalog.Magnitude);
        eq.CData=datenum(obj.catalog.Date);
    end
    
    hold(axm,'on');
    if ~isempty(obj.shape)
        obj.shape.plot(axm,@obj.shapeChangedFcn)
    end
    hold(axm,'off');
end
