function plot_base_events(obj, container, featurelist)
    % PLOT_BASE_EVENTS plot all events from catalog as dots before it gets filtered by shapes, etc.
    % call once at beginning
    % obj.PLOT_BASE_EVENTS(featurelist) where featurelist is a cell array of feature names, such as
    % {'borders', 'coastline'}
    if ~exist('featurelist','var')
        featurelist={};
    end
        
    if isempty(obj.map_axes)
        obj.map_axes=axes(container,'Units','normalized','Position',obj.MapPos_L);
        
        obj.map_axes.Tag = 'mainmap_ax';
        obj.map_axes.TickDir='out';
        obj.map_axes.XMinorTick='on';
        obj.map_axes.YMinorTick='on';
        obj.map_axes.TickLength=[0.006 0.006];
        obj.map_axes.LineWidth=2;
        obj.map_axes.Box='on';
        obj.map_axes.BoxStyle='full';
        obj.map_axes.ZDir='reverse';
    end
    alleq = findobj(obj.map_axes,'Tag','all events');
    
    
    if isempty(alleq)
        if isempty(obj.rawcatalog)

            line(obj.map_axes,'XData',nan,'YData',nan,'ZData',nan,'Marker','.','LineStyle','none',...
                'Color',[.76 .75 .8],...
                'DisplayName','unselected events',...
                'HitTest','off',...
                'Tag','all events');
        else
            line(obj.map_axes, 'XData',obj.rawcatalog.Longitude, 'YData',obj.rawcatalog.Latitude,...
                'ZData',obj.rawcatalog.Depth,'Marker','.','LineStyle','none',...
                'Color',[.76 .75 .8],...
                'DisplayName','unselected events',...
                'HitTest','off',...
                'Tag','all events');
        end
    end
    
    
    obj.map_axes.XLabel.String='Longitude'
    obj.map_axes.YLabel.String='Latitude';
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
        obj.Features(featurelist{i})=copyobj(ZG.features(feat_key),obj.map_axes);
    end
    
    %    obj.Features(feat_key) = copyobj(ZG.features(feat_key), obj.map_axes);
    
    % MapFeature.foreach(obj.Features,'plot',obj.map_axes);
    obj.map_axes.XLimMode='manual';
    obj.map_axes.YLimMode='manual';
    c=uicontextmenu(obj.fig,'Tag','mainmap context');
    
    % options for choosing a shape
    
    uimenu(c,'Label','Delete shape',...
        'Separator','on', Futures.MenuSelectedFcn,{@updatewrapper,@(~,~)cb_shapedelete});
    uimenu(c,'Label','Zoom to shape',Futures.MenuSelectedFcn,@cb_zoom_shape);
    uimenu(c,'Label','Crop to shape',Futures.MenuSelectedFcn,@cb_crop_to_selection);
    uimenu(c,'Label','Zoom to selected events',Futures.MenuSelectedFcn,@cb_zoom)
    uimenu(c,'Label','Define X-section','Separator','on',Futures.MenuSelectedFcn,@obj.cb_xsection);
    uimenu(c,'Separator','on','Label','Hide/Show sampling grid','Tag','ToggleGrid',...
        Futures.MenuSelectedFcn,@cb_toggle_grid)
    obj.map_axes.UIContextMenu=c;

    addLegendToggleContextMenuItem(c,'bottom','above');
    %uimenu(c,'Label','Toggle ColorBar',Futures.MenuSelectedFcn,@(s,v)obj.do_colorbar);
    obj.map_axes.ButtonDownFcn = @control_menu_enablement;
    
    function control_menu_enablement(src,~)
        % enable/disable the axes menu items according to whether or not a shape exists
        % shape menu labels end with the word "shape"
        idx=endsWith({obj.map_axes.UIContextMenu.Children.Label}," shape");
        shapeExists=~isempty(obj.shape);
        set(obj.map_axes.UIContextMenu.Children(idx),'Enable',char(matlab.lang.OnOffSwitchState(shapeExists)));
        
        % enable/disable the axes menu items according to whether or not a grid exists
        % shape menu labels end with the word "shape"
        idx=endsWith({obj.map_axes.UIContextMenu.Children.Label}," sampling grid");
        gridExists=~isempty(obj.Grid);
        set(obj.map_axes.UIContextMenu.Children(idx),'Enable',char(matlab.lang.OnOffSwitchState(gridExists)));
    end
    
    function shapeassignment(sh)
        obj.shape=sh;
    end
    
    function updatewrapper(s,v,f)
        f(s,v);
        return
        obj.shape=ShapeGeneral.ShapeStash;
        obj.cb_redraw();
    end
    
    function cb_toggle_grid(src,~)
        gr = findobj(obj.map_axes.Children,'flat','-regexp','Tag','grid_\w.*');
        if numel(gr)==1
            gr.Visible=toggleOnOff(gr.Visible);
        elseif numel(gr)>1
            error('multiple grids available to toggle');
        end
    end

    function cb_shapedelete
        ShapeGeneral.clearplot();
        delete(obj.shape);
        obj.shape=ShapeGeneral;
        obj.replot_all();
    end
    
    function cb_zoom(~,~)
        xl = [min(obj.catalog.Longitude) max(obj.catalog.Longitude)];
        yl = [min(obj.catalog.Latitude) max(obj.catalog.Latitude)];
        obj.map_axes.XLim=xl;
        obj.map_axes.YLim=yl;
    end

    function cb_zoom_shape(~,~)
        if isempty(obj.shape)
            warning('No shape selected');
            return
        end
        ol=obj.shape.Outline; % as [X, Y]
        xl = [min(ol(:,1)) max(ol(:,1))];
        yl = [min(ol(:,2)) max(ol(:,2))];
        obj.map_axes.XLim=xl;
        obj.map_axes.YLim=yl;
    end
    

    function cb_crop_to_selection(~,~)
        if isempty(obj.shape)
            warning('No shape selected');
            return
        end
        obj.rawcatalog=obj.catalog;
        obj.map_axes.YLim=[min(obj.catalog.Latitude) max(obj.catalog.Latitude)];
        obj.map_axes.XLim=[min(obj.catalog.Longitude) max(obj.catalog.Longitude)];
    end
    
    function commandeer_colorbar_button()
        cbb=findall(obj.fig,'Tooltip','Insert Colorbar');
        origCallback = cbb.ClickedCallback;
        if isequal(origCallback ,@obj.do_colorbar)
            return
        end
        cbb.ClickedCallback={@obj.do_colorbar,origCallback};
        
        
    end
end
