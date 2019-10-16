function submenu = catalog_menu(obj, force)
    % catalog_menu was create_catalog_menu adds a menu designed to handle catalog modifications
    
    
    % to find this menu, use findobj(obj.fig, 'Tag');
    
    ZG = ZmapGlobal.Data; % for use in all subroutines
    submenu = findobj(obj.fig,'Tag','menu_catalog');
    if ~exist('force','var')
        force=false;
    end
    if ~isempty(submenu) && force
        delete(submenu); 
        submenu=[];
    end
    if ~isempty(submenu)
        return
    end
    
    submenu = uimenu('Label','Catalog','Tag','menu_catalog');
    
    catmenu = uimenu(submenu,'Label','Get/Load Catalog');
    
    uimenu(submenu,'Label','Reload last catalog',MenuSelectedField(),@cb_reloadlast,...
        'Enable','off');
    
    uimenu(catmenu,'Label','from *.mat file',...
        MenuSelectedField(), @(s,v)cb_importer(s, v, @load_zmapfile));
    
    uimenu(catmenu,'Label','from other formatted file',...
        MenuSelectedField(), @(s,v)cb_importer(s, v, @zdataimport));
    uimenu(catmenu,'Label','from FDSN webservice',...
        MenuSelectedField(), @(s,v)cb_importer(s, v, @get_fdsn_data_from_web_callback));
    uimenu(catmenu,'Label','from the current MATLAB Workspace',...
        MenuSelectedField(), @(s,v)cb_importer(s, v, @cb_catalog_from_workspace));
    
    
    uimenu(submenu,'Label','Save current catalog',MenuSelectedField(),@(~,~)save_zmapcatalog(obj.catalog));
    
    catexport = uimenu(submenu,'Label','Export current catalog...');
    uimenu(catexport,'Label','to workspace (as catalog)',MenuSelectedField(),@(~,~)exportToWorkspace(obj.catalog,'catalog'));
    uimenu(catexport,'Label','to workspace (Table)',MenuSelectedField(),@(~,~)exportToWorkspace(obj.catalog,'table'));
        uimenu(catexport,'Label','to workspace (old ZmapArray)',MenuSelectedField(),@(~,~)exportToWorkspace(obj.catalog,'ZmapArray'));
    
    
    uimenu(catmenu,'Separator','on','Label','Set as main catalog',...
        MenuSelectedField(),@cb_replace_main); % Replaces the primary catalog, and replots this subset in the map window
    
    %uimenu(catmenu,'Separator','on','Label','Reset',...
    %    MenuSelectedField(),@cb_resetcat); % Resets the catalog to the original selection
    
    uimenu(submenu,'Separator','on',...
        'Label','Edit Raw Catalog Range...',MenuSelectedField(),@cb_editrange);
    
    % choose a time range by clicking on the axes. only available if x-axis is a datetime axis.
    
    uimenu(submenu,'Label','Rename...',MenuSelectedField(),@cb_rename);
    uimenu(submenu,'Separator','on',...
        'Label','Remove inactive events',...
        MenuSelectedField(), @cb_usesubset);
    uimenu(submenu,'Separator','on',...
        'Label','Memorize Catalog',  MenuSelectedField(), @cb_memorize);
    uimenu(submenu,'Label','Recall Catalog', MenuSelectedField(), @cb_recall);
        
    uimenu(submenu,'Label','Combine catalogs',MenuSelectedField(),@cb_combinecatalogs,...
        'Separator','on');
    
    
    uimenu(submenu,'Label','Split and Compare', ...
        MenuSelectedField(),@(~,~)multi_range_selector(obj.catalog, ...
        @(x)ZG.catalogs.set('catalogA',x), @(x)ZG.catalogs.set('catalogB',x)) );
    
    uimenu(submenu,'Label','Compare catalogs - find identical events',MenuSelectedField(),@(~,~)comp2cat);
    

    uimenu(submenu,'Label','Info (Summary)',MenuSelectedField(),@(~,~)info_summary_callback(obj.catalog),...
        'Separator','on');
    
    
    %uimenu (submenu,'Label','Decluster the catalog',...
    %    MenuSelectedField(),@(~,~)ReasenbergDeclusterClass(obj.catalog));
    
    function cb_recall(~,~)
        mcm = MemorizedCatalogManager;
        if ~isempty(mcm) && any(mcm.list == "default")
            obj.rawcatalog = mcm.recall();
            obj.CatalogManager.RawCatalog = obj.rawcatalog;
            
            [obj.mshape,obj.mdate] = obj.filter_catalog();
            obj.map_axes.XLim = bounds2(obj.rawcatalog.X);
            obj.map_axes.YLim = bounds2(obj.rawcatalog.Y);
            
            hh = msgbox_nobutton('The catalog has been recalled.','Recall Catalog');
            hh.delay_for_close(1);
            %obj.replot_all();
        else
            warndlg('No catalog is currently memorized','Recall Catalog');
        end
    end
    
    function cb_memorize(~,~)
        mcm = MemorizedCatalogManager;
        mcm.memorize(obj.catalog);
        hh=msgbox_nobutton('The catalog has been memorized.','Memorize Catalog');
        hh.delay_for_close(1);
    end
    
    function cb_clearmemorized(~,~)
        mcm = MemorizedCatalogManager;
        if isempty(mcm) || ~any(mcm.list=="default")
            warndlg('No catalogs are currently memorized','Clear Memorized Catalog');
        else
            mcm.remove();
            hh = msgbox_nobutton('The memorized catalog has been cleared.','Clear Memorized Catalog');
            hh.delay_for_close(1);
        end
    end
    
    function cb_usesubset(~,~)
        ZG = ZmapGlobal.Data;
        ZG.primeCatalog = obj.catalog;
        obj.rawcatalog = obj.catalog;
        obj.map_axes.XLim = bounds2(obj.catalog.X);
        obj.map_axes.YLim = bounds2(obj.catalog.Y);
        obj.replot_all;
    end
    
    function [catalog,ok]=cb_catalog_from_workspace(opt, fn)
        % TODO Implement this!
        %fig=ancestor(src,'figure');
        ok = false;
        catalog = [];
        ed=errordlg(['not yet fully implemented. To get data from the worskpace into zmap do one of the following:' newline ...
            'for a ZmapCatalog MyCat, use ', newline , ...
            '   ZmapMainWindow(MyCat)'...
            newline 'If loading a table MyCat, use: ' newline '   ZmapMainWindow(ZmapCatalog.from(MyCat))', newline, newline...
            'You can also specify the figure, as in ZmapMainWindow(fig, MyCat)']);
        app=catalog_from_workbench();
        uiwait(app)
    end
    
    function cb_crop(~,~)
        ax = findobj(obj.fig, 'Type','Axes');
        all_ax = [ax.Xaxis, ax.Yaxis, ax.Zaxis];
        v = ax.View;
        switch ax.Tag
            case 'mainmap_ax'
                fields = {obj.XLabel, obj.YLabel, obj.ZLabel};
            case 'cumtimeplot_ax'
                fields = {'Date','',''};
            otherwise
                fields = {'','',''};
                warning('ZMAP:unknownCatalogCut','Do not know how to crop catalog to these axes');
        end
        
        if isequal(v , [0 90]) % XY view
            style = 'XY';
        elseif isequal(v,[0 0]) % XZ view
            style = 'XZ';
        elseif isequal(v,[90 0]) % YZ view
            style = 'YZ';
        else % all three views
            style = 'XYZ';
        end
        mask=true(obj.catalog.Count,1);
        for n = 1 : len(style)
            fname = fields{n};
            lims = ax.([style(n) , 'Lim']);
            mask = mask & lims(1) <= obj.catalog.(fname) & obj.catalog.(fname) <= lims(2);
        end
        obj.catalog.subsetInPlace(mask);
        zmap_update_displays();
    end
    
    
    function cb_replace_main(~,~)
        ZG.primeCatalog = obj.catalog;
        obj.replot_all();
    end
    
    function cb_shapecrop(~,~)
        if isempty(obj.shape)
            errordlg('No polygon exists. Create one from the selection menu first','Cannot crop to polygon');
            return
        end
        events_in_shape = obj.shape.isinterior(obj.catalog.X, obj.catalog.Y);
        obj.catalog = obj.catalog.subset(events_in_shape);
        
        zmap_update_displays();
        
        % adjust the size of the main map if the current figure IS the main map
        set(obj.map_axes,...
            'XLim',bounds2(obj.catalog.X),...
            'YLim',bounds2(obj.catalog.Y));
    end
    
    function cb_editrange(~,~)
        watchon;
        summ = obj.rawcatalog.summary;
        app=range_selector(obj.rawcatalog);
        waitfor(app);
        if ~isequal(summ, obj.rawcatalog.summary)
            obj.catalog = obj.rawcatalog;
            ZG.maepi = obj.catalog.subset(obj.catalog.Magnitude>=ZG.CatalogOpts.BigEvents.MinMag);
        end
        watchoff
        obj.replot_all;
    end
    
    function cb_rename(~,~)
        oldname = obj.rawcatalog.Name;
        [~,~,newname] = smart_inputdlg('Rename',...
            struct('prompt','Catalog Name:','value',oldname));
        obj.rawcatalog.Name = newname;
        obj.catalog.Name = newname;
    end
    
    
    function cb_combinecatalogs(~,~)
        combine_catalogs;
    end
    
    function cb_importer(~, ~, fun)
        f = get(groot,'CurrentFigure');
        f.Pointer = 'watch';
        drawnow('nocallbacks');
        ok=ZmapImportManager(fun);
        if ok
            % get rid of the message box asking us to load a catalog
            delete(findobj(groot,'-depth', 1, 'Tag','Msgbox_No Active Catalogs'));
            f=obj.fig;
            %delete(obj);
            ZmapMainWindow(f);
        else
            warndlg('Did not load a catalog');
        end
        f.Pointer = 'arrow';
    end
end

function exportToWorkspace(catalog, fmt)
    safername = matlab.lang.makeValidName(catalog.Name);
    fn = inputdlg('Variable Name for export:','Export to workspace',1,{safername});
    if ~isempty(fn)
        safername = matlab.lang.makeValidName(fn{1});
        switch lower(fmt)
        case 'catalog'
            assignin('base',safername,catalog);
        case 'zmaparray'
            assignin('base',safername,ZmapArray(catalog));
        case 'table'
            assignin('base',safername,catalog.table())
        end
    end
end

function info_summary_callback(mycatalog)
    summarytext = mycatalog.summary('stats');
    f = msgbox(summarytext,'Catalog Details');
    f.Visible = 'off';
    f.Children(2).Children.FontName = 'FixedWidth';
    p = f.Position;
    p(3) = p(3)+95;
    p(4) = p(4)+10;
    f.Position = p;
    f.Visible = 'on';
end
