function [c,ok] = get_fdsn_data_from_web_callback()
    % GET_FDSN_DATA_FROM_WEB_CALLBACK open the FDSN import dialog box, or just make it visible
    %
    % [c,ok] = GET_FDSN_DATA_FROM_WEB_CALLBACK() 
    %  it is assumed that the FDSN import will drop the catalog directly into ZG.Data.primaryCatalog
    %
    ZG = ZmapGlobal.Data;
    cur_cat_stats = ZG.primeCatalog.summary('stats');
    h = findall(0,'Tag','fdsn_import_dialog');
    if isempty(h)
        fdsn_param_dialog(); % create
        h = findall(0,'Tag','fdsn_import_dialog');
    else
        h.Visible = 'on'; % show existing
    end
    
    waitfor(h,'Visible','off'); 
    new_cat_stats = ZG.primeCatalog.summary('stats');
    
    ok = ~isequal(cur_cat_stats, new_cat_stats);
    c = ZG.primeCatalog;
end