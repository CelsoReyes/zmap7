function [lats, lons] = xsection_poly(endpointA, endpointB, r, roundTips)
    % XSECTION_POLY returns the polygon with radius r (km) surrounding a linear cross-section
    % [LATS, LONS] = XSECTION_POLY(endpointA, endpointB, radius)
    % ... XSECTION_POLY(..., true) will extend the polygon to the radius around the end points
    % endpointA is [lat, lon]
    % endpointB is [lat,lon]
    %                            circleB
    %               <-2*r->         ___   
    %                              /   \    
    %     x         *--x--*     P3*  B  *P4
    %     |         |  :  |       |  :  |
    %     |         |  :  |       |  :  |
    %     x         *--x--*     P2*  A  * P1
    %                              \___/
    %                             
    %                             circleA
    %
    %  original    boundary of    boundary with
    %  segment      polygon       roundTips
    %
    %  of course, the orientation can be arbitrary.
    %
    % NOT THREAD SAFE
    
    persistent prevParams
    persistent prevPoly
    if ~exist('roundTips','var')
        roundTips = false;
    end
    params = struct('endA',endpointA,'endB',endpointB','radius',r,'extendEnds',roundTips);
    if isequal(params,prevParams)
        % return previous answer
        lats = prevPoly.lats;
        lons = prevPoly.lons;
        return;
    end
    prevParams = params;
    
    % find the trend of the given line
    AZ= azimuth(endpointA,endpointB);
    
    % find the arclength of r
    r = km2deg(r);
    
    [p1.lat , p1.lon] = reckon(endpointA(1),endpointA(2),r,AZ+90);
    [p2.lat , p2.lon] = reckon(endpointA(1),endpointA(2),r,AZ-90);
    
    [p3.lat , p3.lon] = reckon(endpointB(1),endpointB(2),r,AZ-90);
    [p4.lat , p4.lon] = reckon(endpointB(1),endpointB(2),r,AZ+90);
    
    if roundTips
        [circAlat,circAlon]=reckon(endpointA(1),endpointA(2),r,AZ+90+(.25:.25:179.75)');
        [circBlat,circBlon]=reckon(endpointB(1),endpointB(2),r,AZ-90+(.25:.25:179.75)');
        lats = [p1.lat; circAlat(:); p2.lat; p3.lat; circBlat(:); p4.lat; p1.lat];
        lons = [p1.lon; circAlon(:); p2.lon; p3.lon; circBlon(:); p4.lon; p1.lon];
    else
        lats = [p1.lat; p2.lat; p3.lat; p4.lat; p1.lat];
        lons = [p1.lon; p2.lon; p3.lon; p4.lon; p1.lon];
    end
    prevPoly=struct('lats',lats,'lons',lons);
    return
end