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
        a %
        newcat
        newt2
        catalog_working
        memorized_catalogs % manually stored via Memorize/Recall
        storedcat % automatically stored catalog, used by synthetic catalogs, etc.
        original % used with declustering
        
        %cluster catalogs 
        newccat % apparently main clustered catalog (csubcat, capara, clpickp)
        ttcat  %  some sort of clustered catalog? selclust
        cluscat %  some sort of clustered catalog? selclust
        newclcat %   some sort of clustered catalog? selclust
        
        %{
        % layers
        features=struct('volcanoes',load_volcanoes(),...
            'plates',load_plates(),...
            'coastline',load_coast('i'),...
            'faults',load_faults(),...
            'borders',load_borders('i'),...
            'rivers',load_rivers('i'),...
            'lakes',load_lakes('i'));
        %}
        %volcanoes % was vo
        %coastline %
        features = get_features('h');
        %mainfault % fault locations
        %faults % fault locations
        well % well locations
        %plates % plate locations
        %rivers
        %lakes
        %borders % national borders
        main
        maepi % large earthquakes, determined by user cutoff
        
        % divisions
        divisions_depth
        divisions_time
        divisions_magnitude
        
        % niceties
        fontsz = FontSizeTracker;
        depth_divisions % plot each division with a different color/symbol
        magnitude_divisions % plot each division with a different color/symbol
        time_divisions % plot each division with a different color/symbol
        color_bg = [1 1 1] % was [cb1 cb2 cb3] axis background
        color_fg = [.9 .9 .9]% was [c1 c2 c3] figure backgorund
        ms6 = 6 % standard markersize %TODO change to a markersize class
        big_eq_minmag = 8  % events of this magnitude or higher are plotted & labeled
        lock_aspect = 'off';
        mainmap_grid = 'on';
        mainmap_plotby = 'depth'; % was typele
        
        bin_days = 14; %bin length, days
        
        % likely to be completely removed stuff
        hold_state = false% was ho, contained 'hold' or 'noho'
        hold_state2 = false % was ho2, contained 'hold' or 'noho'
        hold_state3 = false % was hoc, contained 'hold' or 'noho'
        
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
        compare_window_yrs =1.5 % Compare window length (years)
        compare_window_yrs_v3=1.0% Compare window length, alternate version
        
        % cross section stuff, perhaps
        tresh_km = 50 % radius below which blocks zmap's (?) will be plotted
        xsec_width_km = 10 % not entirely sure units are km
        xsec_rotation_deg = 10 % rotation angle for cross sections
        
        freeze_colorbar = false;
        shading_style = 'flat';
        someColor='w';
        
        % b-value related
        inb1=1; % choice for b-value calculation (?)
        inb2=1; % maximum curvature method(?)
        bo1=nan; % original b-value prior to modifications(?) only used by bvalca3 & bdepth_ratio, but set elsewhere
        bvg=[]; % b-value grid
        calcgrid; % grid used for calculations
        selection_shape=ShapeSelection();
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
            out=max(obj.a.Date);
        end
        function out=get.t0b(obj)
            out=min(obj.a.Date);
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
        function set.bin_days(obj,val)
            if isa(val,'duration')
                obj.bin_days=val;
            elseif isnumeric(val)
                warning('expected bin_days to be a duration. converting and assuming it is days');
                obj.bin_days=days(val);
            else
                error('only can convert durations and numerics to bin_days');
            end
        end
    end
end

function out = get_features(level)
    % imports the various features that can be
    out = containers.Map;
    
    
    % each MapFeature is something that can be overlain on the main map
    %
    out('coastline')= MapFeature('coast', @()load_coast(level), [],...
        struct('Tag','mainmap_coastline',...
        'DisplayName', 'Coastline',...
        'HitTest','off','PickableParts','none',...
        'LineWidth',1.0,...
        'Color',[0.1 0.1 0.1])...
        );
    out('borders')= MapFeature('borders', @()load_borders(level), [],...
        struct('Tag','mainmap_borders',...
        'DisplayName', 'Borders',...
        'HitTest','off','PickableParts','none',...
        'LineWidth',1.0,...
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
            obj.Features(5) = MapFeature('wells', @load_wells, [],...
                struct('Tag','mainmap_wells',...
                    'DisplayName','Wells',...
                    'Marker','d',...
                    'LineWidth',1.5,...
                    'MarkerSize',6,...
                    'LineStyle','none',...
                    'MarkerFaceColor','k',...
                    'MarkerEdgeColor','k')...
                );
            obj.Features(6) = MapFeature('minor_faults', @load_minorfaults, [],...
                struct('Tag','mainmap_faults',...
                    'DisplayName','faults',...
                    'LineWidth',0.2,...
                    'Color','k')...
                );
                
        %}
        %{
            features=struct('volcanoes',load_volcanoes(),...
            'plates',load_plates(),...
            'coastline',load_coast('i'),...
            'faults',load_faults(),...
            'borders',load_borders('i'),...
            'rivers',load_rivers('i'),...
            'lakes',load_lakes('i'));
        %}
end