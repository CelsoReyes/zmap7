classdef ZmapData < handle
    % ZmapData contains the values used globally in zmap
    % access the data via its handle, accessible via ZmapGlobal.Data
    %
    % h = ZmapGlobal.Data;          % get pointer to all the global data
    %
    % catalogcopy = h.catalog;      % get a particular item
    % h.catalog = modified_catalog; % set the item, with changes visible EVERYWHERE
    % 
    %  several of these variables exist as carryovers from previous version of Zmap
    % 
    %
    % change these for your personal use by editing ini_zmap
    %
    % for details about globally accessible variables, see the ZmapData Reference page 
    %
    % see ini_zmap
    
    properties(Constant)
        zmap_version        = '7.1'
        min_matlab_version  = '9.3' % actually 9.4
        min_matlab_release  = '2018a'
        hodi                = fileparts(which('zmap')) % zmap home directory
        torad               = pi / 180
        Re                  = 6378.137 % semimajor Axis radius of earth, km
        
        % positional
        fipo           = get(groot,'ScreenSize') - [ 0 0 0 150]
        welcome_pos    = [ 80, ZmapData.fipo(4) - 380] % wex wey
        welcome_len    = [340 300] % welx, wely
        map_len        = [750 650] % winx winy
    end
    
    properties(SetAccess = immutable)
        CoordinateSystem CoordinateSystems  = CoordinateSystems.geodetic % may only be changed when ZMAP starts anew
    end
    
    properties
        ref_ellipsoid   referenceEllipsoid = getappdata(groot,'ZmapDefaultReferenceEllipsoid');
        catalogs        CatalogStorage = CatalogStorage({'prime','newcat','newt2',...
            'catalog_working','storedcat','original','catalogA','catalogB'})
        cluster_catalogs CatalogStorage = CatalogStorage({'newccat','ttcat','cluscat','newclcat'})
        
        % catalogs
        % primeCatalog    {mustBeZmapCatalog}     = ZmapCatalog
        newcat          {mustBeZmapCatalog}     = ZmapCatalog
        newt2           {mustBeZmapCatalog}     = ZmapCatalog
        catalog_working {mustBeZmapCatalog}     = ZmapCatalog
        storedcat                       % automatically stored catalog, used by synthetic catalogs, etc.
        original        {mustBeZmapCatalog}     = ZmapCatalog('Name','empty catalog')% used with declustering
        
        % cluster catalogs 
        newccat          {mustBeZmapCatalog}     = ZmapCatalog	% apparently main clustered catalog (csubcat, capara, clpickp)
        ttcat            {mustBeZmapCatalog}     = ZmapCatalog	% some sort of clustered catalog? selclust
        cluscat          {mustBeZmapCatalog}     = ZmapCatalog	% some sort of clustered catalog? selclust
        newclcat         {mustBeZmapCatalog}     = ZmapCatalog	% some sort of clustered catalog? selclust
        
        % map features that can be looked up by name. ex. ZG.features('volcanoes')
        features      containers.Map    = get_features('h')         
        well                                                        % well locations
        main
        maepi            {mustBeZmapCatalog}    = ZmapCatalog('Name','big events') % large earthquakes, determined by user cutoff
        
        % niceties
        fontsz       FontSizeTracker    = FontSizeTracker
        
        color_bg                        = [1.0 1.0 1.0] % was [cb1 cb2 cb3] axis background
        color_fg                        = [0.9 0.9 0.9] % was [c1 c2 c3] figure backgorund
        ms6             (1,1) double {mustBePositive}   = 6 % standard markersize %TODO change to a markersize class
        
        lock_aspect     matlab.lang.OnOffSwitchState    % use fixed aspect ratio
        mainmap_grid    matlab.lang.OnOffSwitchState    % show the grid on the main map
        mainmap_plotby  (1,:) char      = '-none-'      % was typele
        
        % features that will be loaded on the main map
        mainmap_features                = {'borders','coastline','faults','lakes','plates',...
                                           'rivers','stations','volcanoes'} 
        
        bin_dur         duration = days(14) %bin length
        
        % likely to be completely removed stuff
        hold_state      logical         = false % was ho, contained 'hold' or 'noho'
        hold_state2     logical         = false % was ho2, contained 'hold' or 'noho'
        
        % directories
        Directories     struct  % includes 'working', 'output', and 'data' directory locations
        
        % scaling params from view_ functions
        minc
        maxc
        
        % unknown other entities
        Rconst % used with the slicers
        ra                    (1,1) double  {mustBeNonnegative}     = 5 % default max sphere radius
        ni                    (1,1) double  {mustBeNonnegative}     = 100 % default number of nearby events for grid calculations
        compare_window_dur    (1,1) duration                        = years(1.5) % Compare window length (years)
        compare_window_dur_v3 (1,1) duration                        = years(1.0) % Compare window length, alternate version
        
        % cross section stuff, perhaps
        tresh_km            (1,1) double    {mustBeNonnegative}     = 50 % radius below which blocks zmap's (?) will be plotted
        xsec_rotation_deg   (1,1) double                            = 10 % rotation angle for cross sections
        xsec_defaults = defaults.readDefaults('cross_section_defaults');
        
        freeze_colorbar                                             = struct('minval', nan,...
                                                                            'maxval',nan,...
                                                                            'freeze', false)
                                                                        
        shading_style {mustBeMember(shading_style,{'flat','interp','faceted'})} = 'flat'
        
        CrossSectionOpts    struct      %
        CatalogOpts         struct
        MainEventOpts       struct      % contains details used for plotting main events
        BigEventOpts        struct      % contains details used for plotting the "big" events
        UnselectedEventOpts struct      % 
        GridOpts            struct      %
        SamplingOpts        struct      % TODO integrate with GridSelector
        ParallelProcessingOpts struct   % contains  details about parallel processing
        ResultOpts          struct      % options for the results screen
        
        someColor           (1,1) char          = 'w'
        event_marker        char                = 'o'
       
        % b-value related
        McCalcMethod        McMethods           = McMethods.MaxCurvature
        UseAutoEstimate     McAutoEstimate      = McAutoEstimate.auto
        overall_b_value (1,1) double = nan % original b-value prior to modifications(?) only used by bvalca3 & bdepth_ratio, but set elsewhere
        bvg                                     = [] % b-value grid
        
        Grid                                             % grid object, used for calculations
        gridopt                                          % options used for creating a grid 
        GridSelector    EventSelectionParameters         % criteria used to select events at a grid point
        debug           matlab.lang.OnOffSwitchState    = matlab.lang.OnOffSwitchState.off % makes special menus visible
        debugLevel      (1,1) double                    = 0
        
        % Views           struct          = struct('primary',[],'layers',[]) % catalog views
        
        % Datastore                       = DataStore % mapseis DataStore adapter
        
        Interactive     logical     = true
        
        RealTimeMode    logical     = false
        RealTimeAgent               = [];
    end
    
    properties(Dependent)
        
        t0b             % start time for earthquakes in primary catalog
        teb             % end time for earthquakes in primary catalog
        primeCatalog
    end
    
    methods
        function obj=ZmapData()
            % initialize zmap data
            
            def_files = defaults.availableDefaults;
            ZDefaults = struct();
            
            % set defaults
            if isappdata(groot,'ZmapCoordinateSystem')
                obj.CoordinateSystem = getappdata(groot, 'ZmapCoordinateSystem');
            end
            
            if isappdata(groot,'ZmapRealTimeMode')
                obj.RealTimeMode = getappdata(groot, 'ZmapRealTimeMode');
            end
            
            
            
            %% a note about defaults
            % default settings are set in the ZmapSettings.mlapp. R2018a
            % To add a setting, one would:
            %   1. add the widget to the app, 
            %   2. add it to setFromDefaults() and saveDefaults()
            %   3. (possibly) manually add it to the +defaults.[whatever].json file
            %   4. add it here.
  
            for i=1:numel(def_files)
                ZDefaults.(erase(def_files{i},'_defaults')) = defaults.readDefaults(def_files{i});
            end
            
            disp(ZDefaults)
            
            % first always process the "general" defaults
            if isfield(ZDefaults, 'general')
                % directories
                d = ZDefaults.general.Directories;
                dnames = fieldnames(d);
                for i = 1 : numel(dnames)
                    obj.Directories(1).(dnames{i}) = fullfile(obj.hodi ,d.(dnames{i}));
                end
                assert(all(ismember(["working","output","data"], dnames)));
                
                % parallel processing
                obj.ParallelProcessingOpts = ZDefaults.general.ParallelProcessing;
                
                % debug
                obj.debug = ZDefaults.general.DebugMode;
            end
                
            for fn = fieldnames(ZDefaults)'   % each field must be column
                switch string(fn)
                    
                    case "general"
                        % already processed
                        
                    case "catalog"
                        
                        obj.CatalogOpts = ZDefaults.catalog;
                        
                        if obj.CatalogOpts.ReopenLastCatalog
                            catalogFile = fullfile(obj.Directories.working, ZDefaults.catalog.LastCatalogFilename);
                            if exist(catalogFile,'file')
                                tmp = load(catalogFile,'catalog');
                                if isa(tmp.catalog,'ZmapCatalog')
                                    obj.primeCatalog = tmp.catalog;
                                    fprintf('<strong>Loaded previous catalog</strong> from: %s\n',catalogFile);
                                    disp(obj.primeCatalog)
                                else
                                    warning('ZMAP:missingCatalog','default catalog file does not contain a zmap catalog');
                                    % failed to open the last catalog
                                    obj.primeCatalog = ZmapCatalog('Name','empty catalog');
                                end
                            else
                                warning('ZMAP:missingCatalog','could not find the default catalog file %s', catalogFile);
                            end
                        end
                        
                    case "cross_section"
                        
                        obj.CrossSectionOpts = ZDefaults.cross_section;
                        
                    case "grid"
                        
                        obj.GridOpts = ZDefaults.grid;
                        sepProps = obj.GridOpts.SeparationProps;
                        opts = {};
                        if sepProps.FollowMeridians
                            opts = [opts,{'FollowMeridians',true}]; %#ok<AGROW>
                        end
                        dxdydz = [sepProps.Dx, sepProps.Dy, sepProps.Dz];
                        myRefEllipsoid = getappdata(groot,'ZmapDefaultReferenceEllipsoid');
                        myRefEllipsoid.LengthUnit = sepProps.xyunits;
                        
                        obj.gridopt = GridOptions( GridTypes.XYZ, dxdydz, myRefEllipsoid, opts{:});
                        clear opts dxdydz sepProps myRefEllipsoid
                        
                    case "mainmap"
                        
                        obj.MainEventOpts = ZDefaults.mainmap.MainEvents;
                        obj.BigEventOpts = ZDefaults.mainmap.BigEvents;
                        obj.UnselectedEventOpts = ZDefaults.mainmap.UnselectedEvents;
                        
                        obj.lock_aspect = ZDefaults.mainmap.AspectRatioByLatitude;
                        obj.mainmap_grid = ZDefaults.mainmap.ShowLatLonGrid;
                        obj.mainmap_plotby = obj.MainEventOpts.ColorBy;
                        
                    case "result"
                        
                        obj.ResultOpts = ZDefaults.result;
                        
                    case "sampling"
                        
                        obj.SamplingOpts = ZDefaults.sampling;
                        obj.GridSelector = EventSelectionParameters.fromStruct(obj.SamplingOpts);
                end
            end
            
        end
        
        function c = get.primeCatalog(obj)
            try
                c = obj.catalogs.get('prime');
            catch
                c = ZmapCatalog();
            end
        end
        function set.primeCatalog(obj, val)
            obj.catalogs.set('prime', val);
        end
        
        function set.GridSelector(obj,val)
            if isstruct(val)
                obj.GridSelector = EventSelectionParameters(val);
            else
                obj.GridSelector = val;
            end
        end
        
        function out=get.Grid(obj)
            if isempty(obj.Grid)
                obj.Grid=ZmapGrid();
            end
            out=obj.Grid; % grid used for calculations
        end
        function out=get.teb(obj)
            out=max(obj.primeCatalog.Date);
        end
        function out=get.t0b(obj)
            out=min(obj.primeCatalog.Date);
        end

        function disp_catalogs(obj)
            p=properties(obj);
            for n=1:numel(p)
                cl=class(obj.(p{n}));
                switch cl
                    case {'ZmapCatalog'}
                        fprintf('%20s : ',p{n})
                        disp(obj.(p{n}));
                end
            end
        end
       
        function c = generateEmptyCatalog(obj)
            c = ZmapCatalog();
        end
    end
    
