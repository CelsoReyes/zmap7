function [tdiff, ac]  = timediff(j,ci,tau, clus, eqtimes)
    % timediff.m                                         A.Allmann
    % calculates the time difference between the ith and jth event
    % works with variable eqtime from function clustime.m
    % gives the indices ac of the eqs not already related to cluster k1
    
    % j : offset in eqtimes
    % ci : ith cluster
    % tau : look-ahead time
    % clus: clusters (length of catalog)
    % eqtimes: datetimes for eevent catalog (newcat)
    
    tdiff=0;
    n=1;    %tdiff index
    ac=[];
    
    comparetime = eqtimes(ci);
    
    tooearly = eqtimes < comparetime;
    toolate = eqtimes > (comparetime + tau);
    tocompare = eqtimes(~tooearly & ~toolate);
    tdiff = tocompare - comparetime;
    
    while tdiff(n) < tau       %while timedifference smaller than look ahead time
        n=n+1;
        if j > numel(clus)     %to avoid problems at end of catalog
            tdiff(n)=tau;
            break;
        end
        tdiff(n)= eqtimes(j) - comparetime;
        j=j+1;
    end
    
    k2=clus(ci);
    
    j=j-2;
    
    if ci == j
        return
    end
    
    % no cluster has already been found
    if k2~=0
            ac = (find(clus(ci+1:j)~= k2)) + ci;   % indices of eqs not already related to cluster k1
    else                               
            ac = ci+1:j;
    end

