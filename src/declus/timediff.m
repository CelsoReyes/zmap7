function [tdiff, ac]  = timediff(clus_idx, look_ahead_time, clus, eqtimes)
    % TIMEDIFF calculates the time difference between the ith and jth event
    % works with variable eqtime from function CLUSTIME
    % gives the indices ac of the eqs not already related to cluster k1
    % eqtimes should be sorted!
    
    % ci : ith cluster
    % tau : look-ahead time
    % clus: clusters (length of catalog)
    % eqtimes: datetimes for event catalog, in days  [did not use duration because of overhead]
    
    j=clus_idx+1; % first offset after our index. 
    comparetime = eqtimes(clus_idx);
    cat_length = numel(eqtimes);
    
    
    max_elapsed = comparetime+look_ahead_time;
    
    if eqtimes(end) >= max_elapsed
        while eqtimes(j) < max_elapsed
            j=j+1;
        end
        j=j-1; % j is now the index of the last event within the window (exclusive!)
    else
        j=cat_length;
    end
    
    tdiff = eqtimes(clus_idx+1 : j) - comparetime;
    
    
    if clus_idx == j-1  % no additional events were found.
        ac = [];
        return
    end
    
    this_clusternum=clus(clus_idx);
    
    if this_clusternum~=0
            ac = (find(clus(clus_idx+1:j)~= this_clusternum)) + clus_idx;   % indices of eqs not already related to cluster
    else                               
            ac = clus_idx+1:j;
    end
end