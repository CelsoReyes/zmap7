function doinvers() 
    %  doinvers calculates orientation of the stress tensor based on Gephard's algorithm.
    % stress tensor orientation. The actual calculation is done using a call to a fortran program.
    %
    % Stefan Wiemer 03/96
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    
    global mif1 mif2 a newcat2
    global tmpi cumu2
    report_this_filefun();
    
    
    if isunix ~= 1
        errordlg('Misfit calculation only implemented for UNIX version! ');
        return
    end
    
    prepfocal2()
    hodis = [hodi '/stinvers'];
    tmpi = tmpout2;
    try
        save(ZmapGlobal.Data.Directories.output, 'data.inp','tmpi','-ascii');
    catch
        errordlg(['Error - could not save file ' ZmapGlobal.Data.Directories.output '/tmpin.dat - permission?']);
        return
    end
    
    infi = [ZmapGlobal.Data.Directories.output 'data.inp'];
    outfi = [ZmapGlobal.Data.Directories.output 'tmpout.dat'];
    
    comm = sprintf('%s %g %g %s %s &',fullfile(hodis,'invshell1',length(tmpi(:,1)), 10, hodis, infi));
    system(comm)
    
    function prepfocal2() 
        % PREPFOCAL2 prepare the events for inversion based  on Lu Zhongs code.
        % turned into function by Celso G Reyes 2017
        
        ZG=ZmapGlobal.Data; % used by get_zmap_globals
        
        report_this_filefun();
        
        
        tmp = [ZG.newt2(:,10:12)];
        try
            save(ZmapGlobal.Data.Directories.output ,'data.inp','tmp','-ascii');
        catch
            err =  ['Error - could not save file ' ZmapGlobal.Data.Directories.output 'data.inp - permission?'];
            errordlg(err);
            return;
        end
        
        infi = [ZmapGlobal.Data.Directories.output 'data.inp'];
        outfi = [ZmapGlobal.Data.Directories.output 'tmpout.dat'];
        outfi2 = [ZmapGlobal.Data.Directories.output 'tmpout2.dat'];
        
        
        fid = fopen([ZmapGlobal.Data.Directories.output 'inmifi.dat'],'w');
        
        fprintf(fid,'%s\n',infi);
        fprintf(fid,'%s\n',outfi);
        
        fclose(fid);
        
        system(['/bin/rm ' outfi])
        system([ hodi '/stinvers/datasetupDD < ' ZmapGlobal.Data.Directories.output 'inmifi.dat '])
        system(['grep  "1.0" ' outfi  '>'  outfi2])
        
        load([ZmapGlobal.Data.Directories.output,'tmpout2.dat'];
    end
    
end
