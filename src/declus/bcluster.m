function bsclu = bcluster(j)
    %bcluster.m              Last change 11/95 A.Allmann
    %builds a vector which contains all event of a cluster if the cluster
    %is stored in more than one column in clust
    %

    global clust
    bsclu=[];
    tmp=clust(20,j);
    for i=1:tmp
        bsclu=[bsclu;clust(:,j+(i-1))];
    end
