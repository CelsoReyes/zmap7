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
    properties(Constant)
        axTag='mainmap_ax';
        catview='prime';
    end
    
    methods
        function obj = MainInteractiveMap()
            persistent lock
            
            h=findobj('Tag','seismicity_map');
            obj.Features=ZmapGlobal.Data.features;
            
            % the lock avoids loading features multiple times when MainInteractiveMap is called
            % TODO find more elegant solution where MainInteractiveMap isn't called twice.
            if isempty(lock)
                lock=1;
                MapFeature.foreach_waitbar(obj.Features,'load');
                obj.initial_setup()
                lock=[];
            end
        end
        
        function v = View(obj)
            % VIEW return primary view
            ZG=ZmapGlobal.Data;
            % get view, always deals with the primary view
            v=ZG.Views.primary;
        end
        function update(obj, opt)
            % update will update the map window. 
            % obj.update() updates the map window
            % obj.update('show') will bring the map window to front, too
            
            ZG=ZmapGlobal.Data; %handle to globals;
            watchon;
            ax = MainInteractiveMap.mainAxes();
            if isempty(ax)
                % we have to redraw the whole thing, instead.
                obj.createFigure()
                return
            end
            MainInteractiveMap.plotEarthquakes(ZG.Views.primary);
            xlim(ax , ZG.Views.primary.LongitudeRange);
            ylim(ax , ZG.Views.primary.LatitudeRange);
            ax.FontSize=ZmapGlobal.Data.fontsz.s;
            axis(ax,'manual');
            MapFeature.foreach(obj.Features,'refreshPlot');
            
            obj.plotBigEarthquakes();
            
            % bring selected events to front
            %uistack(findobj('DisplayName','Selected Events'),'top');
            
            tolegend=findobj(ax,'Type','line');
            tolegend=tolegend(~ismember(tolegend,findNoLegendParts(ax)));
            legend(ax,tolegend,'Location','southeastoutside');
            ax.Legend.Title.String='Seismicity Map';
            if ZG.lock_aspect
                daspect(ax, [1 cosd(mean(ax.YLim)) 10]);
            end
            grid(ax , char(ZG.mainmap_grid));
            
            align_supplimentary_legends(ax);
            
            
            % make sure we're back in a 2-d view
            title(ax,MainInteractiveMap.get_title(ZG.Views.primary),'Interpreter','none');
            view(ax,2); %reset to top-down view
            grid(ax,'on');
            zlabel(ax,'Depth [km]');
            rotate3d(ax,'off'); %activate rotation tool
            set(findobj(figureHandle(),'Label','2-D view'),'Label','3-D view');
            watchoff;
            if exist('opt','var')
                switch opt
                    case 'show'
                        figure(figureHandle());
                    case ''
                        % do nothing
                    otherwise
                        ZmapMessageCenter.set_error('unknown map update option');
                end
            end
            drawnow;
            
            % change some ordering
            bigobj=findobj(figureHandle(),'Tag','mainmap_big_events');
            uistack(bigobj,'top');
            
        end
        function createFigure(obj)
            ZG=ZmapGlobal.Data;
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
                'Position',position_in_current_monitor(900, 650,'right',50));
            
            % get the datacursor tool
            dcm_obj = datacursormode(h);
            dcm_obj.UpdateFcn = @event_datacursor_txt;
            
            watchon; 
            drawnow;
            ax = axes('Parent',h,'Position',[.09 .09 .85 .85],...
                'Tag',MainInteractiveMap.axTag,...
                'FontSize',ZmapGlobal.Data.fontsz.s,...
                'FontWeight','normal',...
                'Ticklength',[0.01 0.01],'LineWidth',1.0,...
                'SortMethod','childorder',...
                'Box','on','TickDir','out');
            xlabel(ax,'Longitude [deg]','FontSize',ZmapGlobal.Data.fontsz.m,'UserData',field_unit.Longitude)
            ylabel(ax,'Latitude [deg]','FontSize',ZmapGlobal.Data.fontsz.m,'UserData',field_unit.Latitude)
            if isempty(ZG.primeCatalog)
                errordlg('No data exists in the currenty catalog')
                title(ax, sprintf('No Events in Catalog :"%s"',ZG.Views.primary),'Interpreter','none');
                return
            end
            title(ax, MainInteractiveMap.get_title(ZG.Views.primary),'FontWeight','normal',...
                ...%'FontSize',ZmapGlobal.Data.fontsz.m,...
                'Color','k','Interpreter','none');
            if ~isempty(MainInteractiveMap.mainAxes())
                % create the main earthquake axis
            end
            if isempty(ZG.Views.primary)
                cf=@()ZG.primeCatalog;
                ZG.Views.primary=ZmapCatalogView(cf);
            else
                disp('Reusing view:');
                disp(ZG.Views.primary);
            end
            %MainInteractiveMap.plotEarthquakes(ZG.primeCatalog)
            MainInteractiveMap.plotEarthquakes(ZG.Views.primary)
            xlim(ax,'auto')
            ylim(ax,'auto');
            axis(ax,'manual');
            disp('     "      features');
            MapFeature.foreach(obj.Features,'plot',ax);
            
            MainInteractiveMap.plotMainshocks(ZG.main);
            disp('     "      "big" earthquakes');
            MainInteractiveMap.plotBigEarthquakes();
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
            if ZG.lock_aspect
                daspect(ax, [1 cosd(mean(ax.YLim)) 10]);
            end
            grid(ax, char(ZG.mainmap_grid));
            align_supplimentary_legends(ax);
            disp('adding menus to main map')
            obj.create_all_menus(true);
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
            add_grid_menu(uimenu('Label','Grid'));
            add_menu_catalog('primeCatalog','primary',force,gcf);
            obj.create_ztools_menu(force);
            
            % add quit menu to main file menu
            hQuit=findall(gcf,'Label','QuitZmap');
            if isempty(hQuit)
                mainfile=findall(gcf,'Tag','figMenuFile');
                uimenu(mainfile,'Label','Quit Zmap','Separator','on',...
                Futures.MenuSelectedFcn,@(~,~)restartZmap);
            end
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
                Futures.MenuSelectedFcn,@(~,~)zmap_update_displays());
            
            uimenu(mapoptionmenu,'Label','3-D view',...
                Futures.MenuSelectedFcn,@set_3d_view); % callback was plot3d
            %TODO use add_symbol_menu(...) instead of creating all these menus
            add_symbol_menu(MainInteractiveMap.axTag, mapoptionmenu, 'Map Symbols');
            ovmenu = uimenu(mapoptionmenu,'Label','Layers');
            MapFeature.foreach(obj.Features,'addToggleMenu',ovmenu)
            
            uimenu(ovmenu,'Label','Plot stations + station names',...
                'Separator', 'on',...
                Futures.MenuSelectedFcn,@(~,~)plotstations(MainInteractiveMap.mainAxes()));
            
            lemenu = uimenu(mapoptionmenu,'Label','Legend by ...  ');
            
            uimenu(lemenu,'Label','Change legend breakpoints',...
                Futures.MenuSelectedFcn,@change_legend_breakpoints);
            legend_types = {'Legend by time','tim';...
                'Legend by depth','depth';...
                'Legend by magnitudes','mag';...
                'Mag by size, Depth by color','mad' %;...
                % 'Symbol color by faulting type','fau'...
                };
            
            for i=1:size(legend_types,1)
                m=uimenu(lemenu,'Label',legend_types{i,1},...
                    Futures.MenuSelectedFcn, {@cb_plotby,legend_types{i,2}});
                if i==1
                    m.Separator='on';
                end
            end
            clear legend_types
            
            uimenu(mapoptionmenu,'Label','Change font size ...',...
                Futures.MenuSelectedFcn,@change_map_fonts);
            
            uimenu(mapoptionmenu,'Label','Change background colors',...
                Futures.MenuSelectedFcn,@(~,~)setcol(gcf),'Enable','off'); %
            
            uimenu(mapoptionmenu,'Label','Mark large event with M > ??',...
                Futures.MenuSelectedFcn,@(s,e) plot_large_quakes);
            uimenu(mapoptionmenu,'Label','Set aspect ratio by latitude',...
                Futures.MenuSelectedFcn,@toggle_aspectratio,...
                'Checked',char(ZmapGlobal.Data.lock_aspect));
            uimenu(mapoptionmenu,'Label','Toggle Lat/Lon Grid',...
                Futures.MenuSelectedFcn,@toggle_grid,...
                'Checked',char(ZmapGlobal.Data.mainmap_grid));

            function cb_plotby(~,~, s)
                ZG=ZmapGlobal.Data;
                ZG.mainmap_plotby=s;
                watchon;
                zmap_update_displays();
                watchoff;
            end
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
                Futures.MenuSelectedFcn, @(s,e)ZmapMessageCenter());
            
            uimenu(submenu,'Label','Analyze time series ...',...
                'Separator','on',...
                Futures.MenuSelectedFcn,@(s,e)analyze_time_series_cb);
            
            obj.create_topo_map_menu(submenu);
            obj.create_random_data_simulations_menu(submenu);
            uimenu(submenu,'Label','Create [simple] cross-section',Futures.MenuSelectedFcn,@cb_xsect);
            uimenu(submenu,'Label','Create cross-section','Enable','off',Futures.MenuSelectedFcn,@(~,~)nlammap());
            
            obj.create_histogram_menu(submenu);
            obj.create_mapping_rate_changes_menu(submenu);
            obj.create_map_ab_menu(submenu);
            obj.create_map_p_menu(submenu);
            obj.create_quarry_detection_menu(submenu);
            obj.create_decluster_menu(submenu);
            
            uimenu(submenu,'Label','Map stress tensor',...
                Futures.MenuSelectedFcn,@(~,~)stressgrid());
            
            uimenu(submenu,'Label','Misfit calculation',...
                Futures.MenuSelectedFcn,@(~,~)cb_inmisfit,...
                'Enable','off'); %FIXME: misfit calclulation poorly documented, not sure what it is comparing.
                
            function cb_inmisfit(~,~)
                inmisfit(obj.Catalog)
            end
            function analyze_time_series_cb(~,~)
                % analyze time series for current catalog view
                ZG=ZmapGlobal.Data;
                ZG.newt2 = obj.Catalog();
                CumTimePlot(ZG.newt2);
            end
        end
        function create_topo_map_menu(obj,parent)
            submenu   =  uimenu(parent,'Label','Plot topographic map',...
                'Enable','off');
            uimenu(submenu,'Label','Open DEM GUI',Futures.MenuSelectedFcn, @(~,~)prepinp());
            uimenu(submenu,'Label','3 arc sec resolution (USGS DEM)',Futures.MenuSelectedFcn, @(~,~)pltopo('lo3'));
            uimenu(submenu,'Label','30 arc sec resolution (GLOBE DEM)',Futures.MenuSelectedFcn, @(~,~)pltopo('lo1'));
            uimenu(submenu,'Label','30 arc sec resolution (GTOPO30)',Futures.MenuSelectedFcn, @(~,~)pltopo('lo30'));
            uimenu(submenu,'Label','2 deg resolution (ETOPO 2)',Futures.MenuSelectedFcn, @(~,~)pltopo('lo2'));
            uimenu(submenu,'Label','5 deg resolution (ETOPO 5, Terrain Base)',Futures.MenuSelectedFcn, @(~,~)pltopo('lo5'));
            uimenu(submenu,'Label','Your topography (mydem, mx, my must be defined)',Futures.MenuSelectedFcn, @(~,~)pltopo('yourdem'));
            uimenu(submenu,'Label','Help on plotting topography',Futures.MenuSelectedFcn, @(~,~)pltopo('genhelp'));
        end
        
        function create_random_data_simulations_menu(obj,parent)
            submenu  =   uimenu(parent,'Label','Random data simulations',...
            'Enable','off');
            uimenu(submenu,'label','Create permutated catalog (also new b-value)...',Futures.MenuSelectedFcn,@cb_create_permutated);
            uimenu(submenu,'label','Create synthetic catalog...',...
                Futures.MenuSelectedFcn,@cb_create_syhthetic_cat);
            
            uimenu(submenu,'Label','Evaluate significance of b- and a-values',Futures.MenuSelectedFcn,@(~,~)brand());
            uimenu(submenu,'Label','Calculate a random b map and compare to observed data',Futures.MenuSelectedFcn,@(~,~)brand2());
            uimenu(submenu,'Label','Info on synthetic catalogs',Futures.MenuSelectedFcn,@(~,~)web(['file:' hodi '/zmapwww/syntcat.htm']));
        end
        function create_mapping_rate_changes_menu(obj,parent)
            submenu  =   uimenu(parent,'Label','Mapping rate changes'...,...
                ...'Enable','off'
                );
            uimenu(submenu,'Label','Compare two periods (z, beta, probabilty)',Futures.MenuSelectedFcn,@(~,~)comp2periodz());
            
            uimenu(submenu,'Label','Calculate a z-value map',Futures.MenuSelectedFcn,@(~,~)inmakegr());
            uimenu(submenu,'Label','Calculate a z-value cross-section',...
                Futures.MenuSelectedFcn,@(~,~)nlammap());
            uimenu(submenu,'Label','Calculate a 3D  z-value distribution',Futures.MenuSelectedFcn,@(~,~)zgrid3d());
            %uimenu(submenu,'Label','Load a z-value grid (map-view)',Futures.MenuSelectedFcn,@(~,~)loadgrid('lo'));
            %uimenu(submenu,'Label','Load a z-value grid (cross-section-view)',Futures.MenuSelectedFcn,@(~,~)magrcros('lo'));
            %uimenu(submenu,'Label','Load a z-value movie (map-view)',Futures.MenuSelectedFcn,@(~,~)loadmovz());
        end
        
        function create_map_ab_menu(obj,parent)
            submenu  =   uimenu(parent,'Label','Mapping a- and b-values');
            % TODO have these act upon already selected polygons (as much as possible?)
            
            bvalgrid.AddMenuItem(submenu,@()ZmapGlobal.Data.primeCatalog);
            %tmp=uimenu(submenu,'Label','Mc, a- and b-value map');
            
            tmp=uimenu(submenu,'Label','differential b-value map (const R)',...
                'Enable','off');
            uimenu(tmp,'Label','Calculate',Futures.MenuSelectedFcn, @(~,~)bvalmapt());
            uimenu(tmp,'Label','Load...',...
                'Enable','off',...
                Futures.MenuSelectedFcn, @(~,~)bvalmapt('lo'));
            
            uimenu(submenu,'Label','Calc a b-value cross-section',...
                ...'Enable','off',...
                Futures.MenuSelectedFcn, @(~,~)nlammap());
            
            tmp=uimenu(submenu,'Label','b-value depth ratio grid',...
                'Enable','off',... 
                Futures.MenuSelectedFcn, @(~,~)bdepth_ratio());
            
            uimenu(submenu,'Label','Calc 3D b-value distribution',...
                'Enable','off',... 
                Futures.MenuSelectedFcn, @(~,~)bgrid3dB());
            
            uimenu(submenu,'Label','Load a b-value grid (cross-section-view)',...
                'Enable','off',...
                Futures.MenuSelectedFcn,@(~,~)bcross('lo'));
            uimenu(submenu,'Label','Load a 3D b-value grid',...
                'Enable','off',...
                Futures.MenuSelectedFcn,@(~,~)myslicer('load')); %also had "sel = 'no'"
        end
        
        function create_map_p_menu(obj,parent)
            submenu  =   uimenu(parent,'Label','Mapping p-values');
            tmp=uimenu(submenu,'Label','p- and b-value map',Futures.MenuSelectedFcn,@(~,~)bpvalgrid());
            %uimenu(tmp,'Label','Calculate',Futures.MenuSelectedFcn, @(~,~)bpvalgrid());
            %uimenu(tmp,'Label','Load...',...
            %    'Enable','off',...'
            %    Futures.MenuSelectedFcn, @(~,~)bpvalgrid('lo'));
            
            tmp=uimenu(submenu,'Label','Rate change, p-,c-,k-value map in aftershock sequence (MLE)');
            uimenu(tmp,'Label','Calculate',Futures.MenuSelectedFcn,@(~,~)rcvalgrid_a2());
            uimenu(tmp,'Label','Load...',...
                'Enable','off',...
                Futures.MenuSelectedFcn,  @(~,~)rcvalgrid_a2('lo'));
        end
        
        function create_quarry_detection_menu(obj,parent)
            submenu  = uimenu(parent,'Label','Detect quarry contamination');
            uimenu(submenu,'Label','Map day/nighttime ration of events',Futures.MenuSelectedFcn,@(~,~)findquar());
            uimenu(submenu,'Label','Info on detecting quarries',Futures.MenuSelectedFcn,@(~,~)web(['file:' hodi '/help/quarry.htm']));
        end
        
        function create_histogram_menu(obj,parent)
            
            submenu = uimenu(parent,'Label','Histograms');
            
            uimenu(submenu,'Label','Magnitude',Futures.MenuSelectedFcn,@(~,~)histo_callback('Magnitude'));
            uimenu(submenu,'Label','Depth',Futures.MenuSelectedFcn,@(~,~)histo_callback('Depth'));
            uimenu(submenu,'Label','Time',Futures.MenuSelectedFcn,@(~,~)histo_callback('Date'));
            uimenu(submenu,'Label','Hr of the day',Futures.MenuSelectedFcn,@(~,~)histo_callback('Hour'));
            % uimenu(submenu,'Label','Stress tensor quality',Futures.MenuSelectedFcn,@(~,~)histo_callback('Quality '));
        end
        
        function create_decluster_menu(obj,parent)
            submenu = uimenu(parent,'Label','Decluster the catalog'...,...
                ...'Enable','off'...
                );
            uimenu(submenu,'Label','Decluster using Reasenberg',Futures.MenuSelectedFcn,@(~,~)inpudenew(obj.catalog));
            uimenu(submenu,'Label','Decluster using Gardner & Knopoff',...
                'Enable','off',... %TODO this needs to be turned into a function
                Futures.MenuSelectedFcn,@(~,~)declus_inp());
        end
        
        function working_catalog = Catalog(obj)
            % CATALOG returns the catalog represented in this map, filtered by area selection
            ZG=ZmapGlobal.Data;
            tmpview = ZG.Views.primary;
            if isempty(tmpview)
                ZmapMessageCenter.set_info('No catalog view', 'The catalog view hasn''t been initialized yet')
                working_catalog=ZG.primeCatalog;
                return
            end
            tmpview = tmpview.PolygonApply(ZG.selection_shape);
            working_catalog=tmpview.Catalog();
        end
            
        
    end
    methods(Static)
        function h = borderHandle()
            h = findobj( 'Tag');
        end
        
        function h = mainAxes()
            h = findobj( 'Tag',MainInteractiveMap.axTag);
        end
        
        %% plot CATALOG layer
        function plotEarthquakes(catview)
            disp(['MainInteractiveMap.plotEarthquakes :',ZmapGlobal.Data.mainmap_plotby]);
            %linkdata off
            set(findobj(gcf,'Tag','mainmap_ax'),'ColorOrderIndex',1);
            if ~any(strcmp(ZmapGlobal.Data.mainmap_plotby,{'magdepth','mad'}))
                delete(findobj(groot,'Tag','mainmap_supplimentary_maglegend'));
                delete(findobj(groot,'Tag','mainmap_supplimentary_deplegend'));
            end
            delete(findobj(MainInteractiveMap.mainAxes,'-regexp','Tag','mapax_part[0-9]+'));
                   
            switch ZmapGlobal.Data.mainmap_plotby
                case {'date'}
                    MainInteractiveMap.plotQuakesBySomething(catview,@(x)dateshift(x,'start','Day','nearest'),'Date');
                case {'tim','time'}
                    MainInteractiveMap.plotQuakesBySomething(catview,@(x)dateshift(x,'start','Second','nearest'),'Date');
                case {'dep','depth'}
                    MainInteractiveMap.plotQuakesBySomething(catview,@(x)round(x,1),'Depth');
                case {'mad','magdepth'}
                    MainInteractiveMap.plotQuakesByMagAndDepth(catview);
                case {'mag','magnitude'}
                    MainInteractiveMap.plotQuakesBySomething(catview,@(x)round(x,1),'Magnitude');
                otherwise
                    error('unanticipated legend type');
            end
            ax = MainInteractiveMap.mainAxes();
            %set aspect ratio
            if ZmapGlobal.Data.lock_aspect
                daspect(ax, [1 cosd(mean(ax.YLim)) 10]);
            end
            align_supplimentary_legends(ax);
            % TODO show subset also
        end
        
        function plotQuakesBySomething(mycat, roundingfun, something)
            % magdivisions: magnitude split points
            global event_marker_types
            if isempty(event_marker_types)
                event_marker_types='+++++++'; %each division gets next type.
            end
            ZG=ZmapGlobal.Data;
            cf=@()ZG.Views.primary;
            subviews=ZmapCatalogView(cf);
            divfn = str2func(['MainInteractiveMap.' lower(something) '_divs']);
            divs = divfn();
            if isempty(divs)
                divs = autosplit(mycat,  something, 'linear', 2, roundingfun); %could be count or linear
                divfn(divs);
            end
            zViews=split_views(mycat , something, divs, 'mapax_part');
            ZG.Views.layers=zViews;
            ax=findobj(gcf,'Tag','mainmap_ax');
            holdstate=HoldStatus(ax,'on');
            for i=1:numel(zViews)
                %myvarname=sprintf('ZmapGlobal.Data.Views.layers(%d)',i);
                %ZmapGlobal.Data.Views.layers(i).linkedplot(ax,myvarname)
                ZmapGlobal.Data.Views.layers(i).plot(ax,...
                    'Marker',event_marker_types(i),...
                    'MarkerSize',ZG.ms6);
            end
            holdstate.Undo();
        end
        
        
        function plotQuakesByMagAndDepth(mycat)
            % colorized by depth, with size dictated by magnitude
            persistent colormapName
            ax=findobj(gcf,'Tag','mainmap_ax');
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
            holdstate=HoldStatus(ax,'on');
            if isvalid(hquakes)
                plund=findobj('Tag','mapax_part1_bg_nolegend');
                set(plund, 'XData',mycat.Longitude,'YData',mycat.Latitude,'SizeData',sm*1.2);
            else
                plund = scatter(ax, mycat.Longitude, mycat.Latitude, sm*1.2,'o','MarkerEdgeColor','k');
                plund.ZData=mycat.Depth;
                plund.Tag='mapax_part1_bg_nolegend';
                plund.DisplayName='';
                plund.LineWidth=2;
            end
            if isvalid(hquakes)
                set(hquakes, 'XData',mycat.Longitude,'YData',mycat.Latitude,'SizeData',sm,...
                    'CData',mycat.Depth);
            else
                pl = scatter(ax, mycat.Longitude, mycat.Latitude, sm, mycat.Depth,'o','filled');
                pl.ZData=mycat.Depth;
                pl.Tag='mapax_part0';
                pl.DisplayName='Events by Mag & Depth';
                pl.MarkerEdgeColor = 'flat';
            end
            ax.ZLimMode='auto';
            holdstate.Undo();
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
        
        
        %% plot NON-catalog layers
        function plotOtherEvents(catalog, idx, varargin)
            %plotOtherEvents will plot the events from a catalog on the map
            % using the name-value pairs from varargin
            % tag: 'mapax_otherN' (where N is the value provided to idx)
            %  this allows the plotting of a variety of clusters.
            % if varargin includes the pair {'DisplayName',..}
            % then that is how this would be represented in the legend
            ax = MainInteractiveMap.mainAxes();
            if isempty(idx), idx=0;end
            thisTag = ['mapax_other' num2str(idx)];
            h = findobj(ax,'Tag',thisTag);
            delete(h);
            holdstate=HoldStatus(ax,'on');
            h=catalog.plot(ax, varargin{:});
            
            h.ZData=-catalog.Depth;
            h.Tag = thisTag;
            holdstate.Undo();
        end
        
        function plotBigEarthquakes(reset)
            % plot big earthquake epicenters labeled with the data/magnitude
            % DisplayName: Events > M [something]
            % Tag: 'mainmap_big_events'
            
            % TODO: maybe make ZG.maepi a view into the catalog
            
            ZG=ZmapGlobal.Data;
            defaults=getPlotDefaults('bigquake');
            textdefaults=getPlotDefaults('bigquake_text');
            big_events = ZG.maepi;
            
            if isempty(big_events)
                big_events = ZmapCatalog();
            end
            
            defaults.DisplayName = sprintf('Events > M %2.1f', ZG.big_eq_minmag);
            
            if big_events.Count > 0
                % show events
                h = plot_helper(big_events,defaults,exist('reset','var')&&reset);
                
                evlabels = event_labels(ZG.maepi);
                ax = MainInteractiveMap.mainAxes();
                delete(findobj(ax,'Tag','bigeventlabel'));
                te1 = text(ax,ZG.maepi.Longitude,ZG.maepi.Latitude,evlabels,'Tag','bigeventlabel');
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
                        char(catalog.Date(idx),'hh:mm'), mag,catalog.Magnitude(idx))};
                end
            end
        end
        
        function plotMainshocks(xycoords, reset)
            % plot mainshock(s)
            % DisplayName: 'mainshocks'
            % Tag: 'mainmap_mainshocks'
            persistent xydata
            
            if nargin
                xydata = replace_xy_if_exists(xydata, xycoords);
            end
            
            reset = exist('reset','var') && reset;
            plot_helper(xydata, getPlotDefaults('mainshock'), reset);
        end
        
        
        function ddivs=date_divs(val)
            persistent date_divisions
            if exist('val','var')
                date_divisions=val;
            end
            ddivs = date_divisions;
        end

        function ddivs=depth_divs(val)
            persistent depth_divisions
            if exist('val','var')
                depth_divisions=val;
            end
            ddivs = depth_divisions;
        end

        function mdivs=magnitude_divs(val)
            persistent magnitude_divisions
            if exist('val','var')
                magnitude_divisions=val;
            end
            mdivs = magnitude_divisions;
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
    
    ax = MainInteractiveMap.mainAxes();
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
        holdstate=HoldStatus(ax,'on');
        if isa(xy,'ZmapCatalog')|| istable(xy) || isstruct(xy)
            h=plot(ax, xy.Longitude, xy.Latitude, defaults);
        else
            h=plot(ax, xy(:,1), xy(:,2), defaults);
        end
        holdstate.Undo();
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
        Futures.MenuSelectedFcn, @popup_callback);
    uicontrol('Parent',d,...
        'Position',[89 20 70 25],...
        'String','Close',...
        Futures.MenuSelectedFcn,@(~,~)delete(gcf));
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
    ZmapMessageCenter.set_message('Save Data', ' ');
    try
        
        [file1, path1] = uiputfile(fullfile(ZmapGlobal.Data.data_dir, '*.mat'), 'Earthquake Datafile');
        if length(file1) > 1
            wholePath=[path1 file1];
            error('not implemented')
            %save('WholePath', 'ZG.primeCatalog', 'faults','main','mainfault','coastline','infstri','well');
        end
        
    catch ME
        warning(ME)
    end
