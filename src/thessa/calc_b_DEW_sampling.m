
%---------- Distance-Exponential-Weighted (DEW) b-value--------------------
%--------------------------------------------------------------------------

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
%**************************************************************************


function [rused,Nused,maxcMc,DEW_b]=calc_b_DEW_sampling(cat,lat,lon,depth,rmax,Nmax)

% input parameters:
% cat - input catalog in zmap format
% lat, lon, depth - coordinates of the gridpoint to consider
% rmax - maximum distance to consider for sampling
% Nmax - maximum number of events to consider, if more are found, use closest Nmax events

% output parameters:
% rused - radius used for sampling, either rmax or the distance within
% which the closest Nmax events were found
% maxcMc - local maximum curvature Mc estimate
% weighted_b - DEW weighted b-value estimate

%--------------------------------------------------------------------------

% set parameters
Nmin = 50; % minimum number to calculate b-value
lambda = 0.7; % decay exponent
mbin = 0.1; % binning of magnitude scale
Mrange = [min(cat(:,6)):mbin:max(cat(:,6))]; % magnitude range vector
dis = km2deg(1.5*rmax); % distance to use for catalog cutting to vicinity of grid point

if rmax<=20
    factor = 1; % local sampling, decay over few km
else
    factor = 0.1; % more regional sampling, decay over few 10 km
end

% prepare output parameters
Nused = nan;
rused = rmax;
DEW_b = nan;
maxcMc = nan;

%--------------------------------------------------------------------------
% cut catalog to grid node vicinity to reduce running time
lv_in = inpolygon(cat(:,1),cat(:,2),[lon-dis;lon+dis;lon+dis;lon-dis],[lat-dis;lat-dis;lat+dis;lat+dis]);
Nused = sum(lv_in);

if Nused>=Nmin
    cellcat = cat(lv_in,:);
    
    % estimate local maximum curvature Mc (+0.2) and cut catalog
    cntnumb = hist(cellcat(:,6),Mrange);
    [~,ind] = max(cntnumb);
    maxcMc = Mrange(ind)+0.2;
    lv_mc = cellcat(:,6)>=maxcMc;
    cellcat = cellcat(lv_mc,:);
    Nused = sum(lv_mc);
    
    if Nused>=Nmin
        
        % determine 3D distance between EQs and grid node
        dists3d = sqrt((deg2km(distance(cellcat(:,2),cellcat(:,1),ones(length(cellcat(:,1)),1)*lat,ones(length(cellcat(:,1)),1)*lon))).^2+ (cellcat(:,7)-depth).^2);
        lv_dis = dists3d<=rmax;
        cellcat = cellcat(lv_dis,:);
        dists = dists3d(lv_dis,:);
        [dists_sort,is] = sort(dists);
        cellcatsort = cellcat(is(:,1),:);
        Nused = sum(lv_dis);
        
        % if at least Nmin events are closer than rmax
        if Nused>=Nmin
            
            % calculate DEW weight
            weight = lambda.*exp(-lambda.*(factor*dists_sort));
            
            % use only the closest Nmax events
            if and(isfinite(Nmax),Nused>Nmax)    
                weightused = weight(1:Nmax);
                subcat = cellcatsort(1:Nmax,:);
                rused = dists_sort(Nmax);
                Nused = Nmax;
            else
                subcat = cellcatsort;
                weightused = weight;
            end
            
            % calculate weighted FMD
            weightnumb = ones(1,length(Mrange))*nan;
            for kk=1:length(Mrange)
                mm = 0.1*round(10*subcat(:,6))==0.1*round(10*Mrange(kk));
                weightnumb(kk) = sum(weightused(mm));
            end
            
            % calculate weighted b-value from weighted mean magnitude
            Mmeanweight = sum(Mrange.*weightnumb)/sum(weightnumb);
            DEW_b = (1/(Mmeanweight-(maxcMc-mbin)))*log10(exp(1));
            
            % plot: compare original and weighted FMDs, and DEW_b fit
            cumweightnumb = cumsum(weightnumb(end:-1:1));
            cumweightnumb = cumweightnumb(end:-1:1);
            cumnumb = hist(subcat(:,6),Mrange);
            cumnumb = cumsum(cumnumb(end:-1:1));
            cumnumb = cumnumb(end:-1:1);
            DEW_a = log10(cumweightnumb(ind+2))+DEW_b*maxcMc;
            N1 = 10^(DEW_a-DEW_b*maxcMc);
            N2 = 10^(DEW_a-DEW_b*max(Mrange));
            
            figure
            semilogy(Mrange,cumnumb,'.b')
            hold on
            semilogy(Mrange,cumweightnumb,'*r')
            semilogy([maxcMc,max(Mrange)],[N1,N2],'-r')
        else
            disp('less than Nmin events above Mc, impossible to calculate b-value')
        end
    else
        disp('less than Nmin events inside rmax')
    end
else
    disp('less than Nmin events inside polygon')
end



