function add_sampling_menu(obj)
    % add grid menu for modifying grid in a ZmapMainWindow
    % obj is a ZmapMainWindow object.
    parent = uimenu(obj.fig,'Label','Sampling');
    MenuSelectedFcn=MenuSelectedField();
    
    %% Grid menu items
    
    uimenu(parent,'Label','Quick-Grid (auto)',MenuSelectedFcn,@cb_autogrid);
    uimenu(parent,'Label','Define Grid',MenuSelectedFcn,@cb_gridfigure);
    uimenu(parent,'Label','Redraw Grid',MenuSelectedFcn,@cb_refresh);
    uimenu(parent,'Label','Clear Grid (Delete)',MenuSelectedFcn,@cb_clear);
    
    %% Sampling menu items
    uimenu(parent,'Separator','on','Label','Choose Sample Radius',MenuSelectedFcn,@cb_manualradius);
    XYfun.sample_preview.AddMenuItem(parent, @()obj.map_zap);
    
    %% Polygon menu items
    uimenu(parent,'Separator','on',...
        'Label','Select events in CIRCLE',MenuSelectedFcn,@cb_makecircle);
    uimenu(parent,'Label','Select events in BOX', MenuSelectedFcn,@cb_makebox);
    uimenu(parent,'Label','Select events in POLYGON', MenuSelectedFcn,@cb_makepolygon);
    uimenu(parent,'Label','Wrap events in POLYGON (complex hull)', MenuSelectedFcn,@cb_makehull);
    uimenu(parent,'Label','about editing polygons...',MenuSelectedFcn,@(~,~)moveable_item('help'));
    uimenu(parent,'Separator','on',...
        'Label','Delete polygon', MenuSelectedFcn, @cb_clear_shape);
    
    shapeiomenu=uimenu(parent,'Separator','on','Label','Polygon IO...');
    uimenu(shapeiomenu,'Label','get default', MenuSelectedFcn, @(~,~)cb_get_default_shape);
    uimenu(shapeiomenu,'Label','set as default', MenuSelectedFcn, @(~,~)ShapeGeneral.ShapeStash(obj.shape));
    uimenu(shapeiomenu,'Separator','on',...
        'Label','Load a polygon',MenuSelectedField(),@cb_load_shape)
    uimenu(shapeiomenu,'Label','Save a polygon',MenuSelectedField(),@cb_save_shape)
    % uimenu(shapeiomenu,'Label','save', MenuSelectedFcn, @(~,~)obj.shape.save(ZmapGlobal.Data.Directories.data));
    
    function cb_makecircle(src,ev)
        bringToForeground(obj.map_axes);
        %bringToForeground(findobj(obj.fig,'Tag','mainmap_ax'));
        sh=ShapeCircle.selectUsingMouse(obj.map_axes, obj.refEllipsoid);
        set_my_shape(obj,sh);
    end
    
    function cb_makebox(src,ev)
        bringToForeground(obj.map_axes);
        %bringToForeground(findobj(obj.fig,'Tag','mainmap_ax'));
        sh=ShapePolygon('box');
        set_my_shape(obj,sh);
    end
    
    function cb_makepolygon(src,ev)
        bringToForeground(obj.map_axes);
        %bringToForeground(findobj(obj.fig,'Tag','mainmap_ax'));
        sh=ShapePolygon('polygon');
        set_my_shape(obj,sh);
    end
    
    function cb_makehull(src,ev)
        bringToForeground(obj.map_axes);
        %bringToForeground(findobj(obj.fig,'Tag','mainmap_ax'));
        eqs = [obj.catalog.X, obj.catalog.Y];
        ch=convhull(eqs,'simplify',true);
        sh=ShapePolygon('polygon',eqs(ch,:));
        set_my_shape(obj,sh);
    end
    function cb_clear_shape(src,ev)
        ShapeGeneral.clearplot();
        delete(obj.shape);
        obj.shape=ShapeGeneral();
        %obj.replot_all();
    end
    
    function cb_save_shape(src,ev)
        if isempty(obj.shape)
            errordlg('No shape is currently selected.');
        else
            obj.shape.save();
        end
    end
    function cb_load_shape(src,ev)
        bringToForeground(obj.map_axes);
        %bringToForeground(findobj(obj.fig,'Tag','mainmap_ax'));
        sh = load_shape();
        if isempty(sh)
            errordlg('Unable to load shape, or operation was cancelled');
        else
            obj.set_my_shape(sh);
        end
    end
    
    function cb_get_default_shape(src,ev)
        sh=ShapeGeneral.ShapeStash();
        if isempty(sh)
            warndlg('No default shape exists');
        else
            set_my_shape(obj,sh);
        end
    end
    
    function cb_autogrid(~,~)
        % following assumes grid from main map
        
        if ~isempty(obj.Grid)
            todel=findobj(obj.map_axes,'Tag',['grid_', obj.Grid.Name]);
        else
            todel=[];
        end
        delete(todel);
        
        [tmpgrid,obj.gridopt]=autogrid(obj.catalog, obj.refEllipsoid, obj.map_axes);
        obj.Grid = tmpgrid.MaskWithShape(obj.shape);
        obj.Grid.plot(obj.map_axes,'ActiveOnly');

    end
    
    function cb_gridfigure(src,ev)
        watchon
        drawnow
        [gr, gro] = GridOptions.fromDialog(obj.gridopt, obj.refEllipsoid,obj.shape);
        if ~isempty(gr)
            obj.Grid = gr;
            obj.gridopt = gro;
        end
        mygr=findobj(obj.map_axes.Children,'flat','-regexp','Tag','grid_\w.*');
        delete(mygr);
        obj.Grid.plot(obj.map_axes,'ActiveOnly');
        watchoff
    end

    function cb_manualradius(~,~)
        ev = obj.get_event_selection;
        if isempty(ev)
            [evselch, okpressed] = EventSelectionChoice.quickshow(true);
        else
            
            [evselch, okpressed] = EventSelectionChoice.quickshow(false, ev);
        end
        if okpressed
            obj.set_event_selection(EventSelectionParameters.fromStruct(evselch));
        end
        
        % send message that global grid changed
    end

    function cb_refresh(~,~)
        if isempty(obj.Grid)
            warning('ZMAP:grid:missingGrid','no grid exists to refresh')
            warndlg('no grid exists to refresh')
            return
        end
        delete(findobj(obj.fig,'Tag',['grid_',obj.Grid.Name]))
        obj.Grid=obj.Grid.MaskWithShape(obj.shape);
        obj.Grid.plot(obj.map_axes,'ActiveOnly');
    end
    
    function cb_clear(~,~)
        try
            obj.Grid = obj.Grid.delete();
        catch ME
            warning(ME.message)
        end
    end
        
end