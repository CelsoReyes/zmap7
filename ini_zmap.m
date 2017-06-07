%    This is the  ZMAP default file used for the SUN Version.
%    Customize setting if desired
%
report_this_filefun(mfilename('fullpath'));
global winx winy

% Set the font size
%
fontsz = FontSizeTracker;

% Marker sizes
ms6 = 3;
ms10 = 10;
ms12 = 12;

% Marker type
ty ='.';
ty1 ='+';
ty2 = 'o';
ty3 ='x';
typele = 'dep';
sel  = 'in';



% Line Thickness
lth1 = 1.0;
lth15 = 1.5;
lth2 = 2.0;

% set up Window size
%
% Welcome window
wex = 80;
wey = fipo(4)-380;
welx = 340;
wely = 300;

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
ho ='noho';
ho2 = 'noho';
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


% set the background color (c1 = red, c2 = green, c3 = blue)
% default: light gray 0.9 0.9 0.9
c1 = 0.9;
c2 = 0.9;
c3 = 0.9;

% Set the Background color for the plot
% default \: light yellow 1 1 0.6
cb1 = 1.0;
cb2 = 1.0;
cb3 = 1.0;

in = 'initf';

% seislap default para,eters
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
par1 = 14;
minmag = 8;

%set the recursion slightly, to avoid error (specialy with the function ploop2.m
set(0,'RecursionLimit',750)

