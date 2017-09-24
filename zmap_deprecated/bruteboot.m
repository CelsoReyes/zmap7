function [pv, pstd, cv, cstd, kv, kstd, loopout] = bruteboot(time_as)
    % function [pv, pstd, cv, cstd, kv, kstd, loopout] = bruteboot(time_as);
    % ----------------------------------------------------------------------
    % bootstrap analysis of Omori parameters calculated by bruteforce.m
    %
    % Input parameters:
    %   time_as     Delay times [days]
    %
    % Output parameters:
    %   pv / pstd   p value / standard deviation
    %   cv / cstd   c value / standard deviation
    %   kv / kstd   k value / standard deviation
    %   loopout     contains all results
    %
    % Samuel Neukomm
    % July 30, 2002

    time_as = sort(time_as);
    bootloops = 50; % number of bootstrap samples
    n = length(time_as);
    loopout = [];
    for j = 1:bootloops
        clear newtas
        randnr = ceil(rand(n,1)*n);
        i = (1:n)';
        newtas(i,:) = time_as(randnr(i),:); % bootstrap sample
        [pval, cval, kval] = bruteforce(sort(newtas)); % bruteforce.m is called
        loopout = [loopout; pval cval kval];
    end

    pv = round(100*mean(loopout(:,1)))/100; 
    pstd = round(100*std(loopout(:,1)))/100;
    
    cv = round(100*mean(loopout(:,2)))/100; 
    cstd = round(100*std(loopout(:,2)))/100;
    
    kv = round(10*mean(loopout(:,3)))/10; 
    kstd = round(10*std(loopout(:,3)))/10;

    % unreasonable parameter values -> no result
    if pv < 0.6 | pv > 2.3 | cv < 0.01 | cv > 3 | cv < cstd | pv < pstd | kv < kstd
        pv = nan; pstd = nan;
        cv = nan; cstd = nan;
        kv = nan; kstd = nan;
    end
end

