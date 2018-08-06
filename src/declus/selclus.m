function clustercat = selclus(windowing, clustercat)
    % SELCLUS select eqs according to cat limits             
    % original:Alexander Allmann
    % clustercat = SELCLUS(windowing, clustercat)
    % select eqs in the map window according to the catalog
    % limits in the Cluster Menu or Single Cluster window

    ZG=ZmapGlobal.Data;

    %call from  Cluster Menu
    % catalog used for windowing
    if ~isempty(ZG.ttcat)
        mycat=ZG.ttcat;
    elseif ~isempty(ZG.newclcat)
        mycat=ZG.newclcat;
    else
        mycat=ZG.cluscat;
    end

    if windowing=='cur_cluster'                    %Cluster window values
        % naming things tmp1 - tmp10 is an executable offense. -mgmt
        tmp1=min(mycat.Longitude);
        tmp2=max(mycat.Longitude);
        tmp3=min(mycat.Latitude);
        tmp4=max(mycat.Latitude);
        tmp5=min(mycat.Date);
        tmp6=max(mycat.Date);
        tmp7=min(mycat.Magnitude);
        tmp8=max(mycat.Magnitude);
        tmp9=min(mycat.Depth);
        tmp10=max(mycat.Depth);

    elseif windowing=='expanded_cluster'       %bigger values than cluster window

        tmp1=min(mycat.Longitude)-.2;
        tmp2=max(mycat.Longitude)+.2;
        tmp3=min(mycat.Latitude)-.2;
        tmp4=max(mycat.Latitude)+.2;
        tmp5=min(mycat.Date)-days(.2);
        tmp6=max(mycat.Date)+days(.2);
        tmp7=min(mycat.Magnitude);
        tmp8=max(mycat.Magnitude);
        tmp9=min(mycat.Depth)-10;
        tmp10=max(mycat.Depth)+10;
    end

    % now, change the "real" catalog"
    tmp11=clustercat.Longitude>=tmp1 & clustercat.Longitude<=tmp2 &...
        clustercat.Latitude>=tmp3 & clustercat.Latitude<=tmp4 & ...
        clustercat.Date>=tmp5 & clustercat.Date<=tmp6 & ...
        clustercat.Magnitude>=tmp7 & clustercat.Magnitude<=tmp8 &...
        clustercat.Depth>=tmp9 & clustercat.Depth<=tmp10;
    
    clustercat=clustercat.subset(tmp11);
    
    if isempty(clustercat)
        disp('No earthquakes with the same limits found')
    end

