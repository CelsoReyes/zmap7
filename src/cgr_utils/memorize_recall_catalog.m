function catalog=memorize_recall_catalog(catalog)
    % memorize_recall_catalog manages access to a temporarily stored version of the catalog
    %
    % c = memorize_recall_catalog()  recalls the catalog
    % memorize_recall_catalog(catalog) memorizes provided catalog
    %
    % see also uimemorize_catalog
    
    ZG = ZmapGlobal.Data;
    hasMemorized = ~isempty(ZG.memorized_catalogs);
    if nargin==1
        
         
        if hasMemorized
            % ask to memorize new catalog, or recall existing catalog
            todo=questdlg(['Memorize "',catalog.Name, '"?',...
                newline, newline, 'Currently memorized catalog:', newline,...
                ZG.memorized_catalogs.summary('simple'), newline, newline...
                'MEMORIZE will replace currently memorized catalog with', newline,...
                catalog.summary('simple') ],'Memorize/Recall Catalog','Memorize','Cancel','Memorize');
            if todo=="Cancel"
                return
            end
        end
        ZG.memorized_catalogs = copy(catalog);
        h=msgbox_nobutton(['Catalog ' catalog.Name ' has been Memorized.    '],'Memorize Catalog');
        h.ButtonVisible=true;
        h.delay_for_close(1);
    else
        % no arguments
        if ~hasMemorized
            warning('no catalogs are already memorized');
            c=[];
        else
            catalog=copy(ZG.memorized_catalogs);
            replaceMainCatalog(ZG.memorized_catalogs);
            txt = sprintf('Catalog "%s" with %d events has been recalled.',catalog.Name, catalog.Count);
            h=msgbox_nobutton(txt,'Recall Catalog');
            h.delay_for_close(2);
    end
    
    
        
    end

    %{
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
    %}
