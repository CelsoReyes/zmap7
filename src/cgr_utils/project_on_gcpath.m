function [projectedcat,mindist,mask,gcDist_km]=project_on_gcpath(pt1,pt2,catalog, maxdist_km, dx_km)
    %PROJECT_TO_GCPATH returns a catalog, with all events projected into the lat/lon defined by curve
    % catalog = PROJECT_TO_GCPATH( PT1, PT2, catalog, maxdist_km, dx_km) where PT1 and PT2 are [lat, lon]. dx_km
    % is the distance from xsection. SO, width is actually maxdist_km*2.  dx_km is resolution used
    % to project the catalog onto the curve;
    %
    % [catalog, dist2curve] = PROJECT_TO_GCPATH(...) also returns distance to curve
    %
    % [catalog, dist2curve, mask] = PROJECT_TO_GCPATH(...) also return t/f vector of whether the
    %   event was used.
    %
    % [catalog, dist2curve, mask, gcDist] = PROJECT_TO_GCPATH(...) return the distance along the
    %  great circle (along strike), (distance in km from pt1)
    %
    % see also gcwaypts
    
    if nargin==1 && pt1 == "test"
        [projectedcat,mindist,mask,gcDist_km]=test_this;
        return
    end
    gcDist_km=[];
    tdist_km = deg2km(distance(pt1,pt2));
    nlegs = ceil(tdist_km / dx_km); % was doubled.
    
    % limit the catalog to the appropriate distance from the curve
    [las,los]=xsection_poly(pt1,pt2,maxdist_km,false);
    mask=polygon_filter(los,las,catalog.Longitude,catalog.Latitude,'inside');
    projectedcat=catalog.subset(mask);
    
    % create the curve
    [curvelats,curvelons]=gcwaypts(pt1(1),pt1(2),pt2(1),pt2(2),nlegs);
    gcDistances=deg2km(distance(pt1(1),pt1(2),curvelats,curvelons));
    % find closest point for each event
    eqLats=projectedcat.Latitude;
    eqLons=projectedcat.Longitude;
    mindist=nan(size(eqLats));
    
    [projectedcat2, mindist2, arcpos] = tryit(projectedcat, curvelats, curvelons);
    
    gcDist_km=arcpos .* max(gcDistances); % where along line is it
end


function [catalog, dist,t] = tryit(catalog, curvelats, curvelons)
    % assumptions
    % simple curve, so events are only closest to 1 point
    % distance grows 
    refEllipse = wgs84Ellipsoid; % defaults to legth unit of meters
    lat0 = median(curvelats);
    lon0 = median(curvelons);
    [xEast,yNorth, zUp] = geodetic2enu(catalog.Latitude, catalog.Longitude, -catalog.Depth*1000,...
        lat0, lon0, 0, refEllipse);
    [xCurveEast, yCurveNorth] = geodetic2enu(curvelats, curvelons, 0, median(curvelats), median(curvelons), 0, refEllipse);
    
    [xy,dist,t]=distance2curve([xCurveEast(:) yCurveNorth(:)], [xEast, yNorth]);
    [catalog.Latitude, catalog.Longitude]= enu2geodetic(xy(:,1), xy(:,2), zUp, lat0, lon0, 0, wgs84Ellipsoid); 
end

function [ProjPoint, length_q] = ProjectPoint(vector, q)
    % Use this function at small scales where we don't have to take curvature into consideration
% write function that projects the  point (q = X,Y) on a vector
% which is composed of two points - vector = [p0x p0y; p1x p1y]. 
% i.e. vector is the line between point p0 and p1. 
%
% The result is a point qp = [x y] and the length [length_q] of the vector drawn 
% between the point q and qp . This resulting vector between q and qp 
% will be orthogonal to the original vector between p0 and p1. 
% 
% This uses the maths found in the webpage:
% http://cs.nyu.edu/~yap/classes/visual/03s/hw/h2/math.pdf
% FROM https://ch.mathworks.com/matlabcentral/answers/26464-projecting-a-point-onto-a-line
      p0 = vector(1,:);
      p1 = vector(2,:);
      length_q = 1; %ignore for now
      a = [p1(1) - p0(1), p1(2) - p0(2); p0(2) - p1(2), p1(1) - p0(1)];
      b = [q(1)*(p1(1) - p0(1)) + q(2)*(p1(2) - p0(2)); ...
          p0(2)*(p1(1) - p0(1)) - p0(1)*(p1(2) - p0(2))] ;
      ProjPoint = a\b;
  end

function [c2,mindist,mask,gcDist]=test_this()
    disp('testing... this test expects that you are currently looking at the map')
    %% some scripts that can be used to test:
    ZG=ZmapGlobal.Data;
    catalog=ZG.primeCatalog;
    [lon, lat] = ginput(2);
    [c2,mindist,mask,gcDist]=project_on_gcpath([lat(1),lon(1)],[lat(2),lon(2)],catalog,20,0.1);
    figure
    subplot(3,1,[1 2])
    scatter3(c2.Longitude,c2.Latitude,-c2.Depth,(c2.Magnitude+3).^2,mindist,'+')
    hold on
    plot(catalog.Longitude,catalog.Latitude,'k.','MarkerSize',1)
    scatter3(catalog.Longitude(mask),catalog.Latitude(mask),-c2.Depth,3,mindist)
    hold off
    subplot(3,1,3)
    histogram(gcDist);
    ylabel('# events');
    xlabel('Distance along strike (km)');
end