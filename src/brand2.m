function brand2(catalog)
    %  brand2  calculates synthetic b distributions based on
    %  a random permutation of original magnitude values,
    %  it then compares it to original b map using bvalmapt
    %                                                 Ram�n Z��iga 9/2000

    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    % first create a new catalog with original data changing the year values
    
    lengtha = catalog.Count;
    conca = copy(catalog);
    conca.Date = conca.Date + 500;  % add 500 to years to make it a consecutive sequence
    
    % now change magnitudes by a random permutation
    conca.Magnitude = conca.Magnitude(randperm(lengtha));  % permuted magnitudes

    catalog = catalog.cat(conca);
    
    minnu = 40;  % minimum number of events in each period
    t4 = catalog.Date(end)
    t3 = catalog.Date(lengtha+1);
    t2 = catalog.Date(lengtha);
    t1 = catalog.Date(1);
    cb_go();
   
    % NOTE: This scriot used to have some sort of interactive dialog that affected
    % ZG.McCalcMethod and ZG.UseAutoEstimate, as well as radius and dx & dy
    
    function cb_go(~,~)
        
        ZG.newt2 = catalog;
        warningdlg('ZMAP:unimplmented','this needs updating...');
        bvalmapt(ZmapAnalysisPkg('newt2'));
    end
    
end
