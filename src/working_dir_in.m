function working_dir_in()
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    mydir=uigetdir(ZG.Directories.working,'Choose your Working Directory');
    if ~isempty(mydir)
        ZG.Directories.working = mydir;
    end
end
