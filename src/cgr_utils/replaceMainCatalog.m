function replaceMainCatalog(otherCatalog)
    % replaceMainCatalog(otherCatalog)
    % use this instead of a=something
    % protects the main catalog from corruption
    report_this_filefun();
    if isempty(otherCatalog)
        otherCatalog=ZmapCatalog();
    end
    if isa(otherCatalog,'ZmapCatalogView')
        otherCatalog=otherCatalog.Catalog();
    end
    assert(isa(otherCatalog,'ZmapCatalog'));
    
    ZG = ZmapGlobal.Data;
    ZG.primeCatalog=copy(otherCatalog);
end