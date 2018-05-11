function [clusterID,EventType,AlgoInfo] = ReasenbergDecluster(taumin,taumax,xk,xmeff,P,rfact,err,derr,ShortCat) 
			
	%Version for MapSeis by David Eberhard 2011 (testing)
	
	import declustering.*;
	
	%ShortCat is produced by the mapseis ShortCut projector and has the following
	%format:  [lon lat depth datennum mag]
	
	
	
	
	%ORIGINAL FROM ZMAP: NEEDS WORK FOR MAPSEIS
	%------------------------------------------
	%What I in the end need out of this code is a list with the clusters, which events belong to 
	%which cluster and the mainshock of the cluster (DE)
	
	% declus.m                                A.Allmann  
	% main decluster algorithm
	% modified version, uses two different circles for already related events
	% works on newcat
	% different clusters stored with respective numbers in clus
	% Program is based on Raesenberg paper JGR;Vol90;Pages5479-5495;06/10/85
	% Last change 8/95
	
	
	
	% variables given by inputwindow
	%
	% rfact  is factor for interaction radius for dependent events (default 10)
	% xmeff  is "effective" lower magnitude cutoff for catalog,it is raised 
	%         by a factor xk*cmag1 during clusters (default 1.5)
	% xk     is the factor used in xmeff    (default .5)
	% taumin is look ahead time for not clustered events (default one day)
	% taumax is maximum look ahead time for clustered events (default 10 days)
	% P      confidence that you are observing the next event in  the sequence (default is 0.95)
	
	
	
	%basic variables used in the program
	%
	% rmain  interaction zone for not clustered events
	% r1     interaction zone for clustered events
	% rtest  radius in which the program looks for clusters
	% tau    look ahead time
	% tdiff  time difference between jth event and biggest eq 
	% mbg    index of earthquake with biggest magnitude in a cluster 
	% k      index of the cluster
	% k1     working index for cluster
	
	%routine works on newcat
	
	%disp('This is src/declus/declus')
	
	
		
	bg=[];
	LastClustID=[]; %k
	oldClustID=[]; %k1
	largestEq=[]; %mbg: largest Eq of a Cluster
	largeEqID=[]; %bgevent: biggest Eq Id of a Clustter
	equi=[];
	bgdiff=[];
	clust=[];
	clustnumbers=[];
	cluslength=[];
	
	AlgoInfo=[];
	
	man =[taumin;taumax;xk;xmeff;P;rfact;err;derr;];
	
	%[rmain,r1]=funInteract(1,newcat,rfact,xmeff);                     %calculation of interaction radii
	%that function was reduced by someone to only one equation, so the function call might not be really 
	%needed (DE)
	
	%calculation of interaction radii
	%from The funInteract function 
	rmain = 0.011*10.^(0.4*ShortCat(:,5)); %interaction zone for mainshock 
	r1    = rfact*rmain;   %interaction zone if included in a cluster
	
	
	%calculation of the eq-time relative to 1902   %again not needed
	%eqtime=funClustime(1,newcat); 
	%maybe replaced, the original format is datenum anyway (DE)
	
	%calculation of the eq-time relative to 1902 
	%(before 1902 -> no instruments -> no decluster needed)
	%again directly from funClustime 
	eqtime = ShortCat(:,4)-datenum(1902,1,1);
	%remember datenum code is days and fraction of days from year 0000 (can be negative)
	
	%variable to store information wether earthquake is already clustered
	%clus = zeros(1,length(newcat(:,1))); %use NAN (DE)
	
	clusterID = NaN(1,length(ShortCat(:,1))); %clus
	%EventType = zeros(1,length(ShortCat(:,1))); %the eventType (new feature)
	EventType = categorical(zeros(1,length(ShortCat(:,1))),[0 1 2 3],...
        {'unclassified','single','mainshock','aftershock'}); %the eventType (new feature)
	%(0: unclassified, 1: single event, 2: mainshock (largest eq) and 3: aftershock)
	
	LastClustID = 0;           %clusterindex k
	
	lenghtCat=length(ShortCat(:,1))-1; %ltn
	
	
	%QUESTION: Does the temporal order of the EQs play a role? (should be avoided) (DE)
	
	%for every earthquake in newcat, main loop
	for i = 1:lenghtCat 
		%    i 
		% variable needed for distance and timediff
		j=i+1; 
		oldClustID = clusterID(i); %k1: Id which might be 
	   
	  
		% attach interaction time
		% In case of a new event or in case this is the strongest event of its cluster, tau is be set to the minimum
		% specified value taumin. ReasTaucalc calculates tau, based on some equations out of the Reasenberg paper, i think they
		% are based on Omori law and probability, better check to be sure (DE) 
	   
		if ~isnan(oldClustID)                
			%i is already related with a cluster
			%->check if the new Eq is the largest of its "pack"
			if ShortCat(i,5)>=largestEq(oldClustID)        
				%Event is the largests so set to minimum time taumin
				largestEq(oldClustID)=ShortCat(i,5);    %set biggest magnitude to magnitude of i
				largeEqID(oldClustID)=i;               	%index of biggest event is i
				tau=taumin;
			
			else
				%Event is not the biggest
				%--> Calculate tau
				
				bgdiff=eqtime(i)-eqtime(largeEqID(oldClustID));
				
				%Calculate Tau
				tau = ReasTaucalc(xk,largestEq(oldClustID),xmeff,bgdiff,P);
				
				%Assure that tau is in the set border [taumin taumax]
				if tau>taumax
					tau=taumax;
				end
		 
				if tau<taumin
					tau=taumin;
				end
	      
			end
	      
	      
		else 
			%Event with no "friends"
			tau=taumin;
		end
		
		
		%SideEffect of this part, it determines the event with magnitude in the cluster (?) (DE)
		%Maybe the Eventype has to be set here, but I will see, I would rather do it somewhere more logical
		
	   
	   
	   
		%extract eqs that fit interation time window
		[tdiff,suitableEq]=ReasTimediff(j,i,tau,clusterID,eqtime,ShortCat); 
		%This determines the interevent times up to tau, and also checks if the 
		%a event is alreaday in the cluster. The function is a bit ineffective and messing
		%needs definitly work (DE)
	   
		%suitableEq=ac
		
		if size(suitableEq)~=0   %if some eqs qualify for further examination
	      		
			if ~isnan(oldClustID)                     % if i is already related with a cluster
			 	tmp1=find(clusterID(suitableEq)~=oldClustID);       %eqs with a clustnumber different than i
			 
			 	if ~isempty(tmp1)
			 		suitableEq=suitableEq(tmp1); 
			 	end
			 	%may not be needed as ReasTimediff does something similar
			end 
				
			 	
			if tau==taumin %--> the event is either new or it is the largest event in the cluster (DE)
				rtest1=r1(i);
				rtest2=0; %why? (DE)
			else
				rtest1=r1(i);
				rtest2=rmain(largeEqID(oldClustID));
			end
	      
			%calculate distances from the epicenter of biggest and most recent eq
			if isnan(oldClustID)
				%untouched eq
				[dist1,dist2]=ReasDistance(i,i,suitableEq,ShortCat,err,derr);
			else   
				%has its bigger brothers
				[dist1,dist2]=ReasDistance(i,largeEqID(oldClustID),suitableEq,ShortCat,err,derr);     
			end;                                   
			
			%Instead of this function also the internal distance function of matlab could be used
			%but it would not used the error of the depth and location, besides it might not be that
			%much faster as the funDistance subroutine does not contain any loops and is vectorized. 
			%The question is more if unnecessarily some distances are calculated twice, which might 
			%be prevented (DE)
	      
	      
	      		%extract eqs that fit the spatial interaction time (time&spatial? probably a typo DE)         
			inRange0=find(dist1<= rtest1 | dist2<= rtest2); %sl0
			
			
			%dist1 seems to be distance between current event and all other event pausible (ac) and dist2 seems to be
			%distance between mainshock (largest Mag) and all other events pausible (ac)
			%So all events are selected which are either in the interaction zone of the current eq or in the interaction zone of 
			%largest eq in the cluster of the current eq. ->that's why ac should only contain events which are in the time window (DE)
	      
					
			%Here the cluster indexes are set and clusters merged (DE)
			%--
			if size(inRange0)~=0    %if some eqs qualify for further examination
				inRanTim=suitableEq(inRange0);      %ll %eqs that fit spatial and temporal criterion 
				inRanTimA=inRanTim(~isnan(clusterID(inRanTim))); %lla   %eqs which are already related with a cluster
				inRanTimB=inRanTim(isnan(clusterID(inRanTim))); %llb   %eqs that are not already in a cluster
				%inRanTimA=suitableEq(find(~isnan(clusterID(inRanTim))));
				%inRanTimB=suitableEq(find(isnan(clusterID(inRanTim))));
				%this could be written better without the find command (DE) (used logical indexes)
				
				
				if ~isempty(inRanTimA)            %find smallest clustnumber in the case several
					smallOne=min(clusterID(inRanTimA));   %sl1         %numbers are possible
	      
					if ~isnan(oldClustID)
						oldClustID= min([smallOne,oldClustID]);
					else 
						oldClustID = smallOne;
					end  
		      
					if isnan(clusterID(i))
						clusterID(i)=oldClustID;
					end                
	      
					%merge all related clusters together in the cluster with the smallest number
					smallTwo=inRanTimA(clusterID(inRanTimA)~=oldClustID); %sl2       
					%smallTwo=inRanTimA(find(clusterID(inRanTimA)~=oldClustID)); %sl2
			
					%Hmmm, again a for-loop, there might be a way to prefent this (DE)
					for j1=[i,smallTwo]
						if clusterID(j1)~=oldClustID
							select5=clusterID==clusterID(j1); %sl5
							clusterID(select5)=oldClustID;
						end
					end
		    
				end
		 
				if isnan(oldClustID)                   %if there was neither an event in the interaction
					LastClustID=LastClustID+1;                         %zone nor i, already related to cluster 
					oldClustID=LastClustID;          
					clusterID(i)=oldClustID;
					largestEq(oldClustID)=ShortCat(i,5);
					largeEqID(oldClustID)=i;
				end
				
				if size(inRanTimB)>0                   %attach clustnumber to events not already 
					clusterID(inRanTimB)=oldClustID;  %related to a cluster
				end
		 
			end                          %if inRange0 end 
			
		end                           %if suitableEq end
		
	end                            %for loop end  
	
	
	%The found clusters are applied to the catalog, at least here a change is needed, as I need a vector with clusternumber, one with clusterType and
	%probably some meta data in a structur. (DE)
	
	if all(isnan(clusterID)) 
	    	return

	else
		[cluslength,bgevent,mbg,bg,clustnumbers] = ReasBuildclu(ShortCat,largeEqID,clusterID,largestEq,oldClustID,bg);  %builds a matrix clust that stored clusters
		%[a,is_mainshock] = funBuildcat(newcat,clus,bg,bgevent);        %new catalog for main program
		
		%Do the translation to ClusterID List and EventType  
		%default is single if anything is processed (which is the case)
		EventType = categorical(ones(1,length(ShortCat(:,1))),...
            [0 1 2 3],...
            {'unclassified','single','mainshock','aftershock'});
		EventType(~isnan(clusterID))='aftershock';
		EventType(largeEqID)='mainshock';
		
		ParamInput=struct(	'taumin',taumin,...
					'taumax',taumax,...
					'xk',xk,...
					'xmeff',xmeff,...
					'P',P,...
					'rfact',rfact,...
					'err',err,...
					'derr',derr);
		
		AlgoInfo.Type='Reasenberg-mapseis-v1';
		AlgoInfo.UsedConfig=ParamInput;
		AlgoInfo.CalculationDate=date;
		
		%Those two can cause problems, thats why the catchs there
		try
			AlgoInfo.ClusterLengths=[clustnumbers',cluslength'];
		catch
			AlgoInfo.ClusterLengths={clustnumbers',cluslength'};
		end
		
		try
			AlgoInfo.largest_Eq=[clustnumbers',largeEqID',mbg'];
		catch
			AlgoInfo.largest_Eq={clustnumbers',largeEqID',mbg'};
		end
	end



end

