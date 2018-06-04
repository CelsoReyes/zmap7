function add_grid_menu(obj)
    % add grid menu for modifying grid in a ZmapMainWindow
    parent = uimenu(obj.fig,'Label','Sampling');
    MenuSelectedFcn=Futures.MenuSelectedFcn;
    uimenu(parent,'Label','Quick-Grid (auto)',MenuSelectedFcn,@cb_autogrid);
    uimenu(parent,'Label','Define Grid',MenuSelectedFcn,@cb_gridfigure);
    uimenu(parent,'Label','Redraw Grid',MenuSelectedFcn,@cb_refresh);
    uimenu(parent,'Label','Clear Grid (Delete)',MenuSelectedFcn,@cb_clear);
    
    uimenu(parent,'Separator','on',...
        'Label','Create Auto Sample Radius',MenuSelectedFcn,@cb_autoradius);
    uimenu(parent,'Label','Choose Sample Radius',MenuSelectedFcn,@cb_manualradius);
    
    uimenu(parent,'Separator','on',...
        'Label','Select events in CIRCLE',MenuSelectedFcn,@cb_makecircle);
    uimenu(parent,'Label','Select events in BOX', MenuSelectedFcn,@cb_makebox);
    uimenu(parent,'Label','Select events in POLYGON', MenuSelectedFcn,@cb_makepolygon);
    
    uimenu(parent,'Label','Delete shape', MenuSelectedFcn, @cb_clear_shape);
    
    shapeiomenu=uimenu(parent,'Separator','on','Label','Shape IO...');
    uimenu(shapeiomenu,'Label','get default', MenuSelectedFcn, @(~,~)cb_get_default_shape);
    uimenu(shapeiomenu,'Label','set as default', MenuSelectedFcn, @(~,~)ShapeGeneral.ShapeStash(obj.shape));
    uimenu(shapeiomenu,'Separator','on',...
        'Label','load', MenuSelectedFcn, @(~,~)cb_load_shape);
    uimenu(shapeiomenu,'Label','save', MenuSelectedFcn, @(~,~)obj.shape.save(ZmapGlobal.Data.data_dir));
    
    function cb_makecircle(src,ev)
        bringToForeground(findobj(obj.fig,'Tag','mainmap_ax'));
        sh=ShapeCircle.selectUsingMouse(obj.map_axes);
        set_my_shape(obj,sh);
    end
    
    function cb_makebox(src,ev)
        bringToForeground(findobj(obj.fig,'Tag','mainmap_ax'));
        sh=ShapePolygon('box');
        set_my_shape(obj,sh);
    end
    
    function cb_makepolygon(src,ev)
        bringToForeground(findobj(obj.fig,'Tag','mainmap_ax'));
        sh=ShapePolygon('polygon');
        set_my_shape(obj,sh);
    end
    
    function cb_clear_shape(src,ev)
        ShapeGeneral.clearplot();
        delete(obj.shape);
        obj.shape=ShapeGeneral;
        %obj.replot_all();
    end
    
    function cb_load_shape(src,ev)
        sh=ShapeGeneral.load(ZmapGlobal.Data.data_dir);
        cb_clear_shape;
        if ~isempty(sh)
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
        
        [tmpgrid,obj.gridopt]=autogrid(obj.catalog,...
            false,... % plot histogram
            true... % put on map
            );
        obj.Grid = tmpgrid.MaskWithShape(obj.shape);
        obj.Grid.plot(obj.map_axes,'ActiveOnly');

    end
    
    function cb_gridfigure(src,ev)
        [obj.Grid, obj.gridopt] = GridOptions.fromDialog(obj.gridopt);
        mygr=findobj(obj.map_axes.Children,'flat','-regexp','Tag','grid_\w.*');
        delete(mygr);
        
        obj.Grid.plot(obj.map_axes,'ActiveOnly');
    end
    
    function cb_autoradius(~,~)
        ZG=ZmapGlobal.Data;
        sdlg.prompt='Required Number of Events:'; sdlg.value=ZG.ni;
        sdlg(2).prompt='Percentile:'; sdlg(2).value=50;
        sdlg(3).prompt='reach:' ; sdlg(3).value=1.5;
        [~,cancelled,minNum,pct,reach]=smart_inputdlg('automatic radius',sdlg);
        if cancelled
            beep
            return
        end
        [r, evselch] = autoradius(obj.catalog, obj.Grid, minNum, pct, reach);
        ZG.ra=r;
        ZG.ni=minNum;
        ZG.GridSelector=evselch;
        obj.set_event_selection(evselch);
        
    end
    function cb_manualradius(~,~)
        ev = obj.get_event_selection;
        if isempty(ev)
            [evselch, okpressed] = EventSelectionChoice.quickshow(true);
        else
            [evselch, okpressed] = EventSelectionChoice.quickshow(false,ev.numNearbyEvents,ev.maxRadiusKm,ev.requiredNumEvents);
        end
        if okpressed
            obj.set_event_selection(evselch);
        end
        
        % send message that global grid changed
    end

    function cb_refresh(~,~)
        if isempty(obj.Grid)
            warning('no grid exists to refresh')
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