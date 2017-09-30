function [mask, furthest_event_km] = eventsInRadius(catalog, lat, lon, radius_km)
    % eventsInRadius subset catalog to a radus from a point. sortorder is preserved
    % mask: corresponds to input catalog, true for all events within radius radius_km
    % furthest_event_km : actual distance of furthest event, within radius radius_km
    % if no events exist, value returned is radius_km
    %
    % see also closestEvents
    dists_km = catalog.epicentralDistanceTo(lat, lon);
    mask = dists_km <= radius_km;
    furthest_event_km = max(dists_km(mask));
    if isempty(furthest_event_km)
        furthest_event_km=radius_km; %maybe use NAN?
    end
end