end

function out = get_features(level)
    % imports the various features that can be plotted on maps
    out = containers.Map;
    featureDefaults=defaults.readDefaults('mainmap_defaults');
    fp = featureDefaults.FeatureProperties;
    keys=fieldnames(fp);
    % each MapFeature is something that can be overlain on the main map
    %
    
    for i=1:numel(keys)
        key=keys{i};
        fnname= str2func(['load_',key]);
        loadfn = @()fnname(level);
        fp.(key)=rmfield(fp.(key),{'IDLabel','UseMe'}); %add DetailLevel here once it is in settings box
        fp.(key).HitTest=char(matlab.lang.OnOffSwitchState(fp.(key).HitTest));
        out(key)=MapFeature(key,loadfn,[],fp.(key));
    end
    %{
            obj.Features('wells') = MapFeature('wells', @load_wells, [],...
                struct('Tag','mainmap_wells',...
                    'DisplayName','Wells',...
                    'Marker','d',...
                    'LineWidth',1.5,...
                    'MarkerSize',6,...
                    'LineStyle','none',...
                    'MarkerFaceColor','k',...
                    'MarkerEdgeColor','k')...
                );
            obj.Features('minor_faults') = MapFeature('minor_faults', @load_minorfaults, [],...
                struct('Tag','mainmap_faults',...
                    'DisplayName','faults',...
                    'LineWidth',0.2,...
                    'Color','k')...
                );
                
        %}
end

    
