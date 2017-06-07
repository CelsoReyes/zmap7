function selclus(var1)
    % selclus.m                            Alexander Allmann
    % function to select eqs in the map window according to the catalog
    % limits in the Cluster Menu or Single Cluster window
    % Last change            8/95


    global newccat ttcat cluscat newclcat

    %call from  Cluster Menu
    if isempty(ttcat)
        if isempty(newclcat)
            tmp=cluscat;
        else
            tmp=newclcat;
        end
    else
        tmp=ttcat;
    end

    if var1==1                    %Cluster window values

        tmp1=min(tmp(:,1));
        tmp2=max(tmp(:,1));
        tmp3=min(tmp(:,2));
        tmp4=max(tmp(:,2));
        tmp5=min(tmp(:,3));
        tmp6=max(tmp(:,3));
        tmp7=min(tmp(:,6));
        tmp8=max(tmp(:,6));
        tmp9=min(tmp(:,7));
        tmp10=max(tmp(:,7));

    elseif var1==2                %bigger values than cluster window

        tmp1=min(tmp(:,1))-.2;
        tmp2=max(tmp(:,1))+.2;
        tmp3=min(tmp(:,2))-.2;
        tmp4=max(tmp(:,2))+.2;
        tmp5=min(tmp(:,3))-.2;
        tmp6=max(tmp(:,3))+.2;
        tmp7=min(tmp(:,6));
        tmp8=max(tmp(:,6));
        tmp9=min(tmp(:,7))-10;
        tmp10=max(tmp(:,7))+10;

    end


    tmp11=find(newccat(:,1)>=tmp1 & newccat(:,1)<=tmp2 & newccat(:,2)>=tmp3 & newccat(:,2)<=tmp4 & newccat(:,3)>=tmp5 & newccat(:,3)<=tmp6 & newccat(:,6)>=tmp7 & newccat(:,6)<=tmp8 & newccat(:,7)>=tmp9 & newccat(:,7)<=tmp10);
    newccat=newccat(tmp11,:);
    if isempty(newccat)
        disp('No earthquakes with the same limits found')
    end
