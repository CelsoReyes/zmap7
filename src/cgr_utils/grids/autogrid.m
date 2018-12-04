function [zgrid, gpc] = autogrid(catalog, refEllipse, plotOnMap)
    % AUTOGRID automatically define grid parameters based on catalog
    % returns a ZmapGrid, 
    %
    % zgrid = AUTOGRID(catalog) calculate a ZmapGrid from a ZmapCatalog
    %
    % [zgrid, gpc] = AUTOGRID(...) additionally, provide a GridOptions
    %
    % [zgrid, gpc] = AUTOGRID(catalog, ellipsoid, plotOnMap) show a 2-d histogram of
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
    if catalog.Count < 2
        error('cannot create autogrid for a catalog with less than 2 points');
    end
    
    if ~exist('refEllipse','var') || isempty(refEllipse)
        refEllipse = ZmapGlobal.Data.ref_ellipsoid;
    end
    
    if catalog.Count==2
        line_len = distance(catalog.Latitude(1), catalog.Longitude(1),...
            catalog.Latitude(2), catalog.Longitude(2), refEllipse);
    else
        ch = convhull(lola,'simplify',true);
        area = areaint(lola(ch,2), lola(ch,1), refEllipse); % in units of refEllipse
        line_len = sqrt(area); % assuming a square area, it would be this long on a side.
    end
    dS = line_len/30;
    gpc = GridOptions('XY',[dS, dS], refEllipse, 'gridEntireArea');
    gpc.AbsoluteGridLimits = [bounds2(catalog.Longitude), bounds2(catalog.Latitude)];
    
    
    zgrid=ZmapGrid('autogrid','FromGridOptions', gpc, 'RefEllipsoid', refEllipse);

    if exist('plotOnMap','var') && plotOnMap
        zgrid.plot(findobj(gcf,'Tag','mainmap_ax'));
    end
end