function add_grid_menu(obj)
    % add grid menu for modifying grid in a ZmapMainWindow
    parent = uimenu(obj.fig,'Label','Grid');
    uimenu(parent,'Label','Create Auto-Grid',Futures.MenuSelectedFcn,@cb_autogrid);
    uimenu(parent,'Label','Create Grid (interactive)',Futures.MenuSelectedFcn,@cb_creategrid);
    uimenu(parent,'Label','Refresh Grid',Futures.MenuSelectedFcn,@cb_refresh);
    uimenu(parent,'Label','Clear Grid (Delete)',Futures.MenuSelectedFcn,@cb_clear);
    uimenu(parent,'Separator','on','Label','Create Auto Sample Radius',Futures.MenuSelectedFcn,@cb_autoradius);
    uimenu(parent,'Label','Choose Sample Radius',Futures.MenuSelectedFcn,@cb_manualradius);
    
    function cb_creategrid(~,~)
        %CB_CREATEGRID interactively create a grid
        %obj=ZmapGlobal.Data;
        
        if ~isempty(obj.Grid)
            todel=findobj(obj.map_axes,'Tag',['grid_', obj.Grid.Name]);
        else
            todel=[];
        end
        delete(todel);
        
        obj.Grid = create_grid(...
            obj.shape.Outline,...
            false,... % do not follow meridians (km)
            false... % do not trim to the shape
            ); % getting result forces program to pause until selection is complete
        obj.Grid.plot(obj.map_axes,'ActiveOnly')
        cb_refresh()
    end
    
    function cb_autogrid(~,~)
        % following assumes grid from main map
        
        if ~isempty(obj.Grid)
            todel=findobj(obj.map_axes,'Tag',['grid_', obj.Grid.Name]);
        else
            todel=[];
        end
        delete(todel);
        
        [obj.Grid,obj.gridopt]=autogrid(obj.catalog,...
            false,... % plot histogram
            true... % put on map
            );
        obj.Grid = obj.Grid.MaskWithShape(obj.shape);
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
        obj.Grid.plot(obj.map_axes,'ActiveOnly')
    end
    
    function cb_clear(~,~)
        try
            obj.Grid = obj.Grid.delete();
        catch ME
            warning(ME.message)
        end
    end
        
end