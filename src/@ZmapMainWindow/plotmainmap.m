function plotmainmap(obj)
    % PLOTMAINMAP set up main map window
    MAX_FOR_MARKER = 100000; %more than this number of earthquakes will be plotted with a "."
    axm=obj.map_axes;
    axm.Visible='off';
    assert(~isempty(axm),'Somehow lost track of main map');
    eq=findobj(axm,'Tag','active quakes');
    
    
    if isempty(eq)
        hold(axm,'on');
        eq=scatter(axm, obj.catalog.Longitude, obj.catalog.Latitude, ...
            mag2dotsize(obj.catalog.Magnitude),datenum(obj.catalog.Date),...
            'Tag','active quakes','HitTest','off');
        eq.ZData=obj.catalog.Depth;
        if obj.catalog.Count > MAX_FOR_MARKER
            eq.Marker='.'
        else
            eq.Marker='o';
        end
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
    axm.Visible='on';
end
