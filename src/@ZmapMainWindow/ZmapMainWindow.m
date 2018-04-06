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
        Features = containers.Map();
        replotting=false
        mdate
        mshape
        colorField='Depth'; % see ValidColorFields for choices 
    end
    
    properties(Constant)
        WinPos=position_in_current_monitor(1200,750)% [50 50 1200 750]; % position of main window
        URPos=[800 380 390 360] %
        LRPos=[800 10 390 360]
        MapPos_S=[70 270 645 450] % width was 670(?)
        MapPos_L=[70 50 645 450+220] %260
        XSPos=[15 10 760 215]
        XSAxPos=[45 40 650 120]
        MapCBPos_S=[70+645+2 270 20 450] % 
        MapCBPos_L=[70+645+2 50 20 450+220]
        FeaturesToPlot = {'borders','coastline',...
            'faults','lakes','plates','rivers','stations','volcanoes'}
        ValidColorFields={'Depth','Date','Magnitude'};
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
            if exist('fig','var') &&... specifed a figure, perhaps.
                    isa(fig,'ZmapMainWindow') &&... actually, specified a ZmapMainWindow object, instead
                    ~isvalid(fig.fig) % but that object's figure isn't valid. (?)
                % recreate the figure (?)
                errordlg('unimplemented');
                return
            end
            
            %if the figure was specified, but wasn't empty, then delete it.
            if exist('fig','var') && ~isempty(fig)
                delete(fig);
            end
            
            % set up figure
            h=msgbox_nobutton('drawing the main window. Please wait'); %#ok<NASGU>
            
            obj.fig=figure('Position',obj.WinPos,'Name','Catalog Name and Date','Units',...
                'pixels','Tag','Zmap Main Window','NumberTitle','off','visible','off');
            % plot all events from catalog as dots before it gets filtered by shapes, etc.
            
            add_menu_divider()
            
            
            ZG=ZmapGlobal.Data;
            if exist('catalog','var')
                obj.rawcatalog=catalog;
            else
                rawview = ZG.Views.primary;
                if ~isempty(rawview)
                    obj.rawcatalog=ZG.Views.primary.Catalog;
                end
            end
            if isempty(obj.rawcatalog)
                errordlg(sprintf('Cannot open the ZmapMainWindow: No catalog is loaded.\nFirst load a catalog into Zmap, then try again.'),'ZMap');
                error('No catalog is loaded');
            end
            obj.daterange=[min(obj.rawcatalog.Date) max(obj.rawcatalog.Date)];
            % initialize from the existing globals
            % obj.Features=ZG.features;
            
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
            
            % obj.Features=ZmapMainWindow.features();
            % MapFeature.foreach_waitbar(obj.Features,'load');
            
            obj.plot_base_events(ZG.features.keys);
            
            obj.prev_states=Stack(5); % remember last 5 catalogs
            obj.pushState();
            
            emm = uimenu(obj.fig,'label','Edit!');
            obj.undohandle=uimenu(emm,'label','Undo',Futures.MenuSelectedFcn,@(s,v)obj.cb_undo(s,v),'Enable','off');
            uimenu(emm,'label','Redraw',Futures.MenuSelectedFcn,@(s,v)obj.cb_redraw(s,v));
            uimenu(emm,'label','xsection',Futures.MenuSelectedFcn,@(s,v)obj.cb_xsection);
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
            
            obj.create_all_menus(true); % plot_base_events(...) must have already been called, ino order to load the features from ZG
            ax=findobj(obj.fig,'Tag','mainmap_ax');
            obj.fig.CurrentAxes=ax;
            legend(ax,'show');
            
            
            
            if isempty(obj.xsections)
                set(findobj('Parent',findobj(obj.fig,'Label','X-sect'),'-not','Tag','CreateXsec'),'Enable','off')
            end
        end
        
        %% METHODS DEFINED IN DIRECTORY
        replot_all(obj,status)
        plot_base_events(obj, featurelist)
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
        do_colorbar(obj,~,~, prevcallback)
        
        % menus
        create_all_menus(obj, force)
        
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
        
        
        function shapeChangedFcn(obj,oldshapecopy,varargin)
            if ~isempty(varargin)
                disp(varargin)
            end
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
            
            % set the colorbar position, if it is visible.
            cb = findobj(obj.fig,'tag','mainmap_colorbar');
            set(cb,'Position',obj.MapCBPos_S);
            
            mytab=uitab(obj.xsgroup, 'Title',mytitle,'ForegroundColor',xsec.color,'DeleteFcn',xsec.DeleteFcn);
            
            % keep tabs alphabetized
            [~,idx]=sort({obj.xsgroup.Children.Title});
            obj.xsgroup.Children=obj.xsgroup.Children(idx);
           
            % add context menu to tab allowing modifications to x-section
            delete(findobj(obj.fig,'Tag',['xsTabContext' mytitle]))
            c=uicontextmenu(obj.fig,'Tag',['xsTabContext' mytitle]);
            uimenu(c,'Label','Info',Futures.MenuSelectedFcn,@(~,~) cb_info);
            uimenu(c,'Label','Change Width',Futures.MenuSelectedFcn,@(~,~)cb_chwidth);
            uimenu(c,'Label','Change Color',Futures.MenuSelectedFcn,@(~,~)cb_chcolor);
            % uimenu(c,'Label','Swap Ends',Futures.MenuSelectedFcn,@(~,~)cb_swapends); doesn't work(?)
            uimenu(c,'Label','Examine This Area',Futures.MenuSelectedFcn,@(~,~)cb_cropToXS);
            uimenu(c,'Separator','on',...
                'Label','Delete',...
                Futures.MenuSelectedFcn,@deltab);
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
                xsec.DeleteFcn=@do_nothing;
                delete(mytab);
                obj.xsec_remove(mytitle);
                obj.replot_all('CatalogUnchanged');
                if isempty(obj.xsections)
                    set(findobj(obj.fig,'Parent',findobj(obj.fig,'Label','X-sect'),'-not','Tag','CreateXsec'),'Enable','off')
                end
            end
        end
        
        
        %% menu items.        %% create menus
        
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
            if isempty(obj.xsections)
                set(findobj(obj.fig,'Parent',findobj(obj.fig,'Label','X-sect'),'-not','Tag','CreateXsec'),'Enable','off')
            end
        end
        
        function xsec_add(obj, key, xsec)
            %XSEC_ADD add/replace cross section
            obj.xsections(key)=xsec;
            % add catalog generated by the cross section (ignoring shape)
            obj.xscats(key)= xsec.project(obj.rawcatalog.subset(obj.mdate));
            % add the information about the catalog used
            obj.xscatinfo(key)=obj.catalog.summary('stats');
            
            if ~isempty(obj.xsections)
                set(findobj('Parent',findobj(obj.fig,'Label','X-sect'),'-not','Tag','CreateXsec'),'Enable','on')
            end
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

