function ini_zmap()
    % INI_ZMAP modifies ZMAP globals according to user preference
    % use this file to override default Zmap Global values
    %
    % system-specific initialization happens in the following
    % see also ini_zmap_GLXNA64, ini_zmap_PCWIN64, ini_zmap_MACI64
    
    report_this_filefun();
    
    ZG=ZmapGlobal.Data;
    
    % MAINMAP_PLOTBY defines by which field the events will be colored on the main map.
    % valid choices are one of  : 'Depth','Date','Magnitude','-none-'
    ZG.mainmap_plotby='-none-';
    
    % MAINMAP_FEATURES lists which features will be plotted by default on the main map.
    % provide the list as a cell. Valid choices are:
    % {'borders','coastline','faults','lakes','plates','rivers','stations','volcanoes'}
    ZG.mainmap_features={'borders','coastline','faults','lakes','plates','rivers'};
    ZG.event_marker = 's';
    
    ZG.grid_markersize = 2.5;
    
    report_this_filefun('on');
    report_this_filefun('set',1);
    
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
