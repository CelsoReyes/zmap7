function get_basemap_parts(resolution)
    % load lake and boundaries
    % resolution is integer from 1 to 5, with 5 being full resolution
    %
    % data from:
    %  https://www.ngdc.noaa.gov/mgg/shorelines/
    %  http://www.soest.hawaii.edu/pwessel/gshhg/index.html
    %
    % this routine expectes them to be in shapefile format
    %
    % GSHHG "Early processing and assmbly of the shoreline data" processing details:
    % Wessel, P., and W. H. F. Smith, A Global Self-consistent, Hierarchical, High-resolution Shoreline Database, J. Geophys. Res., 101, 8741-8743, 1996i
    switch resolution
        case 5
            resolution='f'; % "full"
        case 4
            resolution='h'; % "high"
        case 3
            resolution='i'; % "intermediate"
        case 2
            resolution='l'; % "low"
        otherwise
            resolution='c'; % "crude"
    end
    
    %% define the map features
    % each MapFeature is something that can be overlain on the main map
    %
    disp('MainInteractiveMap construction');
    obj.Features = MapFeature('coast', @load_coast_and_borders, [],...
        struct('Tag','mainmap_coastline',...
        'DisplayName', 'Coastline/Borders',...
        'HitTest','off','PickableParts','none',...
        'LineWidth',1.0,...
        'Color',[0.1 0.1 0.1])...
        );
    
    obj.Features(2) = MapFeature('volcanoes', @load_volcanoes, [],...
        struct('Tag','mainmap_volcanoes',...
        'Marker','^',...
        'DisplayName','Volcanoes',...
        'LineWidth', 1.5,...
        'MarkerSize', 6,...
        'LineStyle','none',...
        'MarkerFaceColor','w',...
        'MarkerEdgeColor','r')...
        );
    
    obj.Features(3) = MapFeature('plates', @load_plates, [],...
        struct('Tag','mainmap_plates',...
        'DisplayName','plate boundaries',...
        'LineWidth', 3.0,...
        'Color',[.2 .2 .5])...
        );
    
    obj.Features(4) = MapFeature('faults', @load_faults, [],...
        struct('Tag','mainmap_faultlines',...
        'DisplayName','main faultine',...
        'LineWidth', 3.0,...
        'Color','b')...
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
        figure;
        %TODO: have this on
        base='/Users/reyesc/Downloads/gshhg-shp-2';
        load_rivers(base,resolution);
        load_lakes(base,resolution);
        %load_boundaries(base,resolution);
        load_faults();
        load_continents(base, resolution);
        load_borders(base, resolution);
        load_plates();
end

function load_borders(base, resolution)
    ZG = ZmapGlobal.Data;
    % load National boundaries
    fn=fullfile(base,'WDBII_shp',resolution,['WDBII_border_' resolution '_L1']);
    S=shaperead(fn,'UseGeoCoords',true);
    ZG.borders=S;
end

function load_continents(base, resolution)
    ZG = ZmapGlobal.Data;
    % load continent boundaries (no antarctica)
    fn=fullfile(base,'GSHHS_shp',resolution,['GSHHS_' resolution '_L1']);
    S=shaperead(fn,'UseGeoCoords',true);
    ZG.coastline=S;
end

function load_faults()
    ZG = ZmapGlobal.Data;
    % load Fault traces
    % from SHARE The European Database of Seismogenic Faults:
    % http://diss.rm.ingv.it/share-edsf/SHARE_WP3.2_Downloads.html
    fn='/Users/reyesc/Downloads/DB-CFS-ESRI-shapefile/Crustal_fault_sources_TOP';
    S=shaperead(fn,'UseGeoCoords',true);
    ZG.faults=S;
end

function load_lakes(base, resolution)
    ZG = ZmapGlobal.Data;
    % load lake boundaries
    fn=fullfile(base,'GSHHS_shp',resolution,['GSHHS_' resolution '_L2']);
    S=shaperead(fn,'UseGeoCoords',true);
    ZG.lakes=S;
end

function load_rivers(base, resolution)
    ZG = ZmapGlobal.Data;
    % load river-lake boundaries
    fn=fullfile(base,'WDBII_shp',resolution,['WDBII_river_' resolution '_L01']);
    S=shaperead(fn,'UseGeoCoords',true);
    
    % load perm. major river boundaries
    fn=fullfile(base,'WDBII_shp',resolution,['WDBII_river_' resolution '_L02']);
    S=[S ; shaperead(fn,'UseGeoCoords',true)];
    
    % load addl. major rivers
    fn=fullfile(base,'WDBII_shp',resolution,['WDBII_river_' resolution '_L03']);
    S=[S ; shaperead(fn,'UseGeoCoords',true)];
    
    % load addl. rivers
    fn=fullfile(base,'WDBII_shp',resolution,['WDBII_river_' resolution '_L04']);
    S=[S ; shaperead(fn,'UseGeoCoords',true)];
    ZG.rivers=S;
end

function load_plates()
    ZG=ZmapGlobal.Data;
    tmp=load('resources/plates.mat','data','metadata');
    disp('Plate Boundary Metadata:');
    disp(tmp.metadata)
    ZG.plates=tmp.data;
end

