function [newt2,is_mainshock]=ReasBuildcat(newcat,clus,bg,bgevent) 

	%ORIGINAL FROM ZMAP: NEEDS WORK FOR MAPSEIS
	%SUBFUNCTION: ReasenbergDeclus.m MIGHT NOT BE NEEDED
	%---------------------------------------------------
	
	%buildcat.m                                A.Allmann
	%builds declustered catalog with equivalent events
	%
	%Last modification 8/95
	%global newcat equi clus eqtime bg original backequi bgevent
	
	
	tm1=find(clus==0);    %elements which are not related to a cluster
	tmpcat=[newcat(tm1,:);bgevent]; % builds catalog with biggest events instead
	
	% I am not sure that this is right , may need 10 coloum 
	                                   %equivalent event
	[tm2,i]=sort([tm1';bg']);  %i is the index vector to sort tmpcat
	
	%elseif var1==2
	%  if isempty(backequi)
	%   tmpcat=[original(tm1,1:9);equi(:,1:9)];
	%  else
	%   tmpcat=[original(tm1,1:9);backequi(:,1:9)];
	%  end
	% [tm2,i]=sort(tmpcat(:,3));
	%end
	 
	newt2=tmpcat(i,:);       %sorted catalog,ready to load in basic program
	
	is_mainshock = [tm1';bg'];  %% contains indeces of all cluster mainshocks.  added  12/7/05
	 



end