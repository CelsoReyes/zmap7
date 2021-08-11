function [zgrid, gpc] = autogrid(catalog, refEllipsoid, axes_h)
    % AUTOGRID automatically define grid parameters based on catalog
    % returns a ZmapGrid 
    %
    % zgrid = AUTOGRID(catalog) calculate a ZmapGrid from a ZmapCatalog
    %
    % [zgrid, gpc] = AUTOGRID(...) additionally, provide a GridOptions
    %
    % [zgrid, gpc] = AUTOGRID(catalog, ellipsoid, axes) plot the grid dots
    % on the provided axes
    %
    % output:
    %    zgrid : ZmapGrid
    %    gpc : GridOptions objects
    %
    % see also autoradius, ZmapGrid, GridOptions
    
    
    % get the convex hull for our catalog.

    if catalog.Count < 2
        error('cannot create autogrid for a catalog with less than 2 points');
    end
    
    if ~exist('refEllipsoid','var') || isempty(refEllipsoid)
        refEllipsoid = catalog.RefEllipsoid;
    end
    
    if iscartesian(refEllipsoid)
        dS = round(cartesian_line_length(catalog) / 30, 2);
        gpc = GridOptions('XY',[dS, dS], refEllipsoid, 'gridEntireArea', true);
        %gpc.dzUnits = catalog.LengthUnit;
        gpc.FixedAnchorPoint = [0 0 0];
        gpc.AbsoluteGridLimits = [bounds2(catalog.X), bounds2(catalog.Y)];
        zgrid = ZmapGrid('autogrid', 'FromGridOptions', gpc);
        
    else
        dS = geodetic_line_length(catalog, refEllipsoid) / 30;
        gpc = GridOptions('XY',[dS, dS], refEllipsoid, 'gridEntireArea',false);
        gpc.AbsoluteGridLimits = [bounds2(catalog.X), bounds2(catalog.Y)];
        zgrid = ZmapGrid('autogrid', 'FromGridOptions', gpc, 'RefEllipsoid', refEllipsoid);
    end
    
    if exist('axes_h','var')
        zgrid.plot(axes_h);
    end
end

function line_length = cartesian_line_length(catalog)
    if catalog.Count==2
        line_length = sqrt((catalog.Y(2) - catalog.Y(1)) .^ 2 + (catalog.X(2) - catalog.X(1)) .^ 2);
    else
        xy = [catalog.X, catalog.Y];
        ch = convhull(xy, 'simplify', true);
        area = polyarea(xy(ch,1), xy(ch,2));
        line_length = sqrt(area); % assuming a square area, it would be this long on a side.
    end
end

function line_length = geodetic_line_length(catalog, refEllipsoid)
    if catalog.Count==2
        line_length = distance(catalog.Y(1), catalog.X(1), catalog.Y(2), catalog.X(2), refEllipsoid);
    else
        xy = [catalog.X, catalog.Y];
        ch = convhull(xy, 'simplify', true);
        area = areaint(xy(ch,2), xy(ch,1), refEllipsoid);
        line_length = sqrt(area); % assuming a square area, it would be this long on a side.
    end
    
end

