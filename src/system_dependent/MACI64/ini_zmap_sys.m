function ini_zmap_sys()
    %    This is the  ZMAP default file used for the MAC system.
    %    It's purpose is to modify the ZmapGlobal variables as necessary
    %    to fit the system.
    report_this_filefun();
    
    ZG=ZmapGlobal.Data;
    % Marker sizes
    ZG.ms6 = 3;
    
    %set the recursion slightly, to avoid error (specialy with ploop functions)
    set(0,'RecursionLimit',750)
    set(0,'DefaultAxesFontName','Arial');
    set(0,'DefaultTextFontName','Arial');
    set(0,'DefaultAxesTickLength',[0.01 0.01]);
    set(0,'DefaultFigurePaperPositionMode','auto');
end