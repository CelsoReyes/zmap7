classdef ClusterState
    % CLUSTERSTATE contains variables used by zmap clustering. were mostly globals. 
    
    properties
        bg
        
        k % index of cluster
        k1 % working index for cluster
        mbg % index of EQ with biggest magnitude in cluster
        bgevent %indices
        bgdiff % indices
        
        
        rmain_km % inderaction zone for mainshock, km
        r1 % intereaction zone if included in a cluster, km
        eqtime % time of all earthquakes catalogs
        
        equi
        ltn
        clus 
        clust 
        clustnumbers
        cluslength
        
        xmeff = 1.5 % "effective" lower magnitude cutoff for catalog. raised during clusters by xk*cmag1
        xk = 0.5        % factor used in xmeff
        rfact = 10      % factor for interaction radius for dependent events
        taumin = days(1) % look ahead time for not clustered events
        taumax = days(10)% look ahead time for clustered events
        P = 0.95 % to be P confident that you are observing the next event in the sequence
    end
end
    