function save_zmapcatalog(catalog) 
    % save_zmapcatalog saves a ZmapCatalog to file in one of several formats
    if ~exist('catalog','var')
        catalog = ZmapGlobal.Data.primeCatalog;
    end
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    filters = {fullfile(ZG.Directories.output,'*.mat'),'ZmapCatalog (*.mat)';...
        fullfile(ZG.Directories.output,'*.dat'),'ZmapCatalog v7+ [ASCII] (*.dat)';...
        fullfile(ZG.Directories.output,'*.dat'), 'Zmap v6.0 [ASCII] (*.dat)'};
    %[newmatfile, newpath] = uiputfile([ ZmapGlobal.Data.Directories.output '*.dat'], 'Save As');
    if endsWith(catalog.Name,'.mat')
        saveName = catalog.Name;
    else
        saveName = [catalog.Name, '.mat'];
    end
    [saveName, newpath, filterindex] = uiputfile(filters, 'Save As', saveName);
    saveName=fullfile(newpath,saveName);
    
    switch filterindex
        case 1
            save_to_v7mat;
        case 2
            save_to_v7ascii
        case 3
            save_to_v6;
    end
    
    function save_to_v6()
        s = [catalog.Longitude   catalog.Latitude  catalog.Date.Year  catalog.Date.Month...
            catalog.Date.Day  catalog.Magnitude  catalog.Depth catalog.Date.Hour catalog.Date.Minute  ];
        fid = fopen(saveName,'w') ;
        fprintf(fid,'%8.3f   %7.3f %4.0f %6.0f  %6.0f %6.1f %6.2f  %6.0f  %6.0f\n',s');
        fclose(fid);
    end
    
    function save_to_v7mat()
        % ZmapCatalog v7+ .mat
        save(saveName, 'catalog');
    end
    
    function save_to_v7ascii()
        % write catalog as a table.
        writetable(catalog.table(),saveName);
    end
    
end
