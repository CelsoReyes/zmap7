function [rused,Nused,maxcMc,DEW_b,DEW_a]=calc_b_DEW_sampling(catalog,lat,lon,depth,rmax, Nmax, doPlot)
    % CALC_B_DEW_SAMPLING Distance-Exponential-Weighted (DEW) b-value
    %
    % [rused,Nused,maxcMc,weighted_b,weighted_a]=calc_b_DEW_sampling(catalog,lat,lon,depth,rmax,Nmax,doPlot)
    %
    % input parameters:
    % catalog - input ZmapCatalog
    % lat, lon, depth - coordinates of the gridpoint to consider
    % rmax - maximum distance to consider for sampling
    % Nmax - maximum number of events to consider, if more are found, use closest Nmax events
    % doPlot - plot results : true or false (default)
    %
    % output parameters:
    % rused - sampling radius, either rmax or the distance encompassing the closest Nmax events
    % maxcMc - local maximum curvature Mc estimate
    % weighted_b - DEW weighted b-value estimate
    % weighted_a - DEW weighted a-value estimate
    %
    % The distance of each earthquake to the considered location (lat/lon/depth-node)
    % is calculated, and translated into a weight, which exponentially decays with distance.
    % For the FMD and b-value analysis, the earthquakes are then not counted
    % as 'one' each, but with their weights: the further away, the less important is
    % an earthquake's contribution to the local estimate of b. The code calculates
    % a local maximum curvature Mc prior to the b-value esitmate. The code considers
    % events within a given rmax, and adapts between very local analysis,
    % e.g. along faults (rmax<20km) and larger scale sampling, e.g. along subduction zones
    % (rmax>20km). There is the option to limit the analysis to the closest Nmax events to
    % enhance the spatial resolution where the earthquake density is high.
    % The radius in which the Nmax closest events were found is returned. If Nmax is set
    % to 'nan', that radius will equal the rmax value given to the function.
    
    % author: Thessa Tormann
    % date: Nov 2017
    
    % set parameters
    Nmin = 50; % minimum number to calculate b-value
    lambda = 0.7; % decay exponent
    mbin = 0.1; % binning of magnitude scale
    Mrange = min(catalog.Magnitude) : mbin : max(catalog.Magnitude); % magnitude range vector
    
    if rmax<=20
        factor = 1; % local sampling, decay over few km
    else
        factor = 0.1; % more regional sampling, decay over few 10 km
    end
    
    if ~exist('doPlot','var')
        doPlot=false;
    end
    
    % prepare output parameters
    Nused = nan;
    rused = rmax;
    DEW_b = nan;
    maxcMc = nan;
    
    %--------------------------------------------------------------------------
    % cut catalog to grid node vicinity to reduce running time
    [cellcat] = cut_to_polygon(catalog, lat, lon, rmax);
    if cellcat.Count < Nmin
        fprintf('less than Nmin [%d] events inside polygon\n', Nmin);
        return
    end
    
    % estimate local maximum curvature Mc (+0.2) and cut catalog
    [cellcat, ind, maxcMc] = cut_to_mc(cellcat, Mrange);
    
    if cellcat.Count < Nmin
        fprintf('less than Nmin [%d] events above Mc [%.2f], impossible to calculate b-value\n', Nmin, maxcMc)
        return
    end
    
    % crop events to the maximum number limited by radius
    selcrit = struct('NumNearbyEvents',Nmax,'maxRadiusKm',rmax,'RadiusKm',rmax,...
        'UseNumNearbyEvents',isfinite(Nmax),...
        'UseEventsInRadius',true);
    subcat=catalog.selectCircle(selcrit, lon,lat,depth);
    
    % if at least Nmax events are closer than rmax
    if subcat.Count < Nmin
        fprintf('less than Nmin [%d] events inside rmax [%.2f km]\n',Nmin, rmax);
        return
    end
    
    % determine 3D distance between EQs and grid node
    [dists_sort, rused] = subcat.hypocentralDistanceTo(lat,lon,depth);
    Nused = subcat.Count;
    
    % calculate DEW weight
    weightused = lambda.*exp(-lambda.*(factor*dists_sort));
    
    weightnumb = weighted_FMD(subcat, Mrange, weightused);
    
    % calculate weighted b-value from weighted mean magnitude
    Mmeanweight = sum(Mrange.*weightnumb)/sum(weightnumb);
    DEW_b = (1/(Mmeanweight-(maxcMc-mbin)))*log10(exp(1));
    cumweightnumb = cumsum(weightnumb,'reverse');
    DEW_a = log10(cumweightnumb(ind+2))+DEW_b*maxcMc;
    
    if doPlot
        % plot: compare original and weighted FMDs, and DEW_b fit
        cumnumb = hist(subcat.Magnitude,Mrange);
        cumnumb = cumsum(cumnumb,'reverse');
        N1 = 10^(DEW_a-DEW_b*maxcMc);
        N2 = 10^(DEW_a-DEW_b*max(Mrange));
        
        figure
        semilogy(Mrange,cumnumb,'.b')
        set(gca,'NextPlot','add')
        semilogy(Mrange,cumweightnumb,'*r')
        semilogy([maxcMc,max(Mrange)],[N1,N2],'-r')
    end
    
end


function [cut_catalog] = cut_to_polygon(catalog, lat, lon, rmax)
    dis = km2deg(1.5*rmax); % distance to use for catalog cutting to vicinity of grid point
    lv_in = inpolygon(catalog.Longitude,catalog.Latitude,[lon-dis;lon+dis;lon+dis;lon-dis],[lat-dis;lat-dis;lat+dis;lat+dis]);
    cut_catalog = catalog.subcat(lv_in);
end

function [cut_catalog, ind, maxcMc] = cut_to_mc(catalog, Mrange)
    % estimate local maximum curvature Mc (+0.2) and cut catalog
    cntnumb = hist(catalog.Magnitude,Mrange);
    [~,ind] = max(cntnumb);
    maxcMc = Mrange(ind)+0.2;
    lv_mc = catalog.Magnitude>=maxcMc;
    cut_catalog = catalog.subset(lv_mc);
end

function [weightnumb] = weighted_FMD(catalog, Mrange, weights)
    % calculate weighted FMD
    % returns total weight for each magnitude bin
    weightnumb = nan(1,length(Mrange));
    for kk=1:length(Mrange)
        mm = round(catalog.Magnitude,1) == round(Mrange(kk),1);
        weightnumb(kk) = sum(weights(mm));
    end
end
