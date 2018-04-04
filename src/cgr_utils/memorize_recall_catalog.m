function memorize_recall_catalog(catalog)
    % memorize_recall_catalog manages access to a temporarily stored version of the catalog
    %
    % recalling a catalog replaces all the active catalogs
    % see also uimemorize_catalog
    
    ZG = ZmapGlobal.Data;
    hasMemorized = ~isempty(ZG.memorized_catalogs);
    if isempty(catalog)
        catalog=ZG.primeCatalog;
    end
    
    if hasMemorized
        % ask to memorize new catalog, or recall existing catalog
        todo=questdlg(['Memorize "',catalog.Name ,'"or  Recall "',ZG.memorized_catalogs.Name,'"?',...
            newline, newline, 'RECALL will replace all active catalogs with', newline,...
            ZG.memorized_catalogs.summary('simple'), newline, newline...
            'MEMORIZE will replace currently memorized catalog with', newline,...
            catalog.summary('simple') ],'Memorize/Recall Catalog','Memorize','Recall','Cancel','Cancel');
    else
        todo='Memorize';
    end
    switch todo
        case 'Memorize'
            ZG.memorized_catalogs = copy(catalog);
            h=msgbox_nobutton(['Catalog ' catalog.Name ' has been Memorized.    '],'Memorize Catalog');
            h.ButtonVisible=true;
            h.delay_for_close(1);
        case 'Recall'
            replaceMainCatalog(ZG.memorized_catalogs);
            h=msgbox(['Catalog ' catalog.Name ' has been Recalled.     '],'Recall Catalog');
            ZG.newcat = ZG.memorized_catalogs; 
            ZG.newt2= ZG.memorized_catalogs;
            zmap_update_displays();
            ZmapMessageCenter.update_catalog();
            h.delay_for_close(2);
    end
end