function selclus(var1)
    % selclus.m                            Alexander Allmann
    % function to select eqs in the map window according to the catalog
    % limits in the Cluster Menu or Single Cluster window


    global newccat ttcat cluscat newclcat

    %call from  Cluster Menu
    if isempty(ttcat)
        if isempty(newclcat)
            mycat=cluscat;
        else
            mycat=newclcat;
        end
    else
        mycat=ttcat;
    end

    if var1==1                    %Cluster window values
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

    elseif var1==2                %bigger values than cluster window

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


    tmp11=find(newccat.Longitude>=tmp1 & newccat.Longitude<=tmp2 & newccat.Latitude>=tmp3 & newccat.Latitude<=tmp4 & newccat.Date>=tmp5 & newccat.Date<=tmp6 & newccat.Magnitude>=tmp7 & newccat.Magnitude<=tmp8 & newccat.Depth>=tmp9 & newccat.Depth<=tmp10);
    newccat=newccat.subset(tmp11);
    if isempty(newccat)
        disp('No earthquakes with the same limits found')
    end
