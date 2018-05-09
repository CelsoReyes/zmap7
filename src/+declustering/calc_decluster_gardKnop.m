function [clusterID,EventType,AlgoInfo] = calc_decluster_gardKnop(mCatalog,nMethod,SetMain)
	% function [mCatDecluster, mCatAfter, vCluster, vCl, vMainCluster] = calc_decluster(mCatalog,nMethod)
	% ----------------------------------------------------------------------------------------------------------
	% 
	% Function to decluster earthquake catalog using the Windowing technique in space and time by 
	% Knopoff & Gardner, GJR astr. Soc, 28, 311-313, 1972
	% Gardner & Knopoff, BSSA, 64,5, 1363-1367, 1974
	% using different windows
	% 
	% Incoming variables
	% mCatalog : Incoming earthquake catalog (ZMAP format)
	% nMethod  : Window length for declustering (see calc_windows.m)
	%            1: Gardener & Knopoff, 1974
	%            2: Gruenthal pers. communication
	%            3: Urhammer, 1986 
	% 
	% Outgoing variables:
	% mCatDecluster : Declustered earthquake catalog
	% mCatAfter     : Catalog of aftershocks (and foreshocks)
	% vCluster      : Vector indicating only aftershocks/foreshocls in cluster using a cluster number
	% vCl           : Vector indicating all events in clusters using a cluster number
	% vMainCluster  : Vector indicating mainshocks of clusters using a cluster number
	%
	% J. Woessner, woessner@seismo.ifg.ethz.ch
	% last update: 29.08.02
	
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
	
	import mapseis.declustering.calc_windows_gardKnop;
	
	%edited for MapSeis: DE 2011
	%This is the first release of the Gardner Knopoff method for mapseis, the code is mainly the same as the zmap version, there might be
	%lot to gain performancewise in case of a rewriting of the code, but for know this should be alright.
	
	
	if nargin<3
		SetMain=false;
	end
	
		
	mCatDecluster = [];
	mCatAfter = [];
	vCluster = zeros(length(mCatalog),1); % Initialize all events as mainshock
	vCl = zeros(length(mCatalog),1); % Initialize all events as mainshock
	vSel = zeros(length(mCatalog),1); % Initialize all events as mainshock
	vMainCluster = zeros(length(mCatalog),1); % Initialize
	
	%[B,MagSortID] = sort(mCatalog(:,6),'descend');
	
	[nXSize, nYsize] = size(mCatalog);
	if nXSize == 0
	    disp('Load new catalog');
	    return
	end
	
	vDecDate = mCatalog(:,3);
	nCount = 0;    % Variable of cluster number
	
	fMagThreshold = min(mCatalog(:,6)); % Set Threshold to minimum magnitude of catalog
	hWaitbar1 = waitbar(0,'Identifying clusters...');
	set(hWaitbar1,'Numbertitle','off','Name','Decluster percentage');
	for nEvent=1:length(mCatalog(:,6))  
	    %nEvent
	    %nCount
	    %nEvent=MagSortID(iCount);
	    if vCluster(nEvent) == 0
	        
	        fMagnitude(nEvent) = mCatalog(nEvent, 6);
	        
	                  %% Define first aftershock zone and determine magnitude of strongest aftershock
	            fMag = fMagnitude(nEvent);
	            [fSpace, fTime] = calc_windows_gardKnop(fMagnitude(nEvent), nMethod);
	            fSpaceDeg = km2deg(fSpace);
	            
	            %% This first if is for events with no location given
	            if isnan(mCatalog(nEvent,1)) %Does this ever happen??? Maybe in a special study (DE)
	                %Select what's on the same time??? (DE)
	                vSel = (mCatalog(:,3) == mCatalog(nEvent,3));
	            
	            else              
	            	%Select what is in range (DE)
	                mPos = [mCatalog(nEvent, 1) mCatalog(nEvent,2)];
	                mPos = repmat(mPos,length(mCatalog(:,1)), 1);
	                mDist = abs(distance(mCatalog(:,1), mCatalog(:,2), mPos(:,1), mPos(:,2)));
	                vSel = ((mDist <= fSpaceDeg) & (vDecDate(:,1)-vDecDate(nEvent,1) >= 0) &...
	                    (vDecDate(:,1)-vDecDate(nEvent,1) <= fTime) & vCluster(nEvent) == 0);          
	                    
	            end;% End of isnan(mCatalog)
	            
	            %maybe here and especially later is a change needed, because it might be expensive to find the "positon" 
	            %in th array later (DE)
	            mTmp = mCatalog(vSel,:);
	            
	            if length(mTmp(:,1)) == 1  % Only one event thus no cluster; IF to determine cluster or not
	                fMaxClusterMag = fMag;
	                
	            else
	                fMaxClusterMag = max(mTmp(:,6));
	                [nIndiceMaxMag] = find(mTmp(:,6) == fMaxClusterMag);
	                fTimeMaxClusterMag = mTmp(max(nIndiceMaxMag),3);
	                
	                %can't stand while loops, try to eliminate it (DE) %probably just sort the whole catalog with magnitude
	                %The while looks ugly but the time it uses is small
	                % Search for event with bigger magnitude in cluster and add to cluster
	                while fMaxClusterMag-fMag > 0
	                    [fSpace, fTime] = calc_windows_gardKnop(fMaxClusterMag, nMethod);
	                    fSpaceDeg = km2deg(fSpace);
	                    
	                    %% Adding aftershocks from bigger aftershock
	                    mPos = [mTmp(min(nIndiceMaxMag),1) mTmp(min(nIndiceMaxMag),2)];
	                    mPos = repmat(mPos,length(mCatalog(:,1)), 1);
	                    mDist = abs(distance(mCatalog(:,1), mCatalog(:,2), mPos(:,1), mPos(:,2)));
	                    vSel2 = ((mDist <= fSpaceDeg) & (vDecDate(:,1)-mTmp(min(nIndiceMaxMag),3) >= 0) &...
	                        (vDecDate(:,1)-mTmp(min(nIndiceMaxMag),3) <= fTime) & vCluster == 0);
	                    mTmp = mCatalog(vSel2,:);
	                    %vSel = (vSel > 0 | vSel2 > 0); % Actual addition %>0 not needed both are logical vectors (DE)
	                    vSel = vSel|vSel2;
	                    if isempty(mTmp) % no events in aftershock zone 
	                        break;
	                    end;
	                    
	                    fMag = fMaxClusterMag;
	                    fMaxClusterMag = max(mTmp(:,6));
	                    [nIndiceMaxMag] = find(mTmp(:,6) == fMaxClusterMag);
	                    fTimeMaxClusterMag = mTmp(max(nIndiceMaxMag),3);
	                    
	                    if fMaxClusterMag - fMag == 0 % no bigger event in aftershock zone
	                        break;
	                    end;
	                    
	                end;  % End of while
	                
	                nCount = nCount + 1; % Set cluster number
	            
	            end; % End of if length(mTmp)
	
	            [vIndice]=find(vSel); % Vector of indices with Clusters
	            vTmpCluster(vIndice,:) = nCount;
	            %length(vTmpCluster(vIndice,:));
	            nI=1; % Variable counting the length of the cluster
	            % Select the right numbers for the cluster using the indice vector vIndice
	            % First: Insert cluster number after check for length
	            % Second: Check if it's a mainshock
	            % Third: Keep the former cluster indice;
	            while nI <= length(vIndice)
	                if (~isempty(vTmpCluster(vIndice(nI))) & length(vTmpCluster(vIndice,:)) > 1 & vCluster(vIndice(nI)) == 0)
	                    vCluster(vIndice(nI)) = vTmpCluster(vIndice(nI));
	                    %vEventnr(vIndice,:) = nEvent;
	                elseif  (~isempty(vTmpCluster(vIndice(nI))) & length(vTmpCluster(vIndice,:)) == 1 & vCluster(vIndice(nI)) == 0)
	                    vCluster(vIndice(nI)) = 0;
	                else
	                    vCluster(vIndice(nI)) = vCluster(vIndice(nI));
	                end;
	                nI=nI+1;
	            end; %End of while nI
	            %                 nCount = nCount + 1; % Set cluster number %% Watch
	            %             end; % End of if to determine cluster or not %% Watch
	            %%% Check if the Cluster is not just one event which can happen in case of keeping the former 
	            %%% cluster number in preceeding while-Loop
	            vSelSingle = (vCluster == nCount);
	            [vIndiceSingle] = find(vSelSingle);
	            %vTmpSingle(vIndiceSingle,:);
	            if length(vIndiceSingle) == 1
	                %nCount
	                %vIndiceSingle
	                vCluster(vIndiceSingle)=0; % Set the event as mainsock
	                nCount = nCount-1; % Correct the cluster number down by one
	            end;
	
	    end; % End of if checking if vCluster == 0 
	    if rem(nEvent,100) == 0
	        waitbar(nEvent/length(mCatalog(:,6)))
	    end; % End updating waitbar
	end; % End of FOR over mCatalog 
	close(hWaitbar1);
	%nCount
	%% vCL Cluster vector with mainshocks in it; vCluster is now modified to get rid of mainshocks
	vCl = vCluster; 
	
	%% Matrix with cluster indice, magnitude and time 
	mTmpCat = [vCluster mCatalog(:,6) mCatalog(:,3)];
	%% Delete largest event from cluster series and add to mainshock catalog
	hWaitbar2 = waitbar(0,'Identifying mainshocks in clusters...');
	set(hWaitbar2,'Numbertitle','off','Name','Mainshock identification ');
	for nCevent = 1:nCount
	    %nCevent
	    vSel4 = (mTmpCat(:,1) == nCevent); % Select cluster 
	    mTmpCat2 = mCatalog(vSel4,:); 
	    fTmpMaxMag = max(mTmpCat2(:,6)); % Select max magnitude of cluster
	    vSelMag = (mTmpCat2(:,6) == fTmpMaxMag);
	    [nMag] = find(vSelMag);
	    if length(nMag) == 1
	        vSel5 = (mTmpCat(:,1) == nCevent & mTmpCat(:,2) == fTmpMaxMag); % Select the event
	        [vIndiceMag] = find(vSel5); % Find indice 
	        vCluster(vIndiceMag) = 0;  % Set cluster value to zero, so it is a mainshock
	        vMainCluster(vIndiceMag) = nCevent; % Set mainshock vector to cluster number
	    elseif length(nMag) == 0
	        disp('Nothing in ')
	        nCevent
	    else
	        vSel = (mTmpCat(:,1) == nCevent & mTmpCat(:,2) == fTmpMaxMag);
	        mTmpCat3 = mCatalog(vSel,:);
	        [vIndiceMag] = min(find(vSel)); % Find minimum indice of event with max magnitude in cluster
	        vCluster(vIndiceMag) = 0;  % Set cluster value to zero, so it is a mainshock
	        vMainCluster(vIndiceMag) = nCevent;  % Set mainshock vector to cluster number
	    end;
	    if rem(nCevent,20) == 0
	        waitbar(nCevent/nCount)
	    end; % End updating waitbar
	end; % End of For nCevent
	close(hWaitbar2);
	%% Create a catalog of aftershocks (mCatAfter) and of declustered catalog (mCatDecluster)
	vSel = (vCluster(:,1) > 0);
	%mCatDecluster=mCatalog(~vSel,:);
	%mCatAfter = mCatalog(vSel,:);
	
	
	
	%create the wanted output for mapseis
	%clusterID,EventType,AlgoInfo
	EventType=ones(length(mCatalog),1);
	clusterID=vCl;
	
	%the type first
	EventType(vCl~=0)=2;
	EventType(vCluster~=0)=3;
	clusterID(clusterID==0)=NaN;
	
	%The original does not set a mainshock if all earhquakes in a cluster have the same Magnitude, this part will 
	%if SetMain is set to true choose the first eq as mainshock, which is as the catalog should be sorted by time
	%the first in the list
	%Also does the original code determine the length of the clusters, this here will do it
	uniqueClust=unique(clusterID(~isnan(clusterID)));
	ClusterLength=zeros(numel(uniqueClust),1);
	if SetMain
		for i=1:numel(ClusterLength);
			ClusterLength(i)=sum(clusterID==uniqueClust(i));
			
			if all(EventType(clusterID==uniqueClust(i))==3)
				TheInder=find(clusterID==uniqueClust(i));
				EventType(TheInder(1))=2;
			end
		end
		
	else
		for i=1:numel(ClusterLength);
			ClusterLength(i)=sum(clusterID==uniqueClust(i));
		end

	
	end
		
	CalcParameter.Method=nMethod;
	CalcParameter.SetMain=SetMain;	
	
	AlgoInfo.Type='Gardner-Knopoff-mapseis-v1';
	AlgoInfo.UsedConfig=CalcParameter;
	AlgoInfo.CalculationDate=date;
	AlgoInfo.ClusterLengths=ClusterLength;
	AlgoInfo.largest_Eq=[];
		
end	
