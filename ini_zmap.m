function ini_zmap()
    % INI_ZMAP modifies ZMAP globals according to user preference
    % use this file to override default Zmap Global values
    %
    % system-specific initialization happens in the following
    % see also ini_zmap_GLXNA64, ini_zmap_PCWIN64, ini_zmap_MACI64
    
    %global ty ty1 ty2 ty3        % marker types '.+ox' respectively
    % xa0, ya0  %center of circle
    %global rad ic step ni
    %global strib stri2 infstri maix maiy
    
    report_this_filefun(mfilename('fullpath'));
    
    ZG=ZmapGlobal.Data;
    
    % Marker type
    ZG.mainmap_plotby='depth';
    
    infstri = ' Please enter information about the | current dataset here';

    % seislap default parameters
    %ldx = 100;
    %tlap = 100;
    %set the recursion slightly, to avoid error (specialy with ploop functions)
    set(0,'RecursionLimit',750)
    
    set(0,'DefaultAxesFontName','Arial');
    set(0,'DefaultTextFontName','Arial');
    set(0,'DefaultAxesTickLength',[0.01 0.01]);
    set(0,'DefaultFigurePaperPositionMode','auto');
    
    %system_dependent(14,'on') % helps with possible wierd copy/paste issues with windows
end
