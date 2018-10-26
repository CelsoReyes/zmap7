function calSave7 (~, ~, xt, cumu2, as)
    % Save cum #  and z value to an interactively chosen file
    
    %msg.infodisp('  ','Save Data');
    
    [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.Directories.output, '*.dat'), 'Earthquake Datafile');
    if file1 && path1
        data = [xt', cumu2', as']';
        fid = fopen([path1 file1],'w') ;
        fprintf(fid, '%6.2f  %6.2f %6.2f\n' , data);
        fclose(fid) ;
    else
        %msg.dbdisp('  ','cancelled save');
    end
    
end