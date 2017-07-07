function memorize_recall_catalog()
    % memorize_recall_catalog manages access to a temporarily stored version of the catalog
    %
    % recalling a catalog replaces all the active catalogs
    
    global a newcat newt2
    ZG = ZmapGlobal.Data;
    hasMemorized = ~isempty(ZG.memorized_catalogs);
    
    if ~exist('newline') %R2017a and later
        newline=sprintf('\n');
    end
    
    if hasMemorized
        % ask to memorize new catalog, or recall existing catalog
        todo=questdlg(['Memorize "',a.Name ,'"or  Recall "',ZG.memorized_catalogs.Name,'"?',...
            newline, newline, 'RECALL will replace all active catalogs with', newline,...
            ZG.memorized_catalogs.summary('simple'), newline, newline...
            'MEMORIZE will replace currently memorized catalog with', newline,...
            a.summary('simple') ],'Memorize/Recall Catalog','Memorize','Recall','Cancel','Cancel');
    else
        todo='Memorize';
    end
    switch todo
        case 'Memorize'
            ZG.memorized_catalogs = a;
            msgbox(['Catalog ' a.Name ' has been Memorized.    '],'Memorize Catalog');
        case 'Recall'
            a = ZG.memorized_catalogs;
            msgbox(['Catalog ' a.Name ' has been Recalled.     '],'Recall Catalog');
            think;
            newcat = ZG.memorized_catalogs; 
            newt2= ZG.memorized_catalogs;
            update(mainmap());
            zmap_message_center.update_catalog();
            done;
    end
end