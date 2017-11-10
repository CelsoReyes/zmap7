function[clusLengths,biggestEvent,mbg,bg,clustnumbers] = funBuildclu(mycat,biggestEvent,clus,mbg)
% funBuildclu builds cluster out out of information stored in clus
% mycat : catalog
% clus: size of catalog, containing cluster index numbers
% biggestEvent: size nClusters
% mbg: max mag in cluster
% bg : size nClusters
%
    %  originally, "mycat" was "newcat"
    % A.Allmann
% modified by C Reyes 2017

%global mycat clus mbg k1 clust clustnumbers 
%global bgevent bg

 % count # events in each cluster
clusLengths = histcounts(clus,'BinLimits',[1 max(clus)], 'BinMethod','integers');

% cull any clusters that don't have events
empty_clusters = clusLengths == 0;      %numbers of clusters that are empty  eg. [1:9 2:0 3: 8 4:0] ->  [0 1 0 1]
clusLengths(empty_clusters)=[];
biggestEvent(empty_clusters)=[];
mbg(empty_clusters)=[];

bg = biggestEvent;
biggestEvent = mycat.subset(bg); %biggest event in a cluster(if more than one,take first)

clustnumbers=(1:numel(clusLengths));    % stores numbers of clusters


