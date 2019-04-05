function [tdiff, ac]  = timediff(clus_idx, look_ahead_time, clus, eqtimes)
    % TIMEDIFF calculates the time difference between the ith and jth event
    % works with variable eqtime from function CLUSTIME
    % gives the indices ac of the eqs not already related to cluster k1
    % eqtimes should be sorted!
    %
    % clus_idx : ith cluster (ci)
    % look_ahead : look-ahead time (tau)
    % clus: clusters (length of catalog)
    % eqtimes: datetimes for event catalog, in days  [did not use duration because of overhead]
    %
    % tdiff: is time between jth event and eqtimes(clus_idx)
    % ac: index of each event within the cluster
    
    comparetime = eqtimes(clus_idx);
    
    first_event = clus_idx + 1; % in cluster
    last_event = numel(eqtimes);
    max_elapsed = comparetime + look_ahead_time;
    
    if eqtimes(end) >= max_elapsed
        last_event = find(eqtimes(first_event : last_event) < max_elapsed, 1, 'last') + clus_idx;
    end
    
    tdiff = eqtimes(first_event : last_event) - comparetime;
    
    if first_event == last_event
        % no additional events were found.
        ac = [];
    else
        
        this_clusternum = clus(clus_idx);
        
        
        if this_clusternum == 0
            ac = first_event:last_event;
        else
            % indices of eqs not already related to this cluster
            ac = (find(clus(first_event : last_event) ~= this_clusternum)) + clus_idx;
        end
    end
    ac = ac(:);
end