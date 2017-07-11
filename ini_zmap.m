%    This is the  ZMAP default file used for the SUN Version.
%    Customize setting if desired
%
report_this_filefun(mfilename('fullpath'));
global wex wey welx wely sel
global ty ty1 ty2 ty3
global lth1 lth15 lth2
global rad xa0 iwl3 ic ya0 iwl2 step ni
global name strib stri2 infstri maix maiy
global tresh wi rotationangle fre
global co par1 minmag
global ca vi sha inb1 inb2 inda ra
global ZG

ZG=ZmapGlobal.Data;
% Marker sizes
ZG.ms6 = 3;
ms10 = 10;
ms12 = 12;

% Marker type
ty ='.';
ty1 ='+';
ty2 = 'o';
ty3 ='x';
ZG.mainmap_plotby='depth';
sel  = 'in';



% Line Thickness
lth1 = 1.0;
lth15 = 1.5;
lth2 = 2.0;

% set up Window size


% Map window
%
winx = 750;
winy = 650;

% Various setups
%
rad = 50.;
ic = 0;
ya0 = 0.;
xa0 = 0.;
iwl3 = 1.;
iwl2 = 1.5;
step = 3;
ni = 100;

name = ' ';
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
tresh = 50;
wi = 10 ;   % initial width of crossections
rotationangle = 10; % initial rotation angle in cross-section window
fre = 0;

% Set the Background color for the plot
% default \: light yellow 1 1 0.6
ZG.color_bg = [1.0 1.0 1.0];
in = 'initf';

% seislap default parameters
ldx = 100;
tlap = 100;

ca = 1;
vi ='on';
sha ='fl';
inb1=1;
inb2=1;
inda = 1;
ra = 5;

co = 'w';
par1 = 14; % bin length, days
minmag = 8; % minimum cutoff for "large" earthquakes

%set the recursion slightly, to avoid error (specialy with the function ploop2.m
set(0,'RecursionLimit',750)

