function [mindist, mask, gcDist] = project_on_gcpath(pt1,pt2,catalog, maxdist_km, dx_km)
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
    %  great circle (along strike), (distance in same units as catalog's RefEllipsoid from pt1)
    %
    % see also gcwaypts
    if nargin==1 && pt1 == "test"
        [mindist,mask,gcDist] = test_this;
        return
    end
    
    tdist_km = distance(pt1,pt2,catalog.RefEllipsoid);
    nlegs   = ceil(tdist_km / dx_km); % was doubled.
    
    % limit the catalog to the appropriate distance from the curve
    [las,los] = xsection_poly(pt1,pt2,maxdist_km,false,catalog.RefEllipsoid);
    % mask=polygon_filter(los,las,catalog.Longitude,catalog.Latitude,'inside');
    mask = inpoly([catalog.Longitude,catalog.Latitude], [los,las]);
    
    % create the curve, representing the centerline of the cross-section
    [curvelats,curvelons] = gcwaypts(pt1(1),pt1(2),pt2(1),pt2(2),nlegs);
    gcDist = distance(pt1, [catalog.Latitude(mask), catalog.Longitude(mask)], catalog.RefEllipsoid);
    % gcDistances = distance(pt1(1),pt1(2), curvelats, curvelons);
    % find closest point for each event
    
    mindist = nan(size(catalog.Latitude(mask)));
    
    [mindist] = tryit(catalog.subset(mask), curvelats, curvelons);
    
    % gcDist_km = arcpos .* max(gcDistances); % where along line is it
end

function [dist] = tryit(catalog, curvelats, curvelons)
    % assumptions
    % simple curve, so events are only closest to 1 point
    % distance grows 
    
    d2c = @distance2curve;
    
    refEllipse = catalog.RefEllipsoid; % defaults to length unit of meters
    lat0 = median(curvelats);
    lon0 = median(curvelons);
    [xEast,yNorth, ~] = geodetic2enu(catalog.Latitude, catalog.Longitude, -catalog.Depth,...
        lat0, lon0, 0, refEllipse);
    [xCurveEast, yCurveNorth] = geodetic2enu(curvelats, curvelons, 0, median(curvelats), median(curvelons), 0, refEllipse);
    
    [~,dist,t]= d2c([xCurveEast(:) yCurveNorth(:)], [xEast, yNorth]);
    % [catalog.Latitude, catalog.Longitude]= enu2geodetic(xy(:,2), xy(:,1), zUp, lat0, lon0, 0, refEllipse); 
end

function [mindist,mask,gcDist]=test_this()
    disp('testing... this test expects that you are currently looking at the map')
    %% some scripts that can be used to test:
    ZG=ZmapGlobal.Data;
    catalog=ZG.primeCatalog; % points to same thing
    [lon, lat] = ginput(2);
    [mindist,mask,gcDist]=project_on_gcpath([lat(1),lon(1)],[lat(2),lon(2)],catalog,20,0.1);
    c2 = catalog.subset(mask);
    figure

    ax1=subplot(3,1,[1 2]);
    scatter3(ax1,c2.Longitude,c2.Latitude,-c2.Depth,(c2.Magnitude+3).^2,mindist,'+')
    ax1.NextPlot='add';
    plot(ax1,catalog.Longitude,catalog.Latitude,'k.','MarkerSize',1)
    scatter3(ax1,catalog.Longitude(mask),catalog.Latitude(mask),-c2.Depth,3,mindist)
    ax1.NextPlot='replace';

    ax2=subplot(3,1,3);
    histogram(ax2,gcDist);
    ax2.YLabel.String='# events';
    ax2.XLabel.String='Distance along strike (km)';
end