function get_fdsn_data_from_web_callback(s, e)
    
    h = findall(0,'Tag','fdsn_import_dialog');
    if isempty(h)
        fdsn_param_dialog(); % create
    else
        h.Visible = 'on'; % show existing
    end
end