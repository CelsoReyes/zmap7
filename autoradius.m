function [r, evselch] = autoradius(catalog, zgrid, minNum, pct, reach)
    %autoradius determine the radius necessary
    %[r, maxXoverlap, maxYoverlap,eventSelectionChoiceStruct] = autoradius(catalog,zgrid,minNum, pct)
    %   CATALOG : ZmapCatalog
    %   ZGRID : ZmapGrid
    %   MINNUM : minimum number of points required to perform calculation
    %   PCT : minimum acceptable percentage of answers
    %   REACH : value(s) that describes search radius in terms of cell width/height [reach*dX, reach*dY]
    %           deafaults to 1.5.  values are approximate since degree distances change with latitude
    %           for a grid spaced at approx 10km in N-S and 8 km in E-W, REACH=2 means the max radius
    %           would be 20 km.
    %
    % TODO: this could be tweaked to return answers based on overlap, too
    
    nX=floor(numel(zgrid.Xvector)/2);
    nY=floor(numel(zgrid.Yvector)/2);
    if nX ~=0
        xdist=deg2km(distance(zgrid.Xvector(nX),zgrid.Yvector(nY),zgrid.Xvector(n),zgrid.Yvector(nY)));
    else
        xdist=0;
    end
    if nY ~=0
        ydist=deg2km(distance(zgrid.Xvector(nX),zgrid.Yvector(nY),zgrid.Xvector(nX),zgrid.Yvector(nY+1)));
    else
        ydist=0;
    end
    selcrit.requiredNumEvents=minNum;
    selcrit.numNearbyEvents=minNum;
    if ~exist('reach','var')
        reach=[1.5 1.5];
    end
    switch numel(reach)
        case 1
            reach=[reach reach];
        case 2
            reach=reshape(reach,1,2);
        otherwise
            reach = [2 2];
    end
    selcrit.maxRadiusKm=max(reach .* [xdist, ydist]);
    
    if ~exist('pct','var') || isempty(pct)
        pct = 75;
    end
    
    % how far is it from each grid point to the required number of earthquakes?
    [ ~, ~, maxDist, ~, wasEvaluated ] = gridfun(  @cnt, catalog, zgrid, selcrit, 1 );
    %histogram(maxDist,'Normalization','probability','BinMethod','fd');
    %drawnow
    [~,EDGES] = histcounts(maxDist(wasEvaluated),'Normalization','probability','BinMethod','fd');
    [N,EDGES] = histcounts(maxDist(wasEvaluated),EDGES(1): (EDGES(2)-EDGES(1))/4 : EDGES(end),'Normalization','probability');
    %title('
    %xlabel('dist')
    %ylabel('occur prob')
    cutoff=find(cumsum(N)>=(pct/100),1);
    
    % now iterate
    %selcrit.maxRadiusKm=median(maxDist)
    r=EDGES(cutoff+1);
    
    % TODO include overlap if imporant.
    %% get grid overlap:
    %assume all circles of radius r, simplified from:
    % https://ch.mathworks.com/matlabcentral/answers/273066-overlapping-area-between-two-circles#answer_213523
    
    %XpctOverlap=overlap(xdist, r);
    %YpctOverlap=overlap(ydist, r);
    
    evselch = toEventSelection();
    
    function c=cnt(~)
        %donothing
        c=1;
    end
    
    function pctOverlap = overlap(D, r)
        % D: Distance (km) between circles
        % R: circle radius (km)
        try
            dm = r*2; % diameter
            t = D * sqrt((D+dm)*(-D+dm));
            %t = sqrt( -D * (D+d) * (D-d)^2 );
            rs=r*r;
            Aov = rs * 2 * atan2(t,D^2) - (t/2); %overlap
            A=pi*rs;
            %Aoverlap = 2 * r^2 * atan2(t,dm^2) - t/2
            pctOverlap = Aov / A;
        catch
            pctOverlap=0;
        end
    end
    
    function esl = toEventSelection()
        % create a default eventSelection to use.  Feel free to modify it before actually using
        esl=struct(...
            'numNearbyEvents', minNum,...
            'radius_km', r,...
            'useNumNearbyEvents', 0,...
            'useEventsInRadius', 1,...
            'maxRadiusKm', selcrit.maxRadiusKm,...
            'requiredNumEvents', minNum);
    end
    
end
