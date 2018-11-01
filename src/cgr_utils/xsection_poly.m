function [lats, lons] = xsection_poly(endpointA, endpointB, r_km, roundTips, ref_ellipsoid)
    % XSECTION_POLY returns the polygon with radius r (km) surrounding a linear cross-section
    % [LATS, LONS] = XSECTION_POLY(endpointA, endpointB, radius)
    % ... XSECTION_POLY(..., true) will extend the polygon to the radius around the end points
    % endpointA is [lat, lon]
    % endpointB is [lat,lon]
    % resulting LATS and LONS are columns, and represent a clockwise traverse of the enclosing area
    % starting to left of endpointA (as facing endpointB)
    %
    % This calculates waypoints along the great circle, and uses that to handle curvature.
    %
    % For cross-sections where the earthquakes are projected onto the plane, do not use the rounded
    % ends.
    %
    %                            circleB
    %               <-2*r->         ___   
    %                              /   \    
    %     x         *--x--*       *  B  *
    %     |         |  :  |       |  :  |
    %     |         |  :  |       *  +  *
    %     |         |  :  |       |  :  |
    %     x         *--x--*       *  A  * 
    %                              \___/
    %                             
    %                             circleA
    %
    %  original    boundary of    boundary with
    %  segment      polygon       roundTips
    %
    %  of course, the orientation can be arbitrary.
    %
    % see also reckon, azimuth
    % NOT THREAD SAFE
    
    %TODO: change from gcwaypts to track using the ellipsoid
    
    persistent prevParams
    persistent prevPoly
    if ~exist('roundTips','var')
        roundTips = false;
    end
    params = struct('endA',endpointA,'endB',endpointB','radius',r_km,'extendEnds',roundTips);
    if isequal(params,prevParams)
        % return previous answer
        lats = prevPoly.lats;
        lons = prevPoly.lons;
        return;
    end
    prevParams = params;
    % get points along the great circle path
    tdist_km = distance(endpointA,endpointB,ref_ellipsoid);
    npoints = round(tdist_km/(r_km)); % choose a number of points based on length/width ratio
    if npoints
        [gclats, gclons] = gcwaypts(endpointA(1),endpointA(2),endpointB(1),endpointB(2), npoints);
    else
        gclats = [endpointA(1);endpointB(1)];
        gclons = [endpointA(2);endpointB(2)];
    end
    
    lats=[];
    lons=[];
    
    % calculate going up the left
    for n = 1 : numel(gclats)-1
        AZ= azimuth(gclats(n),gclons(n),gclats(n+1),gclons(n+1));
        [lats(end+1,1),lons(end+1,1)] = reckon(gclats(n),gclons(n), r_km, AZ-90, ref_ellipsoid);
    end
    
    % calculate left of last point, but using backazimuth
    AZ = azimuth(gclats(end),gclons(end),gclats(end-1),gclons(end-1)); %backazimuth
    [lats(end+1,1),lons(end+1,1)]=reckon(gclats(end),gclons(end),r_km,AZ+90, ref_ellipsoid);
    
    if roundTips
        [circlat,circlon]=reckon(endpointB(1),endpointB(2),r_km,AZ+90+(.25:.25:179.75)',ref_ellipsoid);
        lats=[lats;circlat(:)];
        lons=[lons;circlon(:)];
    end
    
    % calculate going down the right
    for n = numel(gclats): -1 : 2
        AZ= azimuth(gclats(n),gclons(n),gclats(n-1),gclons(n-1));
        [lats(end+1,1),lons(end+1,1)]=reckon(gclats(n),gclons(n),r_km,AZ-90, ref_ellipsoid);
    end
    
    % calculate right of first point, but using backazimuth
    AZ = azimuth(gclats(1),gclons(1),gclats(2),gclons(2)); %backazimuth
    [lats(end+1,1),lons(end+1,1)]=reckon(gclats(1),gclons(1),r_km,AZ+90, ref_ellipsoid);
    
    if roundTips
        [circBlat,circBlon]=reckon(endpointA(1),endpointA(2),r_km,AZ+90+(.25:.25:179.75)',ref_ellipsoid);
        lats=[lats;circBlat(:)];
        lons=[lons;circBlon(:)];
    end
    lats(end+1)=lats(1);
    lons(end+1)=lons(1);
    
    prevPoly=struct('lats',lats,'lons',lons);
end

%{
%% some scripts that can be used to test:
A=[35,70],B=[40,78];
[las,los]=xsection_poly([35,70], [40,78],100,true);
figure;plot(A(2),A(1),'*r');set(gca,'NextPlot','add');plot(B(2),B(1),'*g');plot(los',las',':.');
%}

