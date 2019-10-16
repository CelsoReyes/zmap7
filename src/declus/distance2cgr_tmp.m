function [dist1, dist2] = distance2(i, bgevent, ac, newcat)
    % calculates the distance in [km] between two eqs
    % precise version based on Raesenbergs Program
    % the calculation is done simultaniously for the biggest event in the
    % cluster and for the current event
    %
    % A. Allmann

    global err derr
    
    if isempty(err) 
        err=1.5; % from InitVariables --epicenter error
    end
    
    if isempty(derr)
        derr=2; % from InitVariables --depth error
    end
    
    % columns
    LAT = 2;
    LON = 1;
    DEP = 3;
 
    % if any of these fail, then we are dealing with multiple events simultaneously, and must take that into account
    assert(numel(i)==1)
    assert(numel(bgevent) == 1)
    
    evs = newcat.XYZ([i,bgevent,reshape(ac,1,[])],:);
    
    evs(:,[LAT,LON]) = deg2rad(evs(:,[LAT,LON])); % convert lats & lons to radians
    
    i_ev = evs(1,:);
    big_ev = evs(2,:);
    ac_ev = evs(3,:);
    
    pi2 = pi/2;
    flat= 0.993231;

    tana = flat .* tan([i_ev(LAT); big_ev(LAT)]);
    acol = pi2 - atan(tana);
    
    tanb = flat * tan(ac_ev(LAT));
    bcol = pi2 - atan(tanb);
    
    diflon = (ac_ev(LON) - [i_ev(LON),  big_ev(LON)]);
        
    cosdel = [ ...
        (sin(acol(1))*sin(bcol)) .* cos(diflon(1)) + (cos(acol(1))*cos(bcol)) , ...
        (sin(acol(2))*sin(bcol)) .* cos(diflon(2)) + (cos(acol(2))*cos(bcol)) ];
    
        
    colat = pi2 - (ac_ev(LAT) + [i_ev(LAT), big_ev(LAT)] ./2);
    
    radius = 6371.227*(1+(3.37853e-3)*(1/3-((cos(colat)).^2)));
    r = acos(cosdel) .* radius;            % epicenter distance
    
    r = r - 1.5 * err;               %influence of epicenter error
    
    r(r<0) = 0;
    
    % depth distance
    z = abs(ac_ev(DEP) - [i_ev(DEP), big_ev(DEP)] );
    z = z - derr;
    z(z<0)=0;
    
    r = sqrt(z .^ 2 + r.^2);                   %hypocenter distance
    dist1 = r(:,1);           %distance between eqs
    dist2 = r(:,2);



