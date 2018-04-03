function add_menu_catalog(obj, force)
    % add_menu_catalog was create_catalog_menu adds a menu designed to handle catalog modifications
    % add_menu_catalog(mycatalog, force, handle)
    % mycatalog is a name of the ZmapGlobal.Data field containing a ZmapCatalog
    % myview is a name of the ZmapGlobal.Data.View field containing a ZmapCatalogView
    %
    % Menu Options:
    %   Crop catalog to window -
    %   Edit Ranges -
    %   Rename - 
    %   - - -
    %   Memorize/Recall Catalog -
    %   Clear Memorized Catalog -
    %   - - -
    %   Combine Catalogs -
    %   Compare Catalogs -
    %   Save Current Catalog - save as a ZmapCatdalog (.mat) or a v6 or v7+ ASCII table (.dat)
    %   - - -
    %   Stats -
    %   Get/Load Catalog - 
    %   Reload Last Catalog -
    
    
    %TODO clear up mess between ZG.catalogs and ZG.Views.view
    
    % to find this menu, use findobj(obj.fig, 'Tag');
    
    %mycatalog = 'primeCatalog';
    disp('called ZmapMainWindow version of add_menu_catalog')
    ZG = ZmapGlobal.Data; % for use in all subroutines
    h = findobj(obj.fig,'Tag','menu_catalog');
    if ~exist('force','var')
        force=false;
    end
    if ~isempty(h) && force
        delete(h); h=[];
    end
    if ~isempty(h)
        return
    end
    
    submenu = uimenu('Label','Catalog','Tag','menu_catalog');
    
    %uimenu(submenu,'Label','Crop main catalog to window axes',MenuSelectedFcnName(),@cb_crop);
    %uimenu(submenu,'Label','Crop main catalog to shape',MenuSelectedFcnName(),@cb_shapecrop);
    
    
    uimenu(submenu,'Label','Edit Ranges...',MenuSelectedFcnName(),@cb_editrange,'Enable','off'); %TOFIX
    
    % choose a time range by clicking on the axes. only available if x-axis is a datetime axis.
            
    uimenu(submenu,'Label','Rename...',MenuSelectedFcnName(),@cb_rename);
    
    uimenu(submenu,'Label','Memorize/Recall Catalog',MenuSelectedFcnName(),@(~,~) memorize_recall_catalog(obj.catalog),...
        'Separator','on');
    
    uimenu(submenu,'Label','Clear Memorized Catalog',MenuSelectedFcnName(),@cb_clearmemorized);
    
    uimenu(submenu,'Label','Combine catalogs',MenuSelectedFcnName(),@cb_combinecatalogs,...
        'Separator','on');
    
    uimenu(submenu,'Label','Compare catalogs - find identical events',MenuSelectedFcnName(),@(~,~)comp2cat);
    
    uimenu(submenu,'Label','Save current catalog',MenuSelectedFcnName(),@(~,~)save_zmapcatalog(obj.catalog));
    catexport = uimenu(submenu,'Label','Export current catalog...');
    uimenu(catexport,'Label','to workspace (ZmapCatalog)',MenuSelectedFcnName(),@(~,~)exportToWorkspace(obj.catalog),...
        'Enable','off');
    uimenu(catexport,'Label','to workspace (Table)',MenuSelectedFcnName(),@(~,~)exportToTable(obj.catalog),...
        'Enable','off');
    
    uimenu(submenu,'Label','Info (Summary)',MenuSelectedFcnName(),@(~,~)info_summary_callback(obj.catalog),...
        'Separator','on');
    
    catmenu = uimenu(submenu,'Label','Get/Load Catalog',...
        'Separator','on');
    
    uimenu(submenu,'Label','Reload last catalog',MenuSelectedFcnName(),@cb_reloadlast,...
        'Enable','off');
    
    uimenu(catmenu,'Label','from *.mat file',...
        MenuSelectedFcnName(), {@cb_importer,@load_zmapfile});
    uimenu(catmenu,'Label','from other formatted file',...
        MenuSelectedFcnName(), {@cb_importer,@zdataimport});
    uimenu(catmenu,'Label','from FDSN webservice',...
        MenuSelectedFcnName(), {@cb_importer,@get_fdsn_data_from_web_callback});
    
    
    uimenu(catmenu,'Separator','on','Label','Set as main catalog',...
        MenuSelectedFcnName(),@cb_replace_main); % Replaces the primary catalog, and replots this subset in the map window
    uimenu(catmenu,'Separator','on','Label','Reset',...
        MenuSelectedFcnName(),@cb_resetcat); % Resets the catalog to the original selection
    
    uimenu (catmenu,'Label','Decluster the catalog',...
        MenuSelectedFcnName(),@(~,~)inpudenew())
    
    function cb_crop(~,~)
        ax = findobj(obj.fig, 'Type','Axes');
        all_ax=[ax.Xaxis, ax.Yaxis, ax.Zaxis];
        v=ax.View;
        switch ax.Tag
            case 'mainmap_ax'
                fields={'Longitude','Latitude','Depth'};
            case 'cumtimeplot_ax'
                fields={'Date','',''};
            otherwise
                fields={'','',''};
                warning('Do not know how to crop catalog to these axes');
        end

        if isequal(v , [0 90]) % XY view
            style='XY';
        elseif isequal(v,[0 0]) % XZ view
            style='XZ';
        elseif isequal(v,[90 0]) % YZ view
            style='YZ';
        else % all three views
            style='XYZ';
        end
        mask=true(obj.catalog.Count,1);
        if contains(style,'X') && ~isempty(fields{1})
            mask=mask & obj.catalog.(fields{1}) >= ax.XLim(1) &...
                obj.catalog.(fields{1}) <= ax.XLim(2);
        end
        if contains(style,'Y') && ~isempty(fields{2})
            mask=mask & obj.catalog.(fields{2}) >= ax.YLim(1) &...
                obj.catalog.(fields{2}) <= ax.YLim(2);
        end
        if contains(style,'Z') && ~isempty(fields{3})
            mask=mask & obj.catalog.(fields{3}) >= ax.YLim(1) &...
                obj.catalog.(fields{3}) <= ax.YLim(2);
        end
        obj.catalog.subset_in_place(mask);
        zmap_update_displays();
    end
    

    function cb_replace_main(~,~)
        ZG.primeCatalog=obj.catalog;
        obj.replot_all();
    end
    
    function cb_shapecrop(~,~)
        if isempty(ZG.selection_shape) || isnan(ZG.selection_shape.Points(1))
            errordlg('No shape exists. Create one from the selection menu first','Cannot crop to shape');
            return
        end
        events_in_shape = ZG.selection_shape.isInside(obj.catalog.Longitude, obj.catalog.Latitude);
        obj.catalog=obj.catalog.subset(events_in_shape);
            
        zmap_update_displays();
        
        % adjust the size of the main map if the current figure IS the main map
        set(obj.map_axes,...
            'XLim',[min(obj.catalog.Longitude),max(obj.catalog.Longitude)],...
            'YLim',[min(obj.catalog.Latitude),max(obj.catalog.Latitude)]);
    end
    
    function cb_editrange(~,~)
        cf=@()obj.catalog
        [tmpcat,ZG.maepi,ZG.big_eq_minmag] = catalog_overview(ZmapCatalogView(cf), ZG.big_eq_minmag);
        ZG.Views.(myview)=tmpcat;
        obj.catalog=tmpcat.Catalog();
        zmap_update_displays();
    end
    
    function cb_rename(~,~)
        oldname=obj.rawcatalog.Name;
        [~,~,newname]=smart_inputdlg('Rename',...
            struct('prompt','Catalog Name:','value',oldname));
        obj.rawcatalog.Name=newname;
        obj.catalog.Name=newname;
    end
    
    function cb_clearmemorized(~,~)
        if isempty(ZG.memorized_catalogs)
            msg='No catalogs are currently memorized';
        else
            msg='The memorized catalog has been cleared.';
        end
        ZG.memorized_catalogs=[];
        msgbox(msg,'Clear Memorized');
    end
    
    function cb_combinecatalogs(~,~)
        ZG.newcat=comcat(ZG.Views.(myview));
        timeplot('newcat');
    end
    
    function cb_importer(src, ev, fun)
        ok=ZmapImportManager(fun);
        if ok
            delete(obj.fig);
            ZmapMainWindow();
            delete(obj)
        else
            warndlg('Did not load a catalog');
        end
    end
end

function exportToWorkspace(catalog)
    safername=catalog.Name;
    safername(~ismember(safername,['a':'z','A':'Z','0':'9']))='_';
    fn=inputdlg('Variable Name for export:','Export to workspace',1,safername);
    if ~isempty(fn)
        assignin('base',fn{1},catalog)
    end
end

function exportToTable(catalog)
    safername=catalog.Name;
    safername(~ismember(safername,['a':'z','A':'Z','0':'9']))='_';
    fn=inputdlg('Variable Name for export:','Export to workspace',1,safername);
    if ~isempty(fn)
        assignin('base',fn{1},catalog.table())
    end
end
    

function info_summary_callback(mycatalog)
    ZG=ZmapGlobal.Data;
    summarytext=mycatalog.summary('stats');
    f=msgbox(summarytext,'Catalog Details');
    f.Visible='off';
    f.Children(2).Children.FontName='FixedWidth';
    p=f.Position;
    p(3)=p(3)+95;
    p(4)=p(4)+10;
    f.Position=p;
    f.Visible='on';
end
