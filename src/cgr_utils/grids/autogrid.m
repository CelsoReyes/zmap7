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
    
    % assert(isa(catalog,'ZmapBaseCatalog'), 'catalog must be a zmap catalog')
   
    % use 2-d histogram to automatically determine an appropriate grid coverage
    % for the catalog
    
    % get the convex hull for our catalog.
    xy = [catalog.X, catalog.Y];
    if catalog.Count < 2
        error('cannot create autogrid for a catalog with less than 2 points');
    end
    
    if catalog.CoordinateSystem == CoordinateSystems.cartesian
        % skip so much stuff.
        if catalog.Count==2
            line_len = sqrt((catalog.Y(2)-catalog.Y(1)).^2 + (catalog.X(2)-catalog.X(1))^2);
        else
            ch = convhull(xy,'simplify',true);
            area = polyarea(xy(ch,1), xy(ch,2));
            line_len = sqrt(area); % assuming a square area, it would be this long on a side.
        end
        dS = round(line_len/30,2);
        gpc = GridOptions(catalog.CoordinateSystem, 'XY',[dS, dS], catalog.PositionUnits, 'gridEntireArea');
        gpc.dzUnits = catalog.ZUnits;
        gpc.FixedAnchorPoint = [0 0 0];
        gpc.AbsoluteGridLimits = [bounds2(catalog.X), bounds2(catalog.Y)];
        zgrid = ZmapGrid('autogrid', 'FromGridOptions', gpc);
        
        
    else
        
        if ~exist('refEllipse','var') || isempty(refEllipse)
            refEllipse = ZmapGlobal.Data.ref_ellipsoid;
        end
        
        if catalog.Count==2
            line_len = distance(catalog.Y(1), catalog.X(1),...
                catalog.Y(2), catalog.X(2), refEllipse);
        else
            ch = convhull(xy,'simplify',true);
            area = areaint(xy(ch,2), xy(ch,1), refEllipse);
            line_len = sqrt(area); % assuming a square area, it would be this long on a side.
        end
        dS = line_len/30;
        gpc = GridOptions(catalog.CoordinateSystem, 'XY',[dS, dS], refEllipse, 'gridEntireArea');
        gpc.AbsoluteGridLimits = [bounds2(catalog.X), bounds2(catalog.Y)];
        
        
        zgrid = ZmapGrid('autogrid','FromGridOptions', gpc, 'RefEllipsoid', refEllipse);
    end
    
    if exist('plotOnMap','var') && plotOnMap
        zgrid.plot(findobj(gcf,'Tag','mainmap_ax'));
    end
end