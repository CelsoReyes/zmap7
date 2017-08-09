function  buildclu
    % buildclu.m                                 A.Allmann
    % builds cluster out out of information stored in clus
    % calculates also biggest event in a cluster (bg)
    % replaced by fnBuildClu

    global bgevent clus mbg k1 clustnumbers
    global cluslength %[OUT]
    global bg % bg seems to be an index, and is same as bgevent
    ZG=ZmapGlobal.Data;
    cluslength=[];
    n=0;
    k1 = max(clus);
    for j=1:k1                         %for all clusters
        cluslength(j)=length(find(clus==j));  %length of each cluster
    end

    tmp=find(cluslength);      %numbers of clusters that are not empty

    %cluslength,bg,mbg only for events which are not zero
    cluslength=cluslength(tmp);
    bgevent=bgevent(tmp);
    mbg=mbg(tmp);
    bg=bgevent;
    bgevent=ZG.newcat.subset(bg); %biggest event in a cluster(if more than one,take first)

    clustnumbers=(1:length(tmp));    %stores numbers of clusters
end
