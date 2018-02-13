function plot_base_events(obj)
    % PLOT_BASE_EVENTS plot all events from catalog as dots before it gets filtered by shapes, etc.
    % call once at beginning
    axm=obj.map_axes;
    if isempty(axm)
        axm=axes('Units','pixels','Position',obj.MapPos_L);
    end
    alleq = findobj(obj.fig,'Tag','all events');
    if isempty(alleq)
        alleq=scatter(axm, obj.rawcatalog.Longitude, obj.rawcatalog.Latitude,'.',...
            'CData',[.76 .75 .8],...
            'DisplayName','unselected events',...
            'Tag','all events');
        alleq.ZData=obj.rawcatalog.Depth;
        alleq.HitTest='off';
    end
    
    axm.Tag = 'mainmap_ax';
    axm.TickDir='out';
    axm.Box='on';
    axm.ZDir='reverse';
    
    xlabel(axm,'Longitude')
    ylabel(axm,'Latitude');
    
    MapFeature.foreach(obj.Features,'plot',axm);
    axm.XLimMode='manual';
    axm.YLimMode='manual';
    c=uicontextmenu(obj.fig,'Tag','mainmap context');
    
    % options for choosing a shape
    ShapePolygon.AddPolyMenu(c,obj.shape);
    ShapeCircle.AddCircleMenu(c, obj.shape);
    for j=1:numel(c.Children)
        if startsWith(c.Children(j).Tag,{'circle','poly'})
            c.Children(j).Callback={@updatewrapper,c.Children(j).Callback};
        end
    end
    
    uimenu(c,'Label','Clear Shape','Callback',{@updatewrapper,@(~,~)cb_shapeclear});
    uimenu(c,'Label','Zoom to shape','Callback',@cb_zoom_shape);
    uimenu(c,'Label','Crop to selection','Callback',@cb_crop_to_selection);
    uimenu(c,'Label','Zoom to selection','Callback',@cb_zoom)
    uimenu(c,'Label','Define X-section','Separator','on','Callback',@(s,v)obj.cb_xsection);
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
