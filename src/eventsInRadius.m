function [mask, furthest_event_km] = eventsInRadius(catalog, lat, lon, RadiusKm)
    % eventsInRadius subset catalog to a radus from a point. sortorder is preserved
    % mask: corresponds to input catalog, true for all events within radius RadiusKm
    % furthest_event_km : actual distance of furthest event, within radius RadiusKm
    % if no events exist, value returned is RadiusKm
    %
    % see also closestEvents
    dists_km = catalog.epicentralDistanceTo(lat, lon);
    mask = dists_km <= RadiusKm;
    furthest_event_km = max(dists_km(mask));
    if isempty(furthest_event_km)
        furthest_event_km=RadiusKm; %maybe use NAN?
    end
end
