function plotmainmap(obj)
    % PLOTMAINMAP set up main map window
    
    % TAG : PURPOSE
    % "active quakes" : selected events
    % "big evens" : selected events, above a threshhold magnitude
    
    
    axm = obj.map_axes;
    axm.Visible = 'off';
    assert(~isempty(axm), 'Somehow lost track of main map');
    
    % update the active earthquakes
    eq=findobj(axm,'Tag','active quakes');
    
    mainEventOpts = obj.mainEventProps; % local copy
    szFcn = str2func(mainEventOpts.MarkerSizeFcn);
    
    if mainEventOpts.UseDotsForTooManyEvents && obj.catalog.Count > mainEventOpts.HowManyAreTooMany
        mainEventOpts.Marker = '.';
    end
    
    if isempty(eq) 
        % CREATE the plot
        
        axm.NextPlot='add';
        dispname = replace(obj.catalog.Name,'_','\_');
        
        szFcn = str2func(mainEventOpts.MarkerSizeFcn);
        eq=scatter(axm, obj.catalog.Longitude, obj.catalog.Latitude, ...
            szFcn(obj.catalog.Magnitude), getLegalColors(),...
            'Tag','active quakes',...
            'HitTest','off',...
            'DisplayName',dispname);
        eq.ZData = obj.catalog.Depth;
        axm.NextPlot='replace';
        %obj.do_colorbar(axm);
        
    else
        
        % REUSE the plot
        eq.XData = obj.catalog.Longitude;
        eq.YData = obj.catalog.Latitude;
        eq.ZData = obj.catalog.Depth;
        eq.SizeData = szFcn(obj.catalog.Magnitude);
        eq.MarkerEdgeColor='flat';
        eq.CData = getLegalColors();
        
        % this is a kludge, because if a MarkerEdgeColor is defined that isn't specifically 'flat'
        % then it overrides the CData colors.
        if size(eq.CData(:,1)>1)
            mainEventOpts=renameStructField(mainEventOpts,'MarkerEdgeColor','Marker_Edge_Color');
        else
            mainEventOpts=renameStructField(mainEventOpts,'Marker_Edge_Color','MarkerEdgeColor');
        end
        dispname = replace(obj.catalog.Name, '_', '\_');
        if ~strcmp(eq.DisplayName, dispname)
            eq.DisplayName = dispname;
        end
    end
    
    set_valid_properties(eq, mainEventOpts);
    
    % update the largest events
    update_large()
    
    % update the shape
    axm.NextPlot='add';
    if ~isempty(obj.shape)
        obj.shape.plot(axm);
    end
    axm.NextPlot='replace';
    
    % update the grid
    if ~isempty(obj.Grid)
        if isempty(obj.shape) && all(obj.Grid.ActivePoints(:))
            % do nothing needs to be done.
            obj.Grid.plot(obj.map_axes, 'HitTest', 'off', 'ActiveOnly');
        else
            maskedGrid = obj.Grid.MaskWithShape(obj.shape);
            if ~isequal(maskedGrid.ActivePoints, obj.Grid.ActivePoints)
                obj.Grid.ActivePoints = maskedGrid.ActivePoints;
                obj.Grid.plot(obj.map_axes, 'HitTest', 'off', 'ActiveOnly');
            end
        end
    end
    axm.Visible='on';
    
    function update_large()
        beq = findobj(axm,'Tag','big events');
        
        if ~isempty(obj.bigEvents)
            beq.XData = obj.bigEvents.Longitude;
            beq.YData = obj.bigEvents.Latitude;
            beq.ZData = obj.bigEvents.Depth;
            beq.SizeData=mag2dotsize(obj.bigEvents.Magnitude);
        else
            [beq.XData, beq.YData, beq.ZData, beq.SizeData]=deal([]);
        end
        
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