classdef ZmapMainWindow < handle
    % ZMAPMAINWINDOW
    
    properties
        catalog ZmapCatalog % event catalog
        rawcatalog ZmapCatalog;
        shape {mustBeShape} = ShapeGeneral % used to subset catalog by selected area
        daterange datetime % used to subset the catalog with date ranges
        Grid {mustBeZmapGrid} = ZmapGlobal.Data.Grid % grid that covers entire catalog area
        gridopt % used to define the grid
        evsel {EventSelectionChoice.mustBeEventSelector} = ZmapGlobal.Data.GridSelector % how events are chosen
        fig % figure handle
        xsgroup;
        xsections; % contains XSection 
        xscats; % ZmapXsectionCatalogs corresponding to each cross section
        xscatinfo %stores details about the last catalog used to get cross section, avoids projecting multiple times.
        prev_states Stack = Stack(10);
        undohandle;
        Features;
        replotting=false
        mdate
        mshape
    end
    
    properties(Constant)
        WinPos=position_in_current_monitor(1200,750)% [50 50 1200 750]; % position of main window
        URPos=[800 380 390 360]; %
        LRPos=[800 10 390 360];
        MapPos_S=[70 270 680 450];
        MapPos_L=[70 50 680 450+220]; %260
        XSPos=[15 10 760 215];
        XSAxPos=[45 40 675 120];
    end
    properties(Dependent)
        map_axes % main map axes handle
    end
    
    methods (Static)
        
        function feat=features()
            persistent feats
            ZG=ZmapGlobal.Data;
            if isempty(feats)
                feats=ZG.features;
                MapFeature.foreach_waitbar(feats,'load');
            end
            feat=feats;
        end
        
    end
    methods
        function obj=ZmapMainWindow(fig,catalog)
            if exist('fig','var') && isa(fig,'ZmapMainWindow') && ~isvalid(fig.fig)
                % recreate the figure (?)
                errordlg('unimplemented');
                return
            end
            if exist('fig','var') && ~isempty(fig)
                delete(fig);
            end
            
            % set up figure
            h=msgbox('drawing the main window. Please wait');
            
            obj.fig=figure('Position',obj.WinPos,'Name','Catalog Name and Date','Units',...
                'pixels','Tag','Zmap Main Window','NumberTitle','off','visible','off');
            % plot all events from catalog as dots before it gets filtered by shapes, etc.
            
            add_menu_divider()
            
            
            ZG=ZmapGlobal.Data;
            if exist('catalog','var')
                obj.rawcatalog=catalog;
            else
                obj.rawcatalog=ZG.Views.primary.Catalog;
            end
            if isempty(obj.rawcatalog)
                errordlg(sprintf('Cannot open the ZmapMainWindow: No catalog is loaded.\nFirst load a catalog into Zmap, then try again.'),'ZMap');
                if isvalid(h),delete(h),end
                error('No catalog is loaded');
            end
            obj.daterange=[min(obj.rawcatalog.Date) max(obj.rawcatalog.Date)];
            % initialize from the existing globals
            obj.Features=ZG.features;
            
            obj.shape=ZG.selection_shape;
            [obj.catalog,obj.mdate, obj.mshape]=obj.filtered_catalog();
            obj.Grid=ZG.Grid;
            obj.gridopt= ZG.gridopt;
            obj.evsel = ZG.GridSelector;
            obj.xsections=containers.Map();
            obj.xscats=containers.Map();
            obj.xscatinfo=containers.Map();
            
            obj.fig.Name=sprintf('%s [%s - %s]',obj.catalog.Name ,char(min(obj.catalog.Date)),...
                char(max(obj.catalog.Date)));
            
            obj.Features=ZmapMainWindow.features();
            %MapFeature.foreach_waitbar(obj.Features,'load');
            
            obj.plot_base_events();
            
            obj.prev_states=Stack(5); % remember last 5 catalogs
            obj.pushState();
            
            emm = uimenu(obj.fig,'label','Edit!');
            obj.undohandle=uimenu(emm,'label','Undo','Callback',@(s,v)obj.cb_undo(s,v),'Enable','off');
            uimenu(emm,'label','Redraw','Callback',@(s,v)obj.cb_redraw(s,v));
            uimenu(emm,'label','xsection','Callback',@(s,v)obj.cb_xsection);
            % TODO: undo could also stash grid options & grids
            
            
            TabLocation = 'top'; % 'top','bottom','left','right'
            uitabgroup('Units','pixels','Position',obj.URPos,...
                'Visible','off','SelectionChangedFcn',@cb_selectionChanged,...
                'TabLocation',TabLocation,'Tag','UR plots');
            uitabgroup('Units','pixels','Position',obj.LRPos,...
                'Visible','off','SelectionChangedFcn',@cb_selectionChanged,...
                'TabLocation',TabLocation,'Tag','LR plots');
            
            obj.xsgroup=uitabgroup('Units','pixels','Position',obj.XSPos,...
                'TabLocation',TabLocation,'Tag','xsections',...
                'SelectionChangedFcn',@cb_selectionChanged,'Visible','off');
            
            obj.replot_all();
            obj.fig.Visible='on';
            if isvalid(h)
                delete(h)
            end
            obj.create_all_menus(true);
            add_grid_menu(obj);
        end
        
        %% METHODS DEFINED IN DIRECTORY
        replot_all(obj,status)
        plot_base_events(obj)
        plotmainmap(obj)
        c=context_menus(obj, tag,createmode, varargin) % manage context menus used in figure
        plothist(obj, name, values, tabgrouptag)
        fmdplot(obj, tabgrouptag)
        
        cummomentplot(obj,tabgrouptag)
        time_vs_something_plot(obj, name, whichplotter, tabgrouptag)
        cumplot(obj, tabgrouptag)
        
        % push and pop state
        pushState(obj)
        popState(obj)
        catalog_menu(obj,force)
        [c, mdate, mshape, mall]=filtered_catalog(obj)
        
        %%
        function ax=get.map_axes(obj)
            % get mainmap axes
            ax=findobj(obj.fig,'Tag','mainmap_ax');
        end
        
        function zp = map_zap(obj)
            % MAP_ZAP create a ZmapAnalysis Pkg for the main window
            % the ZmapAnalysisPkg can be used as inputs to the various processing routines
            %
            % zp = obj.MAP_ZAP()
            %
            % see also ZMAPANALYSISPKG
            if isempty(obj.evsel)
                obj.evsel = EventSelectionChoice.quickshow();
            else
                fprintf('Using existing event selection:\n%s\n',...
                    matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(obj.evsel));
            end
            if isempty(obj.Grid)
                gridopts= GridParameterChoice.quickshow();
                obj.Grid = ZmapGrid('grid',gridopts.toStruct);
            else
                fprintf('Using existing grid:\n');
            end
            zp = ZmapAnalysisPkg( [], obj.catalog,obj.evsel,obj.Grid, obj.shape);
        end
        
        function zp = xsec_zap(obj, xsTitle)
            % XSEC_ZAP create a ZmapAnalysis Pkg from a cross section
            % the ZmapAnalysisPkg can be used as inputs to the various processing routines
            %
            % zp = obj.XSEC_ZAP() create a Z.A.P. but use the currently active cross section as a guide
            % zp = obj.XSEC_ZAP(xsTitle)
            %
            % see also ZMAPANALYSISPKG
            
            
            % first, make sure a cross section exists!
            if isempty(obj.xsections)
                errordlg('There is no cross section to analyze. Aborting.');
                zp=[];
                return
            end
            
            ZG=ZmapGlobal.Data;
            
            z_min = floor(min([0 min(obj.catalog.Depth)]));
            z_max = round(max(obj.catalog.Depth) + 4.9999 , -1);
            
            zdlg = ZmapDialog([]);
            if ~exist('xsTitle','var')
                xsTitle=obj.xsgroup.SelectedTab.Title;
            else
                if ~any(strcmp(obj.xsections.keys,xsTitle))
                    warndlg(sprintf('The requested cross section [%s] does not exist. Using selected tab.',xsTitle));
                    xsTitle=obj.xsgroup.SelectedTab.Title;
                end
            end
            xsIndex = find(strcmp(obj.xsections.keys,xsTitle));
            zdlg.AddBasicPopup('xsTitle', 'Cross Section:', obj.xsections.keys, xsIndex, 'Choose the cross section');
            zdlg.AddEventSelectionParameters('evsel', ZG.ni, ZG.ra, 1);
            zdlg.AddBasicEdit('x_km','Horiz Spacing [km]', 5,'Distance along strike, in kilometers');
            zdlg.AddBasicEdit('z_min','min Z [km]', z_min,'Shallowest gridpoint');
            zdlg.AddBasicEdit('z_max','max Z [km]', z_max,'Deepest grid point, in kilometers');
            zdlg.AddBasicEdit('z_delta','number of layers', round(z_max-z_min)+1,'Number of horizontal layers ');
            [zans, okPressed] = zdlg.Create('Cross Section Sample parameters');
            if ~okPressed
                zp = [];
                return
            end
            
            zs_km = linspace(zans.z_min, zans.z_max, zans.z_delta);
            gr = obj.xsections(xsTitle).getGrid(zans.x_km, zs_km);
            zp = ZmapAnalysisPkg( [], obj.xscats(xsTitle), zans.evsel, gr, obj.shape);
            
        end
            
        
        function myTab = findOrCreateTab(obj, parent, title)
            % FINDORCREATETAB if tab doesn't exist yet, create it
            %    parent :
            myTab=findobj(obj.fig,'Title',title,'-and','Type','uitab');
            if isempty(myTab)
                p = findobj(obj.fig,'Tag',parent);
                myTab=uitab(p, 'Title',title);
            end
        end
        
        
        function cb_timeplot(obj)
            ZG=ZmapGlobal.Data;
            ZG.newt2=obj.catalog;
            timeplot();
        end
        
        function cb_starthere(obj,ax)
            disp(ax)
            [x,~]=click_to_datetime(ax);
            obj.pushState();
            obj.daterange(1)=x;
            obj.replot_all();
        end
        
        function cb_endhere(obj,ax)
            [x,~]=click_to_datetime(ax);
            obj.pushState();
            obj.daterange(2)=x;
            obj.replot_all();
        end
        
        function cb_trim_to_largest(obj,~,~)
            biggests = obj.catalog.Magnitude == max(obj.catalog.Magnitude);
            idx=find(biggests,1,'first');
            obj.pushState();
            obj.daterange(1)=obj.catalog.Date(idx);
            %obj.catalog = obj.catalog.subset(obj.catalog.Date>=obj.catalog.Date(idx));
            obj.replot_all()
        end
        
        
        function shapeChangedFcn(obj,oldshapecopy)
            obj.prev_states.push({obj.catalog, oldshapecopy, obj.daterange});
            obj.replot_all();
        end
        function cb_undo(obj,~,~)
            obj.popState()
            obj.replot_all();
        end
        
        function cb_redraw(obj,~,~)
            % REDRAW if things have changed, then also push the new state
            watchon
            item=obj.prev_states.peek();
            do_stash=true;
            if ~isempty(item)
                do_stash = ~strcmp(item{1}.summary('stats'),obj.catalog.summary('stats')) ||...
                    ~isequal(obj.shape,item{2});
            end
            if do_stash
                disp('pushing')
                obj.pushState();
            end
            %[obj.catalog,obj.mdate,obj.mshape]=obj.filtered_catalog();
            obj.replot_all();
            watchoff
        end
        
        function cb_xsection(obj)
            % main map axes, where the cross section outline will be plotted
            axm=obj.map_axes;
            obj.fig.CurrentAxes=axm;
            xsec = XSection.initialize_with_dialog(axm,20);
            mytitle=[xsec.startlabel ' - ' xsec.endlabel];
            
            obj.xsec_add(mytitle, xsec);
            
            mytab=findobj(obj.fig,'Title',mytitle,'-and','Type','uitab');
            if ~isempty(mytab)
                delete(mytab);
            end
            
            obj.xsgroup.Visible = 'on';
            set(obj.map_axes,'Position',obj.MapPos_S);
            mytab=uitab(obj.xsgroup, 'Title',mytitle,'ForegroundColor',xsec.color,'DeleteFcn',xsec.DeleteFcn);
            
            % keep tabs alphabetized
            [~,idx]=sort({obj.xsgroup.Children.Title});
            obj.xsgroup.Children=obj.xsgroup.Children(idx);
           
            % add context menu to tab allowing modifications to x-section
            delete(findobj(obj.fig,'Tag',['xsTabContext' mytitle]))
            c=uicontextmenu(obj.fig,'Tag',['xsTabContext' mytitle]);
            uimenu(c,'Label','Info','Callback',@(~,~) cb_info);
            uimenu(c,'Label','Change Width','Callback',@(~,~)cb_chwidth);
            uimenu(c,'Label','Change Color','Callback',@(~,~)cb_chcolor);
            % uimenu(c,'Label','Swap Ends','Callback',@(~,~)cb_swapends); doesn't work(?)
            uimenu(c,'Label','Examine This Area','Callback',@(~,~)cb_cropToXS);
            uimenu(c,'Separator','on',...
                'Label','Delete',...
                'Callback',@deltab);
            mytab.UIContextMenu=c;
            
            % plot the 
            ax=axes(mytab,'Units','pixels','Position',obj.XSAxPos,'YDir','reverse');
            %xsec.plot_events_along_strike(ax,obj.catalog);
            xsec.plot_events_along_strike(ax,obj.xscats(mytitle));
            ax.Title=[];
            
            % make this the active tab
            mytab.Parent.SelectedTab=mytab;
            obj.replot_all();
            
            function cb_info()
                s=sprintf(...
                    '%g km long by %g km wide cross section containing:\n\n%s',...
                    xsec.length_km,xsec.width_km,...
                    obj.xscats(mytitle).summary('stats'));
             msgbox(s,mytitle);
            end
            function cb_chwidth()
                % change width of a cross-section
                prompt={'Enter the New Width:'};
                name='Cross Section Width';
                numlines=1;
                defaultanswer={num2str(xsec.width_km)};
                answer=inputdlg(prompt,name,numlines,defaultanswer);
                if ~isempty(answer)
                    xsec=xsec.change_width(str2double(answer),axm);
                    obj.xsec_add(mytitle,xsec);
                    
                end
                xsec.plot_events_along_strike(ax,obj.xscats(mytitle),true);
                ax.Title=[];
                obj.replot_all('CatalogUnchanged');
            end
            
            function cb_swapends()
                xsec = xsec.swap_ends(axm);
                obj.xsec_add(mytitle,xsec);
                obj.replot_all();
            end
            
            function cb_chcolor()
                color=uisetcolor(xsec.color,['Color for ' xsec.startlabel '-' xsec.endlabel]);
                xsec=xsec.change_color(color,axm);
                mytab.ForegroundColor = xsec.color;
                obj.xsections(mytitle)=xsec;
                obj.replot_all('CatalogUnchanged');
            end
            function cb_cropToXS()
                oldshape=copy(obj.shape);
                obj.shape=ShapePolygon('polygon',[xsec.polylons(:), xsec.polylats(:)]);
                obj.shapeChangedFcn(oldshape);
                obj.replot_all();
            end
            function deltab(~,~)
                xsec.DeleteFcn();
                xsec.DeleteFcn='';
                delete(mytab);
                obj.xsec_remove(mytitle);
                obj.replot_all('CatalogUnchanged');
            end
        end
        
        
        %% menu items.        %% create menus
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
            obj.create_overlay_menu(force);
            %ShapeGeneral.AddMenu(gcf);
            %add_grid_menu(uimenu('Label','Grid'));
            obj.catalog_menu(force);
            obj.create_ztools_menu(force);
            
            addQuitMenuItem();
            addAboutMenuItem();
            
        end
        
        function create_overlay_menu(obj,force)
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
            mapoptionmenu = uimenu('Label','Map Options','Tag','mainmap_menu_overlay');
            
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
                MapFeature.foreach(obj.Features,'addToggleMenu',ovmenu)
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
        
        function create_ztools_menu(obj,force)
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
            
            obj.create_topo_map_menu(submenu);
            obj.create_random_data_simulations_menu(submenu);
            uimenu(submenu,'Label','Create [simple] cross-section','Callback',@(~,~)obj.cb_xsection);
            
            obj.create_histogram_menu(submenu);
            obj.create_mapping_rate_changes_menu(submenu);
            obj.create_map_ab_menu(submenu);
            obj.create_map_p_menu(submenu);
            obj.create_quarry_detection_menu(submenu);
            obj.create_decluster_menu(submenu);
            
            uimenu(submenu,'Label','Map stress tensor',...
                'Callback',@(~,~)stressgrid());
            
            uimenu(submenu,'Label','Misfit calculation',...
                'Callback',@(~,~)inmisfit(),...
                'Enable','off'); %FIXME: misfitcalclulation poorly documented, not sure what it is comparing.
            
            function analyze_time_series_cb(~,~)
                % analyze time series for current catalog view
                ZG=ZmapGlobal.Data;
                ZG.newt2 = obj.catalog;
                timeplot();
            end
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
            uimenu(submenu,'label','Create permutated catalog (also new b-value)...', 'Callback',@cb_create_permutated);
            uimenu(submenu,'label','Create synthetic catalog...',...
                'Callback',@cb_create_syhthetic_cat);
            
            uimenu(submenu,'Label','Evaluate significance of b- and a-values','Callback',@(~,~)brand());
            uimenu(submenu,'Label','Calculate a random b map and compare to observed data','Callback',@(~,~)brand2());
            uimenu(submenu,'Label','Info on synthetic catalogs','Callback',@(~,~)web(['file:' hodi '/zmapwww/syntcat.htm']));
        end
        function create_mapping_rate_changes_menu(obj,parent)
            submenu  =   uimenu(parent,'Label','Mapping rate changes');
            
            comp2periodz.AddMenuItem(submenu, @()obj.map_zap);
            magrcros.AddMenuItem(submenu, @()obj.map_zap);
            
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
        
        function create_map_ab_menu(obj,parent)
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
        
        function create_map_p_menu(obj,parent)
            submenu  =   uimenu(parent,'Label','Mapping p-values');
            tmp=uimenu(submenu,'Label','p- and b-value map','Callback',@(~,~)bpvalgrid());
            tmp=uimenu(submenu,'Label','Rate change, p-,c-,k-value map in aftershock sequence (MLE)');
            uimenu(tmp,'Label','Calculate','Callback',@(~,~)rcvalgrid_a2());
            uimenu(tmp,'Label','Load...',...
                'Enable','off',...
                'Callback',  @(~,~)rcvalgrid_a2('lo'));
        end
        
        function create_quarry_detection_menu(obj,parent)
            submenu  = uimenu(parent,'Label','Detect quarry contamination');
            uimenu(submenu,'Label','Map day/nighttime ration of events','Callback',@(~,~)findquar());
            uimenu(submenu,'Label','Info on detecting quarries','Callback',@(~,~)web(['file:' hodi '/help/quarry.htm']));
        end
        
        function create_histogram_menu(obj,parent)
            
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
        
        function create_decluster_menu(obj,parent)
            submenu = uimenu(parent,'Label','Decluster the catalog');
            uimenu(submenu,'Label','Decluster using Reasenberg','Callback',@(~,~)inpudenew());
            uimenu(submenu,'Label','Decluster using Gardner & Knopoff',...
                'Enable','off',... %TODO this needs to be turned into a function
                'Callback',@(~,~)declus_inp());
        end
        
        function set_3d_view(obj, src,~)
            watchon
            drawnow;
            axm=obj.map_axes;
            switch src.Label
                case '3-D view'
                    hold(axm,'on');
                    view(axm,3);
                    grid(axm,'on');
                    zlim(axm,'auto');
                    %axis(ax,'tight');
                    zlabel(axm,'Depth [km]','UserData',field_unit.Depth);
                    axm.ZDir='reverse';
                    rotate3d(axm,'on'); %activate rotation tool
                    hold(axm,'off');
                    src.Label = '2-D view';
                otherwise
                    view(axm,2);
                    grid(axm,'on');
                    zlim(axm,'auto');
                    rotate3d(axm,'off'); %activate rotation tool
                    src.Label = '3-D view';
            end
            watchoff
            drawnow;
        end
        
        function set_event_selection(obj,val)
            % SET_EVENT_SELECTION changes the event selection criteria (radius, # events)
            %  obj.SET_EVENT_SELECTION() sets it to the global version
            %  obj.SET_EVENT_SELECTION(val) changes it to val, where val is a struct with fields
            %  similar to what is returned via EventelectionChoice.quickshow
            
            if ~isempty(val)
                assert(isstruct(val)); % could do more detailed checking of fields
                obj.evsel = val;
            elseif isempty(ZmapGlobal.Data.GridSelector)
                obj.evsel = EventSelectionChoice.quickshow();
            else
                ZG=ZmapGlobal;
                obj.evsel = ZG.GridSelector;
            end
        end
        function ev = get_event_selection(obj)
            ev = obj.evsel;
        end
        
    end % METHODS
    methods(Access=protected) % HELPER METHODS
        
        %% CROSS SECTION HELPERS
        
        function xsec_remove(obj, key)
            % XSEC_REMOVE completely removes cross section from object
            obj.xsections.remove(key);
            obj.xscats.remove(key);
            obj.xscatinfo.remove(key);
        end
        
        function xsec_add(obj, key, xsec)
            %XSEC_ADD add/replace cross section
            obj.xsections(key)=xsec;
            % add catalog generated by the cross section (ignoring shape)
            obj.xscats(key)= xsec.project(obj.rawcatalog.subset(obj.mdate));
            % add the information about the catalog used
            obj.xscatinfo(key)=obj.catalog.summary('stats');
        end
            
    end
end % CLASSDEF

%% helper functions
function cb_selectionChanged(~,~)
    %alltabs = src.Children;
    %isselected=alltabs == src.SelectedTab;
    %set(alltabs(isselected).Children, 'Visible','on');
    %subax=findobj(alltabs(~isselected),'Type','axes')
    %set(subax,'visible','off');
end

