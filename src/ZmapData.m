classdef ZmapData < handle
    % ZmapData contains the values used globally in zmap
    % access the data via its handle, accessible via ZmapGlobal.Data
    %
    % h = ZmapGlobal.Data;          % get pointer to all the global data
    %
    % catalogcopy = h.catalog;      % get a particlar item
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
        zmap_version = '7.0'
        min_matlab_version = '9.2'
        min_matlab_release = '2017a'
        hodi = fileparts(which('zmap')) % zmap home directory
        torad  = pi / 180
        Re = 6378.137 % radius of earth, km
        
        % positional
        fipo = get(groot,'ScreenSize') - [ 0 0 0 150]
        welcome_pos = [80, ZmapData.fipo(4) - 380] % wex wey
        welcome_len = [340 300] % welx, wely
        map_len = [750 650] % winx winy
    end
    
    properties
        % catalogs
        primeCatalog ZmapCatalog = ZmapCatalog('default empty catalog')
        newcat ZmapCatalog = ZmapCatalog('default empty catalog')
        newt2 ZmapCatalog = ZmapCatalog('default empty catalog')
        catalog_working ZmapCatalog = ZmapCatalog('default empty catalog') 
        memorized_catalogs % manually stored via Memorize/Recall
        storedcat % automatically stored catalog, used by synthetic catalogs, etc.
        original ZmapCatalog = ZmapCatalog('default empty catalog')  % used with declustering
        lastCatalogFilename='lastcatalog.mat';
        reopenLatCatalog=true;
        %cluster catalogs 
        newccat ZmapCatalog = ZmapCatalog('default empty catalog')  % apparently main clustered catalog (csubcat, capara, clpickp)
        ttcat ZmapCatalog = ZmapCatalog('default empty catalog')   %  some sort of clustered catalog? selclust
        cluscat ZmapCatalog = ZmapCatalog('default empty catalog')  %  some sort of clustered catalog? selclust
        newclcat ZmapCatalog = ZmapCatalog('default empty catalog')  %   some sort of clustered catalog? selclust
        
        features containers.Map = get_features('h') % map features that can be looked up by name. ex. ZG.features('volcanoes')
        well % well locations
        main
        maepi ZmapCatalog = ZmapCatalog('big events') % large earthquakes, determined by user cutoff
        
        % niceties
        fontsz FontSizeTracker = FontSizeTracker
        
        color_bg (1,3) {mustBeNonnegative, mustBeLessThanOrEqual(color_bg,1)} = [1 1 1] % was [cb1 cb2 cb3] axis background
        color_fg (1,3) {mustBeNonnegative, mustBeLessThanOrEqual(color_fg,1)}  = [.9 .9 .9] % was [c1 c2 c3] figure backgorund
        ms6 (1,1) double {mustBePositive} = 6 % standard markersize %TODO change to a markersize class
        big_eq_minmag (1,1) double = 8 % events of this magnitude or higher are plotted & labeled
        lock_aspect matlab.lang.OnOffSwitchState = matlab.lang.OnOffSwitchState.off
        mainmap_grid matlab.lang.OnOffSwitchState = matlab.lang.OnOffSwitchState.on
        mainmap_plotby (1,:) char = '-none-' % was typele
        mainmap_features = {'borders','coastline',...
            'faults','lakes','plates','rivers',...
            'stations','volcanoes'} % features that will be loaded on the main map
        
        bin_dur duration = days(14) %bin length
        
        % likely to be completely removed stuff
        hold_state logical = false % was ho, contained 'hold' or 'noho'
        hold_state2 logical = false % was ho2, contained 'hold' or 'noho'
        
        % directories
        out_dir (1,:) char = fullfile(ZmapData.hodi,'out') % was hodo
        data_dir (1,:) char = fullfile(ZmapData.hodi,'data') % was hoda
        work_dir (1,:) char = fullfile(ZmapData.hodi,'working')
        
        % scaling params from view_ functions
        minc
        maxc
        
        % unknown other entities
        Rconst % used with the slicers
        ra (1,1) double {mustBeNonnegative} = 5 % default max sphere radius
        ni (1,1) double {mustBeNonnegative} = 100 % default number of nearby events for grid calculations
        compare_window_dur (1,1) duration = years(1.5) % Compare window length (years)
        compare_window_dur_v3 (1,1) duration = years(1.0) % Compare window length, alternate version
        
        % cross section stuff, perhaps
        tresh_km (1,1) double {mustBeNonnegative} = 50 % radius below which blocks zmap's (?) will be plotted
        % xsec_width_km (1,1) double {mustBeNonnegative} = 10 % not entirely sure units are km
        xsec_rotation_deg (1,1) double = 10 % rotation angle for cross sections
        xsec_defaults = defaults.readDefaults('cross_section_defaults');
        
        freeze_colorbar = struct('minval',nan,'maxval',nan,'freeze', false)
        shading_style {mustBeMember(shading_style,{'flat','interp','faceted'})} = 'flat'
        someColor (1,1) char = 'w'
        event_marker char = 'o'
        grid_markersize = get(0,'DefaultLineMarkerSize')
        grid_marker = '+'
        grid_color=[.7 0 0]
       
        % b-value related
        inb1 {mustBeNonnegative, mustBeInteger} = 1 % choice for b-value calculation (?)
        inb2 {mustBeNonnegative, mustBeInteger} = 1 % maximum curvature method(?)
        bo1 (1,1) double = nan % original b-value prior to modifications(?) only used by bvalca3 & bdepth_ratio, but set elsewhere
        bvg=[] % b-value grid
        Grid % grid used for calculations
        gridopt=GridOptions(.5, .5, 1, 'deg', 'off', 'off') % options used for creating a grid
        GridSelector {EventSelectionChoice.mustBeEventSelector} = ...
            struct('useEventsInRadius',true,'radius_km',5,...
            'useNumNearbyEvents',false,'numNearbyEvents',100,...
            'maxRadiusKm',5,'requiredNumEvents',1) % criteria used to select events at a grid point
        %selection_shape {mustBeShape} = ShapeGeneral()
        debug matlab.lang.OnOffSwitchState = matlab.lang.OnOffSwitchState.off % makes special menus visible
        
        Views struct = struct('primary',[],'layers',[]) % catalog views
        
        useParallel logical = false % use parallel pool when available
        MinPointsForParallel = 100000;
        Datastore = DataStore % mapseis DataStore adapter
    end
    
    properties(Dependent)
        wex % welcome window x (welcome_pos(1))
        wey % welcome window y (welcome_pos(2))
        welx % welcome window x length
        wely % welcome window y length
        
        t0b % start time for earthquakes in primary catalog
        teb % end time for earthquakes in primary catalog
    end
    
    methods
        function obj=ZmapData()
            % initialize zmap data
            def_files = defaults.availableDefaults;
            ZDefaults=struct();
            
            for i=1:numel(def_files)
                ZDefaults.(erase(def_files{i},'_defaults')) = defaults.readDefaults(def_files{i});
            end
            
            if isfield(ZDefaults,'general')
                obj.work_dir = fullfile(obj.hodi ,ZDefaults.general.Directories.working);
                obj.out_dir =  fullfile(obj.hodi, ZDefaults.general.Directories.output);
                obj.data_dir =  fullfile(obj.hodi, ZDefaults.general.Directories.data);
                obj.useParallel = ZDefaults.general.ParallelProcessing.Enable;
                obj.MinPointsForParallel = ZDefaults.general.ParallelProcessing.Threshhold;
                obj.debug = ZDefaults.general.DebugMode;
            end
            
            if isfield(ZDefaults,'catalog')
                if ZDefaults.catalog.ReopenLastCatalog
                    catalogFile = fullfile(obj.work_dir,ZDefaults.catalog.LastCatalogFilename);
                    if exist(catalogFile,'file')
                        tmp=load(catalogFile,'catalog');
                    end
                    obj.primeCatalog = tmp.catalog;
                end
            end
            
            if isfield(ZDefaults,'cross_section')
            end
            
            
            if isfield(ZDefaults,'grid')
            end
            
            if isfield(ZDefaults,'mainmap')
            end
            
            if isfield(ZDefaults,'result')
            end
            
            if isfield(ZDefaults,'sampling')
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
        function out=get.wex(obj)
            out=obj.welcome_pos(1);
        end
        
        function out=get.wey(obj)
            out=obj.welcome_pos(2);
        end
        function out=get.welx(obj)
            out=obj.welcome_len(1);
        end
        function out=get.wely(obj)
            out=obj.welcome_len(2);
        end
        
        function disp_catalogs(obj)
            p=properties(obj);
            for n=1:numel(p)
                cl=class(obj.(p{n}));
                switch cl
                    case 'ZmapCatalog'
                        fprintf('%20s : ',p{n})
                        disp(obj.(p{n}));
                end
            end
        end
        
        function disp_views(obj)
            f=fields(obj.Views);
            for n=1:numel(f)
                cl=class(obj.Views.(f{n}));
                switch cl
                    case 'ZmapCatalogView'
                        fprintf('%20s : ',f{n})
                        try
                            blurb(obj.Views.(f{n}));
                        catch
                            disp(' unable to show');
                        end
                end
            end
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

    