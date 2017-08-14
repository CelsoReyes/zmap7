function [mask, max_km] = closestEvents(catalog, lat, lon, n)
    % sortByDistance determine t/f array (mask) for catalog. true for n  events closest to (lat,lon).
    % the distance to the nth closest event
    
    dists_km = catalog.epicentralDistanceTo(lat, lon);
    
    % find nth closest by grabbing from the sorted distances
    sorted_dists = sort(dists_km);
    max_km = sorted_dists(n);
    
    mask = dists_km <= max_km;
end
