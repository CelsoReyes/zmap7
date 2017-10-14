function calSave9 (~, ~, A, B)
    % calSave9 = save data to an interactively chosen file
    
    ZmapMessageCenter.set_info('Save Data','  ');
    
    [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.out_dir, '*.dat'), 'Filename ? ');
    if file1 && path1
        if ~iscolumn(A)
            A = A';
        end
        if ~iscolumn(B)
            B = B';
        end
        data = [A, B]';
        fid = fopen([path1 file1],'w') ;
        fprintf(fid, '%6.2f  %6.2f\n' , data);
        fclose(fid) ;
    else
        ZmapMessageCenter.set_message('cancelled save', '  ');
    end
    
end