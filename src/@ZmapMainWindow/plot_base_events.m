function plot_base_events(obj)
    % PLOT_BASE_EVENTS plot all events from catalog as dots before it gets filtered by shapes, etc.
    % call once at beginning
    axm=findobj(obj.fig,'Tag','mainmap_ax');
    if isempty(axm)
        axm=axes('Units','pixels','Position',obj.MapPos_L);
    end
    
    alleq = findobj(obj.fig,'Tag','all events');
    if isempty(alleq)
        alleq=scatter(axm, obj.rawcatalog.Longitude, obj.rawcatalog.Latitude,'.','CData',[.76 .75 .8],'Tag','all events');
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
    
    mapoptionmenu=uimenu(obj.fig,'Label','Map Options','Tag','mainmap_menu_overlay');
    uimenu(mapoptionmenu,'Label','Set aspect ratio by latitude',...
        'callback',@toggle_aspectratio,...
        'checked',ZmapGlobal.Data.lock_aspect);
    if strcmp(ZmapGlobal.Data.lock_aspect,'on')
        daspect(axm, [1 cosd(mean(axm.YLim)) 10]);
    end
    
    uimenu(mapoptionmenu,'Label','Toggle Lat/Lon Grid',...
        'callback',@toggle_grid,...
        'checked',ZmapGlobal.Data.mainmap_grid);
    if strcmp(ZmapGlobal.Data.mainmap_grid,'on')
        grid(axm,'on');
    end
    
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
    
    function toggle_aspectratio(src, ~)
        src.Checked=toggleOnOff(src.Checked);
        switch src.Checked
            case 'on'
                daspect(axm, [1 cosd(mean(axm.YLim)) 10]);
            case 'off'
                daspect(axm,'auto');
        end
        ZG = ZmapGlobal.Data;
        ZG.lock_aspect = src.Checked;
        %align_supplimentary_legends();
    end
    
    function toggle_grid(src, ~)
        src.Checked=toggleOnOff(src.Checked);
        grid(axm,src.Checked);
        drawnow
    end
end
