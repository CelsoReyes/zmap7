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
    
    if nargin==1 && strcmp(pt1,'test')
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
    % it would be nice to loop through curve, not catalog. oh well.
    for n=1:projectedcat.Count
        dists_km=deg2km(distance(curvelats, curvelons, eqLats(n), eqLons(n)));
        [mindist(n),I]=min(dists_km);
        gcDist_km(n)=gcDistances(I);
        projectedcat.Longitude(n)=curvelons(I);
        projectedcat.Latitude(n)=curvelats(I);
    end
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