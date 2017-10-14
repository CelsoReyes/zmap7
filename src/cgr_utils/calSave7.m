function calSave7 (~, ~, xt, cumu2, as)
    % calSave7 = Save cum #  and z value to an interactively chosen file
    
    ZmapMessageCenter.set_info('Save Data','  ');
    
    [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.out_dir, '*.dat'), 'Earthquake Datafile');
    if file1 && path1
        data = [xt', cumu2', as']';
        fid = fopen([path1 file1],'w') ;
        fprintf(fid, '%6.2f  %6.2f %6.2f\n' , data);
        fclose(fid) ;
    else
        ZmapMessageCenter.set_message('cancelled save', '  ');
    end
    
end