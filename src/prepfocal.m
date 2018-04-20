function dall=prepfocal(catalog)
    % PREPFOCAL
    % to prepare the events for inversion based
    % on Lu Zhongs code.
    
    report_this_filefun();
    
    
    tmp = [catalog.Dip(:), catalog.DipDirection(:), catalog.Rake(:)];
    data_inp_file=fullfile(ZmapGlobal.Data.out_dir,'data.inp');
    try
        save(data_inp_file, 'tmp', '-ascii');
    catch ME
        warning(ME.message);
        errordlg('Error - could not save file %s - permission?', data_inp_file);
        return
    end
    infi = fullfile(ZmapGlobal.Data.out_dir, 'tmp.inp');
    outfi = fullfile(ZmapGlobal.Data.out_dir, 'tmp.out');
    
    
    fid = fopen(fullfile(ZmapGlobal.Data.out_dir, 'inmifi.dat'),'w');
    
    fprintf(fid,'%s\n',infi);
    fprintf(fid,'%s\n',outfi);
    
    fclose(fid);
    try %#ok<TRYNC>
        delete(outfi);
    end
    ddsetupprogram = fullfile(ZmapGlobal.Data.hodi,'external','datasetupDD');
    filetoreadfrom = [ZmapGlobal.Data.out_dir 'inmifi.dat'];
    [status, result] = system(sprintf('%s < %s',ddsetupprogram,filetoreadfrom))
    
    fid = fullfile(ZmapGlobal.Data.out_dir, 'tmpout.dat');
    
    format = '%f%f%f%f%f';
    %[d1, d2, d3, d4, d5] = textread(fid,format,'headerlines',1);
    C = textscan(fid,format,'HeaderLines',1); %Problem: "Errorlines" cause crashes.
    dall=[C{:}];
end
