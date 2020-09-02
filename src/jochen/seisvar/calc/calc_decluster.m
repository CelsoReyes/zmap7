function [declusteredCatalog, aftershockCatalog, vCluster, vCl, vMainCluster] = calc_decluster(inCatalog, dcwMethod)
    % Decluster earthquake catalog using the Windowing technique in space and time
    %
    % [declusteredCatalog, aftershockCatalog, vCluster, vCl, vMainCluster] = calc_decluster(inCatalog, dcwMethod)
    % ----------------------------------------------------------------------------------------------------------
    
    % Knopoff & Gardner, GJR astr. Soc, 28, 311-313, 1972
    % Gardner & Knopoff, BSSA, 64,5, 1363-1367, 1974
    % using different windows
    %
    % Incoming variables
    % inCatalog : Incoming earthquake catalog (ZMAP format)
    % dcwMethod  :  decluster window calculation method  (see DeclusterWindowingMethods)
    %
    % Outgoing variables:
    % declusteredCatalog    : Declustered earthquake catalog
    % aftershockCatalog     : Catalog of aftershocks (and foreshocks)
    % vCluster      : Vector indicating only aftershocks/foreshocks in cluster using a cluster number
    % vCl           : Vector indicating all events in clusters using a cluster number
    % vMainCluster  : Vector indicating mainshocks of clusters using a cluster number
    %
    % J. Woessner, woessner@seismo.ifg.ethz.ch
    % updated: 29.08.02
    %
    % see also DeclusterWindowingMethods
    
    %% Added:
    % 31.07.02 Correction for problem of mainshocks with a cluster number as aftershocks belong to two sequences
    % 31.07.02 Corrected fMaxClusterMag(nMagCount) to fMaxClusterMag, since counting variable not needed
    % 31.07.02 Improved resizing time window by adding time difference from initial event to bigger aftershock
    % 13.08.02 Added waitbars
    % 28.08.02 Changed distance determination using now distance and repmat
    % 29.08.02 Cluster determination strategy change: Now selecting all aftershocks using the window of the first shock,
    %          adding the events from the bigger aftershocks (later labelled mainshocks); calc_decluster_ver3.m keeps
    %          resizing technique
    
    %%% Remember: Improve zero length cluster problem which might appear
    
    %% Initialize Vectors and Matrices
    report_this_filefun();
    assert(issorted(inCatalog.Date),'Catalog must be sorted by date before declusting');
    
    declusteredCatalog = [];
    aftershockCatalog = [];
    
    % Initialize all events as mainshock
    vCluster        = zeros(inCatalog.Count,1); % Vector indicating only aftershocks/foreshocks in cluster using a cluster number
    vCl             = zeros(inCatalog.Count,1); % Vector indicating all events in clusters using a cluster number
    vSel            = zeros(inCatalog.Count,1); % ??? inZone
    vMainCluster    = zeros(inCatalog.Count,1); % Vector indicating mainshocks of clusters using a cluster number
    
    if isempty(inCatalog)
        msg.dbdisp('Load a catalog first');
        beep
        return
    end
    
    thisClusterNumber = 0;    % track current cluster number
    
    fMagThreshold = min(inCatalog.Magnitude); % Set Threshold to minimum magnitude of catalog
    hWaitbar1 = waitbar(0,'Identifying clusters...');
    set(hWaitbar1,'Numbertitle','off','Name','Decluster percentage');
    
    % store relevant data in a table for ease of use
    quakes = table(inCatalog.Date, inCatalog.Longitude, inCatalog.Latitude, inCatalog.Magnitude);
    quakes.Properties.VariableNames = {'Date','Lon','Lat','Mag'};
    
    [quakes.KmZone, quakes.DurZone] = calc_windows(quakes.Mag, dcwMethod);
    quakes.DegZone = km2deg(quakes.KmZone);
    
    quakes.ClusterNumber = zeros(size(quakes.DegZone));
    
    
    for nEvent=1:height(quakes)
        thisEvent = quakes(nEvent,:);
        if thisEvent.ClusterNumber == 0 && thisEvent.Mag >= fMagThreshold
            
            %% Define first aftershock zone and determine magnitude of strongest aftershock
            
            if isnan(thisEvent.Lon)
                % no location was given. (?)
                inZone = (quakes.Date == thisEvent.Date);
            else
                inZone = getIndexForEventsInZone(quakes, thisEvent);
            end
            
            quakesInZone = quakes(inZone,:);
            if height(quakesInZone) <= 1  % Only one event thus no cluster. Skip ahead
                continue;
            else
                maxClusterMag       = max(quakesInZone.Mag);
                biggerAftershocks   = quakesInZone(quakesInZone.Mag == maxClusterMag , :);
                if ~isempty(biggerAftershocks)
                    biggerAftershockFirst = biggerAftershocks(1,:);
                    
                    
                    % Search for event with bigger magnitude in cluster and add to cluster
                    % Note: quakesInZone drifts during this loop
                    mag = thisEvent.Mag;
                    while maxClusterMag > mag
                        
                        %% Adding aftershocks from bigger aftershock
                        mag = biggerAftershockFirst.Mag;
                        inNewZone = getIndexForEventsInZone(quakes, biggerAftershockFirst);
                        
                        quakesInZone = quakes(inNewZone,:);
                        inZone = (inZone | inNewZone); % combine
                        if isempty(quakesInZone) % no events in aftershock zone
                            break;
                        end
                        prevMaxMag = maxClusterMag;
                        maxClusterMag = max(quakesInZone.Mag);
                        if maxClusterMag > prevMaxMag % no bigger event in aftershock zone
                            break;
                        end
                    end
                end
            end
            
            quakes.ClusterNumber(inZone) = thisClusterNumber;
            vCluster(inZone) = thisClusterNumber;
            nQuakesInCluster = sum(inZone);
            
            thisClusterNumber = thisClusterNumber + 1; % Set cluster number
            
            %% I have no idea what this is actually trying to do. Remarking it out, since I tend to beleive it is counterproductive code-CGR
            %{
            vIndice=find(inZone); % Vector of indices with Clusters
            vTmpCluster(vIndice,:) = thisClusterNumber;
            %length(vTmpCluster(vIndice,:));
            nI=1; % Variable counting the length of the cluster
            
            
            % Select the right numbers for the cluster using the indice vector vIndice
            % First: Insert cluster number after check for length
            % Second: Check if it's a mainshock
            % Third: Keep the former cluster indice;
            while nI <= nQuakesInCluster
                someQuakeInCluster = vIndice(nI); % ALWAYS a quake in this cluster
                someClusterNum = vTmpCluster(someQuakeInCluster); % therefore, alwayas THIS cluster number
                
                if (~isempty(someClusterNum)) && length(vTmpCluster(vIndice,:)) > 1 && vCluster(someQuakeInCluster) == 0)
                    vCluster(vIndice(nI)) = someClusterNum;
                elseif  (~isempty(someClusterNum)  && length(vTmpCluster(vIndice,:)) == 1  && vCluster(someQuakeInCluster) == 0)
                    vCluster(someQuakeInCluster) = 0;
                else
                    vCluster(someQuakeInCluster) = vCluster(someQuakeInCluster);
                end
                nI=nI+1;
            end
            %}
            
            
            %% Check if the Cluster is not just one event which can happen in case of keeping the former
            % cluster number in preceeding while-Loop
            
            assert(nQuakesInCluster > 1, 'a single quake should not have made it through to this point');
        end 
        
        if rem(nEvent,100) == 0
            waitbar(nEvent / height(quakes))
        end % End updating waitbar
        
    end % End of FOR over inCatalog
    
    close(hWaitbar1);
    
    
    %% vCL Cluster vector with mainshocks in it; vCluster is now modified to get rid of mainshocks
    vCl = vCluster;
    
    %% Matrix with cluster indice, magnitude and time
    quakes.vCluster = vCluster;
    
    %% Delete largest event from cluster series and add to mainshock catalog
    totalClusters = max(quakes.ClusterNumber);
    
    for thisClust = 1:totalClusters
        magsInCluster = quakes.Mag(quakes.vCluster == thisClust);
        maxClustMag =  max(magsInCluster);
        firstBiggestEvent = find( quakes.vCluster == thisClust & quakes.Mag == maxClustMag, 1, 'first');
        vCluster(firstBiggestEvent) = 0; % push it back to the mainshock category
        vMainCluster(firstBiggestEvent) = thisClust;
    end
    
    %% Create a catalog of aftershocks (aftershockCatalog) and of declustered catalog (declusteredCatalog)
    inSomeCluster = (vCluster(:,1) > 0);
    declusteredCatalog=inCatalog.subset(~inSomeCluster);
    declusteredCatalog.Name = "GK-Declustered("+string(dcwMethod)+") "+ declusteredCatalog.Name;
    aftershockCatalog = inCatalog.subset(inSomeCluster);
    aftershockCatalog.Name = "GK-Fore/Aftershocks("+string(dcwMethod)+") " + aftershockCatalog.Name;
end

function inZone = getIndexForEventsInZone(quakes, thisEvent)
    
    % avoid calculating distance for quakes that are definitely ignored
    startTime = thisEvent.Date;
    idx = quakes.Date > startTime;
    mDist = nan(size(idx));
    mDist(idx) = distance(quakes.Lat(idx), quakes.Lon(idx), thisEvent.Lat, thisEvent.Lon); % lats and lons were reversed!
    
    inZone = mDist <= thisEvent.DegZone &...
        quakes.Date > thisEvent.Date &...
        quakes.Date - thisEvent.Date <= thisEvent.DurZone &...
        quakes.ClusterNumber == 0;
end