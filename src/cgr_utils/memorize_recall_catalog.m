function memorize_recall_catalog()
    % memorize_recall_catalog manages access to a temporarily stored version of the catalog
    %
    % recalling a catalog replaces all the active catalogs
    
    ZG = ZmapGlobal.Data;
    hasMemorized = ~isempty(ZG.memorized_catalogs);
    
    if hasMemorized
        % ask to memorize new catalog, or recall existing catalog
        todo=questdlg(['Memorize "',ZG.primeCatalog.Name ,'"or  Recall "',ZG.memorized_catalogs.Name,'"?',...
            newline, newline, 'RECALL will replace all active catalogs with', newline,...
            ZG.memorized_catalogs.summary('simple'), newline, newline...
            'MEMORIZE will replace currently memorized catalog with', newline,...
            ZG.primeCatalog.summary('simple') ],'Memorize/Recall Catalog','Memorize','Recall','Cancel','Cancel');
    else
        todo='Memorize';
    end
    switch todo
        case 'Memorize'
            ZG.memorized_catalogs = ZG.primeCatalog;
            msgbox(['Catalog ' ZG.primeCatalog.Name ' has been Memorized.    '],'Memorize Catalog');
        case 'Recall'
            replaceMainCatalog(ZG.memorized_catalogs);
            msgbox(['Catalog ' ZG.primeCatalog.Name ' has been Recalled.     '],'Recall Catalog');
            
            ZG.newcat = ZG.memorized_catalogs; 
            ZG.newt2= ZG.memorized_catalogs;
            zmap_update_displays();
            ZmapMessageCenter.update_catalog();
            
    end
end