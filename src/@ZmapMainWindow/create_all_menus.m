function create_all_menus(obj, force)
    % create menus for main zmap figure
    % create_all_menus() - will create all menus, if they don't exist
    % create_all_menus(force) - will delete and recreate menus if force is true
    h = findobj(obj.fig,'Tag','mainmap_menu_divider');
    if ~exist('force','var')
        force=false;
    end
    if ~isempty(h) && force
        delete(h); h=[];
    end
    if isempty(h)
        add_menu_divider('mainmap_menu_divider');
    end
    create_overlay_menu();
    %ShapeGeneral.AddMenu(gcf);
    %add_grid_menu(uimenu('Label','Grid'));
    obj.catalog_menu(force);
    create_ztools_menu();
    
    create_map_analysis_menu();
    create_xsec_analysis_menu();
    create_3d_analysis_menu();
    
    addQuitMenuItem();
    addAboutMenuItem();
    
    %% map-view analysis menu
    % analyze items according to spacing in a horizontal plane
    function create_map_analysis_menu()
        submenu = uimenu('Label','Analyze:Map');
        bvalgrid.AddMenuItem(submenu, @()obj.map_zap);
        bvalmapt.AddMenuItem(submenu, @()obj.map_zap);
        bdepth_ratio.AddMenuItem(submenu,@()obj.map_zap);
        bpvalgrid.AddMenuItem(submenu,@()obj.map_zap);
    end
    
    %% xsec-view analysis menu
    % analyze items according to position & depth along strike.
    
    function create_xsec_analysis_menu()
        submenu = uimenu('Label','Analyze:X-sect');
    end
    
    
    %% 3D-view analysis menu
    % analyze items in a volume
    
    function create_3d_analysis_menu()
        submenu = uimenu('Label','Analyze:3D-Volume','Enable','off');
        
        uimenu(submenu,'Label','Calc 3D b-value distribution',...
            'Enable','off',...
            'Callback', @(~,~)bgrid3dB());
        
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
            'Callback',@obj.set_3d_view); % callback was plot3d
        
        uimenu(mapoptionmenu,'Label','Set aspect ratio by latitude',...
            'callback',@toggle_aspectratio,...
            'Checked',char(ZmapGlobal.Data.lock_aspect));
        if ZmapGlobal.Data.lock_aspect
            daspect(axm, [1 cosd(mean(axm.YLim)) 10]);
        end
        
        uimenu(mapoptionmenu,'Label','Toggle Lat/Lon Grid',...
            'callback',@toggle_grid,...
            'checked',char(ZmapGlobal.Data.mainmap_grid));
        grid(axm,char(ZmapGlobal.Data.mainmap_grid));
        
        
        add_symbol_menu(axm, mapoptionmenu, 'Map Symbols');
        ovmenu = uimenu(mapoptionmenu,'Label','Layers');
        try
            MapFeature.foreach(obj.Features,'addToggleMenu',ovmenu,axm)
        catch ME
            warning(ME.message)
        end
        
        uimenu(ovmenu,'Label','Plot stations + station names',...
            'Separator', 'on',...
            'Callback',@(~,~)plotstations(axm));
        
        lemenu = uimenu(mapoptionmenu,'Label','Legend by ...  ','Enable','off');
        
        uimenu(lemenu,'Label','Change legend breakpoints',...
            'Callback',@change_legend_breakpoints);
        legend_types = {'Legend by time','tim';...
            'Legend by depth','depth';...
            'Legend by magnitudes','mag';...
            'Mag by size, Depth by color','mad' %;...
            % 'Symbol color by faulting type','fau'...
            };
        
        for i=1:size(legend_types,1)
            m=uimenu(lemenu,'Label',legend_types{i,1},...
                'Callback', {@cb_plotby,legend_types{i,2}});
            if i==1
                m.Separator='on';
            end
        end
        clear legend_types
        
        uimenu(mapoptionmenu,'Label','Change font size ...','Enable','off',...
            'Callback',@change_map_fonts);
        
        uimenu(mapoptionmenu,'Label','Change background colors',...
            'Callback',@(~,~)setcol,'Enable','off'); %
        
        uimenu(mapoptionmenu,...
            'Label',['Mark large event with M > ' num2str(ZmapGlobal.Data.big_eq_minmag)],...
            'Callback',@cb_plot_large_quakes);
        
        function cb_plotby(~,~, s)
            ZG=ZmapGlobal.Data;
            ZG.mainmap_plotby=s;
            watchon;
            % zmap_update_displays();
            watchoff;
        end
        
        
        function cb_plot_large_quakes(src,~)
            ZG=ZmapGlobal.Data;
            [~,~,ZG.big_eq_minmag] = smart_inputdlg('Choose magnitude threshold',...
                struct('prompt','Mark events with M > ? ','value',ZG.big_eq_minmag));
            src.Label=['Mark large event with M > ' num2str(ZG.big_eq_minmag)];
            ZG.maepi = obj.catalog.subset(obj.catalog.Magnitude > ZG.big_eq_minmag);
            obj.replot_all();
        end
        
        
        function toggle_aspectratio(src, ~)
            src.Checked=toggleOnOff(src.Checked);
            switch src.Checked
                case 'on'
                    daspect(axm, [1 cosd(mean(axm.YLim)) 10]);
                case 'off'
                    daspect(axm,'auto');
            end
            ZG = ZmapGlobal.Data;
            ZG.lock_aspect = matlab.lang.OnOffSwitchState(src.Checked);
            %align_supplimentary_legends();
        end
        
        function toggle_grid(src, ~)
            src.Checked=toggleOnOff(src.Checked);
            grid(axm,src.Checked);
            drawnow
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
        
        uimenu(submenu,'Label','Show main message window',...
            'Callback', @(s,e)ZmapMessageCenter());
        
        uimenu(submenu,'Label','Analyze time series ...',...
            'Separator','on',...
            'Callback',@(s,e)analyze_time_series_cb);
        
        create_topo_map_menu(submenu);
        create_random_data_simulations_menu(submenu);
        uimenu(submenu,'Label','Create [simple] cross-section','Callback',@(~,~)obj.cb_xsection);
        
        create_histogram_menu(submenu);
        create_mapping_rate_changes_menu(submenu);
        create_map_ab_menu(submenu);
        create_map_p_menu(submenu);
        create_quarry_detection_menu(submenu);
        create_decluster_menu(submenu);
        
        uimenu(submenu,'Label','Map stress tensor', 'Callback',@(~,~)stressgrid());
        
        uimenu(submenu,'Label','Misfit calculation','Callback',@(~,~)inmisfit(),...
            'Enable','off'); %FIXME: misfitcalclulation poorly documented, not sure what it is comparing.
        
        function analyze_time_series_cb(~,~)
            % analyze time series for current catalog view
            ZG=ZmapGlobal.Data;
            ZG.newt2 = obj.catalog;
            timeplot();
        end
    end
    function create_topo_map_menu(parent)
        submenu   =  uimenu(parent,'Label','Plot topographic map',...
            'Enable','off');
        uimenu(submenu,'Label','Open DEM GUI','Callback', @(~,~)prepinp());
        uimenu(submenu,'Label','3 arc sec resolution (USGS DEM)','Callback', @(~,~)pltopo('lo3'));
        uimenu(submenu,'Label','30 arc sec resolution (GLOBE DEM)','Callback', @(~,~)pltopo('lo1'));
        uimenu(submenu,'Label','30 arc sec resolution (GTOPO30)','Callback', @(~,~)pltopo('lo30'));
        uimenu(submenu,'Label','2 deg resolution (ETOPO 2)','Callback', @(~,~)pltopo('lo2'));
        uimenu(submenu,'Label','5 deg resolution (ETOPO 5, Terrain Base)','Callback', @(~,~)pltopo('lo5'));
        uimenu(submenu,'Label','Your topography (mydem, mx, my must be defined)','Callback', @(~,~)pltopo('yourdem'));
        uimenu(submenu,'Label','Help on plotting topography','Callback', @(~,~)pltopo('genhelp'));
    end
    
    function create_random_data_simulations_menu(parent)
        submenu  =   uimenu(parent,'Label','Random data simulations',...
            'Enable','off');
        uimenu(submenu,'label','Create permutated catalog (also new b-value)...', 'Callback',@cb_create_permutated);
        uimenu(submenu,'label','Create synthetic catalog...',...
            'Callback',@cb_create_syhthetic_cat);
        
        uimenu(submenu,'Label','Evaluate significance of b- and a-values','Callback',@(~,~)brand());
        uimenu(submenu,'Label','Calculate a random b map and compare to observed data','Callback',@(~,~)brand2());
        uimenu(submenu,'Label','Info on synthetic catalogs','Callback',@(~,~)web(['file:' hodi '/zmapwww/syntcat.htm']));
    end
    function create_mapping_rate_changes_menu(parent)
        submenu  =   uimenu(parent,'Label','Mapping rate changes');
        
        comp2periodz.AddMenuItem(submenu, @()obj.map_zap);
        magrcros.AddMenuItem(submenu, @()obj.xsec_zap);% @()obj.map_zap);
        
        uimenu(submenu,'Label','Calculate a z-value map',...
            'Enable','off',...
            'Callback',@(~,~)inmakegr(obj.catalog));
        % uimenu(submenu,'Label','Calculate a z-value cross-section','Callback',@(~,~)nlammap());
        uimenu(submenu,'Label','Calculate a 3D  z-value distribution',...
            'Enable','off',...
            'Callback',@(~,~)zgrid3d('in',obj.catalog));
        
        %uimenu(submenu,'Label','Load a z-value grid (map-view)','Callback',@(~,~)loadgrid('lo'));
        %uimenu(submenu,'Label','Load a z-value grid (cross-section-view)','Callback',@(~,~)magrcros('lo'));
        %uimenu(submenu,'Label','Load a z-value movie (map-view)','Callback',@(~,~)loadmovz());
    end
    
    function create_map_ab_menu(parent)
        submenu  =   uimenu(parent,'Label','Mapping a- and b-values');
        % TODO have these act upon already selected polygons (as much as possible?)
        
        bvalgrid.AddMenuItem(submenu, @()obj.map_zap);
        bvalmapt.AddMenuItem(submenu, @()obj.map_zap);
        
        uimenu(submenu,'Label','Calc a b-value cross-section',...
            ...'Enable','off',...
            'Callback', @(~,~)nlammap(@()obj.xsec_zap));
        
        bdepth_ratio.AddMenuItem(submenu,@()obj.map_zap);
        
        uimenu(submenu,'Label','Calc 3D b-value distribution',...
            'Enable','off',...
            'Callback', @(~,~)bgrid3dB());
        
        uimenu(submenu,'Label','Load a b-value grid (cross-section-view)',...
            'Enable','off', 'Visible','off', 'Callback',@(~,~)bcross('lo'));
        uimenu(submenu,'Label','Load a 3D b-value grid',...
            'Enable','off', 'Visible','off','Callback',@(~,~)myslicer('load')); %also had "sel = 'no'"
    end
    
    function create_map_p_menu(parent)
        submenu  =   uimenu(parent,'Label','Mapping p-values');
        tmp=uimenu(submenu,'Label','p- and b-value map','Callback',@(~,~)bpvalgrid());
        tmp=uimenu(submenu,'Label','Rate change, p-,c-,k-value map in aftershock sequence (MLE)');
        uimenu(tmp,'Label','Calculate','Callback',@(~,~)rcvalgrid_a2());
        uimenu(tmp,'Label','Load...',...
            'Enable','off',...
            'Callback',  @(~,~)rcvalgrid_a2('lo'));
    end
    
    function create_quarry_detection_menu(parent)
        submenu  = uimenu(parent,'Label','Detect quarry contamination');
        uimenu(submenu,'Label','Map day/nighttime ration of events','Callback',@(~,~)findquar());
        uimenu(submenu,'Label','Info on detecting quarries','Callback',@(~,~)web(['file:' hodi '/help/quarry.htm']));
    end
    
    function create_histogram_menu(parent)
        
        submenu = uimenu(parent,'Label','Histograms');
        
        uimenu(submenu,'Label','Magnitude','Callback',@(~,~)histo_callback('Magnitude'));
        uimenu(submenu,'Label','Depth','Callback',@(~,~)histo_callback('Depth'));
        uimenu(submenu,'Label','Time','Callback',@(~,~)histo_callback('Date'));
        uimenu(submenu,'Label','Hr of the day','Callback',@(~,~)histo_callback('Hour'));
        % uimenu(submenu,'Label','Stress tensor quality','Callback',@(~,~)histo_callback('Quality '));
        
        function histo_callback(hist_type)
            hisgra(obj.catalog, hist_type);
        end
        
    end
    
    function create_decluster_menu(parent)
        submenu = uimenu(parent,'Label','Decluster the catalog');
        uimenu(submenu,'Label','Decluster using Reasenberg','Callback',@(~,~)inpudenew());
        uimenu(submenu,'Label','Decluster using Gardner & Knopoff',...
            'Enable','off',... %TODO this needs to be turned into a function
            'Callback',@(~,~)declus_inp());
    end
    
end