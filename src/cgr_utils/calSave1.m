function calSave1 (~, ~, A, B)
    % calSave9 = save data to an interactively chosen file
    
    zmap_message_center.set_info('Save Data','  ');
    
    [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.out_dir, '*.dat'), 'Filename ');
    if file1 && path1
        if ~iscolumn(A)
            A = A';
        end
        if ~iscolumn(B)
            B = B';
        end
        data = [A, B]';
        fid = fopen([path1 file1],'w') ;
        fprintf(fid, '%12.5f  %12.5f\n' , data);
        fclose(fid) ;
    else
        zmap_message_center.set_message('cancelled save', '  ');
    end
    
end