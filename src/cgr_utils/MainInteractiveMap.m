classdef MainInteractiveMap
    %MainInteractiveMap controls the display of the main map window
    %  plotting of all features, overlays, and events happens through
    %  class.
    %
    %
    
    % TODO: add menu option to delete layers from the map.
    properties
        Features
    end
    
    methods
        function obj = MainInteractiveMap()
            obj.Features=ZmapGlobal.Data.features;
            
            k=obj.Features.keys;
            for i=1:obj.Features.Count
                f=obj.Features(k{i});
                f.load();
            end
            obj.initial_setup()
            
        end
        function update(obj)
            ZG=ZmapGlobal.Data; %handle to globals;
            watchon; drawnow;
            disp('MainInteractiveMap.update()');
            %h=figureHandle();
            ax = mainAxes();
            if isempty(ax)
                % we have to redraw the whole thing, instead.
                obj.createFigure()
                return
            end
            MainInteractiveMap.plotEarthquakes(ZG.a)
            xlim(ax,[min(ZG.a.Longitude) max(ZG.a.Longitude)])
            ylim(ax,[min(ZG.a.Latitude) max(ZG.a.Latitude)]);
            ax.FontSize=ZmapGlobal.Data.fontsz.s;
            axis(ax,'manual');
            k=obj.Features.keys;
            for i=1:numel(k)
                ftr=obj.Features(k{i});
                ftr.refreshPlot();
            end
            % bring selected events to front
            uistack(findobj('DisplayName','Selected Events'),'top');
            
            tolegend=findobj(ax,'Type','line');
            tolegend=tolegend(~ismember(tolegend,findNoLegendParts(ax)));
            legend(ax,tolegend,'Location','southeastoutside');
            ax.Legend.Title.String='Seismicity Map';
            if strcmp(ZG.lock_aspect,'on')
                daspect(ax, [1 cosd(mean(ax.YLim)) 10]);
            end
            grid(ax,ZG.mainmap_grid);
            
            align_supplimentary_legends(ax);
            
            
            % make sure we're back in a 2-d view
            title(ax,MainInteractiveMap.get_title(ZG.a),'Interpreter','none');
            view(ax,2); %reset to top-down view
            grid(ax,'on');
            zlabel(ax,'Depth [km]');
            rotate3d(ax,'off'); %activate rotation tool
            set(findobj(figureHandle(),'Label','2-D view'),'Label','3-D view');
            figure(figureHandle());
            watchoff;
            drawnow;
        end
        function createFigure(obj)
            % will delete figure if it exist
            disp('MainInterativeMap.createFigure()');
            h=figureHandle();
            if ~isempty(h)
                delete(h);
            end
            h=figure_w_normalized_uicontrolunits( ...
                'Name','Seismicity Map',...
                'NumberTitle','off', ...
                'backingstore','on',...
                'NextPlot','add', ...
                'Visible','on', ...
                'Tag','seismicity_map',...
                'Position',[10 10 900 650]);
            watchon; drawnow;
            ax = axes('Parent',h,'Position',[.09 .09 .85 .85],...
                'Tag','mainmap_ax',...
                'FontSize',ZmapGlobal.Data.fontsz.s,...
                'FontWeight','normal',...
                'Ticklength',[0.01 0.01],'LineWidth',1.0,...
                'Box','on','TickDir','out');
            xlabel(ax,'Longitude [deg]','FontSize',ZmapGlobal.Data.fontsz.m)
            ylabel(ax,'Latitude [deg]','FontSize',ZmapGlobal.Data.fontsz.m)
            %strib = [  ' Map of '  ZG.a.Name '; '  char(min(ZG.a.Date),'uuuu-MM-dd HH:mm:ss') ' to ' char(max(ZG.a.Date),'uuuu-MM-dd HH:mm:ss') ];
            title(ax, MainInteractiveMap.get_title(ZG.a),'FontWeight','normal',...
                ...%'FontSize',ZmapGlobal.Data.fontsz.m,...
                'Color','k','Interpreter','none');
            if ~isempty(mainAxes())
                % create the main earthquake axis
            end
            disp('setting up main map:');
            disp('preplotting catalog');
            MainInteractiveMap.plotEarthquakes(ZG.a)
            xlim(ax,'auto')
            ylim(ax,'auto');
            axis(ax,'manual');
            disp('     "      features');
            k=obj.Features.keys;
            for i=1:numel(k)
                ftr=obj.Features(k{i});
                ftr.plot(ax);
            end
            MainInteractiveMap.plotMainshocks(ZG.main);
            disp('     "      "big" earthquakes');
            MainInteractiveMap.plotBigEarthquakes(ZG.maepi);
            try
                % to keep lines out of the legend, append a '_nolegend' to the item's Tag
                tolegend=findobj(ax,'Type','line');
                tolegend=tolegend(~ismember(tolegend,findNoLegendParts(ax)));
                legend(ax,tolegend,'Location','southeastoutside');
                ax.Legend.Title.String='Seismicity Map';
            catch ME
                disp(ax.Children);
                rethrow(ME);
            end
            ZG = ZmapGlobal.Data; % handle to "globals"
            if strcmp(ZG.lock_aspect,'on')
                daspect(ax, [1 cosd(mean(ax.YLim)) 10]);
            end
            grid(ax,ZG.mainmap_grid);
            align_supplimentary_legends(ax);
            disp('adding menus to main map')
            obj.create_all_menus(true);
            disp('done')
            watchoff; drawnow;
        end
        
        function initial_setup(obj)
            
            h = figureHandle();
            %% load/create features to be used in map
            
            if isempty(h)
                obj.createFigure();
            end
        end
        
        %% create menus
        function create_all_menus(obj, force)
            % create menus for main zmap figure
            % create_all_menus() - will create all menus, if they don't exist
            % create_all_menus(force) - will delete and recreate menus if force is true
            h = findobj(figureHandle(),'Tag','mainmap_menu_divider');
            if ~isempty(h) && exist('force','var') && force
                delete(h); h=[];
            end
            if isempty(h)
                add_menu_divider('mainmap_menu_divider');
            end
            obj.create_overlay_menu(force);
            obj.create_select_menu(force);
            obj.create_catalog_menu(force);
            obj.create_ztools_menu(force);
        end
        
        function create_overlay_menu(obj,force)
            h = findobj(figureHandle(),'Tag','mainmap_menu_overlay');
            if ~isempty(h) && exist('force','var') && force
                delete(h); h=[];
            end
            if ~isempty(h)
                return
            end
            
            % Make the menu to change symbol size and type
            %
            mapoptionmenu = uimenu('Label','Map Options','Tag','mainmap_menu_overlay');
            
            uimenu(mapoptionmenu,'Label','Refresh map window',...
                'Callback','update(mainmap())');
            
            uimenu(mapoptionmenu,'Label','3-D view',...
                'Callback',@set_3d_view); % callback was plot3d
            %TODO use add_symbol_menu(...) instead of creating all these menus
            add_symbol_menu('mainmap_ax', mapoptionmenu, 'Map Symbols');
            
            ovmenu = uimenu(mapoptionmenu,'Label','Layers');
            k=obj.Features.keys;
            for i=1:numel(k)
                ftr=obj.Features(k{i});
                ftr.addToggleMenu(ovmenu);
            end
            %{
            % Calls GSHHS data already accessed in resources/features
            % TODO: create option to control Resolution
                uimenu(ovmenu,'Label','Load a coastline  from GSHHS database',...
                'Separator','on',...
                    'Callback','selt = ''in'';  plotmymap;');
                uimenu(ovmenu,'Label','Add coastline/faults from existing *.mat file',...
                    'Callback','think; addcoast;done');
            %}
            uimenu(ovmenu,'Label','Plot stations + station names',...
                'Separator', 'on',...
                'Callback',@(~,~)plotstations(mainAxes()));
            
            lemenu = uimenu(mapoptionmenu,'Label','Legend by ...  ');
            
            uimenu(lemenu,'Label','Change legend breakpoints',...
                'Callback',@change_legend_breakpoints);
            legend_types = {'Legend by time','tim';...
                'Legend by depth','depth';...
                'Legend by magnitudes','mag';...
                'Mag by size, Depth by color','mad' %;...
                % 'Symbol color by faulting type','fau'...
                };
            
            for i=1:size(legend_types,1)
                wrapped_leg = ['''' legend_types{i,2} ''''];
                uimenu(lemenu,'Label',legend_types{i,1},...
                    'Callback', ['ZG=ZmapGlobal.Data;ZG.mainmap_plotby=' wrapped_leg ';update(mainmap());']);
            end
            clear legend_types
            
            uimenu(mapoptionmenu,'Label','Change font size ...',...
                'Callback',@change_map_fonts);
            
            uimenu(mapoptionmenu,'Label','Change background colors',...
                'Callback',@(~,~)setcol,'Enable','off'); %
            
            uimenu(mapoptionmenu,'Label','Mark large event with M > ??',...
                'Callback',@(s,e) plot_large_quakes);
            uimenu(mapoptionmenu,'Label','Set aspect ratio by latitude',...
                'callback',@toggle_aspectratio,'checked',ZmapGlobal.Data.lock_aspect);
            uimenu(mapoptionmenu,'Label','Toggle Grid',...
                'callback',@toggle_grid,'checked',ZmapGlobal.Data.mainmap_grid);
        end
        
        function create_select_menu(obj,force)
            
            h = findobj(figureHandle(),'Tag','mainmap_menu_select');
            if ~isempty(h) && exist('force','var') && force
                delete(h); h=[];
            end
            if ~isempty(h)
                return
            end
            submenu = uimenu('Label','Select ','Tag','mainmap_menu_select');
            uimenu(submenu,'Label','Select EQ in Polygon (Menu)',...
                'Callback',@mycb01);
            
            uimenu(submenu,'Label','Select EQ inside Polygon',...
                'Callback',@(~,~) selectp('inside'));
            
            uimenu(submenu,'Label','Select EQ outside Polygon',...
                'Callback',@(~,~) selectp('outside'));
            
            uimenu(submenu,'Label','Select EQ in Circle (fixed ni)',...
                'Callback',@mycb02);
            
            uimenu(submenu,'Label','Select EQ in Circle (Menu)',...
                'Callback',@mycb03);
            
            function mycb01(mysrc,~)
                global noh1;
                noh1 = gca;
                ZG.newt2 = ZG.a;
                stri = 'Polygon';
                keyselect
            end
            
            function mycb02(mysrc,~)
                h1 = gca;set(gcf,'Pointer','watch');
                stri = ' ';
                stri1 = ' ';
                circle
            end
            
            function mycb03(mysrc,~)
                h1 = gca;
                set(gcf,'Pointer','watch');
                stri =' ';
                stri1 = ' ';
                incircle
            end
        end
        
        function create_catalog_menu(obj,force)
            h = findobj(figureHandle(),'Tag','mainmap_menu_catalog');
            if ~isempty(h) && exist('force','var') && force
                delete(h); h=[];
            end
            if ~isempty(h)
                return
            end
            submenu = uimenu('Label','Catalog','Tag','mainmap_menu_catalog');
            
            uimenu(submenu,'Label','Crop catalog to window',...
                'Callback','ZG.a.setFilterToAxesLimits(findobj( ''Tag'',''mainmap_ax''));ZG.a.cropToFilter();update(mainmap())');
            
            uimenu(submenu,'Label','Edit Ranges...',...
                'Callback','replaceMainCatalog(catalog_overview(ZG.a));update(mainmap())');
            
            uimenu(submenu,'Label','Rename...',...
                'Callback','nm=inputdlg(''Catalog Name:'',''Rename'',1,{ZG.a.Name});if ~isempty(nm),ZG.a.Name=nm{1};end;zmap_message_center.update_catalog();update(mainmap())');
            
            uimenu(submenu,'Label','Memorize/Recall Catalog',...
                'Separator','on',...
                ... % was "keep catalog in memory (use reset below to recall)"
                'Callback',@(~,~) memorize_recall_catalog); %' storedcat=a; '
            
            uimenu(submenu,'Label','Clear Memorized Catalog',...
                'Callback',['ZG=ZmapGlobal.Data;'...
                'if isempty(ZG.memorized_catalogs),msg=''No catalogs are currently memorized     '';'...
                'else, msg=''The memorized catalog has been cleared.      ''; end;'...
                'ZG.memorized_catalogs=[];msgbox(msg,''Clear Memorized'')']);
            
            uimenu(submenu,'Label','Combine catalogs',...
                'Separator','on',...
                'Callback',@(~,~)comcat());
            
            uimenu(submenu,'Label','Compare catalogs - find identical events',...
                'Callback','do = ''initial''; comp2cat');
            
            uimenu(submenu,'Label','Save current catalog (ASCII)','Callback',@(~,~)save_ca());
            uimenu(submenu,'Label','Save current catalog (.mat)','Callback','eval(catSave);');
            uimenu(submenu,'Label','Info (Summary)',...
                'Separator','on',...
                'Callback',@(~,~)msgbox(ZmapGlobal.Data.a.summary('stats'),'Catalog Details'));
            
            catmenu = uimenu(submenu,'Label','Get/Load Catalog',...
                'Separator','on');
            
            uimenu(submenu,'Label','Reload last catalog','Enable','off',...
                'Callback','think; load(lopa); if length(ZG.a(1,:))== 7,ZG.a.Date = datetime(ZG.a.Year,ZG.a.Month,ZG.a.Day));elseif length(ZG.a(1,:))>=9,ZG.a(:,decyr_idx) = decyear(ZG.a(:,[3:5 8 9]));end;ZG.a=catalog_overview(ZG.a);done');
            
            uimenu(catmenu,'Label','from *.mat file','Callback', {@(s,e) load_zmapfile() });
            uimenu(catmenu,'Label','from other formatted file','Callback', @(~,~)zdataimport());
            uimenu(catmenu,'Label','from FDSN webservice','Callback', @get_fdsn_data_from_web_callback);
            
        end
        function create_ztools_menu(obj,force)
            h = findobj(figureHandle(),'Tag','mainmap_menu_ztools');
            if ~isempty(h) && exist('force','var') && force
                delete(h); h=[];
            end
            if ~isempty(h)
                return
            end
            submenu = uimenu('Label','ZTools','Tag','mainmap_menu_ztools');
            
            uimenu(submenu,'Label','Show main message window',...
                'Callback', @(s,e)zmap_message_center());
            
            uimenu(submenu,'Label','Analyse time series ...',...
                'Separator','on',...
                'Callback','stri = ''Polygon''; ZG.newt2 = ZG.a; ZG.newcat = ZG.a; timeplot(ZG.newt2)');
            
            obj.create_topo_map_menu(submenu);
            obj.create_random_data_simulations_menu(submenu);
            
            uimenu(submenu,'Label','Create cross-section',...
                'Callback',@(~,~)nlammap());
            
            
            obj.create_histogram_menu(submenu);
            obj.create_mapping_rate_changes_menu(submenu);
            obj.create_map_ab_menu(submenu);
            obj.create_map_p_menu(submenu);
            obj.create_quarry_detection_menu(submenu);
            obj.create_decluster_menu(submenu);
            
            uimenu(submenu,'Label','Map stress tensor',...
                'Callback',@(~,~)stressgrid());
            
            uimenu(submenu,'Label','Misfit calculation',...
                'Callback',@(~,~)inmisfit());
            
        end
        function create_topo_map_menu(obj,parent)
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
        
        function create_random_data_simulations_menu(obj,parent)
            submenu  =   uimenu(parent,'Label','Random data simulations',...
                'Enable','off');
            uimenu(submenu,'label','Create permutated catalog (also new b-value)...', 'Callback','ZG.a = syn_invoke_random_dialog(ZG.a); ZG.newt2 = ZG.a; timeplot(ZG.newt2); update(mainmap()); bdiff(ZG.a); revertcat');
            uimenu(submenu,'label','Create synthetic catalog...',...
                'Callback','ZG.a = syn_invoke_dialog(ZG.a); ZG.newt2 = ZG.a; timeplot(ZG.newt2); update(mainmap()); bdiff(ZG.a); revertcat');
            
            uimenu(submenu,'Label','Evaluate significance of b- and a-values','Callback',@(~,~)brand());
            uimenu(submenu,'Label','Calculate a random b map and compare to observed data','Callback',@(~,~)brand2());
            uimenu(submenu,'Label','Info on synthetic catalogs','Callback',@(~,~)web(['file:' hodi '/zmapwww/syntcat.htm']));
        end
        function create_mapping_rate_changes_menu(obj,parent)
            submenu  =   uimenu(parent,'Label','Mapping rate changes',...
                'Enable','off');
            uimenu(submenu,'Label','Compare two periods (z, beta, probabilty)','Callback',@(~,~)comp2periodz('in'));
            
            uimenu(submenu,'Label','Calculate a z-value map','Callback',@(~,~)inmakegr('in'));
            uimenu(submenu,'Label','Calculate a z-value cross-section','Callback',@(~,~)nlammap());
            uimenu(submenu,'Label','Calculate a 3D  z-value distribution','Callback',@(~,~)zgrid3d('in'));
            uimenu(submenu,'Label','Load a z-value grid (map-view)','Callback',@(~,~)loadgrid('lo'));
            uimenu(submenu,'Label','Load a z-value grid (cross-section-view)','Callback',@(~,~)magrcros('lo'));
            uimenu(submenu,'Label','Load a z-value movie (map-view)','Callback',@(~,~)loadmovz());
        end
        
        function create_map_ab_menu(obj,parent)
            submenu  =   uimenu(parent,'Label','Mapping a- and b-values');
            % TODO have these act upon already selected polygons (as much as possible?)
            
            tmp=uimenu(submenu,'Label','Mc, a- and b-value map');
            uimenu(tmp,'Label','Calculate','Callback',@(~,~)bvalgrid());
            uimenu(tmp,'Label','Load...',...
                'Enable','off',...
                'Callback', @(~,~)bvalgrid('lo')); %map-view
            
            tmp=uimenu(submenu,'Label','differential b-value map (const R)');
            uimenu(tmp,'Label','Calculate','Callback', @(~,~)bvalmapt());
            uimenu(tmp,'Label','Load...',...
                'Enable','off',...
                'Callback', @(~,~)bvalmapt('lo'));
            
            uimenu(submenu,'Label','Calc a b-value cross-section',...
                'Callback', @(~,~)nlammap());
            
            tmp=uimenu(submenu,'Label','b-value depth ratio grid');
            uimenu(tmp,'Label','Calculate','Callback', @(~,~)bdepth_ratio());
            uimenu(tmp,'Label','Load...',...
                'Enable','off',...
                'Callback', @(~,~)bdepth_ratio('lo'));
            
            uimenu(submenu,'Label','Calc 3D b-value distribution','Callback', @(~,~)bgrid3dB());
            
            uimenu(submenu,'Label','Load a b-value grid (cross-section-view)',...
                'Enable','off',...
                'Callback',@(~,~)bcross('lo'));
            uimenu(submenu,'Label','Load a 3D b-value grid',...
                'Enable','off',...
                'Callback',@(~,~)myslicer('load')); %also had "sel = 'no'"
        end
        
        function create_map_p_menu(obj,parent)
            submenu  =   uimenu(parent,'Label','Mapping p-values');
            tmp=uimenu(submenu,'Label','p- and b-value map');
            uimenu(tmp,'Label','Calculate','Callback', @(~,~)bpvalgrid());
            uimenu(tmp,'Label','Load...',...
                'Enable','off',...'
                'Callback', @(~,~)bpvalgrid('lo'));
            
            tmp=uimenu(submenu,'Label','Rate change, p-,c-,k-value map in aftershock sequence (MLE)');
            uimenu(tmp,'Label','Calculate','Callback',  @(~,~)rcvalgrid_a2());
            uimenu(tmp,'Label','Load...',...
                'Enable','off',...
                'Callback',  @(~,~)rcvalgrid_a2('lo'));
        end
        
        function create_quarry_detection_menu(obj,parent)
            submenu  = uimenu(parent,'Label','Detect quarry contamination');
            uimenu(submenu,'Label','Map day/nighttime ration of events','Callback',@(~,~)findquar('in'));
            uimenu(submenu,'Label','Info on detecting quarries','Callback',@(~,~)web(['file:' hodi '/help/quarry.htm']));
        end
        
        function create_histogram_menu(obj,parent)
            
            submenu = uimenu(parent,'Label','Histograms');
            
            uimenu(submenu,'Label','Magnitude','Callback',@(~,~)histo_callback('Magnitude'));
            uimenu(submenu,'Label','Depth','Callback',@(~,~)histo_callback('Depth'));
            uimenu(submenu,'Label','Time','Callback',@(~,~)histo_callback('Date'));
            uimenu(submenu,'Label','Hr of the day','Callback',@(~,~)histo_callback('Hour'));
            % uimenu(submenu,'Label','Stress tensor quality','Callback',@(~,~)histo_callback('Quality '));
        end
        
        
        function create_decluster_menu(obj,parent)
            submenu = uimenu(parent,'Label','Decluster the catalog',...
                'Enable','off');
            uimenu(submenu,'Label','Decluster using Reasenberg','Callback',@(~,~)inpudenew());
            uimenu(submenu,'Label','Decluster using Gardner & Knopoff','Callback',@(~,~)declus_inp());
        end
        
        
    end
    methods(Static)
        function h = borderHandle()
            h = findobj( 'Tag');
        end
        
        
        %% plot CATALOG layer
        function plotEarthquakes(catalog, divs)
            disp('MainInteractiveMap.plotEarthquakes(...)');
            if ~exist('divs','var')
                divs=[];
            end
            switch ZmapGlobal.Data.mainmap_plotby
                
                case {'tim','time'}
                    %delete(extralegends);
                    MainInteractiveMap.plotQuakesByTime(catalog,divs);
                case {'dep','depth'}
                    %delete(extralegends);
                    size(divs)
                    MainInteractiveMap.plotQuakesByDepth(catalog,divs);
                case {'mad','magdepth'}
                    MainInteractiveMap.plotQuakesByMagAndDepth(catalog);
                case {'mag','magnitude'}
                    %delete(extralegends)
                    MainInteractiveMap.plotQuakesByMagnitude(catalog,divs);
                otherwise
                    error('unanticipated legend type');
            end
            
            ax = mainAxes();
            %set aspect ratio
            ZG = ZmapGlobal.Data; % handle to "globals"
            if strcmp(ZG.lock_aspect,'on')
                daspect(ax, [1 cosd(mean(ax.YLim)) 10]);
            end
            align_supplimentary_legends(ax);
            % TODO show subset also
        end
        function plotQuakesByMagnitude(mycat, divs)
            % magdivisions: magnitude split points
            
            % deletes existing event plots from the current axis
            
            global event_marker_types ZG
            if isempty(event_marker_types)
                event_marker_types='ooooooo'; %each division gets next type.
            end
            
            if isempty(divs)
                divs = linspace(min(mycat.Magnitude),max(mycat.Magnitude),4);
                divs([1 4])=[]; % no need for min, no quakes greater than max...
            end
            
            assert(numel(divs) < 8); % else, too many for our colormap.
            
            cmapcolors = colormap('lines');
            cmapcolors=cmapcolors(1:7,:); %after 7 it starts repeating
            
            
            mask = mycat.Magnitude <= divs(1);
            
            ax = mainAxes();
            clear_quake_plotinfo();
            washeld = ishold(ax); hold(ax,'on');
            h = plot(ax, mycat.Longitude(mask), mycat.Latitude(mask),...
                'Marker',event_marker_types(1),...
                'Color',cmapcolors(1,:),...
                'LineStyle','none',...
                'MarkerSize',ZG.ms6,...
                'Tag','mapax_part0');
            h.DisplayName = sprintf('M ≤ %3.1f', divs(1));
            h.ZData=-mycat.Depth(mask);
            
            for i = 1 : numel(divs)
                mask = mycat.Magnitude > divs(i);
                if i < numel(divs)
                    mask = mask & mycat.Magnitude <= divs(i+1);
                end
                dispname = sprintf('M > %3.1f', divs(i));
                h=plot(ax, mycat.Longitude(mask), mycat.Latitude(mask),...
                    'Marker',event_marker_types(i+1),...
                    'Color',cmapcolors(i+1,:),...
                    'LineStyle','none',...
                    'MarkerSize',ZG.ms6*(i+1),...
                    'Tag',['mapax_part' num2str(i)],...
                    'DisplayName',dispname);
                h.ZData=-mycat.Depth(mask);
            end
            if ~washeld; hold(ax,'off');end
        end
        
        function plotQuakesByDepth(mycat, divs)
            % plotQuakesByDepth
            % plotQuakesByDepth(catalog)
            % plotQuakesByDepth(catalog, divisions)
            %   divisions is a vector of depths (up to 7)
            
            % magdivisions: magnitude split points
            global event_marker_types ZG
            if isempty(event_marker_types)
                event_marker_types='+++++++'; %each division gets next type.
            end
            
            % eg. cat mags -0.5 to 5.2 ; magdiv= [1];
            %  M <= 1 and M >1
            % eq > 1
            
            if isempty(divs)
                divs = linspace(min(mycat.Depth),max(mycat.Depth),4);
                divs([1 4])=[]; % no need for min, andno quakes greater than max...
            end
            
            assert(numel(divs) < 8); % else, too many for our colormap.
            
            cmapcolors = [ 0    0.4470    0.7410;
                0.8500    0.3250    0.0980;
                0.9290    0.6940    0.1250;
                0.4940    0.1840    0.5560;
                0.4660    0.6740    0.1880;
                0.3010    0.7450    0.9330;
                0.6350    0.0780    0.1840]; % from the lines colormap
            
            mask = mycat.Depth <= divs(1);
            
            ax = mainAxes();
            clear_quake_plotinfo();
            washeld = ishold(ax); hold(ax,'on')
            
            h = plot(ax, mycat.Longitude(mask), mycat.Latitude(mask),...
                'Marker',event_marker_types(1),...
                'Color',cmapcolors(1,:),...
                'LineStyle','none',...
                'MarkerSize',ZG.ms6,...
                'Tag','mapax_part0');
            h.ZData=-mycat.Depth(mask);
            h.DisplayName = sprintf('Z ≤ %.1f km', divs(1));
            
            for i = 1 : numel(divs)
                mask = mycat.Depth > divs(i);
                if i < numel(divs)
                    mask = mask & mycat.Depth <= divs(i+1);
                end
                dispname = sprintf('Z > %.1f km', divs(i));
                myline=plot(ax, mycat.Longitude(mask), mycat.Latitude(mask),...
                    'Marker',event_marker_types(i+1),...
                    'Color',cmapcolors(i+1,:),...
                    'LineStyle','none',...
                    'MarkerSize',ZG.ms6,...
                    'Tag',['mapax_part' num2str(i)],...
                    'DisplayName',dispname);
                myline.ZData=-mycat.Depth(mask);
            end
            if ~washeld; hold(ax,'off'); end
        end
        
        function plotQuakesByMagAndDepth(mycat)
            % colorized by depth, with size dictated by magnitude
            persistent colormapName
            
            ax = mainAxes();
            hquakes = findobj(ax,'DisplayName','Events by Mag & Depth');
            if isempty(hquakes)
                clear_quake_plotinfo();
            end
            if isempty(colormapName)
                colormapName = colormapdialog();  %todo: move into menu.
            end
            switch colormapName
                case 'jet'
                    c = jet;
                    c = c(64:-1:1,:);
                otherwise
                    c = colormap(colormapName);
            end % switch
            colormap(c)
            % sort by depth
            mycat.sort('Depth');
            
            % set all sizes by mag
            sm = mag2dotsize(mycat.Magnitude);
            
            washeld = ishold(ax); hold(ax,'on')
            if isvalid(hquakes)
                plund=findobj('Tag','mapax_part1_bg_nolegend');
                set(plund, 'XData',mycat.Longitude,'YData',mycat.Latitude,'SizeData',sm*1.2);
            else
                plund = scatter(ax, mycat.Longitude, mycat.Latitude, sm*1.2,'o','MarkerEdgeColor','k');
                plund.ZData=-mycat.Depth;
                plund.Tag='mapax_part1_bg_nolegend';
                plund.DisplayName='';
                plund.LineWidth=2;
            end
            if isvalid(hquakes)
                set(hquakes, 'XData',mycat.Longitude,'YData',mycat.Latitude,'SizeData',sm,...
                    'CData',mycat.Depth);
            else
                pl = scatter(ax, mycat.Longitude, mycat.Latitude, sm, mycat.Depth,'o','filled');
                pl.ZData=-mycat.Depth;
                pl.Tag='mapax_part0';
                pl.DisplayName='Events by Mag & Depth';
                pl.MarkerEdgeColor = 'flat';
            end
            if ~washeld; hold(ax,'off'); end
            %set(ax,'pos',[0.13 0.08 0.65 0.85]) %why?
            drawnow
            watchon;
            
            % resort by time
            mycat.sort('Date');
            
            % make a depth legend
            c=findobj(groot,'Tag','mainmap_supplimentary_deplegend');
            if isempty(c)
                c=colorbar('Direction','reverse','Position',[0.87 0.7 0.06 0.2],...
                    ...'Ticks',[0 5 10 15 20 25 30],
                    'Tag','mainmap_supplimentary_deplegend');
                c.Label.String='Depth [km]';
            end
            
            % make a mag legend:
            eventsizes = floor(min(mycat.Magnitude)) : ceil(max(mycat.Magnitude));
            eqmarkersizes = mag2dotsize(eventsizes);
            eqmarkerx = zeros(size(eqmarkersizes));
            eqmarkery = linspace(0,10,numel(eqmarkersizes));
            magleg_ax = findobj(groot,'Tag','mainmap_supplimentary_maglegend');
            if ~isempty(magleg_ax)
                pl = findobj(groot,'Tag','eqsizesamples');
                set(pl,'XData',eqmarkerx, 'YData', eqmarkery, 'SizeData',eqmarkersizes);
                delete(findobj(magleg_ax,'Type','Text'));
                
                %do nothing?
            else
                rect = [0.87 0.5 0.06 0.2];
                magleg_ax = axes(figureHandle,'Position',rect,'Tag','mainmap_supplimentary_maglegend');
                axes(magleg_ax);
                hold(magleg_ax,'on');
                pl=scatter(magleg_ax, eqmarkerx, eqmarkery, eqmarkersizes, [0 0 0],'filled','Tag','eqsizesamples');
                magleg_ax.YLim = [-1 11];
                magleg_ax.XLim = [-1 2];
                magleg_ax.XTick=[];
                magleg_ax.YTick=[];
                magleg_ax.Box='on';
                set(magleg_ax,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal','yaxislocation','right');
                ylabel(magleg_ax,'Magnitude');
                xlabel(magleg_ax,'Events');
            end
            for ii=1:numel(eqmarkersizes)
                mytxt = ['   M ',num2str(eventsizes(ii))];
                text(magleg_ax, eqmarkerx(ii), eqmarkery(ii), mytxt);
            end
            align_supplimentary_legends(ax);
            hold(magleg_ax,'off');
            
        end
        
        function plotQuakesByTime(mycat, divs)
            global event_marker_types ZG
            if isempty(event_marker_types)
                event_marker_types='+++++++'; %each division gets next type.
            end
            if isnumeric(divs) && ~isempty(divs)
                divs = linspace(min(mycat.Date),max(mycat.Date),divs);
            elseif isa(divs,'datetime')
                % do nothing...
            elseif isa(divs,'duration')
                %plot at intervals
                divs = min(mycat.Date):divs:max(mycat.Date);
            elseif isempty(divs)
                divs = linspace(min(mycat.Date),max(mycat.Date),4);
                divs([1])=[]; % no need for min, andno quakes greater than max...
            end
            
            
            % make sure the ends are accounted for
            if any(mycat.Date < divs(1))
                % first category is DD < timedivisions(1)
                divs = [min(mycat.Date); divs(:)];
            end
            if any(mycat.Date > divs(end))
                divs = [divs(:); max(mycat.Date)];
            end
            
            assert(numel(divs) < 8); % else, too many for our colormap.
            
            cmapcolors = colormap('lines');
            cmapcolors=cmapcolors(1:7,:); %after 7 it starts repeating
            
            ax = mainAxes();
            clear_quake_plotinfo();
            washeld=ishold(ax); hold(ax,'on');
            for i=1:numel(divs)-1
                if i == numel(divs)-1
                    % inclusive of last value
                    mask = divs(i) <= mycat.Date & mycat.Date <= divs(i+1);
                    dispname = sprintf('%s ≤ t ≤ %s ',...
                        char(divs(i),'uuuu-MM-dd hh:mm'),...
                        char(divs(i+1),'uuuu-MM-dd hh:mm'));
                else
                    % exclusive of last value
                    mask = divs(i) <= mycat.Date & mycat.Date < divs(i+1);
                    dispname = sprintf('%s ≤ t < %s ',...
                        char(divs(i),'uuuu-MM-dd hh:mm'),...
                        char(divs(i+1),'uuuu-MM-dd hh:mm'));
                end
                h = plot(ax, mycat.Longitude(mask), mycat.Latitude(mask),...
                    'Tag',['mapax_part' num2str(i)]);
                h.ZData=-mycat.Depth(mask);
                set(h,'Marker',event_marker_types(i),...
                    'MarkerSize',ZG.ms6,...
                    'Color',cmapcolors(i,:),...
                    'LineStyle','none',...
                    'DisplayName', dispname);
            end
            if ~washeld, hold(ax,'off');end
        end
        
        %% plot NON-catalog layers
        function plotOtherEvents(catalog, idx, varargin)
            %plotOtherEvents will plot the events from a catalog on the map
            % using the name-value pairs from varargin
            % tag: 'mapax_otherN' (where N is the value provided to idx)
            %  this allows the plotting of a variety of clusters.
            % if varargin includes the pair {'DisplayName',..}
            % then that is how this would be represented in the legend
            ax = mainAxes();
            if isempty(idx), idx=0;end
            thisTag = ['mapax_other' num2str(idx)];
            h = findobj(ax,'Tag',thisTag);
            delete(h);
            
            washeld=ishold(ax); hold(ax,'on');
            h=plot(catalog.Longitude, catalog.Latitude, varargin{:});
            
            h.ZData=-catalog.Depth;
            h.Tag = thisTag;
            if ~washeld, hold(ax,'off'),end
        end
        
        function plotBigEarthquakes(maepi, reset)
            % plot big earthquake epicenters labeled with the data/magnitude
            % DisplayName: Events > M [something]
            % Tag: 'mainmap_big_events'
            
            % TODO: maybe make ZG.maepi a view into the catalog
            
            persistent big_events defaults textdefaults
            ZG=ZmapGlobal.Data;
            if isempty(defaults)
                defaults = struct('Tag','mainmap_big_events',...
                    'DisplayName',sprintf('Events > M%2.1f',ZG.big_eq_minmag),...
                    'Marker','h',...
                    'Color','m',...
                    'LineWidth',1.5,...
                    'MarkerSize',12,...
                    'LineStyle','none',...
                    'MarkerFaceColor','y',...
                    'MarkerEdgeColor','k');
            end
            
            if isempty(textdefaults)
                textdefaults = struct('FontWeight','bold',...
                    'Color','k',...
                    'FontSize',9,...
                    'Clipping','on');
            end
            
            if nargin
                big_events = ZG.maepi;
            end
            
            if isempty(big_events)
                big_events = ZmapCatalog();
            end
            
            defaults.DisplayName = sprintf('Events > M %2.1f', ZG.big_eq_minmag);
            
            if big_events.Count > 0
                % show events
                h = plot_helper(big_events,defaults,exist('reset','var')&&reset);
                
                evlabels = event_labels(ZG.maepi);
                ax = mainAxes();
                te1 = text(ax,ZG.maepi.Longitude,ZG.maepi.Latitude,evlabels);
                set(te1,textdefaults);
                set(h,'Visible','on');
            end
            
            function ev_labels = event_labels(catalog)
                % label with YYYY-DOY HH:MM M=X.X
                doy=ceil(days(catalog.Date- dateshift(catalog.Date,'start','year')));
                
                ev_labels = cell(catalog.Count,1);
                for idx = 1:catalog.Count
                    if isempty(catalog.MagnitudeType{idx})
                        mag='m'; % default magnitude description
                    else
                        mag = catalog.MagnitudeType{idx}; % use catalog's magnitude
                    end
                    ev_labels(idx)={sprintf(' %4d-%03d %5s %s=%3.1f',...
                        year(catalog.Date(idx)),doy(idx),...
                        char(catalog.Date(idx),'hh:mm'), mag)};
                end
            end
        end
        
        function plotMainshocks(xycoords, reset)
            % plot mainshock(s)
            % DisplayName: 'mainshocks'
            % Tag: 'mainmap_mainshocks'
            persistent xydata defaults
            
            if isempty(defaults)
                defaults=struct('Tag','mainmap_mainshocks',...
                    'Marker','*',...
                    'DisplayName','mainshocks',...
                    'LineStyle','none',...
                    'LineWidth', 2.0,...
                    'MarkerSize', 12,...
                    'MarkerEdgeColor','k');
            end
            
            if nargin
                xydata = replace_xy_if_exists(xydata, xycoords);
            end
            
            reset = exist('reset','var') && reset;
            plot_helper(xydata, defaults, reset);
            
        end
        
    end
    methods(Static, Access=protected)
        function strib = get_title(mycat)
            strib = [  ' Map of '  mycat.Name '; '  char(min(mycat.Date),'uuuu-MM-dd HH:mm:ss') ' to ' char(max(mycat.Date),'uuuu-MM-dd HH:mm:ss') ];
        end
    end
end

function h = figureHandle()
    h = findobj( 'Tag','seismicity_map');
end
function h = mainAxes()
    h = findobj( 'Tag','mainmap_ax');
end

function xy_list = replace_xy_if_exists(xy_list, new_xy_list)
    % replaces list of [lon,lat] with new list, if it exist.
    % if the new list is actually a ZmapCatalog, then Longitude and Latitude
    % are extracted
    if nargin==1
        return
    end
    
    if isa(new_xy_list,'ZmapCatalog') || isstruct(new_xy_list) || istable(new_xy_list)
        xy_list = [new_xy_list.Longitude, new_xy_list.Latitude];
    else
        xy_list = new_xy_list;
    end
    
    if isempty(xy_list)
        xy_list = [nan nan];
    end
end
function clear_quake_plotinfo()
    delete(findMapaxParts());
    delete(findobj('Tag','mainmap_supplimentary_maglegend'));
    delete(findobj('Tag','mainmap_supplimentary_deplegend'));
end

function h=plot_helper(xy, defaults, reset)
    % plot_helper
    % linehandle = plot_helper(xy, defaults, reset)
    % xy is a list of [x(:),y(:)] positions ie.(lon,lat)
    % Defaults contain all the plotting defaults necessary
    % reset - if true, then all default values are re-applied
    
    ax = mainAxes();
    h = findobj(ax,'Tag',defaults.Tag);
    if ~isempty(h)
        isEmptyNumeric = (isnumeric(xy) && (isempty(xy) || all(isnan(xy(:)))));
        isEmptyCatalog = isa(xy,'ZmapCatalog') && xy.Count==0;
        if isEmptyNumeric || isEmptyCatalog
            delete(h);
            return
        end
    end
    if isempty(h)
        hold(ax,'on');
        if isa(xy,'ZmapCatalog')|| istable(xy) || isstruct(xy)
            h=plot(ax, xy.Longitude, xy.Latitude, defaults);
        else
            h=plot(ax, xy(:,1), xy(:,2), defaults);
        end
        hold(ax,'off');
    else
        %simply change the data
        if isa(xy,'ZmapCatalog')
            h.XData = xy.Longitude;
            h.YData = xy.Latitude;
        else
            h.XData = xy(:,1);
            h.YData=xy(:,2);
        end
        if exist('reset','var') && reset
            set(h,defaults);
        end
    end
end


function choice = colormapdialog()
    % allow user to choose colormap
    persistent colormap_choice
    
    if isempty(colormap_choice)
        colormap_choice = 'jet';
    end
    color_maps = {'parula';'jet';'hsv';'hot';'cool';'spring';'summer';'autumn';'winter'};
    % provide a simple dialog allowing the user to choose a colormap
    d = dialog('Position',[300 300 250 150], 'Name', 'Choose Colormap');
    uicontrol('Parent',d, 'Style','Popup','Position',[20 80 210 40],...
        'String',color_maps,...
        'Value',find(strcmp(color_maps,colormap_choice)),...
        'Callback', @popup_callback);
    uicontrol('Parent',d,...
        'Position',[89 20 70 25],...
        'String','Close',...
        'Callback','delete(gcf)');
    uiwait(d);
    choice = colormap_choice;
    
    function popup_callback(popup, ~)
        idx = popup.Value;
        popup_items = popup.String;
        colormap_choice = char(popup_items(idx,:));
    end
end


%% % % % callbacks
function catSave()
    zmap_message_center.set_message('Save Data', ' ');
    try
        think;
        [file1, path1] = uiputfile(fullfile(ZmapGlobal.Data.data_dir, '*.mat'), 'Earthquake Datafile');
        if length(file1) > 1
            wholePath=[path1 file1];
            error('not implemented')
            %save('WholePath', 'ZG.a', 'faults','main','mainfault','coastline','infstri','well');
        end
        done
    catch ME
        warning(ME)
    end
end

function change_markersize(val)
    global ZG
    ZG.ms6 = val;
    ax = findobj('Tag','mainmap_ax');
    set(findobj(ax,'Type','Line'),'MarkerSize',val);
end

function change_symbol(~, clrs, symbs)
    global ZG
    ax = findobj('Tag','mainmap_ax');
    hlines = findMapaxParts(ax);
    %line_tags = {'mapax_part1','mapax_part2','mapax_part3'};
    for n=1:numel(hlines)
        if ~isempty(clrs)
            set(hlines(n),'MarkerSize',ZG.ms6,...
                'Marker',symbs(n),...
                'Color',clrs(n,:),...
                'Visible','on');
        else
            set(hlines(n),'MarkerSize',ZG.ms6,...
                'Marker',symbs(n),...
                'Visible', 'on');
        end
    end
end

function change_color(c)
    hlines = findMapaxParts();
    n =listdlg('PromptString','Change color for which item?',...
        'SelectionMode','multiple',...
        'ListString',{hlines.DisplayName});
    if ~isempty(n)
        c = uisetcolor(hlines(n(1)));
        set(hlines(n),'Color',c,'Visible','on');
    end
end


function plot_large_quakes()
    globalZG
    mycat=ZmapCatalog(ZG.a);
    def = {'6'};
    ni2 = inputdlg('Mark events with M > ? ','Choose magnitude threshold',1,def);
    l = ni2{:};
    ZG.big_eq_minmag = str2double(l);
    
    ZG.maepi = mycat.subset(mycat.Magnitude > ZG.big_eq_minmag);
    update(mainmap()) %TOFIX changing magnitudes didn't chnge map output
end
function align_supplimentary_legends(ax)
    % reposition supplimentary legends, if they exist
    try
        le = ax.Legend;
    catch
        return
    end
    if isempty(le)
        return;
    end
    tags = {'mainmap_supplimentary_deplegend','mainmap_supplimentary_maglegend'};
    for i=1:numel(tags)
        c=findobj('Tag',tags{i});
        if ~isempty(c)
            c.Position([1]) = le.Position([1]); % scoot it over to match the legend
        end
    end
end


function toggle_grid(src, ~)
    ax = mainAxes();
    switch src.Checked
        case 'off'
            ax = mainAxes();
            src.Checked = 'on';
            grid(ax,'on');
        case 'on'
            src.Checked = 'off';
            grid(ax,'off');
    end
    ZG = ZmapGlobal.Data;
    ZG.lock_aspect = src.Checked;
    drawnow
    align_supplimentary_legends();
    drawnow
    
end

function toggle_aspectratio(src, ~)
    ax = mainAxes();
    switch src.Checked
        case 'off'
            src.Checked = 'on';
            daspect(ax, [1 cosd(mean(ax.YLim)) 10]);
        case 'on'
            src.Checked = 'off';
            daspect(ax,'auto');
    end
    ZG = ZmapGlobal.Data;
    ZG.lock_aspect = src.Checked;
    align_supplimentary_legends();
    
end
function hide_events()
    set(findMapaxParts(),'visible','off');
end
function h=findMapaxParts(ax)
    if ~exist('ax','var'), ax=0; end
    h = findobj(ax,'-regexp','Tag','\<mapax_part[0-9].*\>');
end
function h=findNoLegendParts(ax)
    % to keep lines out of the legend, append a '_nolegend' to the item's Tag
    if ~exist('ax','var'), ax=0; end
    h = findobj(ax,'-regexp','Tag','\<.*_nolegend.*\>');
end

function change_legend_breakpoints(~, ~)
    % TODO fix this, breakpoints aren't changed
    switch ZmapGlobal.Data.mainmap_plotby
        case {'tim','time'}
            setleg;
        case {'dep','depth'}
            setlegm;
        case {'mad'}
            % pick new color?
        case {'mag'}
            setlegm;
        case {'fau'}
            % donno
        otherwise
            error('unrecognized legend type');
            % donno
            
    end
    
end

function change_map_fonts(~,~)
    ax = findobj('Tag','mainmap_ax');
    f = uisetfont(ax,'Change Font Size');
    fontsz = ZmapGlobal.Data.fontsz;
    fontsz.base_size = f.FontSize;
    % TODO note, this does not change the font (maybe later)
    set(ax,'FontSize',f.FontSize);
    set(ax.Legend,'FontSize', f.FontSize);
    axmag=findobj('Tag','mainmap_supplimentary_maglegend');
    set(axmag,'FontSize',f.FontSize);
end

function set_3d_view(src,~)
    watchon
    drawnow;
    switch src.Label
        case '3-D view'
            ax=mainAxes();
            hold on
            view(ax,3);
            grid(ax,'on');
            zlim(ax,'auto');
            %axis(ax,'tight');
            zlabel(ax,'Depth [km]');
            rotate3d(ax,'on'); %activate rotation tool
            hold off
            src.Label = '2-D view';
        otherwise
            ax=mainAxes();
            view(ax,2);
            grid(ax,'on');
            rotate3d(ax,'off'); %activate rotation tool
            src.Label = '3-D view';
    end
    watchoff
    drawnow;
end


function histo_callback(hist_type)
    ZG=ZmapGlobal.Data;
    hisgra(ZG.a, hist_type);
end