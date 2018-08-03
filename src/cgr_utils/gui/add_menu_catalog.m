function add_menu_catalog(mycatalog, myview, force, figureHandle)
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
    
    % to find this menu, use findobj(figurehandle, 'Tag', mytag);
    mytag = 'menu_catalog';
    
    %
    %mycatalog = 'primeCatalog';
    
    ZG = ZmapGlobal.Data; % for use in all subroutines
    h = findobj(figureHandle,'Tag','menu_catalog');
    if ~isempty(h) && exist('force','var') && force
        delete(h); h=[];
    end
    if ~isempty(h)
        return
    end
    
    submenu = uimenu('Label','Catalog','Tag','menu_catalog');
    
    switch figureHandle.Name
        case 'Seismicity Map'
            uimenu(submenu,'Label','Crop main catalog to window axes',MenuSelectedField(),@cb_crop);
            uimenu(submenu,'Label','Crop main catalog to shape',MenuSelectedField(),@cb_shapecrop);
            
        case 'Cumulative Number'
            uimenu(submenu,'Label','Replace main catalog',MenuSelectedField(),@cb_replace_main);
            uimenu(submenu,'Label','Crop main catalog to shape',MenuSelectedField(),@cb_shapecrop);
    end
        
    
    uimenu(submenu,'Label','Edit Ranges...',MenuSelectedField(),@cb_editrange);
    
    % choose a time range by clicking on the axes. only available if x-axis is a datetime axis.
    uimenu(submenu,'Label','Cut in Time (cursor) ',MenuSelectedField(),@cursor_timecut_callback);
            
    uimenu(submenu,'Label','Rename...',MenuSelectedField(),@cb_rename);
    
    uimenu(submenu,'Label','Memorize/Recall Catalog',MenuSelectedField(),@(~,~) memorize_recall_catalog,...
        'Separator','on');
    
    uimenu(submenu,'Label','Clear Memorized Catalog',MenuSelectedField(),@cb_clearmemorized);
    
    uimenu(submenu,'Label','Combine catalogs',MenuSelectedField(),@cb_combinecatalogs,...
        'Separator','on');
    
    uimenu(submenu,'Label','Compare catalogs - find identical events',MenuSelectedField(),@(~,~)comp2cat);
    
    uimenu(submenu,'Label','Save current catalog',MenuSelectedField(),@(~,~)save_zmapcatalog(ZG.(mycatalog)));
    catexport = uimenu(submenu,'Label','Export current catalog...');
    uimenu(catexport,'Label','to workspace (ZmapCatalog)',MenuSelectedField(),@(~,~)exportToWorkspace(ZG.(mycatalog)),...
        'Enable','off');
    uimenu(catexport,'Label','to workspace (Table)',MenuSelectedField(),@(~,~)exportToTable(ZG.(mycatalog)),...
        'Enable','off');
    
    uimenu(submenu,'Label','Info (Summary)',MenuSelectedField(),@(~,~)info_summary_callback(mycatalog),...
        'Separator','on');
    
    catmenu = uimenu(submenu,'Label','Get/Load Catalog',...
        'Separator','on');
    
    uimenu(submenu,'Label','Reload last catalog',MenuSelectedField(),@cb_reloadlast,...
        'Enable','off');
    
    uimenu(catmenu,'Label','from *.mat file',...
        MenuSelectedField(), @(~,~) ZmapImportManager(@load_zmapfile));
    uimenu(catmenu,'Label','from other formatted file',...
        MenuSelectedField(), @(~,~)ZmapImportManager(@zdataimport));
    uimenu(catmenu,'Label','from FDSN webservice',...
        MenuSelectedField(), @(~,~)ZmapImportManager(@get_fdsn_data_from_web_callback));
    
    
    uimenu(catmenu,'Separator','on','Label','Set as main catalog',...
        MenuSelectedField(),@cb_keep); % Replaces the primary catalog, and replots this subset in the map window
    uimenu(catmenu,'Separator','on','Label','Reset',...
        MenuSelectedField(),@cb_resetcat); % Resets the catalog to the original selection
    
    uimenu (catmenu,'Label','Decluster the catalog',...
        MenuSelectedField(),@(~,~)inpudenew(mycatalog))
    
    function cb_crop(~,~)
        ax = findobj(figureHandle, 'Type','Axes');
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
        mask=true(ZG.(mycatalog).Count,1);
        if contains(style,'X') && ~isempty(fields{1})
            mask=mask & ZG.(mycatalog).(fields{1}) >= ax.XLim(1) &...
                ZG.(mycatalog).(fields{1}) <= ax.XLim(2);
        end
        if contains(style,'Y') && ~isempty(fields{2})
            mask=mask & ZG.(mycatalog).(fields{2}) >= ax.YLim(1) &...
                ZG.(mycatalog).(fields{2}) <= ax.YLim(2);
        end
        if contains(style,'Z') && ~isempty(fields{3})
            mask=mask & ZG.(mycatalog).(fields{3}) >= ax.YLim(1) &...
                ZG.(mycatalog).(fields{3}) <= ax.YLim(2);
        end
        ZG.(mycatalog).subset_in_place(mask);
        zmap_update_displays();
    end
    
    function cb_replace_main(~,~)
        ZG.primeCatalog=ZG.(mycatalog);
        zmap_update_displays();
    end
    
    function cb_shapecrop(~,~)
        theShape = ShapeGeneral.ShapeStash;
        if isempty(theShape)
            errordlg('No shape exists. Create one from the selection menu first','Cannot crop to shape');
            return
        end
        events_in_shape = theShape.isInside(ZG.(mycatalog).Longitude, ZG.(mycatalog).Latitude);
        ZG.(mycatalog)=ZG.(mycatalog).subset(events_in_shape);
            
        zmap_update_displays();
        
        % adjust the size of the main map if the current figure IS the main map
        set(findobj(gcf,'Tag','mainmap_ax'),...
            'XLim',[min(ZG.(mycatalog).Longitude),max(ZG.(mycatalog).Longitude)],...
            'YLim',[min(ZG.(mycatalog).Latitude),max(ZG.(mycatalog).Latitude)]);
    end
    
    function cb_editrange(~,~)
        cf=@()ZG.(mycatalog)
        [tmpcat,ZG.maepi,ZG.CatalogOpts.BigEvents.MinMag] = catalog_overview(ZmapCatalogView(cf), ZG.CatalogOpts.BigEvents.MinMag);
        ZG.Views.(myview)=tmpcat;
        ZG.(mycatalog)=tmpcat.Catalog();
        zmap_update_displays();
    end
    
    function cb_rename(~,~)
        oldname=ZG.(mycatalog).Name;
        [~,~,newname]=smart_inputdlg('Rename',...
            struct('prompt','Catalog Name:','value',oldname));
        ZG.(mycatalog).Name=newname;
        %ZmapMessageCenter.update_catalog();
        %zmap_update_displays();
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
    
    function cb_reloadlast(~,~)
        error('Unimplemented create this function from scratch!');
    end
    
    function cb_combinecatalogs(~,~)
        ZG.newcat=comcat(ZG.Views.(myview));
        timeplot('newcat');
    end
    
    function cursor_timecut_callback(src,~)
        % will change ZG.newt2
        
        ax = findobj(figureHandle,'Type','axes');
        showTimeCut = any(arrayfun(@(x)isa(get(x,'Xaxis'),'matlab.graphics.axis.decorator.DatetimeRuler'),ax));
        if ~showTimeCut
            src.Visible='off';
            msgbox('The X axis is not a datetime axis, so this menu item will not work.','Inactive Menu Item','modal');
        end
        
        [tt1,tt2]=timesel('cum');
        %ZG.Views.(myview).DateRange=[tt1, tt2];
        ZG.(mycatalog)=ZG.(mycatalog).subset(ZG.(mycatalog).Date>=tt1 & ZG.(mycatalog).Date<=tt2);
        ctp=CumTimePlot(ZG.(mycatalog));
        ctp.plot();
    end

end

function exportToWorkspace(catalog)
    safername=catalog.Name;
    safername(~ismember(safername,['a':'z','A':'Z','0':'9']))='_';
    fn=inputdlg('Variable Name for export:','Export to workspace',1,safername);
    if ~isempty(fn)
        assignin('base',matlab.lang.makeValidName(fn{1}),catalog)
    end
end

function exportToTable(catalog)
    safername=catalog.Name;
    safername(~ismember(safername,['a':'z','A':'Z','0':'9']))='_';
    fn=inputdlg('Variable Name for export:','Export to workspace',1,safername);
    if ~isempty(fn)
        assignin('base',matlab.lang.makeValidName(fn{1}),catalog.table())
    end
end
    

function info_summary_callback(mycatalog)
    ZG=ZmapGlobal.Data;
    summarytext=ZG.(mycatalog).summary('stats');
    f=msgbox(summarytext,'Catalog Details');
    f.Visible='off';
    f.Children(2).Children.FontName='FixedWidth';
    p=f.Position;
    p(3)=p(3)+95;
    p(4)=p(4)+10;
    f.Position=p;
    f.Visible='on';
end
