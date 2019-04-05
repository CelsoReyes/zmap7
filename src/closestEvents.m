function [mask, max_km] = closestEvents(catalog, lat, lon, depth, n)
    % closestEvents determine which N events are closest to a point (lat,lon, depth).
    % for hypocentral distance, leave depth empty.
    %  ex.  closestEvents(mycatalog, 82,-120,[],20);
    % the distance to the nth closest event
    %
    % see also eventsInRadius
    if isempty(depth)
        dists = catalog.epicentralDistanceTo(lat, lon,'kilometer');
    else
        dists = catalog.hypocentralDistanceTo(lat, lon, depth,'kilometer');
    end
    % find nth closest by grabbing from the sorted distances
    sorted_dists = sort(dists);
    max_km = sorted_dists(n);
    
    mask = dists_km <= max_km;
end
