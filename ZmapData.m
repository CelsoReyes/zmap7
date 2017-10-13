classdef ZmapData < handle
    % ZmapData contains the values used globally in zmap
    % access the data via its handle, accessible via ZmapGlobal.Data
    %
    % h = ZmapGlobal.Data;          % get pointer to all the global data
    %
    % catalogcopy = h.catalog;      % get a particlar item
    % h.catalog = modified_catalog; % set the item, changes visible EVERYWHERE
    %
    properties(Constant)
        zmap_version = '7.0'
        min_matlab_version = '9.2';
        min_matlab_release = '2017a';
        hodi = fileparts(which('zmap')); % zmap home directory
        torad  = pi / 180;
        Re = 6378.137; % radius of earth, km
        
        % positional
        fipo = get(groot,'ScreenSize') - [ 0 0 0 150];
        welcome_pos = [80, ZmapData.fipo(4) - 380]; %wex wey
        welcome_len = [340 300]; %welx, wely
        map_len = [750 650]; % winx winy
    end
    
    properties
        % catalogs
        primeCatalog=ZmapCatalog('default empty catalog'); %
        newcat=ZmapCatalog('default empty catalog'); 
        newt2=ZmapCatalog('default empty catalog'); 
        catalog_working=ZmapCatalog('default empty catalog'); 
        memorized_catalogs % manually stored via Memorize/Recall
        storedcat % automatically stored catalog, used by synthetic catalogs, etc.
        original=ZmapCatalog('default empty catalog');  % used with declustering
        
        %cluster catalogs 
        newccat=ZmapCatalog('default empty catalog');  % apparently main clustered catalog (csubcat, capara, clpickp)
        ttcat=ZmapCatalog('default empty catalog');   %  some sort of clustered catalog? selclust
        cluscat=ZmapCatalog('default empty catalog');  %  some sort of clustered catalog? selclust
        newclcat=ZmapCatalog('default empty catalog');  %   some sort of clustered catalog? selclust
        
        features = get_features('h'); % map features that can be looked up by name. ex. ZG.features('volcanoes')
        well % well locations
        main
        maepi=ZmapCatalog('big events'); % large earthquakes, determined by user cutoff
        
        % divisions
        divisions_depth
        divisions_time
        divisions_magnitude
        
        % niceties
        fontsz = FontSizeTracker;
        depth_divisions % plot each division with a different color/symbol
        magnitude_divisions % plot each division with a different color/symbol
        date_divisions % plot each division with a different color/symbol
        color_bg = [1 1 1] % was [cb1 cb2 cb3] axis background
        color_fg = [.9 .9 .9]% was [c1 c2 c3] figure backgorund
        ms6 = 6 % standard markersize %TODO change to a markersize class
        big_eq_minmag = 8  % events of this magnitude or higher are plotted & labeled
        lock_aspect = 'off';
        mainmap_grid = 'on';
        mainmap_plotby = 'depth'; % was typele
        
        bin_dur = days(14); %bin length
        
        % likely to be completely removed stuff
        hold_state = false % was ho, contained 'hold' or 'noho'
        hold_state2 = false % was ho2, contained 'hold' or 'noho'
        
        % directories
        out_dir=fullfile(ZmapData.hodi,'out') % was hodo
        data_dir=fullfile(ZmapData.hodi,'data') % was hoda
        work_dir=fullfile(ZmapData.hodi,'working');
        
        % scaling params from view_ functions
        minc
        maxc
        
        %unknown other entities
        Rconst %used with the slicers
        ra=5% default max sphere radius
        ni=100 %default number of nearby events for grid calculations
        compare_window_dur=years(1.5) % Compare window length (years)
        compare_window_dur_v3=years(1.0) % Compare window length, alternate version
        
        % cross section stuff, perhaps
        tresh_km = 50 % radius below which blocks zmap's (?) will be plotted
        xsec_width_km = 10 % not entirely sure units are km
        xsec_rotation_deg = 10 % rotation angle for cross sections
        
        freeze_colorbar = struct('minval',nan,'maxval',nan,'freeze', false);
        shading_style = 'flat';
        someColor='w';
       
        % b-value related
        inb1=1; % choice for b-value calculation (?)
        inb2=1; % maximum curvature method(?)
        bo1=nan; % original b-value prior to modifications(?) only used by bvalca3 & bdepth_ratio, but set elsewhere
        bvg=[]; % b-value grid
        Grid; % grid used for calculations
        gridopt=struct('dx',.5,'dx_units','deg',...
            'dy',.5,'dy_units','deg',...
            'dz',1,'dz_units','km',...
            'GridEntireArea',false,...
            'SaveGrid',false,'LoadGrid',false,'CreateGrid',true); % options used for creating a grid
        GridSelector;% criteria used to select events at a grid point
        selection_shape=ShapeSelection();
        debug='on'; % makes special menus visible
        
        Views=struct('primary',[],'selected',[],'layers',[]); % catalog views
    end
    properties(Dependent)
        wex %welcome window x (welcome_pos(1))
        wey %welcome window y (welcome_pos(2))
        welx %welcome window x length
        wely %welcome window y length
        
        t0b % start time for earthquakes in primary catalog
        teb % end time for earthquakes in primary catalog
    end
    methods
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
        function set.bin_dur(obj,val)
            if isa(val,'duration')
                obj.bin_dur=val;
            elseif isnumeric(val)
                warning('expected bin_dur to be a duration. converting and assuming it is days');
                obj.bin_dur=days(val);
            else
                error('only can convert durations and numerics to bin_dur');
            end
        end
    end
