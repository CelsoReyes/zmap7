function calSave9 (~, ~, A, B)
    % calSave9 = save data to an interactively chosen file
    global hodi
    zmap_message_center.set_info('Save Data','  ');
    think;
    [file1,path1] = uiputfile(fullfile(hodi, 'out', '*.dat'), 'Filename ? ');
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
        zmap_message_center.set_message('cancelled save', '  ');
    end
    done;
end