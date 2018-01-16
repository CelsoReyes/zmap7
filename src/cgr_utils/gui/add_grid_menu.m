function add_grid_menu(parent)
    % add grid menu for modifying global ZmapGrid
    
    uimenu(parent,'Label','Change grid parameters',...
        'Separator','on',...
        'Callback',@(~,~)cb_changegridopts);
    uimenu(parent,'Label','Create Auto-Grid','Callback',@(~,~)cb_autogrid);
    uimenu(parent,'Label','Create Auto-Radius','Callback',@(~,~)cb_autoradius);
    uimenu(parent,'Label','Apply grid','Callback',@cb_applygrid);
     
    function cb_applygrid(~,~)
        % cb_applygrid sets the grid according to the selected shape
        ZG=ZmapGlobal.Data;
        obj=ZG.selection_shape;
        gopt=ZG.gridopt; %get grid options
        if gopt.GridEntireArea || (isempty(obj.Lon)||isnan(obj.Lon(1)))% use catalog
            xmin=min(ZG.primeCatalog.Longitude);
            xmax=max(ZG.primeCatalog.Longitude);
            ymin=min(ZG.primeCatalog.Latitude);
            ymax=max(ZG.primeCatalog.Latitude);
        else %use shape
            xmin=min(obj.Lon);
            xmax=max(obj.Lon);
            ymin=min(obj.Lat);
            ymax=max(obj.Lat);
        end
        ZG.Grid=ZmapGrid.FromVectors('grid',...
            xmin:gopt.dx:xmax,...
            ymin:gopt.dy:ymax,...
            gopt.dx_units);
        if ~isempty(obj.Lon) && ~isnan(obj.Lon(1)) && ~gopt.GridEntireArea
            ZG.Grid=ZG.Grid.MaskWithPolygon(obj.Lon, obj.Lat);
        end
        ZG.Grid.plot();
    end
    
    function cb_autogrid(~,~)
        % following assumes grid from main map
        ZG=ZmapGlobal.Data;
        m=mainmap();
        [ZG.Grid,ZG.gridopt]=autogrid(m.Catalog(),true,true);
        if ~isempty(ZG.selection_shape)
            ZG.Grid = ZG.Grid.MaskWithPolygon(ZG.selection_shape.Lon,ZG.selection_shape.Lat);
        end
        ZG.Grid.plot(m.mainAxes,'markersize',20,'ActiveOnly')
        % following assumes global 
        %ZG=ZmapGlobal.Data;
        %[ZG.Grid,ZG.gridopt]=autogrid(ZG.primeCatalog,true,true);
        %[ZG.Grid,ZG.gridopt]=autogrid(ZG.Views.primary,true,true);
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
    
    function cb_changegridopts(~,~)
        error('unimplemented')
        GridParameterChoice();
    end
end