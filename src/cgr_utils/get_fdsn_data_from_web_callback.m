function [c,ok] = get_fdsn_data_from_web_callback()
    % GET_FDSN_DATA_FROM_WEB_CALLBACK open the FDSN import dialog box, or just make it visible
    %
    % [c,ok] = GET_FDSN_DATA_FROM_WEB_CALLBACK() 
    %  it is assumed that the FDSN import will drop the catalog directly into ZG.Data.primaryCatalog
    %
    ZG = ZmapGlobal.Data;
    cur_cat_stats = ZG.primeCatalog.summary('stats');
    h=findall(0,'Type','figure','-and','Name','Import from FDSN webservice');
    % h = findall(0,'Tag','fdsn_import_dialog');
    if isempty(h)
        app= fdsn_chooser();
        h = app.ImportfromFDSNwebserviceUIFigure;
    else
        app = h.UserData;
    end
    
    c=[];
    app.setCatalogFcn = @setfrom;
    h.Visible = 'on'; % show existing
    
    waitfor(h,'Visible','off'); 
    ok = ~isempty(c);
    if ok
        new_cat_stats = c.summary('stats');
        
        ok = ~isequal(cur_cat_stats, new_cat_stats);
        ZG.primeCatalog = c;
        
        uimemorize_catalog();
    end
    function setfrom(incat)
        c = incat;
    end
end