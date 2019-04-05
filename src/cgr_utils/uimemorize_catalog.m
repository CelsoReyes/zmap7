function uimemorize_catalog(catalog)
    % uimemorize_catalog manages access to a temporarily stored version of the catalog
    %
    % see also MemorizedCatalogManager
    mcm = MemorizedCatalogManager();
    hasMemorized = ~isempty(mcm);
    if ~exist('catalog','var')
        ZG=ZmapGlobal.Data;
        catalog = ZG.primeCatalog; % points to same thing
    end
    
    if hasMemorized
        % ask to memorize new catalog, or recall existing catalog
        msg = sprintf(['Memorize %s ?\n\n',...
            'MEMORIZE will replace currently memorized catalog:\n%s\n\nwith:\n%s'],...
        	catalog.Name, mcm.info(), catalog.summary('simple'));
        
        todo=questdlg( msg,'Memorize Catalog', 'Memorize', 'Cancel','Cancel');
    else
        todo='Memorize';
    end
    
    switch todo
        case 'Memorize'
            mcm.memorize(catalog)
            h=msgbox_nobutton(['Catalog ' catalog.Name ' has been Memorized.    '],'Memorize Catalog');
            set(findobj(h,'Style','pushbutton'),'Enable','off');
            h.delay_for_close(1);
    end
end