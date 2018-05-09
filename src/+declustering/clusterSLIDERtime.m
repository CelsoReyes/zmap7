function [ClusterID,EventType,AlgoInfo] =  clusterSLIDERtime(ShortCat,MainMag,BackTime,ForeTime,MinRad,MagRadScale,MagRadConst)

	% Example [mCatclus] =  clusterGK(b, 1.95, 1.95, 1984, 1, 1);
	
	%
	% Input parameters:
	%   mCatalog        Earthquake catalog
	%   Mainmag         minimum mainmag magnitude
	%   Mc              Completeness magnitude 
	%   startyear       
	%   t1              time before an earthquake in days
	%   t2              time window following an earthquake in days
	%
	% Output parameters:
	%   fBValue         mCatclus: The clustered catalog for further anaysis
	%
	% Annemarie Christophersen, 23. August 2007
	
	
	% Clustering function, based on Annemarie's perl codes for finding
	% aftershock sequences, 14 March 2007
	
	% Code written for catalogue under zmap, thus the input
	% catalogue is in the variable a, where
	% column 1: longitude
	% column 2: latitude
	% column 3: year (decimal year, including seconds)
	% column 4: month
	% column 5: day
	% column 6: magnitude
	% column 7: depth
	% column 8: hour
	% column 9: minute
	% column 10: seconds
	% column 11-23 not important for clustering and cluster analysis
	% column 24: SCSN flag for event type (l=local, r=regional, q=quarry)
	
	% variables used
	% mc completeness magnitude
	% twindow duration in time in which to look for related events
	
	%Converted for MapSeis by DE 21.6.2012
	
	
	
	%Default values
	%MinRad=5;
	%MagRadScale=0.59;
	%MagRadConst=2.44;
	
	%may make this switchable if needed
	Rounding=true;
	

	%init work arrays
	numEvents = length(ShortCat);
	WorkArray=zeros(numEvents,4);
		
	%init output
	ClusterID=nan(numEvents,1);
	EventType=ones(numEvents,1);
	InitEvent=false(numEvents,1);
	AlgoInfo=[];
	
	%InitEvent is currently not directly supported by mapseis, but will be 
	%added to AlgoInfo, so it can be used by specialiced algorithms

	clusterno = 1;

	
	
	% find the number of rows of this new matrix be
	
	for i = 1:numEvents
	    %write i to screen
	    if rem(i,100) == 0;
		disp(['Current Step: ',num2str(i),' of ', num2str(numEvents)]);
	    end
	    % write to screen every 100th line
	    
	    if (WorkArray(i,2) == 0 & ShortCat(i,5) > MainMag)
		%We got a new one
		
		%Get Data of new event
	    	tref=ShortCat(i,4); %reference time
		magref=ShortCat(i,5); %reference mag
		latref = ShortCat(i,2);
		lonref = ShortCat(i,1);
		
		%give it a cluster number for now
		WorkArray(i,2)=clusterno;
		
		%search radius according to Wells-Coppersmith
		searchradius=max(MinRad, 10^(MagRadScale*magref-MagRadConst));
		 
		%find events before this one
		eventsDtbefore=(ShortCat(:,4) > tref-BackTime & ShortCat(:,4) < tref);
		eventsbefore = sum(eventsDtbefore);
		lino = i-eventsbefore;
	
		while ShortCat(lino,4) < (tref+ForeTime) & (lino+1 < numEvents)
		
		    if WorkArray(lino,2) == 0
			
			edist = deg2km(distance(latref,lonref,ShortCat(lino,2),ShortCat(lino,1)));
			% distance is a mapping toolbox function that calculates
			% the distance between to points on the surface of the
			% earth from lat lon and deg2km is mapping toolbox function
			% to calculate that distance in km
			
			if (edist <= searchradius)
			    WorkArray(lino,2)=clusterno;
			    %changed, because catalog should already be cutted
			    %if (ShortCat(lino,5) > Mc && ShortCat(lino,4) >tref)
			    
			    if (ShortCat(lino,4) >tref)&(ShortCat(lino,5) > MainMag)
				tref=ShortCat(lino,4);
			    end
			    
			    %old event bigger than current one
			    %make newone to the reference
			    if ShortCat(lino,5) > magref
				latref = ShortCat(lino,2);
				lonref = ShortCat(lino,1);
				magref= ShortCat(lino,5);
				eventsDtbefore=(ShortCat(:,4) > tref-BackTime & ShortCat(:,4) < tref);
				eventsbefore = sum(eventsDtbefore);
				
				%update lino (that's why it needs a while instead of a for
				lino = lino-eventsbefore -1;
				
			    end
			    
			    
			end
			
			
			%searchradius=max(5, 10^(0.59*magref-2.44));
			searchradius=max(MinRad, 10^(MagRadScale*magref-MagRadConst));
		    end
		    
		    lino=lino+1;
		    
		end
		
		clusterno=clusterno+1;
		
	    end
	    
	
	
		
		
	end
	
	
	
	
	if Rounding
		ShortCat(:,5)=round(ShortCat(:,5)*10)/10;%  round magnitudes to 0.1
	end
	
	%may not be needed anymore -> it is needed
	WorkArray(:,1)= 1:length(ShortCat)'; %introduce column 1 with row number

	%WorkArray(WorkArray(:,2)==0,2)=nan;
	UsedCluster=unique(WorkArray(~isnan(WorkArray(:,2))&WorkArray(:,2)~=0,2));
	clusterno=1;
	
	
	disp(numel(UsedCluster));
	
	for i=UsedCluster'
		inCluster = WorkArray(:,2)==i;
		
		if sum(inCluster) >1
			%A real cluster
			
			%First mark all as Events of the cluster and as Aftershocks
			ClusterID(inCluster)=clusterno;
			EventType(inCluster)=3;
			
			%find the first of the largest events label it as mainshock
			[MaxMag IDX] = max(ShortCat(inCluster,5));
			availIndex=WorkArray(inCluster,1);
			MrMaxMag=availIndex(IDX(1));
			EventType(MrMaxMag)=2;
			
			%Mark initial event
			[MinTime IDX] = min(ShortCat(inCluster,4));
			availIndex=WorkArray(inCluster,1);
			MrInit=availIndex(IDX(1));
			InitEvent(MrInit)=true;
			
			clusterno=clusterno+1;
			
		elseif sum(inCluster)==1
			%only one event
			ClusterID(inCluster)=nan;
			EventType(inCluster)=1;
			
			%clusterno=clusterno+1;
			
		end
		
		
		
	end
	
	%And set all not assign clusters to NaN and 1
	notInClust=WorkArray(:,2)==0;
	ClusterID(notInClust)=nan;
	EventType(notInClust)=1
	
	
	%And finally the AlgoInfo
	ParamInput=struct(	'MainMag',MainMag,...
				'BackTime',BackTime,...
				'ForeTime',ForeTime,...
				'MinRad',MinRad,...
				'MagRadScale',MagRadScale,...
				'MagRadConst',MagRadConst);
	
	AlgoInfo.Type='SLIDER-Time-mapseis-v1';
	AlgoInfo.UsedConfig=ParamInput;
	AlgoInfo.CalculationDate=date;
	AlgoInfo.InitialEvents=InitEvent;
	AlgoInfo.WorkArray=WorkArray;
	
	
	
	
end	