end

function plot_large_quakes()
    ZG=ZmapGlobal.Data;
    mycat=ZmapCatalog(ZG.primeCatalog);

    [~,~,ZG.big_eq_minmag] = smart_inputdlg('Choose magnitude threshold',...
        struct('prompt','Mark events with M > ? ','value',ZG.big_eq_minmag));
    
    ZG.maepi = mycat.subset(mycat.Magnitude > ZG.big_eq_minmag);
    zmap_update_displays(); %FIXME changing magnitudes didn't chnge map output
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
            c.Position(1) = le.Position(1); % scoot it over to match the legend
        end
    end
end


function toggle_grid(src, ~)
    src.Checked=toggleOnOff(src.Checked);
    ax = MainInteractiveMap.mainAxes();
    grid(ax,src.Checked);
    ZG = ZmapGlobal.Data;
    ZG.lock_aspect = matlab.lang.OnOffSwitchState(src.Checked);
    align_supplimentary_legends();
    drawnow
end

function toggle_aspectratio(src, ~)
    src.Checked=toggleOnOff(src.Checked);
    ax = MainInteractiveMap.mainAxes();
    switch src.Checked
        case 'on'
            daspect(ax, [1 cosd(mean(ax.YLim)) 10]);
        case 'off'
            daspect(ax,'auto');
    end
    ZG = ZmapGlobal.Data;
    ZG.lock_aspect = matlab.lang.OnOffSwitchState(src.Checked);
    align_supplimentary_legends();
    
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
    dlg_title='Change Breakpoints';
    options.Resize='on';
    num_lines=1;
    switch ZmapGlobal.Data.mainmap_plotby
        case {'tim','time'}
            div=MainInteractiveMap.date_divs;
            prompt={'Specify date divisions or "--".',...
                ' ex. ',...
                '  datetime(2000,1,1):years(3):datetime(2015,1,1)',...
                'or ',...
                '  datetime([2010;2012;2015],1,1)',' '};
            def_ans={char(strjoin(['datetime({''', strjoin(string(div,'uuuu-MM-dd'),''','''), '''})'],''))};
            myans=inputdlg(strjoin(prompt,'\n'),dlg_title,3,def_ans,options);
            if ~isempty(myans)
                if myans{1} ~= "--"
                    div=myans{1}; % NO divisions
                else
                    div=eval(myans{1});
                end
                if isa(div,'datetime') || isempty(div) || div == "--"
                    MainInteractiveMap.date_divs(div);
                end
                zmap_update_displays()
            end
            %setleg;
        case {'dep','depth'}
            div=MainInteractiveMap.depth_divs();
            prompt='Specify depth divisions or "--". ex.  "5:10:50" or "[5 15 25]';
            def_ans={mat2str(div)};
            myans=inputdlg(prompt,dlg_title,num_lines,def_ans,options);
            if ~isempty(myans)
                if myans{1} == "--"
                    div=myans{1}; % NO divisions
                else
                    try
                    div=eval(myans{1});
                    catch
                        div=eval(['[' myans{1} ']']);
                    end
                end
                if isnumeric(div) || isempty(div) || div == "--"
                    MainInteractiveMap.depth_divs(div);
                end
                zmap_update_displays()
            end
            %setlegm;
        case {'mad'}
            % pick new color?
        case {'mag'}
            div=MainInteractiveMap.magnitude_divs();
            prompt='Specify magnitude divisions or "--". ex.  "[1 5 7]';
            def_ans={mat2str(div)};
            myans=inputdlg(prompt,dlg_title,num_lines,def_ans,options);
            if ~isempty(myans)
                if myans{1} == "--"
                    div=myans{1}; % NO divisions
                else
                    try
                    div=eval(myans{1});
                    catch
                        div=eval(['[' myans{1} ']']);
                    end
                end
                if isnumeric(div) || isempty(div) || div == "--"
                    MainInteractiveMap.magnitude_divs(div);
                end
                zmap_update_displays()
            end
            %setlegm;
        case {'fau'}
            % donno
        otherwise
            error('unrecognized legend type');
            % donno
            
    end
    
end

function change_map_fonts(~,~)
    ax = findobj('Tag',MainInteractiveMap.axTag);
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
            ax=MainInteractiveMap.mainAxes();
            hold on
            view(ax,3);
            grid(ax,'on');
            zlim(ax,'auto');
            %axis(ax,'tight');
            zlabel(ax,'Depth [km]','UserData',field_unit.Depth);
            ax.ZDir='reverse';
            rotate3d(ax,'on'); %activate rotation tool
            hold off
            src.Label = '2-D view';
        otherwise
            ax=MainInteractiveMap.mainAxes();
            view(ax,2);
            grid(ax,'on');
            zlim(ax,'auto');
            rotate3d(ax,'off'); %activate rotation tool
            src.Label = '3-D view';
    end
    watchoff
    drawnow;
end


function histo_callback(hist_type)
    ZG=ZmapGlobal.Data;
    hisgra(ZG.Views.primary.Catalog(), hist_type);
end

function cb_create_permutated(src,~)
    % will replace existing primary catalog
    ZG=ZmapGlobal.Data;
    ZG.primeCatalog=syn_invoke_random_dialog(ZG.primeCatalog);
    ZG.newt2 = ZmapCatalog(ZG.primeCatalog); 
    CumTimePlot(ZG.newt2);
    zmap_update_displays(); 
    bdiff(ZG.primeCatalog); 
    revertcat
end

function cb_create_syhthetic_cat(src,~)
    % will replace existing primary catalog
    ZG=ZmapGlobal.Data;
    ZG.primeCatalog=syn_invoke_dialog(ZG.primeCatalog); 
    ZG.newt2 = ZG.primeCatalog; 
    CumTimePlot(ZG.newt2);
    zmap_update_displays(); 
    bdiff(ZG.primeCatalog); 
    revertcat
end

function cb_xsect(src,~)
    plot_cross_section_from_mainmap();
    return
    %CB_XSECT create a cross-section from the map.
    % you can choose section width, start & end labels, and color.
    %
    % plots cross-section (great-circle curve) on map, along with boundary for selected events.
    % brings up new figure containing cross-section, with selected events plotted with depth, 
    % and histograms of events along sgtrike and with depth
    
    ZG=ZmapGlobal.Data;
    catalog=ZG.primeCatalog;
    
    % dialog box to choose cross-section
    zdlg=ZmapDialog([]);
    zdlg.AddBasicEdit('slicewidth_km','Width of slice [km]',20,'distance from slice for which to select events. 1/2 distance in either direction');
    zdlg.AddBasicEdit('startlabel','start label','A','start label for map');
    zdlg.AddBasicEdit('endlabel','end label','A''','start label for map');
    zdlg.AddBasicCheckbox('choosecolor','choose cross-section color [red]', false,{},...
                    'When checked, a color selection dialog will allow you to choose a different cross-section color');
    zdlg.AddBasicPopup('chooser','Choose Points',{'choose start and end with mouse'},1,'no choice');
    zans=zdlg.Create('slicer');
    C = [1 0 0]; % color for cross-section
    if zans.choosecolor
        C=uisetcolor(C,['Color for ' zans.startlabel '-' zans.endlabel]);
    end
    
    disp('click on start and end points for cross section');
    
    % pick first point
    [lon, lat] = ginput(1);
    hold on; 
    xs_endpts=plot(lon,lat,'x','LineWidth',2,'MarkerSize',5,'Color',C);
    
    % pick second point
    [lon(2), lat(2)] = ginput(1);
    xs_endpts.XData=lon; 
    xs_endpts.YData=lat;
    
    [curvelats,curvelons]=gcwaypts(lat(1),lon(1),lat(2),lon(2),100);
    
    % plot great-circle path
    xs_line=plot(curvelons,curvelats,'--','LineWidth',1.5,'Color',C);
    
    % plot width polygon
    [plat,plon] = xsection_poly([lat(1),lon(1)], [lat(2) lon(2)], zans.slicewidth_km/2);
    xspoly=plot(plon,plat,'-.','Color',C);
    
    %label it: put labels offset and outside the great-circle line.
    hOffset=@(x,polarity) x+(1/75).*diff(xlim) * sign(lon(2)-lon(1)) * polarity;
    vOffset=@(x,polarity) x+(1/75).*diff(ylim) * sign(lat(2)-lat(1)) * polarity;
    slabel = text(hOffset(lon(1),-1),vOffset(lat(1),-1),zans.startlabel,'Color',C.*0.8, 'FontWeight','bold');
    elabel = text(hOffset(lon(2),1),vOffset(lat(2),1),zans.endlabel,'Color',C.*0.8, 'FontWeight','bold');

    [c2,mindist,mask,gcDist]=project_on_gcpath([lat(1),lon(1)],[lat(2),lon(2)],catalog,zans.slicewidth_km/2,0.1);
    
    % PLOT X-SECTION IN NEW FIGURE
    figure('Name',['cross-section ' zans.startlabel '-' zans.endlabel],...
        'DeleteFcn',@(~,~)delete([xs_endpts,xs_line,slabel,elabel, xspoly])... autodelete xsection when figure is closed
        );
    
    % plot events
    ax=subplot(3,3,[1 5])
    scatter3(ax,c2.Longitude,c2.Latitude,c2.Depth,(c2.Magnitude+3).^2,mindist,'+')
    hold on
    plot(ax,catalog.Longitude,catalog.Latitude,'.','Color',[.75 .75 .75],'MarkerSize',1);
    scatter3(catalog.Longitude(mask),catalog.Latitude(mask),c2.Depth,3,mindist)
    ax.ZDir='reverse';
    copyobj(ZG.features('coastline'),ax);
    copyobj(ZG.features('borders'),ax);
    copyobj(ZG.features('faults'),ax);
    copyobj(ZG.features('lakes'),ax);
    hold off
    
    subplot(3,3,[7 8])
    h=histogram(gcDist);
    h.Parent.XTickLabel{1}=zans.startlabel;
    h.Parent.XTickLabel{end}=zans.endlabel;
    ylabel('# events');
    xlabel('Distance along strike (km)');
    subplot(3,3,[3 6])
    histogram(c2.Depth,'Orientation','horizontal');
    set(gca, 'YDir','reverse')
    xlabel('# events');
    ylabel('Distance Depth Profile (km)');
end

function A = toggleOnOff(A)
    if A == "on"
        A='off';
    else
        A='on';
    end
end


function splitpoints = autosplit(c,  prop, method, nPoints, roundingfn)
    % splitpoints = autosplit(c, prop, method, nPoints, roundingfn)
    % c is a catalog (or view)
    % prop is the valid catalog property
    % method : 'linear',  'count'
    %    linear: linearly splits catalog
    %    count : splits catalog into even chunks (#s of events)
    % nPoints is the number of split points  (1 = devide catalog in half
    %
    % see also split_views
    myrange=[min(c.(prop)) max(c.(prop))];
    switch method
        case 'linear'
            sp = linspace(myrange(1),myrange(2),nPoints+2); % begin pt1 pt2 ... ptN, end
            splitpoints=sp(2:end-1);
        case 'count'
            idx=round(linspace(1,c.Count, nPoints+2));
            idx=idx(2:end-1);
            splitpoints=c.(prop)(idx);
        otherwise
            error('no splitting method chosen')
    end
            
    if exist('roundingfn','var') && isa(roundingfn,'function_handle')
        splitpoints=roundingfn(splitpoints);
    end
end

function zmvs = split_views(zmv , prop, splitpoints, tagbase)
    % divides the catalog into a bunch of views
    % should preserve any polygon selections
    % split_views(zmv , prop, splitpoints, tagbase)
    % zmv is a ZmapCatalogView
    % prop is the name of a valid catalog property
    % splitpoints : the divisions along which to split.   
    % tagbase : text prepended to an index number, used for finding graphical objects
    %
    % see also autosplit
    if isempty(splitpoints)
        zmvs = zmv;
        return
    end
    switch prop
        case {'Date'}
            fmtfn=@(x) char(x,'uuuu-MM-dd'); %
            label='t';
            units='';
            tinydelta=seconds(0.01); % used so that bins are N<=X<M instead of  N<=x<=M
        case {'Time'}
            fmtfn=@(x) char(x,'uuuu-MM-dd hh:mm:ss'); %
            label='t';
            units='';
            tinydelta=seconds(0.01); % used so that bins are N<=X<M instead of  N<=x<=M
        case {'Latitude','Longitude'}
            fmtfn=@(x) num2str(x,-4);
            label=lower(prop(1:3));
            units='deg';
            tinydelta=0.00001;
        case {'Depth'}
            fmtfn=@(x) num2str(x,-2);
            label='Z';
            units='km';
            tinydelta=0.0001;
        case {'Magnitude'}
            fmtfn=@(x) num2str(x,-1);
            label='mag';
            units='';
            tinydelta=0.01;
            
        otherwise
            error('unanticipated property')
    end
    
    % prop is something like Depth, but the range is DepthRange
    propRange=[prop, 'Range'];
    zmvs=zmv;
    zmvs.(propRange)=[]; % start with the entire catalog
    zmvs=repmat(zmvs,numel(splitpoints)+1,1); % preallocate
    
    % beginning to splitpoint1
    zmvs(1).(propRange) = [min(zmvs(1).(prop)), splitpoints(1)-tinydelta]; % grab slice
    zmvs(1).DisplayName=[label ' < ' fmtfn(splitpoints(1)) ' ' units]; % for legend
    zmvs(1).Tag=[tagbase, num2str(1)]; % for finding, once plotted, via findobj/findall
    
    
    % from splitpoint 1 to last splitpoint
    for n=2:numel(splitpoints)
        zmvs(n).(propRange) = [splitpoints(n-1), splitpoints(n)-tinydelta];
        zmvs(n).DisplayName=[fmtfn(splitpoints(n-1)) ' <= ', label ' < ' fmtfn(splitpoints(n)) ' ' units];
        zmvs(n).Tag=[tagbase, num2str(n)];
    end
    
    % last splitpoint to end
    zmvs(end).(propRange) = [splitpoints(end), max(zmvs(end).(prop))];
    zmvs(end).DisplayName=[label ' >= ' fmtfn(splitpoints(end)) ' ' units];
    zmvs(end).Tag=[tagbase, num2str(n)];
end

function pd = getPlotDefaults(name)
    persistent defaults
    if isempty(defaults)
        ZG=ZmapGlobal.Data;
        defaults=containers.Map;
        defaults('mainshock') = struct('Tag','mainmap_mainshocks',...
            'Marker','*',...
            'DisplayName','mainshocks',...
            'LineStyle','none',...
            'LineWidth', 2.0,...
            'MarkerSize', 12,...
            'MarkerEdgeColor','k');
        
        defaults('bigquake') = struct('Tag','mainmap_big_events',...
            'DisplayName',sprintf('Events > M%2.1f',ZG.big_eq_minmag),...
            'Marker','h',...
            'Color','m',...
            'LineWidth',1.5,...
            'MarkerSize',12,...
            'LineStyle','none',...
            'MarkerFaceColor','y',...
            'MarkerEdgeColor','k');
        defaults('bigquake_text')=struct('FontWeight','bold',...
            'Color','k',...
            'FontSize',9,...
            'Clipping','on');
        
    end
    pd=defaults(name);
end