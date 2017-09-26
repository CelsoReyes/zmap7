function [pv, pstd, cv, cstd, kv, kstd, loopout] = brutebootloglike(time_as,n_boots)
    % brutebootloglike Bootstrap analysis of Omori parameters calculated by bruteforceloglike
    %
    % [pv, pstd, cv, cstd, kv, kstd, loopout] = brutebootloglike(time_as, bootloops);
    % ----------------------------------------------------------------------
    % (p,c,k)-pair is mean of the bootstrap values by determining the mean cumulative number modeled a end of the learning period
    % Standard deviations are calculated as the 2nd moment, not to rely fully on normal distributions
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
    % Samuel Neukomm / S. Wiemer / J. Woessner
    % last update: 17.07.03

    % figure parameters from bootstraps
    time_as = sort(time_as);
    n = length(time_as);
    randnr = ciel(rand(n,n_boots)*n); % n x n_boots
    loopout=struct(...
        'pval',nan(n_boots,1),...
        'cval',nan(n_boots,1),...
        'kval',nan(n_boots,1));
    
    for j = 1:n_boots
        newtas = time_as(randnr(:,j)); % jth bootstrap sample (n x j)
        [loopout.pval(j), loopout.cval(j), loopout.kval(j)] = bruteforceloglike(sort(newtas));
    end

    % New version: Choose mean (p,c,k)-variables by modelling the cumulative number at end of
    % the learning period

    % 2nd moment i.e. Standard deviations
    [pstd] = calc_StdDev(loopout.pval);
    [cstd] = calc_StdDev(loopout.cval);
    [kstd] = calc_StdDev(loopout.kval);
    % in some implementations, pstd and cstd are rounded to 2 decimals, kstd to one.

    % Compute best fitting pair of variates
    
    conf_fun = get_confidence_function(pval(end));
    conf_lims = conf_fun(loopout.pval, loopout.cval, loopout.kval, time_as);
    loopout.maxes = max(conf_lims,[],2);
    
    pv = median(loopout.pval);
    cv = median(loopout.cval);
    kv = median(loopout.kval);

