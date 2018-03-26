function [pv, pstd, cv, cstd, kv, kstd, loopout] = brutebootloglike(time_as,n_boots)
    % BRUTEBOOTLOGLIKE Bootstrap analysis of Omori parameters calculated by BRUTEFORCELOGLIKE
    %
    % [pv, pstd, cv, cstd, kv, kstd, loopout] = BRUTEBOOTLOGLIKE(time_as, bootloops);
    % ----------------------------------------------------------------------
    % (p,c,k)-pair is mean of the bootstrap values by determining the mean cumulative number modeled
    % at end of the learning period. Standard deviations are calculated as the 2nd moment, not to 
    % rely fully on normal distributions. [IS THIS STILL TRUE?]
    %
    % Input parameters:
    %   time_as     Delay times [days]
    %   n_boots   Number of bootstraps
    %
    % Output parameters:
    %   pv / pstd   p value [median] / standard deviation
    %   cv / cstd   c value [median] / standard deviation
    %   kv / kstd   k value [median] / standard deviation
    %   loopout     struct containing all results with fields pval, cval, kval
    %
    % see also BOOTSTRP
    %
    % Samuel Neukomm / S. Wiemer / J. Woessner
    % modified 2018 by CGR

    % figure parameters from bootstraps, taking advantage of statistics toolbox function BOOTSTRP
    
    % get bootstrapped p,c,k values in Nx3 matrix [p , c, k]
    pck = bootstrp(n_boots,@(x)bruteforceloglikecgr(sort(x)),time_as);% can make parallel, even.
    
    % New version: Choose mean (p,c,k)-variables by modelling the cumulative number at end of
    % the learning period
    
    % 2nd moment i.e. Standard deviations
    pck_std = std(pck,1,'omitnan');
    pstd = pck_std(1);
    cstd = pck_std(2); 
    kstd = pck_std(3);
    % in some implementations, pstd and cstd are rounded to 2 decimals, kstd to one.
    
    % Compute best fitting pair of variates
    pck_med = median(pck); % should this also 'omitnan' ?
    pv = pck_med(1); 
    cv = pck_med(2); 
    kv = pck_med(3);
    
    if nargout == 7
        loopout.pval = pck(:,1);
        loopout.cval = pck(:,2);
        loopout.kval = pck(:,3);
    end