function[cluslength,bgevent,mbg,bg,clustnumbers] = ReasBuildclu(ShortCat,bgevent,clusterID,mbg,k1,bg)     

	%ORIGINAL FROM ZMAP: NEEDS WORK FOR MAPSEIS
	%SUBFUNCTION: ReasenbergDeclus.m MIGHT NOT BE NEEDED
	%---------------------------------------------------
	
	% buildclu.m                                 A.Allmann
	% builds cluster out out of information stored in clus
	% calculates also biggest event in a cluster
	%
	% Last modification 8/95
	
	%global newcat bgevent clus mbg k1 clust clustnumbers cluslength bg
	cluslength=[];
	n=0;
	highestID=max(clusterID); %k1
	uniClust=unique(clusterID);
	uniClust=uniClust(~isnan(uniClust));
	for j=uniClust		                         %for all clusters
	    cluslength(j)=length(find(clusterID==j));  %length of each clusters
	end
	
	tmp=find(cluslength);      %numbers of clusters that are not empty
	
	%That could be done better, for instance use 'unique' on clus and process only the numbers which really are
	%used, optional it might also be an idea see if the thing could be vectorized, although it might be a bit
	%overkill (DE) (and probably slower because of the memory usage but distributed computing could be used)
	%--->lets do that
	
	
	%cluslength,bg,mbg only for events which are not zero
	cluslength=cluslength(tmp); 
	bgevent=bgevent(tmp);
	mbg=mbg(tmp);
	bg=bgevent;
	bgevent=ShortCat(bg,:); %biggest event in a cluster(if more than one,take first)
	
	clustnumbers=(1:length(tmp));    %stores numbers of clusters

end