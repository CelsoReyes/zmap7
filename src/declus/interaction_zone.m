function [rmain_km,r1]= interaction_zone( catalog, rfact )
    % interaction_zone calculates the interaction zones of the earthquakes in [km]
    % [rmain_km,r1]= interaction_zone( catalog, rfact )
    %
    % output:
    %    rmain_km : interaction zone for mainshock, km
    %    r1 : interaction zone if included in a cluster, km
    % A. Allmann
    
    rmain_km = 0.011*10.^(0.4* catalog.Magnitude); %interaction zone for mainshock
    r1 = rfact * rmain_km;                  %interaction zone if included in a cluster
end

