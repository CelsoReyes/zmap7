function add_grid_menu(parent)
    % add grid menu for modifying global ZmapGrid
    GRIDPOINT.Marker='.';
    GRIDPOINT.MarkerSize=15;
    uimenu(parent,'Label','Create Auto-Grid','Callback',@cb_autogrid);
    uimenu(parent,'Label','Create Grid (interactive)','Callback',@cb_creategrid);
    uimenu(parent,'Label','Create Auto-Radius','Callback',@cb_autoradius);
    uimenu(parent,'Label','Refresh','Callback',@cb_refresh);
    uimenu(parent,'Label','Clear(Delete)','Callback',@cb_clear);
    
    function cb_creategrid(~,~)
        %CB_CREATEGRID interactively create a grid
        ZG=ZmapGlobal.Data;
        [~] = create_grid(ZG.selection_shape.Points); % getting result forces program to pause until selection is complete
        ax=mainmap('axes');
        ZG.Grid.plot(ax,'markersize',15,'ActiveOnly')
        cb_refresh()
    end
    
    function cb_autogrid(~,~)
        % following assumes grid from main map
        ZG=ZmapGlobal.Data;
        m=mainmap();
        [ZG.Grid,ZG.gridopt]=autogrid(m.Catalog(),true,true);
        if ~isempty(ZG.selection_shape)
            ZG.Grid = ZG.Grid.MaskWithShape(ZG.selection_shape);
        end
        ZG.Grid.plot(m.mainAxes,'markersize',GRIDPOINT.MarkerSize,'ActiveOnly')
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
        [r, evselch] = autoradius(ZG.primeCatalog, ZG.Grid, minNum, pct, reach);
        ZG.ra=r;
        ZG.ni=minNum;
        ZG.GridSelector=evselch;
    end
    
    function cb_refresh(~,~)
        ZG=ZmapGlobal.Data;
        ax=mainmap('axes');
        delete(findobj(gcf,'Tag',['grid_',ZG.Grid.Name]))
        ZG.Grid=ZG.Grid.MaskWithShape(ZG.selection_shape);
        ZG.Grid.plot(ax,'markersize',GRIDPOINT.MarkerSize,'ActiveOnly')
    end
    function cb_clear(~,~)
        ZG=ZmapGlobal.Data;
        try
            ZG.Grid.delete();
        catch ME
            warning(ME.message)
        end
    end
        
end