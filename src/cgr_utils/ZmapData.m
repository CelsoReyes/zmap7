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
        hodi = pwd; % zmap home directory
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
        catalog % overall catalog of earthquakes
        catalog_working 
        memorized_catalogs % manually stored via Memorize/Recall
        storedcat % automatically stored catalog, used by synthetic catalogs, etc.
        
        % layers
        volcanoes % was vo
        coastline % 
        overlay_features % 
        mainfault % fault locations
        faults % fault locations
        well % well locations
        plates % plate locations
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
        
        % statistical stuff
        teb % time end earthquakes
        t0b % time begin earthquakes
        
        % likely to be completely removed stuff
        hold_state % was ho, contained 'hold' or 'noho'
        hold_state2 % was ho2, contained 'hold' or 'noho'
        hold_state3 % was hoc, contained 'hold' or 'noho'
        
    end
    
end