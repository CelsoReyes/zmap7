function [catalog, dists_km] = sortByDistance(catalog, lat, lon, depth)
    % sortByDistance sort a ZmapCatalog by the distance to a lat/lon point
    % returns both a sorted catalog and a distance vector (km)
    
    if exist('depth','var')
        % sort on 3d distance
        error('sorting by depth is an unimplemented feature');
    else
        %s sort on lat-lon only
        dists_km = catalog.epicentralDistanceTo(lat, lon);
        [dists_km,idx] = sort(dists_km);
        catalog = catalog.subset(idx);
    end
end