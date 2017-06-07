function newt2=buildcat(var1)
    %buildcat.m                                A.Allmann
    %builds declustered catalog with equivalent events
    %
    %Last modification 8/95
    global newcat equi clus eqtime bg original backequi bgevent


    tm1=find(clus==0);    %elements which are not related to a cluster

    if var1==1

        ans_ = questdlg('  ',...
            'Replace mainshocks with equivalent events?',...
            'Yes please','No thank you','No' );

        switch ans_
            case 'Yes please'
                tmpcat=[newcat(tm1,1:9);equi(:,1:9)];  %new catalog, but not sorted
            case 'No thank you'
                tmpcat=[newcat(tm1,:);bgevent]; % builds catalog with biggest events instead

                disp('Original mainshocks kept');

        end

        % I am not sure that this is right , may need 10 coloum
        %equivalent event
        [tm2,i]=sort([tm1';bg']);  %i is the index vector to sort tmpcat

    elseif var1==2
        if isempty(backequi)
            tmpcat=[original(tm1,1:9);equi(:,1:9)];
        else
            tmpcat=[original(tm1,1:9);backequi(:,1:9)];
        end
        [tm2,i]=sort(tmpcat(:,3));
    end

    newt2=tmpcat(i,:);       %sorted catalog,ready to load in basic program






