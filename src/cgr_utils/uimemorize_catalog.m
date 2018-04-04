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

        % don't bother if catalogs are the same
        if strcmp(ZG.memorized_catalogs.summary('stats'),...
            catalog.summary('stats'))
            todo='Cancel';
            disp('Ignoring. catalog matches already memorized catalog.')
        else
        % ask to memorize new catalog, or recall existing catalog
        todo=questdlg(['Memorize "',catalog.Name ,'?',...
            newline, newline, 'MEMORIZE will replace currently memorized catalog:', newline,...
            ZG.memorized_catalogs.summary('simple'), newline, newline...
            'with:', newline,...
            catalog.summary('simple') ],'Memorize Catalog','Memorize','Cancel','Cancel');
        end
    else
        todo='Memorize';
    end
    switch todo
        case 'Memorize'
            ZG.memorized_catalogs = catalog;
            h=msgbox_nobutton(['Catalog ' catalog.Name ' has been Memorized.    '],'Memorize Catalog');
            set(findobj(h,'Style','pushbutton'),'Enable','off');
            h.delay_for_close(1);
    end
end