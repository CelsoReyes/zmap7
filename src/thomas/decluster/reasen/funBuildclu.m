function[cluslength,bgevent,mbg,bg,clustnumbers] = funBuildclu(ZG.newcat,bgevent,clus,mbg,k1,bg)
% buildclu.m                                 A.Allmann
% builds cluster out out of information stored in clus
% calculates also biggest event in a cluster
%
% Last modification 8/95

%global ZG.newcat bgevent clus mbg k1 clust clustnumbers cluslength bg
cluslength=[];
n=0;
k1=max(clus);
for j=1:k1                         %for all clusters
    cluslength(j)=length(find(clus==j));  %length of each clusters
end

tmp=find(cluslength);      %numbers of clusters that are not empty

% modified to aviod large matrix clust

%clust=zeros(max(cluslength),length(tmp));

%for j=tmp                    %for all not empty clusters
 %  n=n+1;
 %  clust(1:cluslength(j),n)=find(clus==j)'; %matrix which stores clusters
%end


%cluslength,bg,mbg only for events which are not zero
cluslength=cluslength(tmp);
bgevent=bgevent(tmp);
mbg=mbg(tmp);
bg=bgevent;
bgevent=ZG.newcat.subset(bg); %biggest event in a cluster(if more than one,take first)

clustnumbers=(1:length(tmp));    %stores numbers of clusters

