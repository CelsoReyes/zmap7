function ZG.newt2=buildcat(var1)
    %buildcat.m                                A.Allmann
    %builds declustered catalog with equivalent events
    %
   
    % highly modified by Celso Reyes, 2017
    global ZG.newcat equi clus eqtime bg original backequi bgevent
    
    
    tm1=find(clus==0);    %elements which are not related to a cluster
    
    if var1==1
        
        ans_ = questdlg('  ',...
            'Replace mainshocks with equivalent events?',...
            'Yes please','No thank you','No' );
        
        switch ans_
            case 'Yes please'
                tmpcat=cat(ZG.newcat.subset(tm1), ZmapCatalog(equi));  %new catalog, but not sorted
            case 'No thank you'
                tmpcat=cat(ZG.newcat.subset(tm1),bgevent); % builds catalog with biggest events instead
                
                disp('Original mainshocks kept');
                
        end
        
        % I am not sure that this is right , may need 10 coloum
        %equivalent event
        tmpcat.sort('Date')
        
    elseif var1==2
        if isempty(backequi)
            tmpcat=cat(original.subset(tm1),ZmapCatalog(equi));
        else
            tmpcat=cat(original.subset(tm1),ZmapCatalog(backequi));
        end
    end
    if exist('tmpcat','var')
        tmpcat.sort('Date')
        ZG.newt2 = tmpcat;
    else
        warning('tmpcat was never created');
    end
end






