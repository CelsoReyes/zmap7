function replaceMainCatalog(otherCatalog)
    % replaceMainCatalog(otherCatalog)
    % use this instead of a=something
    % protects the main catalog from corruption
    report_this_filefun(mfilename('fullpath'));
    if isempty(otherCatalog)
        otherCatalog=ZmapCatalog();
    end
    assert(isa(otherCatalog,'ZmapCatalog'));
    
    ZG = ZmapGlobal.Data;
    ZG.primeCatalog = otherCatalog;
end