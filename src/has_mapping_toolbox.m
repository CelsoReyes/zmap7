function tf=require_mapping_toolbox()
     % check if mapping toolbox and topo map exists
    tf = license('test','map_toolbox');
    if ~tf
        errordlg('It seems like you do not have the mapping toolbox installed - plotting topography will not work without it, sorry');
    end
end