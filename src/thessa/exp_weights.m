function [weights] = exp_weights(catalog, lat,lon, depth)
    % EXP_WEIGHTS get distance-dependent weights for a catalog
    % calculates weights for catalog based on exponential decay from a point. weights have
    % size [catalog.Count, 1]
    %
    % WEIGHTS = EXP_WEIGHTS(CATALOG, LAT,LON) weights according to epicentral distances to
    %   the point (LAT,LON)
    %
    % WEIGHTS = exp_weights(CATALOG, LAT, LON, DEPTH) weights according to hypocentral distances
    %   to the point (LAT, LON, DEPTH) where depth is km
    %
    % based on calc_b_DEW_sampling from Thessa Tormann (SED, Nov 2017)
    
    % set parameters
    lambda = 0.7; % decay exponent
    
    LOCAL_DISTANCE_KM = 20; %km
    LOCAL_FACTOR = 1; % local sampling, decay over few km, up to LOCAL_DISTANCE_KM
    REGIONAL_FACTOR = 0.1; % more regional sampling, decay over few 10 km
    
    
    % cut events based on selectionCriteria [EventSelectionChoice]
    if exist('depth','var')
        dists=catalog.hypocentralDistanceTo(lat,lon,depth,'kilometer');
    else
        dists=catalog.epicentralDistanceTo(lat,lon,'kilometer');
    end
    
    if max(dists)<=LOCAL_DISTANCE_KM
        factor = LOCAL_FACTOR; 
    else
        factor = REGIONAL_FACTOR; 
    end
    
    weights = lambda.*exp(-lambda.*(factor*dists));
end