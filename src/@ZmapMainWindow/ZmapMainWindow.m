classdef ZmapMainWindow < handle
    % ZMAPMAINWINDOW controls the main interactive window for ZMAP
    
    properties(SetObservable)
        catalog ZmapCatalog % event catalog
        bigEvents ZmapCatalog
        shape {mustBeShape} = ShapeGeneral.ShapeStash % used to subset catalog by selected area
        Grid {mustBeZmapGrid} = ZmapGlobal.Data.Grid % grid that covers entire catalog area
        daterange datetime % used to subset the catalog with date ranges
        colorField=ZmapGlobal.Data.mainmap_plotby; % see ValidColorFields for choices 
        CrossSections
    end
    
    properties
        rawcatalog ZmapCatalog;
        gridopt % used to define the grid
        evsel {EventSelectionChoice.mustBeEventSelector} = ZmapGlobal.Data.GridSelector % how events are chosen
        fig % figure handle
        map_axes % main map axes handle
        xsgroup;
        maingroup; % maps will be plotted in here
        maintab; % handle to tab where the main map is plotted
        xscats; % ZmapXsectionCatalogs corresponding to each cross section
        xscatinfo %stores details about the last catalog used to get cross section, avoids projecting multiple times.
        prev_states Stack = Stack(10);
        undohandle;
        Features = containers.Map();
        replotting=false % keep from plotting while plotting
        mdate %
        mshape %
        WinPos (4,1) = position_in_current_monitor(Percent(95), Percent(90))% [50 50 1200 750]; % position of main window
        mainEventProps = ZmapGlobal.Data.MainEventOpts; % properties describing the main events
        sharedContextMenus;
    end
    
    properties(Constant)
        TabGroupPositions = struct(...
            'UR', [0.6658    0.5053    0.3250    0.4800],... URPos
            'LR',[0.6658    0.0620    0.3250    0.4400],... [0.6658    0.0120    0.3250    0.4800],...LRPos
            'Main',[0.0125    0.012    0.64    0.9733],...MainGroupPos
            'XS',[0 0  1  0.28]);%[0.01    0.008    0.98    0.28]); % XSPos
        MapPos_S=[0.059    0.33    0.8    0.64] % width was .5375
        MapPos_L=[0.059    0.065    0.8    0.8933]
        XSAxPos=[0.06    0.2    0.86    0.7] % inside XSPos
        MapCBPos_S=[0.5975    0.5600    0.0167    0.4000]
        MapCBPos_L=[0.5975    0.5600    0.0167    0.4000]
        FeaturesToPlot = ZmapGlobal.Data.mainmap_features
        ValidColorFields={'Depth', 'Date', 'Magnitude', '-none-'};
        Type = 'zmapwindow';
    end
    
    properties(Dependent)
        XSectionTitles
    end
    
    properties(Access=private)
        lastXSectionCount = 0
        AllAxes=gobjects(0)
    end
    events
        XsectionEmptied
        XsectionAdded
        XsectionChanged
        XsectionRemoved
        GridChanged
        ShapeChanged
        CatalogChanged
        DateRangeChanged
    end
    
    methods
        function obj=ZmapMainWindow(varargin)
            % ZMAPMAINWINDOW
            % obj = ZMAPMAINWINDOW( CATALOG )
            % obj = ZMAPMAINWINDOW( FIG, ... )
            % obj = ZMAPMAINWINDOW( ) 
            
            fig = gobjects(0);
            in_catalog = [];
            
            switch nargin
                case 0
                    % do nothing
                case 1
                    % either CATALOG or FIG is provided
                    try
                        switch varargin{1}.Type
                            case 'zmapcatalog'
                                in_catalog = varargin{1};
                            case 'figure'
                                fig = varargin{1};
                            otherwise
                                error('unexpected argument to ZmapMainWindow: %s', varargin{1}.Type);
                        end
                    catch ME
                        warning(ME)
                        error('unexpected argument to ZmapMainWindow: %s', class(varargin{1}));
                    end
                case 2
                    % provided a FIGURE and a CATALOG
                    if isempty(varargin{1})
                        % do nothing. it was a place holder
                    elseif isgraphics(varargin{1}) && isvalid(varargin{1}) && varargin{1}.Type == "figure"
                        fig = varargin{1};
                    else
                        error('Usage: ZmapMainWindow(FIG, catalog)\n%s', '  First argument was not a figure');
                    end
                    
                    if isa(varargin{2}, 'ZmapCatalog')
                        in_catalog = varargin{2};
                    else
                        error('Usage: ZmapMainWindow(fig, CATALOG).\nSecond argument was not a catalog');
                    end
            end
            
            
            %if the figure was specified, but wasn't empty, then clear it out.
            if isvalid(fig)
                isMainMapWindow=isa(fig.UserData, 'ZmapMainWindow');
                resultplot_exists = isMainMapWindow && numel(fig.UserData.maingroup.Children)>1;
                shape_exists =  isMainMapWindow && ~isempty(fig.UserData.shape);
                grid_exists = isMainMapWindow && ~isempty(fig.UserData.Grid);
                catalog_exists = isMainMapWindow && isempty(fig.UserData.rawcatalog);
                
                   
                if resultplot_exists
                    an=questdlg(sprintf('Replace existing Map Windows?\nWarning: This will delete any results tabs'),...
                        'Window exists', 'Replace Existing', 'Create Another', 'cancel', 'cancel');
                else
                    an='Replace Existing';
                end
                switch an
                    case 'Replace Existing'
                        obj.fig=fig;
                        clf(fig);
                        fig.UserData=[];
                    case 'Create a new figure'
                        do_nothing();
                    case 'Nevermind'
                        return;
                end
            end
            
            %% prepare the catalog
            % if no catalog is provided, then use the default primary catalog.
            ZG=ZmapGlobal.Data;
            if ~isa(in_catalog, 'ZmapCatalog')
                rawview = ZG.Views.primary;
                if ~isempty(rawview)
                    obj.rawcatalog=ZG.Views.primary.Catalog;
                end
            else
                obj.rawcatalog=in_catalog;
            end
            
            % TODO: make this handle a default shape once again
            
            %obj.shape.subscribe('ShapeChanged', @obj.shapeChangedFcn);
            
            if isempty(obj.rawcatalog)
                obj.daterange = [NaT NaT];
                obj.catalog = ZmapCatalog();
                obj.mdate = [];
                obj.mshape=[];
            else
                obj.daterange=[min(obj.rawcatalog.Date) max(obj.rawcatalog.Date)];
                [obj.mdate, obj.mshape]=obj.filter_catalog();
            end
            % retrieve default values from ZmapGlobal.
            [obj.mdate, obj.mshape]=obj.filter_catalog();
            obj.Grid=ZG.Grid;
            obj.gridopt= ZG.gridopt;
            obj.evsel = ZG.GridSelector;
            obj.xscats=containers.Map();
            obj.xscatinfo=containers.Map();
            if isempty(obj.rawcatalog)
                obj.bigEvents=obj.rawcatalog;
            else
                obj.bigEvents=obj.rawcatalog.subset(obj.rawcatalog.Magnitude >= ZG.CatalogOpts.BigEvents.MinMag);
            end
            %% prepare the figure
            obj.prepareMainFigure();
            
            
            % "listeners" are functions called when certain values are changed.
            obj.attach_listeners();
            
            %% prepare the UNDO
            
            obj.prev_states=Stack(5); % remember last 5 catalogs
            obj.pushState();
        end
        
        function xst = get.XSectionTitles(obj)
            if isempty(obj.CrossSections)
                xst={};
            else
                xst =  {obj.CrossSections.name};
            end
        end
            
        function attach_listeners(obj)
            attach_catalog_listeners(obj);
            
            % attach cross-section listeners
            addlistener(obj, 'XsectionEmptied',@(~,~)obj.deactivateXsections);
            addlistener(obj, 'XsectionAdded',  @(~,~)obj.activateXsections);
            addlistener(obj, 'XsectionAdded', @(~,~)clear_empty_legend_entries(obj.fig));
            
            addlistener(obj, 'XsectionChanged',@obj.replot_all);
            addlistener(obj, 'XsectionRemoved' ,@obj.replot_all);
            addlistener(obj, 'XsectionEmptied',@obj.replot_all);
            
            % other listeners
            addlistener(obj, 'CatalogChanged'  ,      @obj.replot_all);
            addlistener(obj, 'daterange', 'PostSet', @obj.replot_all);
            addlistener(obj, 'catalog',   'PostSet', @obj.attach_catalog_listeners);
            addlistener(obj, 'shape',     'PostSet', @obj.replot_all);
            addlistener(obj, 'bigEvents',     'PostSet', @obj.replot_all);
            % addlistener(obj, 'Grid',      'PostSet', @(~,~)disp('**Grid Changed'));
            addlistener(obj, 'CrossSections', 'PostSet',@obj.notifyXsectionChange);
        end
        
        function attach_catalog_listeners(obj,~,~)
            % reapply listeners to this specific catalog
            addlistener(obj.catalog, 'Name', 'PostSet',@(~,~)obj.set_figure_name);
            addlistener(obj.catalog, 'ValueChange',@(~,~)notify('CatalogChanged'));
        end
            
        
        %% functions called by individual display panes to "hook into" the main window
        function getCatalogUpdates(obj, callbackfn)
            obj.addlistener('catalog', 'PostSet', callbackfn);
        end
        
        function getXSectionUpdates(obj, callbackfn)
            obj.addlistener('CrossSections', 'PostSet', callbackfn);
        end
        
        function notifyXsectionChange(obj,~,~) 
            % NOTIFYXSECTIONCHANGE
            % obj.NOTIFYXSECTIONCHANGE(prop, evt)
            lastCount = obj.lastXSectionCount;
            thisCount = numel(obj.CrossSections);
            obj.lastXSectionCount= thisCount;
            if thisCount == 0
                notify(obj, 'XsectionEmptied');
            elseif thisCount > lastCount
                notify(obj, 'XsectionAdded');
            elseif thisCount < lastCount
                notify(obj, 'XsectionRemoved');
            else
                disp('Registered a simple cross-section change');
                notify(obj, 'XsectionChanged');
            end
        end
        
    function set_my_shape(obj, sh)
        % call this whenever shape is replaced, otherwise catalog will not adjust to it
        if ~isempty(sh)
            obj.shape=sh;
            subscribe(obj.shape, 'ShapeChanged',@obj.replot_all);
            obj.shape.plot(obj.map_axes);
            obj.replot_all('ShapeChanged');
        end
    end
        
        function getBigEventUpdates(obj, callbackfn)
            % obj.addlistener('maepi', 'PostSet', callbackfn);
        end
        
        %% METHODS DEFINED IN DIRECTORY
        %
        %
        %
        %
        
        replot_all(obj, metaProp, eventData)
        plot_base_events(obj, container, featurelist)
        plotmainmap(obj)
        c=context_menus(obj, tag, createmode, varargin) % manage context menus used in figure
        plothist(obj, name, values, tabgrouptag)
        fmdplot(obj, tabgrouptag)
        
        cummomentplot(obj, tabgrouptag)
        time_vs_something_plot(obj, name, whichplotter, tabgrouptag)
        cumplot(obj, tabgrouptag)
        
        % push and pop state
        pushState(obj)
        popState(obj)
        catalog_menu(obj, force)
        [mdate, mshape, mall]=filter_catalog(obj)
        %do_colorbar(obj,~,~, prevcallback)
        
        % menus
        create_all_menus(obj, force)
        
        %
        %
        %
        %
        %%
        
        function zp = map_zap(obj)
            % MAP_ZAP create a ZmapAnalysisPkg for the main window
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
                [obj.gridopt, obj.Grid] = GridOptions.fromDialog();
            else
                fprintf('Using existing grid:\n');
            end
            zp = ZmapAnalysisPkg( [], obj.catalog, obj.evsel, obj.Grid, obj.shape);
        end
        
        function zp = xsec_zap(obj, xsTitle)
            % XSEC_ZAP create a ZmapAnalysisPkg from a cross section
            % the ZmapAnalysisPkg can be used as inputs to the various processing routines
            %
            % zp = obj.XSEC_ZAP() create a Z.A.P. but use the currently active cross section as a guide
            % zp = obj.XSEC_ZAP(xsTitle)
            %
            % see also ZMAPANALYSISPKG
            
            if isempty(obj.CrossSections)
                errordlg('There is no cross section to analyze. Aborting operation.');
                zp=[];
                return
            end
            
            ZG=ZmapGlobal.Data;
            
            z_min = floor(min([0 min(obj.catalog.Depth)]));
            z_max = round(max(obj.catalog.Depth) + 4.9999 , -1);
            
            zdlg = ZmapDialog([]);
            if ~exist('xsTitle', 'var')
                xsTitle=obj.xsgroup.SelectedTab.Title;
            else
                if ~any(strcmp(obj.XSectionTitles, xsTitle))
                    warndlg(sprintf('The requested cross section [%s] does not exist. Using selected tab.', xsTitle));
                    xsTitle=obj.xsgroup.SelectedTab.Title;
                end
            end
            xsIndex = find(strcmp(obj.XSectionTitles, xsTitle));
            zdlg.AddBasicPopup('xsTitle', 'Cross Section:', obj.XSectionTitles, xsIndex, 'Choose the cross section');
            zdlg.AddEventSelectionParameters('evsel', ZG.ni, ZG.ra, 1);
            zdlg.AddBasicEdit('x_km', 'Horiz Spacing [km]', 5, 'Distance along strike, in kilometers');
            zdlg.AddBasicEdit('z_min', 'min Z [km]', z_min, 'Shallowest grid point');
            zdlg.AddBasicEdit('z_max', 'max Z [km]', z_max, 'Deepest grid point, in kilometers');
            zdlg.AddBasicEdit('z_delta', 'number of layers', round(z_max-z_min)+1, 'Number of horizontal layers ');
            [zans, okPressed] = zdlg.Create('Cross Section Sample parameters');
            if ~okPressed
                zp = [];
                return
            end
            
            zs_km = linspace(zans.z_min, zans.z_max, zans.z_delta);
            idx=strcmp(xsTitle, obj.XSectionTitles);
            gr = obj.CrossSections(idx).getGrid(zans.x_km, zs_km);
            zp = ZmapAnalysisPkg( [], obj.xscats(xsTitle), zans.evsel, gr, obj.shape);
            
        end
        
        function cb_timeplot(obj, src, evt)
            disp('oh')
            CumTimePlot(@()obj.catalog);
        end
        
        function cb_starthere(obj, ax)
            disp(ax)
            [x,~]=click_to_datetime(ax);
            obj.pushState();
            obj.daterange(1)=x;
        end
        
        function cb_endhere(obj, ax)
            [x,~]=click_to_datetime(ax);
            obj.pushState();
            obj.daterange(2)=x;
        end
        
        function cb_trim_to_largest(obj,~,~)
            biggests = obj.catalog.Magnitude == max(obj.catalog.Magnitude);
            idx=find(biggests,1, 'first');
            obj.pushState();
            obj.daterange(1)=obj.catalog.Date(idx);
        end
             
        function shapeChangedFcn(obj, varargin)
            %obj.replot_all([], varargin{1});
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
                do_stash = ~strcmp(item{1}.summary('stats'), obj.catalog.summary('stats')) ||...
                    ~isequal(obj.shape, item{2});
            end
            if do_stash
                disp('pushing')
                obj.pushState();
            end
            obj.replot_all();
            watchoff
        end
        
        function cb_xsection(obj,~,~)
            import callbacks.copytab
            % main map axes, where the cross section outline will be plotted
            axm=obj.map_axes;
            obj.fig.CurrentAxes=axm;
            try
                xsec = XSection.initialize_with_mouse(axm, 20);
            catch ME
                warning(ME.message)
                return
                % do not set segment
            end
            if isempty(xsec), return, end
            mytitle=xsec.name;
            
            
            mytab=findobj(obj.fig, 'Title', mytitle, '-and', 'Type', 'uitab');
            if ~isempty(mytab)
                delete(mytab);
            end
            
            mytab=uitab(obj.xsgroup, 'Title', mytitle, 'ForegroundColor', xsec.color, 'DeleteFcn', xsec.DeleteFcn);
            
            % keep tabs alphabetized
            [~, idx]=sort({obj.xsgroup.Children.Title});
            obj.xsgroup.Children=obj.xsgroup.Children(idx);
           
            % add context menu to tab allowing modifications to x-section
            delete(findobj(obj.fig, 'Tag',['xsTabContext' mytitle]))
            c=uicontextmenu(obj.fig, 'Tag',['xsTabContext' mytitle]);
            uimenu(c, 'Label', 'Copy Contents to new figure (static)', 'Callback',@copytab);
            uimenu(c, 'Label', 'Info', 'Separator', 'on', CallbackFld,@obj.cb_info);
            uimenu(c, 'Label', 'Change Width', CallbackFld,@obj.cb_chwidth);
            uimenu(c, 'Label', 'Change Color', CallbackFld,@obj.cb_chcolor);
            uimenu(c, 'Label', 'Examine This Area', CallbackFld,{@obj.cb_cropToXS, xsec});
            uimenu(c, 'Separator', 'on',...
                'Label', 'Delete',...
                CallbackFld,{@obj.cb_deltab, xsec});
            mytab.UIContextMenu=c;
            
            
            ax=axes(mytab, 'Units', 'normalized', 'Position', obj.XSAxPos, 'YDir', 'reverse');
            obj.xsec_add(mytitle, xsec);
            xsec.plot_events_along_strike(ax, obj.xscats(mytitle));
            ax.Title=[];
            
            
            % make this the active tab
            mytab.Parent.SelectedTab=mytab;
            
        end
        
        function cb_cropToXS(obj,~,~, xsec)
            sh=ShapePolygon('polygon',[xsec.polylons(:), xsec.polylats(:)]);
            set_my_shape(obj, sh);
            %obj.replot_all();
        end
            
        function cb_deltab(obj, ~,~, xsec)
            prevPtr = obj.fig.Pointer;
            obj.fig.Pointer='watch';
            mytitle = get(gco, 'Title');
            try
                
                if get(gco, 'Type') == "uitab" && strcmp(get(gco, 'Title'), xsec.name)
                    delete(gco);
                else
                    error('Supposed to delete tab, but gco is not what is expected');
                end
                % drawnow
                delete(findobj(obj.fig, 'Type', 'uicontextmenu', '-and', '-regexp', 'Tag',['.sel_ctxt .*' xsec.name '$']))
                
                obj.xsec_remove(mytitle);
                if isempty(obj.CrossSections)
                    set(findobj(obj.fig, 'Parent', findobj(obj.fig, 'Label', 'X-sect'), '-not', 'Tag', 'CreateXsec'), 'Enable', 'off');
                    % a notification will be sent notifying that we have no more
                else
                    notify(obj, 'XsectionRemoved');
                end
                
                obj.fig.Pointer=prevPtr;
            catch ME
                obj.fig.Pointer=prevPtr;
                rethrow(ME);
            end
        end
            
        function cb_chwidth(obj,~,~)
            % change width of a cross-section
            secTitle=get(gco, 'Title');
            idx = strcmp(secTitle, obj.XSectionTitles);
            prompt={'Enter the New Width:'};
            name='Cross Section Width';
            numlines=1;
            defaultanswer={num2str(obj.CrossSections(idx).width_km)};
            answer=inputdlg(prompt, name, numlines, defaultanswer);
            if ~isempty(answer)
                obj.CrossSections(idx).change_width(str2double(answer));
            end
            ax= findobj(gco, 'Type', 'axes', '-and', '-regexp', 'Tag', 'Xsection strikeplot.*');
            ax.UserData.cep.catalogFcn=@()obj.xscats(obj.CrossSections(idx).name);
            ax.UserData.cep.update();
            ax.Title=[];
            obj.notify('XsectionChanged')
        end
        
        function cb_chcolor(obj,~,~)
            secTitle=get(gco, 'Title');
            idx = strcmp(secTitle, obj.XSectionTitles);
            obj.CrossSections(idx).change_color([], obj.fig);
            set(gco, 'ForegroundColor', obj.CrossSections(idx).color); %was mytab
        end

        function cb_info(obj,~,~)
            secTitle=get(gco, 'Title');
            idx = strcmp(secTitle, obj.XSectionTitles);
            s=sprintf('%s containing:\n\n%s', obj.CrossSections(idx).info(),...
                obj.xscats(secTitle).summary('stats'));
            msgbox(s, secTitle);
        end
        
        %% menu items.        %% create menus
        
        function set_3d_view(obj, src,~)
            watchon
            drawnow nocallbacks;
            axm=obj.map_axes;
            switch src.Label
                case '3-D view'
                    hold(axm, 'on');
                    view(axm,3);
                    grid(axm, 'on');
                    zlim(axm, 'auto');
                    %axis(ax, 'tight');
                    zlabel(axm, 'Depth [km]', 'UserData', field_unit.Depth);
                    axm.ZDir='reverse';
                    rotate3d(axm, 'on'); %activate rotation tool
                    hold(axm, 'off');
                    src.Label = '2-D view';
                otherwise
                    view(axm,2);
                    grid(axm, 'on');
                    zlim(axm, 'auto');
                    rotate3d(axm, 'off'); %activate rotation tool
                    src.Label = '3-D view';
            end
            watchoff
            drawnow;
        end
        
        function set_event_selection(obj, val)
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
        
        function copy_mainmap_into_container(obj, container)
            c=copyobj(obj.map_axes, container);
            c.Tag=[c.Tag '_' container.Tag];
            t=findobj(c, 'Type', 'line', '-or', 'Type', 'scatter', '-not', 'Tag', 'grid_Grid');
            set(t, 'PickableParts', 'none'); % mute the values
        end
    end % METHODS
    methods(Access=protected) % HELPER METHODS
        
        function prepareMainFigure(obj)
            % set up figure
            h=msgbox_nobutton('drawing the main window. Please wait'); %#ok<NASGU>
            if ~isempty(obj.fig) && isgraphics(obj.fig) && isvalid(obj.fig)
                set(obj.fig, 'Units','pixels','Position', obj.WinPos, 'Name', 'Catalog Name and Date',...
                    'Tag', 'Zmap Main Window', 'NumberTitle', 'off', 'visible', 'off');
                obj.fig.Units='Normalized';
            else
                obj.fig=figure('Position', obj.WinPos, 'Name', 'Catalog Name and Date', 'Units',...
                    'Normalized', 'Tag', 'Zmap Main Window', 'NumberTitle', 'off', 'visible', 'off');
            end
            % plot all events from catalog as dots before it gets filtered by shapes, etc.
            obj.fig.Pointer='watch';
            
            % add the time stamp
            s=sprintf('Created by: ZMAP %s , %s', ZmapData.zmap_version, char(datetime));
            uicontrol(obj.fig, 'Style', 'text', 'Units', 'normalized', 'Position',[0.67 0.0 0.3 0.05],...
                'String', s, 'FontWeight', 'bold', 'Tag', 'zmap_watermark')
            
            % make sure that empty legend entries automatically disappear when the menu is called up
             set(findall(obj.fig, 'Type', 'uitoggletool', '-and', 'Tag', 'Annotation.InsertLegend'), 'ClickedCallback',...
                char("insertmenufcn(gcbf, 'Legend');clear_empty_legend_entries(gcf);"));
            
            
            c=uicontextmenu(obj.fig, 'tag', 'yscale contextmenu');
            uimenu(c, 'Label', 'Use Log Scale', CallbackFld,{@logtoggle, 'Y'});
            obj.sharedContextMenus.LogLinearYScale = c;
            
            c=uicontextmenu(obj.fig, 'tag', 'xscale contextmenu');
            uimenu(c, 'Label', 'Use Log Scale', CallbackFld,{@logtoggle, 'X'});
            obj.sharedContextMenus.LogLinearXScale = c;
            
            add_menu_divider(obj.fig,'mainmap_menu_divider')
            
            
            obj.fig.Name=sprintf('%s [%s - %s]', obj.catalog.Name , char(min(obj.catalog.Date)),...
                char(max(obj.catalog.Date)));
            
            TabLocation = 'top'; % 'top', 'bottom', 'left', 'right'
            
            obj.maingroup=uitabgroup(obj.fig, 'Units', 'normalized', 'Position', obj.TabGroupPositions.Main,...
                'Visible', 'on',...
                'SelectionChangedFcn',@cb_mainMapSelectionChanged,...
                'TabLocation', TabLocation, 'Tag', 'main plots');
            obj.maintab = findOrCreateTab(obj.fig, obj.maingroup, obj.catalog.Name);
            obj.maintab.Tag = 'mainmap_tab';
            
            obj.plot_base_events(obj.maintab, obj.FeaturesToPlot);
            
            if isempty(obj.Grid)
                set(groot, 'CurrentFigure', obj.fig); % following line uses current figure to assign properties
                obj.Grid=ZmapGrid('Grid', obj.gridopt, 'shape', obj.shape);
            end
            
            
            
            uitabgroup(obj.fig, 'Units', 'normalized', 'Position', obj.TabGroupPositions.UR,...
                'Visible', 'off', 'SelectionChangedFcn',@cb_selectionChanged,...
                'TabLocation', TabLocation, 'Tag', 'UR plots');
            uitabgroup(obj.fig, 'Units', 'normalized', 'Position', obj.TabGroupPositions.LR,...
                'Visible', 'off', 'SelectionChangedFcn',@cb_selectionChanged,...
                'TabLocation', TabLocation, 'Tag', 'LR plots');
            
            obj.xsgroup=uitabgroup(obj.maintab, 'Units', 'normalized',...
                'Position', obj.TabGroupPositions.XS,...
                'TabLocation', TabLocation, 'Tag', 'xsections',...
                'SelectionChangedFcn',@cb_selectionChanged, 'Visible', 'off');
            
            obj.replot_all();
            obj.fig.Visible='on';
            set(findobj(obj.fig, 'Type', 'uitabgroup', '-and', 'Tag', 'LR plots'), 'Visible', 'on');
            set(findobj(obj.fig, 'Type', 'uitabgroup', '-and', 'Tag', 'UR plots'), 'Visible', 'on');
            
            drawnow nocallbacks
            
            obj.create_all_menus(true); % plot_base_events(...) must have already been called, in order to load the features from ZG
            obj.fig.CurrentAxes=obj.map_axes;
            legend(obj.map_axes, 'show');
            clear_empty_legend_entries(obj.fig);
            
            
            if isempty(obj.CrossSections)
                set(findobj('Parent', findobj(obj.fig, 'Label', 'X-sect'), '-not', 'Tag', 'CreateXsec'), 'Enable', 'off')
            end
            obj.fig.UserData=obj; % hopefully not creating a problem with the space-time-continuum.
            
            if isempty(obj.rawcatalog)
                obj.disable_non_load_menus();
            end
            obj.fig.Pointer='arrow';
        end
        
        function disable_non_load_menus( obj)
            % make Get/Load Catalog only valid option from catalog menus
            % there is no catalog in the system, so there is nothing to recall, and nothing to filter
            % therefore, force the user to the right menu choice
            txt = 'To load a catalog, choose GET/LOAD CATALOG from the  CATALOG Menu';
            hdlg=helpdlg(txt, 'No Active Catalogs');
            hdlg.Units='normalized';
            hdlg.Position([1 2]) = obj.fig.Position([1 2])+ [0.3 0.6].* obj.fig.Position([3 4]);
            obj.fig.ToolBar = 'none';
            h=findobj(obj.fig, 'Type', 'uimenu', '-depth',1, '-not', 'Label', 'Catalog', '-not', 'Label', 'Help');
            set(h, 'Enable', 'off');
            h=findobj(obj.fig, 'Type', 'uimenu', '-depth',1, 'Label', 'Catalog');
            % disable all the other items at this level
            set(findobj(h.Children, 'flat', '-not', 'Label', 'Get/Load Catalog'), 'Enable', 'off');
            h=get(findall(obj.fig, 'Label', 'Get/Load Catalog'), 'Children');
            if iscell(h)
                for i=1:numel(h)
                    set(h{i}(~startsWith(get(h{i}, 'Label'), 'from ')), 'Enable', 'off');
                end
            else
                set(h(~startsWith(get(h, 'Label'), 'from ')), 'Enable', 'off');
            end
        end
            
            
        
        %% CROSS SECTION HELPERS
        %
        %
        
        function xsec_remove(obj, key)
            % XSEC_REMOVE completely removes cross section from object
            idx = strcmp(key, obj.XSectionTitles);
            obj.CrossSections(idx)=[];
            obj.xscats.remove(key);
            obj.xscatinfo.remove(key);
        end
        
        function xsec_add(obj, key, xsec)
            %XSEC_ADD add/replace cross section
            isUpdating=ismember(key, obj.XSectionTitles);
            
            % add catalog generated by the cross section (ignoring shape)
            obj.xscats(key)= xsec.project(obj.rawcatalog.subset(obj.mdate));
            % add the information about the catalog used
            obj.xscatinfo(key)=obj.catalog.summary('stats');
            
            if isempty(obj.CrossSections)
                obj.CrossSections=xsec;
            elseif ~isUpdating
                obj.CrossSections(end+1)=xsec;
            end
            
        end
        
        function activateXsections(obj)
            disp('activationg Xsections')
            set(findobj(obj.fig, 'Parent', findobj(obj.fig, 'Label', 'X-sect'), '-not', 'Tag', 'CreateXsec'), 'Enable', 'on');
            
            obj.xsgroup.Visible = 'on';
            set(obj.map_axes, 'Position', obj.MapPos_S);
            
            % modify the colorbar position, if it is visible.
            cb = findobj(obj.fig, 'tag', 'mainmap_colorbar');
            set(cb, 'Position', obj.MapCBPos_S);
            obj.notifyXsectionChange();
            
        end
        
        function deactivateXsections(obj)
            set(findobj(obj.fig, 'Parent', findobj(obj.fig, 'Label', 'X-sect'), '-not', 'Tag', 'CreateXsec'), 'Enable', 'off');
            obj.xsgroup.Visible='off';
            set(obj.map_axes, 'Position', obj.MapPos_L);
            
            % reset the colorbar position, if it is visible.
            cb = findobj(obj.fig, 'tag', 'mainmap_colorbar');
            set(cb, 'Position', obj.MapCBPos_L);
        end
            
        function plot_xsections(obj, plotfn, tagBase)
            % PLOT_XSECTIONS 
            %  obj.plot_xsections(plotfn, tagBase)
            % plotfn is a function like: [@(xs, xcat)plot(...)] that does plotting and returns a handle
            for j=1:numel(obj.CrossSections)
                set(gca, 'NextPlot', 'add')
                tit=obj.CrossSections(j).name;
                h=plotfn(obj.CrossSections(j), obj.xscats(tit) );
                h.Tag=[tagBase, ' ' , tit];
            end
        end
        
        function set_figure_name(obj)
            obj.fig.Name=sprintf('%s [%s - %s]', obj.catalog.Name , char(min(obj.catalog.Date)),...
                char(max(obj.catalog.Date)));
            obj.maintab.Title=obj.catalog.Name;
            drawnow nocallbacks;
        end
        
    end
end % CLASSDEF

%% helper functions
function cb_selectionChanged(~,~)
    disp('cb_selectionChanged. no action taken, though');
    %alltabs = src.Children;
    %isselected=alltabs == src.SelectedTab;
    %set(alltabs(isselected).Children, 'Visible', 'on');
    %subax=findobj(alltabs(~isselected), 'Type', 'axes')
    %set(subax, 'visible', 'off');
end
function cb_mainMapSelectionChanged(~,~)
    disp('cb_mainMapSelectionChanged. no action taken');
end

function s=CallbackFld()
    s=Futures.MenuSelectedFcn;
end