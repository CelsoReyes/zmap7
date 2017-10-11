function [r, evsel] = autoradius(catalog, zgrid, minNum, pct, reach)
    %AUTORADIUS determine the ideal radius to use for the grid function
    %[r,eventSelectionChoiceStruct] = AUTORADIUS(catalog,zgrid,minNum, pct, reach)
    %   where:
    %       CATALOG : ZmapCatalog
    %       ZGRID : ZmapGrid
    %       MINNUM : minimum number of points required to perform calculation
    %       PCT : minimum acceptable percentage of answers
    %       REACH : value(s) that describes search radius in terms of cell width/height [reach*dX, reach*dY]
    %           deafaults to 1.5.  values are approximate since degree distances change with latitude
    %           for a grid spaced at approx 10km in N-S and 8 km in E-W, REACH=2 means the max radius
    %           would be 15 km.
    %
    %  Output:
    %     r : recommended radius
    %     evsel : structure styled after EventSelection.toStruct() to make this
    %             answer easily compatible with other sections of Zmap.
    %
    % see also ZmapGrid, ShapeSelection
    
    % TODO: this could be tweaked to return answers based on overlap, too
   
    
    assert(isa(zgrid,'ZmapGrid'),'zgrid must be a ZmapGrid');
    assert(isa(catalog,'ZmapCatalog'),'catalog must be a ZmapCatalog');
    
    % determine the probable distance between grid points horizontally (E-W) and vertically (N-S)
    %
    nX=floor(numel(zgrid.Xvector)/2);
    nY=floor(numel(zgrid.Yvector)/2);
    if nX ~=0
        xdist=deg2km(distance(zgrid.Xvector(nX),zgrid.Yvector(nY),zgrid.Xvector(nX+1),zgrid.Yvector(nY)));
    else
        xdist=0;
    end
    if nY ~=0
        ydist=deg2km(distance(zgrid.Xvector(nX),zgrid.Yvector(nY),zgrid.Xvector(nX),zgrid.Yvector(nY+1)));
    else
        ydist=0;
    end
    
    % determine distance that represents the maximum number of cell-lengths
    % to allow. This is the "reach".
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
    
    
    selcrit.requiredNumEvents=minNum;
    selcrit.numNearbyEvents=minNum;
    
    
    if ~exist('pct','var') || isempty(pct)
        pct = 75;
    end
    
    % how far is it from each grid point to the required number of earthquakes?
    % if not enough events exist within selcrit.maxRadiusKm of the gridpoint,
    % then this point is thrown out, and will not affect the recommended distance
    [ ~, ~, maxDist, ~, wasEvaluated ] = gridfun(  @cnt, catalog, zgrid, selcrit, 1 );

    
    % only use those distances where enough events occurred within maxRadiusKm.
    maxDist = maxDist(wasEvaluated);
    % use automatically generated bins
    [~,EDGES] = histcounts(maxDist,'Normalization','probability','BinMethod','fd');
    % but now, subdivide the bins to determine the distances to a finer degree
    step = (EDGES(2)-EDGES(1))/4;
    EDGES = EDGES(1): step : EDGES(end);
    
    % and then get values in terms of probability so that...
    [N,EDGES] = histcounts(maxDist,EDGES,'Normalization','probability');

    % ... a cutoff percentage can be determined.
    cutoff=find(cumsum(N)>=(pct/100),1);
    
    r=EDGES(cutoff+1); % distance at which PCT percent of Cells have a value
    
    % TODO include overlap if imporant.
    
    %% get grid overlap:
    %assume all circles of radius r, simplified from:
    % https://ch.mathworks.com/matlabcentral/answers/273066-overlapping-area-between-two-circles#answer_213523
    
    %XpctOverlap=overlap(xdist, r);
    %YpctOverlap=overlap(ydist, r);
    
    evsel = toEventSelection();
    
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
