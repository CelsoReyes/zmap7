function uimemorize_catalog(catalog)
    % uimemorize_catalog manages access to a temporarily stored version of the catalog
    %
    % see also memorize_recall_catalog
    
    ZG = ZmapGlobal.Data;
    hasMemorized = ~isempty(ZG.memorized_catalogs);
    if ~exist('catalog','var')
        catalog=ZG.primeCatalog;
    end
    if hasMemorized
        % ask to memorize new catalog, or recall existing catalog
        todo=questdlg(['Memorize "',catalog.Name ,'?',...
            newline, newline, 'MEMORIZE will replace currently memorized catalog:', newline,...
            ZG.memorized_catalogs.summary('simple'), newline, newline...
            'with:', newline,...
            catalog.summary('simple') ],'Memorize Catalog','Memorize','Cancel','Cancel');
    else
        todo='Memorize';
    end
    switch todo
        case 'Memorize'
            ZG.memorized_catalogs = catalog;
            h=msgbox(['Catalog ' catalog.Name ' has been Memorized.    '],'Memorize Catalog');
            pause(1)
            if isvalid(h),delete(h),end
    end
end