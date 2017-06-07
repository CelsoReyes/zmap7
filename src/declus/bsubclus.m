function [maintmp,swarmtmp,dubletttmp]=bsubclus
    %bsubclus.m                   A.Allmann
    %builds swarms mainclusters or dubletts
    %
    %Last modification 6/95
    global clust bgevent original cluslength equi

    maintmp=[];swarmtmp=[];dubletttmp=[];
    for j=equi(:,10)'
        tm1=find(original(clust(find(clust(:,j)),j),6)>=(bgevent(j,6)-0.3));
        if length(tm1)>=2       %swarm criterium
            tm2(j)=j;
        else
            tm3(j)=j;
        end
    end
    if ~isempty(tm3)
        maintmp=tm3(find(tm3));           %indices of clus that contain mainclusters
    end
    if ~isempty(tm2)
        tm4=tm2(find(tm2));
        if ~isempty(tm4)
            dubletttmp=tm4(find(cluslength(tm4)==2));      %indices that contain dubletts
            swarmtmp=tm4(find(cluslength(tm4)~=2));        %indices tha contain swarms
        end
    end

