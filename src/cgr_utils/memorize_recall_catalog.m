function memorize_recall_catalog()
    % memorize_recall_catalog manages access to a temporarily stored version of the catalog
    %
    % recalling a catalog replaces all the active catalogs
    
    ZG = ZmapGlobal.Data;
    hasMemorized = ~isempty(ZG.memorized_catalogs);
    
    if hasMemorized
        % ask to memorize new catalog, or recall existing catalog
        todo=questdlg(['Memorize "',ZG.a.Name ,'"or  Recall "',ZG.memorized_catalogs.Name,'"?',...
            newline, newline, 'RECALL will replace all active catalogs with', newline,...
            ZG.memorized_catalogs.summary('simple'), newline, newline...
            'MEMORIZE will replace currently memorized catalog with', newline,...
            ZG.a.summary('simple') ],'Memorize/Recall Catalog','Memorize','Recall','Cancel','Cancel');
    else
        todo='Memorize';
    end
    switch todo
        case 'Memorize'
            ZG.memorized_catalogs = a;
            msgbox(['Catalog ' ZG.a.Name ' has been Memorized.    '],'Memorize Catalog');
        case 'Recall'
            ZG.a=ZG.memorized_catalogs;
            msgbox(['Catalog ' ZG.a.Name ' has been Recalled.     '],'Recall Catalog');
            think;
            ZG.newcat = ZG.memorized_catalogs; 
            ZG.newt2= ZG.memorized_catalogs;
            update(mainmap());
            zmap_message_center.update_catalog();
            done;
    end
end