function calSave1 (~, ~, A, B)
    % save data to an interactively chosen file
    
    msg.infodisp('  ','Save Data');
    
    [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.Directories.output, '*.dat'), 'Filename ');
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
        msg.dbdisp('  ','cancelled save');
    end
    
end