end

function out = get_features(level)
    % imports the various features that can be plotted on maps
    out = containers.Map;
    
    
    % each MapFeature is something that can be overlain on the main map
    %
    out('coastline')= MapFeature('coast', @()load_coast(level), [],...
        struct('Tag','mainmap_coastline',...
        'DisplayName', 'Coastline',...
        'HitTest','off','PickableParts','none',...
        'LineWidth',1.5,...
        'Color',[0.1 0.1 0.1])...
        );
    out('borders')= MapFeature('borders', @()load_borders(level), [],...
        struct('Tag','mainmap_borders',...
        'DisplayName', 'Borders',...
        'HitTest','off','PickableParts','none',...
        'LineWidth',1.5,...
        'Color',[0.1 0.1 0.1])...
        );
    out('lakes')=MapFeature('lakes', @() load_lakes(level), [],...
        struct('Tag','mainmap_lakes',...
        'DisplayName', 'Lakes',...
        'HitTest','off','PickableParts','none',...
        'LineWidth',0.5,...
        'Color',[0.3 0.3 .8])...
        );
    out('rivers')=MapFeature('rivers', @() load_rivers(level), [],...
        struct('Tag','mainmap_rivers',...
        'DisplayName', 'Rivers',...
        'HitTest','off','PickableParts','none',...
        'LineWidth',0.5,...
        'Color',[0.7 0.7 1])...
        );
    out('volcanoes')= MapFeature('volcanoes', @load_volcanoes, [],...
        struct('Tag','mainmap_volcanoes',...
        'Marker','^',...
        'DisplayName','Volcanoes',...
        'LineWidth', 1.5,...
        'MarkerSize', 6,...
        'LineStyle','none',...
        'MarkerFaceColor','w',...
        'MarkerEdgeColor','r')...
        );
    
    out('plates') = MapFeature('plates', @load_plates, [],...
        struct('Tag','mainmap_plates',...
        'DisplayName','plate boundaries',...
        'LineWidth', 3.0,...
        'Color',[.2 .2 .5])...
        );
    
    out('faults') = MapFeature('faults', @load_faults, [],...
        struct('Tag','mainmap_faultlines',...
        'DisplayName','main faultine',...
        'LineWidth', 3.0,...
        'Color','b')...
        );
    out('stations') = MapFeature('stations', @load_stations, [],...
        struct('Tag','mainmap_stations',...
        'DisplayName','stations',...
        'LineStyle','none',...
        'MarkerEdgeColor',[0.4 0.4 0.4],...
        'MarkerFaceColor',[0.5 0.5 0.5],...
        'Marker','s',...
        'MarkerSize',6)...
        );
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