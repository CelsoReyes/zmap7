function [mask, max_km] = closestEvents(catalog, lat, lon, depth, n)
    % closestEvents determine which N events are closest to a point (lat,lon, depth).
    % for hypocentral distance, leave depth empty.
    %  ex.  closestEvents(mycatalog, 82,-120,[],20);
    % the distance to the nth closest event
    %
    % see also eventsInRadius
    if isempty(depth)
        dists_km = catalog.epicentralDistanceTo(lat, lon);
    else
        dists_km = catalog.hypocentralDistanceTo(lat, lon, depth);
    end
    % find nth closest by grabbing from the sorted distances
    sorted_dists = sort(dists_km);
    max_km = sorted_dists(n);
    
    mask = dists_km <= max_km;
end
