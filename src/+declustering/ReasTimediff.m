function [tdiff, ac]  = ReasTimediff(j,currentIndex,tau,clusterID,eqtime,ShortCat)                     

	%ORIGINAL FROM ZMAP: NEEDS WORK FOR MAPSEIS
	%SUBFUNCTION: ReasenbergDeclus.m MIGHT NOT BE NEEDED
	%---------------------------------------------------
	
	%vectorized version for MapSeis by David Eberhard 2011
	%(has to be checked if it all work like it should
	
	
	% timediff.m                                         A.Allmann
	% calculates the time difference between the ith and jth event
	% works with variable eqtime from function clustime.m
	% gives the indices ac of the eqs not already related to cluster k1 
	% last modification 8/95
	% global  clus eqtime k1 newcat  
	
	%ci: currentIndex
	%oldClustID was k1, but is that needed here?  ---> NO
	
	tdiff(1)=0;
	n=1;
	ac=[];
	
	
	
	%Lets kill that while
	tdiff_raw=eqtime(j:end)-eqtime(currentIndex);
	lowerTau=tdiff_raw(tdiff_raw<tau);
	tdiff(2:(numel(lowerTau)+1))=lowerTau;
	n=numel(tdiff);
	%should be the end position
	j=j+n;
	
	%while tdiff(n) < tau       %while timedifference smaller than look ahead time
		
	%	 if j <= length(ShortCat(:,1))     %to avoid problems at end of catalog
	%	  n=n+1;
	%	  tdiff(n)=eqtime(j)-eqtime(currentIndex);
	%	  j=j+1;
		
	%	 else
	%	  n=n+1;
	%	  tdiff(n)=tau;
	%	 end 
	
	
	%end
	
	
	TheID=clusterID(currentIndex); %k2 == k1 == oldClustID
	j=j-2;  %That needs to be commented: if nothing is found j will be ci+2, as j=i+1 and the while loop will run once (DE) 
	if ~isnan(TheID)
	 	if currentIndex~=j
	 		ac = (find(clusterID(currentIndex+1:j)~=TheID))+currentIndex;   %indices of eqs not already related to
	 	end                                        				%cluster k1
	else
	 	if currentIndex~=j                                    %if no cluster is found already
	 		ac = currentIndex+1:j;
	 	end 
	end
	

end