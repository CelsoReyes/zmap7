function [ClusterID,EventType,AlgoInfo] =  clusterSLIDERmag(ShortCat,MainMag,BackTime,ForeTime,MinRad,MagRadScale,MagRadConst)

	% Example [mCatclus] =  clusterSTEPmag(mCatalog, 1.95, 1.95, 1984, 1, 1);
	
	% code to cluster catalog with spatial windows according to STEP forecasting model 
	% with sliding windows of t1 backwards in time and t2 forward in time
	% starting with the largest earthquake in the catalog
	
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
	% Annemarie Christophersen, 31. January 2008
	
	
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
	
	%may make this switchable if needed
	Rounding=true;
	

	%init work arrays
	numEvents = length(ShortCat);
	WorkArray=zeros(numEvents,4);
	WorkArray(:,1)= (1:numEvents)'; %introduce column 11 with row number
	
	%init output
	ClusterID=nan(numEvents,1);
	EventType=ones(numEvents,1);
	InitEvent=false(numEvents,1);
	AlgoInfo=[];
	
	%InitEvent is currently not directly supported by mapseis, but will be 
	%added to AlgoInfo, so it can be used by specialiced algorithms

	clusterno = 1;


	%Dtafter = t2/365; %30 days in decimal years
	%Dtbefore = t1/365; %2 days in decimal years
	clusterno = 1;
	

	
	
	while any(WorkArray(:,2)==0)
		notClustered=WorkArray(:,2)==0;
	    
		[maxmag IDX]=max(ShortCat(notClustered,5)); %the magnitude of the largest earthquake not yet clustered
		maxmag=maxmag(1); %could have mor than one maximum afterall
		NrInGame=WorkArray(notClustered,1);
		ActualIndex=NrInGame(IDX(1));
		
	   	lino = ActualIndex;
	   	WorkArray(lino,2)=clusterno; %write cluster number into column 12
	   	searchradius=max(MinRad, 10^(MagRadScale*maxmag-MagRadConst)); %calculate search radius
	    
		%get data of the new event
		tref = ShortCat(lino,4); %set reference time
		latref = ShortCat(lino,2); %set reference latitude
		lonref = ShortCat(lino,1); %set reference longitude
		
		%search for earthquakes before, extend by sliding time windows of t1
		eventsDtbefore=(ShortCat(:,4) > tref-BackTime & ShortCat(:,4) < tref);
		eventsbefore = sum(eventsDtbefore);
		linobefore = lino-eventsbefore;
		    
		    
		    
		%%That did not work like it was intended
		%%--------------------------------------
		    
		% for i=linobefore:lino
			% if (b(i,12) == 0) % don't bother if event already clustered
			    % edist = deg2km(distance(latref,lonref,ShortCat(i,2),ShortCat(i,1))); %calculate distance to mainshock
			    % if (edist <= searchradius)
				% WorkArray(i,2)=clusterno;
				% %make this event new tref and search for events before
				% tref=ShortCat(i,4);
				% eventsDtbefore=(ShortCat(:,4) > tref-BackTime & ShortCat(:,4) < tref);
				% eventsbefore = length(b(eventsDtbefore,1));
				% linobefore = max(1, i-eventsbefore);
				% i=linobefore; %is this the right way to restart loop at linobefore?
			    % end
			% end
		% end %this could now have an earlier linebefore and will loop up to lino 
		% % where lino remains the number of mainshoc
		% % now look for later earthquakes
		    
		%old version whould not work, for "borders" once set, will stay as the are;
		i=linobefore;
		while i<=lino
			if WorkArray(i,2)==0
				edist = deg2km(distance(latref,lonref,ShortCat(i,2),ShortCat(i,1))); %calculate distance to mainshock
				if (edist <= searchradius)
					WorkArray(i,2)=clusterno;
					%make this event new tref and search for events before
					tref=ShortCat(i,4);
					eventsDtbefore=(ShortCat(:,4) > tref-BackTime & ShortCat(:,4) < tref);
					eventsbefore = sum(eventsDtbefore);
					linobefore = max(1, i-eventsbefore);
					i=linobefore; %Now it does restart 
					
				else
					i=i+1;
				end
			else
				i=i+1;
			end
			
		end
	    
	    
	
		tref=ShortCat(lino,4); %reset reference time to mainshock
		
		while (lino < numEvents+1) && ShortCat(lino,4) < (tref+ForeTime) 
			if WorkArray(lino,2) == 0
				edist = deg2km(distance(latref,lonref,ShortCat(lino,2),ShortCat(lino,1)));
				if (edist <= searchradius)
					WorkArray(lino,2)=clusterno;
			
					%Not needed already cutted
					%if (ShortCat(lino,6) > Mc)
					tref=ShortCat(lino,4); %set reference time to new earthquake in cluster
		
				end
				lino=lino+1;
			end
		end
		
		
		
		clusterno=clusterno+1;
		
		
	end
	
	%Ouput clustered matrix
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
	% column 11: line number
	% column 12: cluster number
	% column 13: mainshock with its cluster number
	% column 14: initiating event cluster number
	
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
	
	AlgoInfo.Type='SLIDER-Magnitude-mapseis-v1';
	AlgoInfo.UsedConfig=ParamInput;
	AlgoInfo.CalculationDate=date;
	AlgoInfo.InitialEvents=InitEvent;
	AlgoInfo.WorkArray=WorkArray;
	
end	
