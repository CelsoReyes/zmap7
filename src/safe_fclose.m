function safe_fclose(fid)
    % safe_fclose close a file only if it is open
    %
    % Celso G Reyes, 2017
    open_files=fopen('all'); %get list of open file handles
    if any(open_files == fid)
        fclose(fid);
    end
end