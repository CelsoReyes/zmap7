function ini_zmap_sys()
    %    This is the  ZMAP default file used for the system specified in title
    %    It's purpose is to modify the ZmapGlobal variables as necessary
    %    to fit the system.
    
    report_this_filefun();
    
    ZG=ZmapGlobal.Data;
    % Marker sizes
    ZG.ms6 = 3;
    
    fontscaling = 72 / get(groot,'ScreenPixelsPerInch');
    % reset it
    orig_fontsz = FontSizeTracker();
    ZG.fontsz.base_size=orig_fontsz.base_size * fontscaling;
    %set the recursion slightly, to avoid error (specialy with ploop functions)
    set(0,'RecursionLimit',750)
    
    set(0,'DefaultAxesFontName','Arial');
    set(0,'DefaultTextFontName','Arial');
    set(0,'DefaultAxesTickLength',[0.01 0.01]);
    set(0,'DefaultFigurePaperPositionMode','auto');
    
    system_dependent(14,'on') % helps with possible wierd copy/paste issues with windows
end
