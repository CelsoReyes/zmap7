function ini_zmap()
%    This is the  ZMAP default file used for the MAC system.
%    It's purpose is to modify the ZmapGlobal variables as necessary
%    to fit the system.

%global ty ty1 ty2 ty3        % marker types '.+ox' respectively
% xa0, ya0  %center of circle
%global rad ic step ni
%global strib stri2 infstri maix maiy

report_this_filefun(mfilename('fullpath'));

ZG=ZmapGlobal.Data;
% Marker sizes
ZG.ms6 = 3;
%ms10 = 10;
%ms12 = 12;

% Marker type
%ty ='.';
%ty1 ='+';
%ty2 = 'o';
%ty3 ='x';
ZG.mainmap_plotby='depth';
sel  = 'in';

% set up Window size

% Various setups
%
%rad = 50.;
%ic = 0;
%ya0 = 0.;
%xa0 = 0.;
%ZG.compare_window_dur_v3 = years(1);
%ZG.compare_window_dur = years(1.5);
%step = 3;
%ni = 100;

strib = ' ';
stri2 = [];
ZG.hold_state=false;
ZG.hold_state2=false;
infstri = ' Please enter information about the | current dataset here';
maix = [];
maiy = [];


% Initial Time setting

% Tresh is the radius in km below which blocks
% in the zmap's will be plotted
%
ZG.tresh_km = 50; %radius below which blocks in the zmap's will be plotted
ZG.xsec_width_km = 10 ;   % initial width of crossections
ZG.xsec_rotation_deg = 10; % initial rotation angle in cross-section window
ZG.freeze_colorbar = false;
    % Set the Background color for the plot
    % default \: light yellow 1 1 0.6
    ZG.color_bg = [1.0 1.0 1.0];
    in = 'initf';
    
    % seislap default parameters
    %ldx = 100;
    %tlap = 100;
    
    ZG.shading_style ='flat';
    ZG.inb1=1;
    ZG.inb2=1;
    % inda = 1;
    ZG.ra = 5;
    
    ZG.someColor = 'w';
    ZG.bin_dur = days(14); % bin length, days
    ZG.big_eq_minmag = 8; % minimum cutoff for "large" earthquakes
    
    %set the recursion slightly, to avoid error (specialy with ploop functions)
    set(0,'RecursionLimit',750)
    
    set(0,'DefaultAxesFontName','Arial');
    set(0,'DefaultTextFontName','Arial');
    set(0,'DefaultAxesTickLength',[0.01 0.01]);
    set(0,'DefaultFigurePaperPositionMode','auto');
    
    %system_dependent(14,'on') % helps with possible wierd copy/paste issues with windows
end
