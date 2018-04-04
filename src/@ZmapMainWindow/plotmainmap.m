function plotmainmap(obj)
    % PLOTMAINMAP set up main map window
    MAX_FOR_MARKER = 100000; %more than this number of earthquakes will be plotted with a "."
    axm=obj.map_axes;
    axm.Visible='off';
    assert(~isempty(axm),'Somehow lost track of main map');
    eq=findobj(axm,'Tag','active quakes');
    
    
    if isempty(eq) 
        % CREATE the pot
        hold(axm,'on');
        eq=scatter(axm, obj.catalog.Longitude, obj.catalog.Latitude, ...
            mag2dotsize(obj.catalog.Magnitude),getLegalColors(),...
            'Tag','active quakes','HitTest','off');
        eq.ZData=obj.catalog.Depth;
        if obj.catalog.Count > MAX_FOR_MARKER
            eq.Marker='.';
        else
            eq.Marker='o';
        end
        hold(axm,'off');
    else
        % REUSE the plot
        eq.XData=obj.catalog.Longitude;
        eq.YData=obj.catalog.Latitude;
        eq.ZData=obj.catalog.Depth;
        eq.SizeData=mag2dotsize(obj.catalog.Magnitude);
        eq.CData=getLegalColors();
    end
    
    hold(axm,'on');
    if ~isempty(obj.shape)
        obj.shape.plot(axm,@obj.shapeChangedFcn)
    end
    hold(axm,'off');
    if ~isempty(obj.Grid)
        obj.Grid = obj.Grid.MaskWithShape(obj.shape);
        obj.Grid.plot(obj.map_axes,'ActiveOnly');
    end
    axm.Visible='on';
    
    function c = getLegalColors()
        % because datetime isn't allowed
        switch  obj.colorField
            case 'Date'
                c=datenum(obj.catalog.Date);
            otherwise
                c=obj.catalog.(obj.colorField);
        end
    end
    
end