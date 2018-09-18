function selectp(in_or_out)
    %  This .m file selects the earthquakes within a polygon
    %  and plots them. Sets "primeCatalog" equal to the catalogue produced after the
    %  general parameter selection. Operates on "storedcat", replaces "primeCatalog"
    %  with new data and makes "primeCatalog" equal to ZG.newcat
    %
    %   operates on main map window
    % plot tags:
    %  'poly_selected_events' : earthquakes in/out of polygon
    %  'mouse_points_overlay' : polygon outline
    
    ZG=ZmapGlobal.Data;
    echo on
    % ___________________________________________________________
    %  Please use the left mouse button or the cursor to select
    %  the polygon vertexes.
    %
    %  Use the right mouse button to select the final point.
    %_____________________________________________________________
    echo off
    report_this_filefun();
    %zoom off
    ZG.newt2 = [ ];           % reset catalogue variables
    %a=storedcat;              % uses the catalogue with the pre-selected main
    % general parameters
    ZG.newcat = ZG.primeCatalog;
    
    delete(findobj('Tag','mouse_points_overlay'));
    delete(findobj('Tag','poly_selected_events'));
    
    % pick polygon points,
    ax=findobj(gcf,'Tag','mainmap_ax');
    [x,y, mouse_points_overlay] = select_polygon(ax);
    
    
    if ~exist('in_or_out','var')
        in_or_out = 'inside';
    end
    if isnumeric(ZG.primeCatalog)
        error('old catalog');
    else
        mask = polygon_filter(x,y, ZG.primeCatalog.Longitude, ZG.primeCatalog.Latitude, in_or_out);
        ZG.newt2 = ZG.primeCatalog.subset(mask);
        
        % Plot of new catalog
        washeld=ishold(ax); ax.NextPlot='add';
        hMap=mainmap();
        hMap.plotOtherEvents(ZG.newt2,0,...
            'Marker','.',...
            'LineStyle','none',...
            'MarkerEdgeColor','g',...
            'MarkerFaceColor','none',...
            ...'Linewidth',1.5,...
            'DisplayName','Selected Events');
        
        %change the polygon characteristics
        set(mouse_points_overlay,'LineStyle','--','LineWidth',2,'Color',[.5 .5 .5],'Marker','none');
        if ~washeld; ax.NextPlot='replace';end
    end
    % ask for a name for this new catalog
    %ploc = get(0,'PointerLocation');
    prompt = 'Please provide a catalog name:';
    dlgname = 'CatalogSelection';
    numlines = 1;
    defaultans = {'new_catalog'};
    sel_nm = inputdlg('Please provide a catalog name:','Name of Selected Catalog',1, defaultans);
    if ~isempty(sel_nm)
        ZG.newt2.Name = sel_nm{1};
    end
    xy = [x y];
    
    %save polcor.dat xy -ascii
    [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.Directories.data, '*.txt'),'Save Polygon ? (yes/cancel)');
    if length(file1) > 1
        if length(file1)>3
            if strcmp(file1(length(file1)-3:length(file1)),'.txt')==0
                file1=[file1 '.txt']
            end
        end
        save([path1 file1],'xy', '-ascii');
    end
    
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %
    %   The new catalog (ZG.newcat) with points only within the
    %   selected Polygon is created and resets the original
    %   "primeCatalog" .
    %
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    ZG.newcat = ZG.newt2;                   % resets ZG.newcat and ZG.newt2
    
    ctp=CumTimePlot(ZG.newt2);
    ctp.plot();
    
    h=ZmapMessageCenter;
    h.update_catalog();
end