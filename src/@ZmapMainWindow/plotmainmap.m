function plotmainmap(obj)
    % PLOTMAINMAP set up main map window
    MAX_FOR_MARKER = 100000; %more than this number of earthquakes will be plotted with a "."
    axm=obj.map_axes;
    axm.Visible='off';
    assert(~isempty(axm),'Somehow lost track of main map');
    
    % update the active earthquakes
    eq=findobj(axm,'Tag','active quakes');
    
    
    if isempty(eq) 
        % CREATE the plot
        
        axm.NextPlot='add';
        dispname = replace(obj.catalog.Name,'_','\_');
        eq=scatter(axm, obj.catalog.Longitude, obj.catalog.Latitude, ...
            mag2dotsize(obj.catalog.Magnitude),getLegalColors(),...
            'LIneWidth',.5,...
            'Tag','active quakes','HitTest','off','DisplayName',dispname);
        eq.ZData=obj.catalog.Depth;
        if obj.catalog.Count > MAX_FOR_MARKER
            eq.Marker='.';
        else
            eq.Marker=obj.eventMarker;
        end
        axm.NextPlot='replace';
        %obj.do_colorbar(axm);
    else
        % REUSE the plot
        eq.XData=obj.catalog.Longitude;
        eq.YData=obj.catalog.Latitude;
        eq.ZData=obj.catalog.Depth;
        eq.SizeData=mag2dotsize(obj.catalog.Magnitude);
        eq.CData=getLegalColors();
        dispname = replace(obj.catalog.Name,'_','\_');
        if ~strcmp(eq.DisplayName,dispname)
            eq.DisplayName=dispname;
        end
        
    end
    % update the largest events
    update_large()
    %{
    beq = findobj(axm,'Tag','big events');
    
    beq.XData=obj.bigEvents.Longitude;
    beq.YData=obj.bigEvents.Latitude;
    beq.ZData=obj.bigEvents.Depth;
    beq.SizeData=mag2dotsize(obj.bigEvents.Magnitude);
    %}
    
    % update the shape
    axm.NextPlot='add';
    if ~isempty(obj.shape)
        %obj.shape.plot(axm,@obj.shapeChangedFcn)
        obj.shape.plot(axm);
    end
    axm.NextPlot='replace';
    
    % update the grid
    if ~isempty(obj.Grid)
        if isempty(obj.shape) && all(obj.Grid.ActivePoints(:))
            % do nothing needs to be done.
        else
            maskedGrid = obj.Grid.MaskWithShape(obj.shape);
            if ~isequal(maskedGrid.ActivePoints, obj.Grid.ActivePoints)
                %obj.Grid = obj.Grid.MaskWithShape(obj.shape);
                obj.Grid.ActivePoints = maskedGrid.ActivePoints;
                obj.Grid.plot(obj.map_axes,'ActiveOnly');
            end
        end
    end
    axm.Visible='on';
    
    function update_large()
        beq = findobj(axm,'Tag','big events');
        beq.XData=obj.bigEvents.Longitude;
        beq.YData=obj.bigEvents.Latitude;
        beq.ZData=obj.bigEvents.Depth;
        beq.SizeData=mag2dotsize(obj.bigEvents.Magnitude);
    end
    function c = getLegalColors()
        % because datetime isn't allowed
        switch  obj.colorField
            case '-none-'
                c=[0 0 .15];
            case 'Date'
                c=datenum(obj.catalog.Date);
            otherwise
                c=obj.catalog.(obj.colorField);
        end
    end
    
end