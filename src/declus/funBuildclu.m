function[cluslength,bgevent,mbg,bg,clustnumbers] = funBuildclu(mycat,bgevent,clus,mbg,k1,bg)
% fnBuildclu                                 A.Allmann
% builds cluster out out of information stored in clus
% calculates also biggest event in a cluster
%
    %  originally, "mycat" was "newcat"
%modified by C Reyes 2017

%global mycat clus mbg k1 clust clustnumbers cluslength 
%global bgevent bg
cluslength=[];
n=0;
k1=max(clus);
for j=1:k1                         %for all clusters
    cluslength(j)=length(find(clus==j));  %length of each clusters
end

tmp=find(cluslength);      %numbers of clusters that are not empty

%cluslength,bg,mbg only for events which are not zero
cluslength=cluslength(tmp);
bgevent=bgevent(tmp);
mbg=mbg(tmp);
bg=bgevent;
bgevent=mycat.subset(bg); %biggest event in a cluster(if more than one,take first)

clustnumbers=(1:length(tmp));    %stores numbers of clusters

