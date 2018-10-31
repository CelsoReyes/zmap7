function [zgrid, gpc] = autogrid(catalog, dohist, plotOnMap)
    % AUTOGRID automatically define grid parameters based on catalog
    % returns a ZmapGrid, 
    %
    % zgrid = AUTOGRID(catalog) calculate a ZmapGrid from a ZmapCatalog
    %
    % [zgrid, gpc] = AUTOGRID(...) additionally, provide a GridOptions
    %
    % [zgrid, gpc] = AUTOGRID(catalog, dohist, plotOnMap) show a 2-d histogram of
    % events if dohist is true, and plot the grid dots on the main map if plotOnMap
    % is true.
    %
    % output:
    %    zgrid : ZmapGrid
    %    gpc : GridOptions objects
    %
    % see also autoradius, ZmapGrid, GridOptions
    
    % assert(isa(catalog,'ZmapCatalog'), 'catalog must be a zmap catalog')
   
    % use 2-d histogram to automatically determine an appropriate grid coverage
    % for the catalog
    
    % get the convex hull for our catalog.
    lola = [catalog.Longitude, catalog.Latitude];
    ch = convhull(lola,'simplify',true);
    area = areaint(lola(ch,2),lola(ch,1));
    area=area * 510.1e6;   % times area of earth(km) to get to km^2
    line_len = sqrt(area); % assuming a square area, it would be this long on a side.
    dS=line_len/30;
    gpc = GridOptions(dS, dS, [], 'km', false, true );
    gpc.AbsoluteGridLimits = [bounds2(catalog.Longitude), bounds2(catalog.Latitude)];
    
    
    zgrid=ZmapGrid('autogrid',gpc);
    f=gcf;
    if exist('dohist','var') && dohist
        hf=figure('Name','Automatic Grid');
        histogram2(catalog.Longitude,catalog.Latitude,XEDGES,YEDGES);
        ax=gca;
        ax.title.String='Event distribution';
        ax.XLabel.String='Longitude';
        ax.YLabel.String='Latitude';
        ax.ZLabel.String='# events';
    end
    figure(f);
    if exist('plotOnMap','var') && plotOnMap
        zgrid.plot(findobj(gcf,'Tag','mainmap_ax'));
    end
end