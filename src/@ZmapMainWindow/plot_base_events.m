function plot_base_events(obj, featurelist)
    % PLOT_BASE_EVENTS plot all events from catalog as dots before it gets filtered by shapes, etc.
    % call once at beginning
    % obj.PLOT_BASE_EVENTS(featurelist) where featurelist is a cell array of feature names, such as
    % {'borders', 'coastline'}
    if ~exist('featurelist','var'), featurelist={}; end
        
    axm=obj.map_axes;
    if isempty(axm)
        axm=axes('Units','pixels','Position',obj.MapPos_L);
    end
    alleq = findobj(obj.fig,'Tag','all events');
    if isempty(alleq)
        line(axm, 'XData',obj.rawcatalog.Longitude, 'YData',obj.rawcatalog.Latitude,...
            'ZData',obj.rawcatalog.Depth,'Marker','.','LineStyle','none',...
            'Color',[.76 .75 .8],...
            'DisplayName','unselected events',...
            'HitTest','off',...
            'Tag','all events');
    end
    
    axm.Tag = 'mainmap_ax';
    axm.TickDir='out';
    axm.Box='on';
    axm.ZDir='reverse';
    
    xlabel(axm,'Longitude')
    ylabel(axm,'Latitude');
    ZG=ZmapGlobal.Data;
    
    
    wereLoaded = cellfun(@(x) ZG.features(x).WasLoaded , featurelist);
    if ~all(wereLoaded)
        % prior to 2017B (ver 9.3), cellfun can't simply return a featurelist.
        doNewWay =  ~verLessThan('matlab','9.3');
        theFeatures = cellfun(@(x) ZG.features(x), featurelist, 'UniformOutput',doNewWay); 
        if iscell(theFeatures),theFeatures=[theFeatures{:}]; end
        MapFeature.foreach_waitbar(theFeatures(~wereLoaded),'load');
    end
    for i=1:numel(featurelist)
        feat_key = featurelist{i};
        obj.Features(featurelist{i})=copyobj(ZG.features(feat_key),axm);
    end
    
    %    obj.Features(feat_key) = copyobj(ZG.features(feat_key), axm);
    
    % MapFeature.foreach(obj.Features,'plot',axm);
    axm.XLimMode='manual';
    axm.YLimMode='manual';
    c=uicontextmenu(obj.fig,'Tag','mainmap context');
    
    % options for choosing a shape
    ShapePolygon.AddPolyMenu(c,obj.shape);
    ShapeCircle.AddCircleMenu(c, obj.shape);
    for j=1:numel(c.Children)
        if startsWith(c.Children(j).Tag,{'circle','poly'})
            c.Children(j).MenuSelectedFcn={@updatewrapper,c.Children(j).Callback};
        end
    end
    
    uimenu(c,'Label','Clear Shape','MenuSelectedFcn',{@updatewrapper,@(~,~)cb_shapeclear});
    uimenu(c,'Label','Zoom to shape','MenuSelectedFcn',@cb_zoom_shape);
    uimenu(c,'Label','Crop to selection','MenuSelectedFcn',@cb_crop_to_selection);
    uimenu(c,'Label','Zoom to selection','MenuSelectedFcn',@cb_zoom)
    uimenu(c,'Label','Define X-section','Separator','on','MenuSelectedFcn',@(s,v)obj.cb_xsection);
    axm.UIContextMenu=c;
    addLegendToggleContextMenuItem(axm,axm,c,'bottom','above');
    
    function updatewrapper(s,v,f)
        f(s,v);
        obj.shape=copy(ZmapGlobal.Data.selection_shape);
        obj.cb_redraw();
    end
    
    function cb_shapeclear
        ZG=ZmapGlobal.Data;
        ZG.selection_shape=ShapeGeneral('unassigned');
        ZG.selection_shape.clearplot();
    end
    function cb_zoom(~,~)
        xl = [min(obj.catalog.Longitude) max(obj.catalog.Longitude)];
        yl = [min(obj.catalog.Latitude) max(obj.catalog.Latitude)];
        axm.XLim=xl;
        axm.YLim=yl;
    end

    function cb_zoom_shape(~,~)
        if isempty(obj.shape)
            warning('No shape selected');
            return
        end
        ol=obj.shape.Outline; % as [X, Y]
        xl = [min(ol(:,1)) max(ol(:,1))];
        yl = [min(ol(:,2)) max(ol(:,2))];
        axm.XLim=xl;
        axm.YLim=yl;
    end
    

    function cb_crop_to_selection(~,~)
        if isempty(obj.shape)
            warning('No shape selected');
            return
        end
        obj.rawcatalog=obj.catalog;
        axm.YLim=[min(obj.catalog.Latitude) max(obj.catalog.Latitude)];
        axm.XLim=[min(obj.catalog.Longitude) max(obj.catalog.Longitude)];
    end
    
end
