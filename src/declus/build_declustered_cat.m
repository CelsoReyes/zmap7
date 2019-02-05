function newt2=build_declustered_cat(from_where)
    %BUILD_DECLUSTERED_CAT builds declustered catalog with equivalent events
    %A.Allmann
    %
   
    % highly modified by Celso Reyes, 2017
    global equi %[IN]
    global clus original backequi bgevent
    ZG=ZmapGlobal.Data;
    
    eq_noclus=find(clus==0);    %elements which are not related to a cluster
    
    if from_where == "interactive"
        
        ans_ = questdlg('Replace mainshocks with equivalent events?',...
            'Replace mainshocks with equivalent events?',...
            'Replace','No','No' );
        
        switch ans_
            case 'Replace'
                tmpcat=cat(ZG.newcat.subset(eq_noclus), ZmapCatalog.from(equi));  %new catalog, but not sorted
            case 'No'
                tmpcat=cat(ZG.newcat.subset(eq_noclus),bgevent); % builds catalog with biggest events instead
                
                disp('Original mainshocks kept');
                
        end
        
        % I am not sure that this is right , may need 10 coloum
        %equivalent event
        tmpcat.sort('Date')
        
    elseif from_where == "original"
        if isempty(backequi)
            tmpcat=cat(original.subset(eq_noclus),ZmapCatalog.from(equi));
        else
            tmpcat=cat(original.subset(eq_noclus),ZmapCatalog.from(backequi));
        end
    else
        error('unknown option for build_declustered_cat "%s"',from_where);
    end
    
    if exist('tmpcat','var')
        tmpcat.sort('Date')
        newt2 = tmpcat;
    else
        warning('tmpcat was never created');
    end
end







