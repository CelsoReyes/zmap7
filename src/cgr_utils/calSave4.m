
function calSave4(~, ~, a, faults, mainfault, coastline, main, infstri)
    % save fault information, I think. called from ZmapInBox/src/setup.m
    % infstri is user-entered information about hte current dataset
    
    zmap_message_center.set_info('Save Data','  ');
    think;
    [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.data_dir, '*.mat'), 'Filename?');
    save([path1, file21], 'a', 'faults', 'mainfault', 'coastline', 'main', 'infstri');
    close(loda);
    update(mainmap());
    done
end