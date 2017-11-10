function uimemorize_catalog()
    % uimemorize_catalog manages access to a temporarily stored version of the catalog
    %
    % see also memorize_recall_catalog
    
    ZG = ZmapGlobal.Data;
    hasMemorized = ~isempty(ZG.memorized_catalogs);
    
    if hasMemorized
        % ask to memorize new catalog, or recall existing catalog
        todo=questdlg(['Memorize "',ZG.primeCatalog.Name ,'?',...
            newline, newline, 'MEMORIZE will replace currently memorized catalog:', newline,...
            ZG.memorized_catalogs.summary('simple'), newline, newline...
            'with:', newline,...
            ZG.primeCatalog.summary('simple') ],'Memorize Catalog','Memorize','Cancel','Cancel');
    else
        todo='Memorize';
    end
    switch todo
        case 'Memorize'
            ZG.memorized_catalogs = ZG.primeCatalog;
            msgbox(['Catalog ' ZG.primeCatalog.Name ' has been Memorized.    '],'Memorize Catalog');
    end
end