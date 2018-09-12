function create_all_menus(obj, force)
    % create menus for main zmap figure
    % create_all_menus() - will create all menus, if they don't exist
    % create_all_menus(force) - will delete and recreate menus if force is true
    import zmaptopo.pltopo
    
    h = findobj(obj.fig,'Tag','mainmap_menu_divider');
    if ~exist('force','var')
        force=false;
    end
    if ~isempty(h) && force
        delete(h); h=[];
    end
    if isempty(h)
        add_menu_divider(obj.fig, 'mainmap_menu_divider');
    end
    create_overlay_menu();
    
    obj.catalog_menu(force);
    
    create_decluster_menu(findobj(obj.fig,'Label','Catalog','-and','type','uimenu'));
    
    add_grid_menu(obj);
    create_ztools_menu();
    
    
    uimenu('Label','|Analyse:','Enable','off');
    create_map_analysis_menu();
    create_xsec_analysis_menu();
    create_3d_analysis_menu();
    add_menu_divider(obj.fig);
    
    % modify the file menu to add ZMAP stuff
    hFileMenu = findall(obj.fig, 'tag', 'figMenuFile');
    copyobj(findobj(obj.fig,'Label','Get/Load Catalog'),hFileMenu,'legacy');
    
    addPreferencesMenuItem();
    addQuitMenuItem();
    addAboutMenuItem();
    
    if ZmapGlobal.Data.debug
        mainhelp=findall(obj.fig,'Tag','figMenuHelp');
        uimenu(mainhelp,'Label','Export ZmapMainWindow to workspace as zmw',...
            'Separator','on', MenuSelectedField(),@export_me);
    end
    
    function export_me(~,~)
        assignin('base','zmw',obj);
    end
    
    %% map-view analysis menu
    % analyze items according to spacing in a horizontal plane
    function create_map_analysis_menu()
        submenu = uimenu('Label','Map');
        
        import XYfun.* % the map functions exist in the XYfun package
        % AB menu
        bvalgrid.AddMenuItem(submenu, @()obj.map_zap);
        bvalmapt.AddMenuItem(submenu, @()obj.map_zap);
        bdepth_ratio.AddMenuItem(submenu,@()obj.map_zap);
        
        % P menu
        h=bpvalgrid.AddMenuItem(submenu,@()obj.map_zap);
        h2=rcvalgrid_a2.AddMenuItem(submenu, @()obj.map_zap);
        h2.Enable='off';
        h.Separator='on';
        
        % Rate Change menu
        h=comp2periodz.AddMenuItem(submenu, @()obj.map_zap);
        uimenu(submenu,'Label','Calculate a z-value map','Enable','off',MenuSelectedField(),@(~,~)inmakegr(obj.catalog));
        h.Separator='on';
        
        % Quarry menu : detect quarry contamination
        h=findquar.AddMenuItem(submenu,@()obj.map_zap);
        h.Separator='on';
        
        %h=uimenu(submenu,'Label','Map stress tensor',MenuSelectedField(),@(~,~)stressgrid());
        h=stressgrid.AddMenuItem(submenu, @()obj.map_zap);
        h.Separator='on';
        %{
            uimenu(tmp,'Label','Load...','Enable','off',MenuSelectedField(),  @(~,~)rcvalgrid_a2('lo'));
            uimenu(submenu,'Label','Load a z-value movie (map-view)',MenuSelectedField(),@(~,~)loadmovz());
        %}
    end
    
    %% xsec-view analysis menu
    % analyze items according to position & depth along strike.
    
    function create_xsec_analysis_menu()
        submenu = uimenu('Label','X-sect');
        uimenu(submenu,'Label','Define a cross-section',MenuSelectedField(),@obj.cb_xsection,'Tag','CreateXsec');
        
        import XZfun.* % the cross-section functions exist in the XZfun package
        
        h=magrcros.AddMenuItem(submenu, @()obj.xsec_zap);% @()obj.map_zap);
        rc_cross_a2.AddMenuItem(submenu, @()obj.xsec_zap);
        
        h.Separator='on';
        
        uimenu(submenu,'enable','off','Label','Calc a b-value cross-section',MenuSelectedField(), @(~,~)nlammap(@()obj.xsec_zap));
        
        h=bcross.AddMenuItem(submenu,@()obj.xsec_zap); h.Enable = 'off';
        h=bcrossV2.AddMenuItem(submenu,@()obj.xsec_zap); h.Enable = 'off';
        h=bcrossVt2.AddMenuItem(submenu,@()obj.xsec_zap); h.Enable = 'off';
        h=calc_Omoricross.AddMenuItem(submenu,@()obj.xsec_zap); h.Enable = 'off';
        h=calc_across.AddMenuItem(submenu,@()obj.xsec_zap); h.Enable = 'off';
        h=cross_stress.AddMenuItem(submenu,@()obj.xsec_zap); h.Enable = 'off';
    end
    
    
    %% 3D-view analysis menu
    % analyze items in a volume
    
    function create_3d_analysis_menu()
        submenu = uimenu('Label','3D-Vol');
        uimenu(submenu, 'Label','Nothing here yet','Enable','off');
        
        import XYZfun.* % the cross-section functions exist in the XYZfun package
        
        h=bgrid3dB.AddMenuItem(submenu, @()obj.map_zap); h.Enable = 'off';
        h=zgrid3d.AddMenuItem(submenu, @()obj.map_zap); h.Enable = 'off';
        
        %{
            uimenu(submenu,'Label','Load a 3D b-value grid',MenuSelectedField(),@(~,~)myslicer('load'));
        %}
        
    end
    
    
    %% individual menus to create
    
    function create_overlay_menu()
        h = findobj(obj.fig,'Tag','mainmap_menu_overlay');
        axm=obj.map_axes;
        if ~isempty(h) && exist('force','var') && force
            delete(h); h=[];
        end
        if ~isempty(h)
            return
        end
        
        % Make the menu to change symbol size and type
        %
        mapoptionmenu = uimenu(obj.fig,'Label','Map Options','Tag','mainmap_menu_overlay');
        
        uimenu(mapoptionmenu,'Label','3-D view',...
            MenuSelectedField(),@obj.set_3d_view); % callback was plot3d
        
        uimenu(mapoptionmenu,'Label','Set aspect ratio by latitude',...
            MenuSelectedField(),{@callbacks.toggle_aspectratio, axm,"SetGlobal"}, ...
            'Checked',char(ZmapGlobal.Data.lock_aspect));
        if ZmapGlobal.Data.lock_aspect
            daspect(axm, [1 cosd(mean(axm.YLim)) 10]);
        end
        
        uimenu(mapoptionmenu,'Label','Toggle Lat/Lon Grid',...
            MenuSelectedField(),@toggle_grid,...
            'checked',char(ZmapGlobal.Data.mainmap_grid));
        grid(axm,char(ZmapGlobal.Data.mainmap_grid));
        
        % choose what to plot by
        for j=1:numel(obj.ValidColorFields)
            myfn = obj.ValidColorFields{j};
            um(j)=uimenu(mapoptionmenu,'Label',['Color by ' myfn],MenuSelectedField(),{@set_colorby,myfn},...
                'Checked',tf2onoff(strcmp(obj.colorField,myfn)));
            if j==1
                um(j).Separator='on';
            end
        end
        uimenu(mapoptionmenu,'Label','Edit Main Map Symbols',MenuSelectedField(), @manage_mainmap_symbols);
        uimenu(mapoptionmenu,'Label','Edit Current Map Symbols',MenuSelectedField(),@manage_symbols_for_current_map);
        % add_symbol_menu(axm, mapoptionmenu, 'Map Symbols');
        ovmenu = uimenu(mapoptionmenu,'Label','Layers');
        try
            MapFeature.foreach(obj.Features,'addToggleMenu',ovmenu,axm)
        catch ME
            warning(ME.message)
        end
        
        uimenu(ovmenu,'Label','Plot stations + station names',...
            'Separator', 'on',...
            MenuSelectedField(),@(~,~)plotstations(axm));
        
        lemenu = uimenu(mapoptionmenu,'Label','Legend by ...  ','Enable','off');
        
        uimenu(lemenu,'Label','Change legend breakpoints',...
            MenuSelectedField(),@change_legend_breakpoints);
        legend_types = {'Legend by time','tim';...
            'Legend by depth','depth';...
            'Legend by magnitudes','mag';...
            'Mag by size, Depth by color','mad' %;...
            % 'Symbol color by faulting type','fau'...
            };
        
        for i=1:size(legend_types,1)
            m=uimenu(lemenu,'Label',legend_types{i,1},...
                MenuSelectedField(), {@cb_plotby,legend_types{i,2}});
            if i==1
                m.Separator='on';
            end
        end
        clear legend_types
        
        uimenu(mapoptionmenu,'Label','Change font size ...','Enable','off',...
            MenuSelectedField(),@change_map_fonts);
        
        uimenu(mapoptionmenu,'Label','Change background colors',...
            MenuSelectedField(),@(~,~)setcol,'Enable','off'); %
        
        uimenu(mapoptionmenu,...
            'Label',['Mark large event with M > ' num2str(ZmapGlobal.Data.CatalogOpts.BigEvents.MinMag)],...
            MenuSelectedField(),@cb_plot_large_quakes);
        
        uimenu(mapoptionmenu,...
            'Separator','on',...
            'Label','Close all result tabs', MenuSelectedField(),@clear_result_tabs);

        uimenu(mapoptionmenu,'label','Redraw',...
            'Separator','on',...
            MenuSelectedField(),@(s,v)obj.cb_redraw(s,v));
        
        function clear_result_tabs(src,ev)
            delete(obj.maingroup.Children(obj.maingroup.Children ~= obj.maintab))
        end
        function manage_symbols_for_current_map(src,ev)
            ax=findobj(obj.maingroup.SelectedTab,'Type','axes');
            SymbolManager.cb(src,ev,ax);
        end
        
        function manage_mainmap_symbols(src,ev)
            bringToForeground(axm);
            SymbolManager.cb(src,ev,axm);
        end
        
        function set_colorby(~,~,val)
            obj.colorField=val;
            
            % update menus
            for jj=1:numel(um)
                myfn = obj.ValidColorFields{jj};
                um(jj).Checked = tf2onoff(strcmp(obj.colorField,myfn));
            end
            h=findobj(obj.fig,'Type','colorbar','-and','Parent',obj.fig);
            % hascolorbar=~isempty(h) && ~isempty(obj.colorField);
            delete(h)
            obj.plotmainmap();
            %obj.fig.CurrentAxes=findobj(obj.fig,'Tag','mainmap_ax');
            % redraw the colorbar?
            %if hascolorbar
            %    obj.do_colorbar();
            %end
        end
        
        function cb_plotby(~,~, s)
            ZG=ZmapGlobal.Data;
            ZG.mainmap_plotby=s;
            watchon;
            % zmap_update_displays();
            watchoff;
        end
        
        
        function cb_plot_large_quakes(src,~)
            ZG=ZmapGlobal.Data;
            [~,~,ZG.CatalogOpts.BigEvents.MinMag] = smart_inputdlg('Choose magnitude threshold',...
                struct('prompt','Mark events with M > ? ','value',ZG.CatalogOpts.BigEvents.MinMag));
            src.Label = "Mark large event with M > " + ZG.CatalogOpts.BigEvents.MinMag;
            obj.bigEvents=obj.catalog.subset(obj.catalog.Magnitude > ZG.CatalogOpts.BigEvents.MinMag);
            set(findobj(obj.fig,'Tag','big events'), 'DisplayName', src.Label);
        end
        
        
        
        function toggle_grid(src, ~)
            src.Checked=toggleOnOff(src.Checked);
            grid(axm,src.Checked);
            drawnow nocallbacks
        end
        
    end
    
    function create_ztools_menu()
        h = findobj(obj.fig,'Tag','mainmap_menu_ztools');
        if ~isempty(h) && exist('force','var') && force
            delete(h); h=[];
        end
        if ~isempty(h)
            return
        end
        submenu = uimenu('Label','ZTools','Tag','mainmap_menu_ztools');
        
        %uimenu(submenu,'Label','Show main message window',...
        %    MenuSelectedField(), @(s,e)ZmapMessageCenter());
        
        uimenu(submenu,'Label','Analyze time series ...',...
            'Separator','on',...
            MenuSelectedField(),@(s,e)analyze_time_series_cb);
        
        create_topo_map_menu(submenu);
        create_random_data_simulations_menu(submenu);
        % uimenu(submenu,'Label','Create [simple] cross-section',MenuSelectedField(),@obj.cb_xsection);
        
        % create_histogram_menu(submenu);
        create_explore_catalog_menu(submenu);
        
        uimenu(submenu,'Label','Misfit calculation',MenuSelectedField(),@(~,~)inmisfit(),...
            'Enable','off'); %FIXME: misfitcalclulation poorly documented, not sure what it is comparing.
        
        function analyze_time_series_cb(~,~)
            % pick which time series we are investigating
            if ~isempty(obj.shape)
                items = ["Selected Events (IN polygon)", "Unselected Events (OUTSIDE polygon)"];
                items_data = {@()obj.catalog, @()obj.rawcatalog.subset(~obj.shape.isInside(obj.rawcatalog.Longitude,obj.rawcatalog.Latitude))}
            else
                items = ["Selected Events"];
                items_data = {@()obj.catalog};
            end
            if ~isempty(obj.XSectionTitles)
                items(end+1 : end + numel(obj.XSectionTitles)) = [strcat("XSEC: ",string(obj.XSectionTitles))];
                for i=1:numel(obj.XSectionTitles)
                    items_data(end+1) = {@()obj.xscats(obj.XSectionTitles{i}) };
                end
            end
            items(end+1) = "FULL (raw) Catalog";
            items_data(end+1) = {@()obj.rawcatalog};
            [selection, ok] = listdlg('PromptString','Select catalog to analyze',...
                'SelectionMode', 'single',...
                'ListString',items);
            if ok
                c = items_data{selection};
                ctp = CumTimePlot(items_data{selection}() );
                ctp.plot();
            end
            
            % analyze time series for current catalog view
            %ctp=CumTimePlot(@()obj.catalog);
            %ctp.plot();
        end
    end
    function create_topo_map_menu(parent)
        submenu   =  uimenu(parent,'Label','Plot topographic map');
        uimenu(submenu,'Label','Open a Web Map Display',MenuSelectedField(),@(~,~)webmap_of_catalog(obj.catalog,true));
        uimenu(submenu,'Label','Plot Topography on main map',MenuSelectedField(),@add_topography_to_main_map);
        uimenu(submenu,'Label','Plot Swiss Topography on main map',MenuSelectedField(),{@add_topography_to_main_map,'CH'});
        return
        % FIXME the following need to be found and fixed
        uimenu(submenu,'Label','Open DEM GUI',MenuSelectedField(), @(~,~)zmaptopo.prepinp());
        uimenu(submenu,'Label','3 arc sec resolution (USGS DEM)',MenuSelectedField(), @(~,~)pltopo('lo3'));
        uimenu(submenu,'Label','30 arc sec resolution (GLOBE DEM)',MenuSelectedField(), @(~,~)pltopo('lo1'));
        uimenu(submenu,'Label','30 arc sec resolution (GTOPO30)',MenuSelectedField(), @(~,~)pltopo('lo30'));
        uimenu(submenu,'Label','2 deg resolution (ETOPO 2)',MenuSelectedField(), @(~,~)pltopo('lo2'));
        uimenu(submenu,'Label','5 deg resolution (ETOPO 5, Terrain Base)',MenuSelectedField(), @(~,~)pltopo('lo5'));
        uimenu(submenu,'Label','Your topography (mydem, mx, my must be defined)',MenuSelectedField(), @(~,~)pltopo('yourdem'));
        uimenu(submenu,'Label','Help on plotting topography',MenuSelectedField(), @(~,~)pltopo('genhelp'));
    end
    
    function add_topography_to_main_map(~,~,code)
        htopo=findobj(obj.map_axes,'-regexp','Tag','topographic_map.*');
        delete(htopo);
        
        if exist('code','var')
            zmaptopo.add_topo(obj.map_axes,'locale',code);
            % zmaptopo.add_topo(obj.map_axes,'locale',code,'ShadedOnly',true);
        end
        % now plot the world topography too.
        zmaptopo.add_topo(obj.map_axes,'locale','world');
        % zmaptopo.add_topo(obj.map_axes,'locale','world','ShadedOnly',true);
    end
    
    function create_random_data_simulations_menu(parent)
        submenu  =   uimenu(parent,'Label','Random data simulations');
        uimenu(submenu,'label','Create permutated catalog (also new b-value)...',MenuSelectedField(),@cb_create_permutated);
        uimenu(submenu,'label','Create synthetic catalog...',MenuSelectedField(),@cb_create_synhthetic_cat);
        
        % uimenu(submenu,'Label','Evaluate significance of b- and a-values',MenuSelectedField(),@(~,~)brand());
        %  uimenu(submenu,'Label','Calculate a random b map and compare to observed data',MenuSelectedField(),@(~,~)brand2());
        uimenu(submenu,'Label','Info on synthetic catalogs',MenuSelectedField(),@(~,~)web(['file:' ZmapGlobal.Data.hodi '/zmapwww/syntcat.htm']));
        
        
        function cb_create_permutated(~,~)
            % will replace existing primary catalog
            [rand_catalog,ok]=syn_invoke_random_dialog(obj.catalog);
            if ok
                ZmapMainWindow(figure,rand_catalog);
            end
        end
        
        function cb_create_synhthetic_cat(~,~)
            % will replace existing primary catalog
            [syn_cat,ok]=syn_invoke_dialog(obj.catalog);
            if ok
                ZmapMainWindow(figure,syn_cat);
            end
        end
        
        
    end
    
    function create_explore_catalog_menu(parent)
        uimenu(parent,'Separator','on',...
            'Label','Explore Catalog', MenuSelectedField(), @explore_catalog);
        
        function explore_catalog(~,~)
            t = findOrCreateTab(obj.fig, obj.maingroup,'Exploration','deleteable');
            ax=findobj(t.Children,'Type','axes');
            if isempty(ax)
                ax=axes(t);
            end
            cep=CatalogExplorationPlot(ax,@get_catalog);
            cep.scatter('explore catalog')
            legend(ax,'show','Location','northeast');
            title(ax,sprintf('Exploring : catalog: %s , with %d events',...
                strrep(obj.catalog.Name,'_', '\_'), obj.catalog.Count));
            bringToForeground(ax);
        end
        
        function c=get_catalog()
            c=obj.catalog;
        end
        
    end
    
    
    function create_decluster_menu(parent)
        submenu = parent;% uimenu(parent,'Label','Decluster the catalog');
        
        uimenu(submenu,'Label','Decluster (Reasenberg)',MenuSelectedField(),@(~,~)ResenbergDeclusterClass(obj.catalog),...
            'Separator','on');
        uimenu(submenu,'Label','Decluster (Gardner & Knopoff)',...
            MenuSelectedField(),@cb_declus_inp);
    end
    function cb_declus_inp(~,~)
        [out,nMethod]=declus_inp
        error('declustered. now what to do with results?');
    end
end