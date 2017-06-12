% This files start up ZMAP.
%
% The matlab searchpathes are updated, existing windows closed.
%
%  Stefan Wiemer  12/94
%  Modified by Celso Reyes Spring/Summer 2017

%system_dependent(14,'on')
disp('This is zmap.m - version 7.0')

% read the welcome screen
rng('shuffle');
r = ceil(rand(1,1)*21);
cd slides
if r <10
    str = [ 'Slide' num2str(r,1) '.JPG'];
else
    str = [ 'Slide' num2str(r,2) '.JPG'];
end

try
    [x, imap] = imread(str);
    figure_w_normalized_uicontrolunits('Menubar','none','NumberTitle','off');
    fi0 = gcf;
    axes('pos',[0 0 1 1]);axis off; axis ij
    image(x)
    drawnow
    close
catch ME
    % do nothing
end


cd ..

% Get the screensizxe and color
global a action_button aw
global b1 b2 bfig bg bmapc bvalsum3 bw
global c1 c2 c3 cb1 cb2 cb3 clus cputype cum dx dy equi eqtime
global figp file1 freq_field freq_field1 freq_field2 freq_field3 freq_field4 fontsz
global Go_p_button histo hisvar ho hodi
global lat1 lon1 lat2 lon2 leng maepi mess ni n1 n2 newa2 newcat original
global pos pri ptt Re sax1 sax2 scale seismap strii1 strii2 sys
global teb t0b torad term ttcat wex wey welx wely winx winy
global xsec_fig xt3

% temporarily turn off all warnings...
% warning off   %nuh-uh - CGR

fipo = get(groot,'ScreenSize');
hodi = pwd;
fipo(4) = fipo(4)-150;
term = get(groot,'ScreenDepth');

% Set up the different compuer systems
sys = computer;
cputype = computer;

if verLessThan('matlab','9.2')
    messtext = ['Warning: You are running a version of MatLab '
        ' older than 2017a. ZMAP was modified for compatibility '
        ' with r2017a or later, so your version may no longer be'
        ' compatible'];
    errdlg(messtext,'Warning!')
    pause(5)
end

tested_systems = {'MAC'};
prviously_tested_systems = {'PCW', 'SOL', 'SUN', 'HP7', 'LNX', 'MAC'};
if ~ismember( sys(1:3), tested_systems)
    errordlg(' Warning: ZMAP has not been tested on this computer type!','Warning!')
    pause(5)
end

% set some of the paths
    fs = filesep;
    hodo = [hodi fs 'out' fs];
    hoda = [hodi fs 'eq_data' fs];
    p = path;

    source_path = fullfile(hodi, 'src', filesep);
    addpath(hodi);
    addpath(...fullfile(hodi, 'myfiles'),...
        fullfile(hodi, 'src'),...
        [source_path 'utils'],...
        [source_path 'declus'],...
        [source_path 'fractal'],...
        fullfile(hodi, 'help'),...
        fullfile(hodi, 'dem'),...
        fullfile(hodi, 'zmapwww'),...
        fullfile(hodi, 'importfilters'),...
        ...[hodi fs  fs 'src' fs 'utils' fs 'eztool'],...
        fullfile(hodi, 'm_map'),...
        [source_path 'pvals'],...
        [source_path 'synthetic'], ...
        ...[source_path 'movies'],...
        [source_path 'danijel'],...
        [source_path 'danijel' fs 'calc'],...
        [source_path 'danijel' fs 'ex'],...
        [source_path 'danijel' fs 'gui'],...
        [source_path 'danijel' fs 'focal'],...
        [source_path 'danijel' fs 'plot'],...
        [source_path 'danijel' fs 'probfore'],...
        [source_path 'jochen'],...
        [source_path 'jochen' fs 'seisvar' fs 'calc'],...
        [source_path 'jochen' fs 'seisvar'],...
        [source_path 'jochen' fs 'ex'],...
        [source_path 'thomas' fs 'slabanalysis'],...
        [source_path 'thomas' fs 'seismicrates'],...
        [source_path 'thomas' fs 'montereason'],...
        [source_path 'thomas' fs 'gui'],...
        [source_path 'jochen' fs 'plot'],...
        [source_path 'jochen' fs 'stressinv'],...
        [source_path 'jochen' fs 'auxfun'],...
        [source_path 'thomas'], ...
        [source_path 'thomas' fs 'seismicrates'], ...
        [source_path 'thomas' fs 'montereason'], ...
        [source_path 'thomas' fs 'etas'],...
        [source_path 'thomas' fs 'decluster'],...
        [source_path 'thomas' fs 'decluster' fs 'reasen'],...
        [source_path 'thomas'], ...
        [source_path 'thomas' fs 'seismicrates'], ...
        [source_path 'thomas' fs 'montereason'], ...
        [source_path 'thomas' fs 'etas'],...
        [source_path 'thomas' fs 'decluster'],...
        [source_path 'thomas' fs 'decluster' fs 'reasen'],...
        ...[source_path 'juerg' fs 'misc'],...
        [source_path 'afterrate'],...
        [source_path 'cgr_utils']...
        );

 % set some initial variables
 ini_zmap


%Create the 5 data categories
main = [];
mainfault = [];
coastline = [];
well = [];
stat = [];
a = [];
faults = [];


% set a whitebackground if the terminal is black and white
% Does not alway work

if term  == 1
    whitebg([0 0 0 ])
    c1 = 0;
    c2 = 0;
    c3 = 0;
    cb1 = 0;
    cb2 = 0;
    cb3 = 0;
end

% Almost all zmap routine's calls to th uicontrol do so in the following order:
%   uicontrol(...,'Position',[0. ... ], 'Units', 'normalized')
%   however, the program may have a different default, like 'Pixel', and so the previous
%   command incorrectly places the controls.  This can be fixed by changing the order to
%   uicontrol(...,'Units','normalized',Position',[0. ... ])
%
%   But there are thousands of uicontrol calls with differing formats making this a chore
%   one solution, is to change the defaultuicontrolunits to 'normalized'. The problem, 
%   however, is that this breaks the default dialogs which count on (for some reason) the
%   default units being "pixels".
%
% current solution? always call 'figure_w_normalized_uicontrolunits' instead of 'figure'
% this adapter will change the default units for all children of that figure.  This routine,
% or others like it, would allow us to control figure behavior across the entire codebase.
%
% SO... if something doesn't have buttons, but should, then maybe it was assuming "pixels".

set(0,'DefaultAxesFontName','Arial')
set(0,'DefaultTextFontName','Arial')
set(0,'DefaultAxesTickLength',[0.01 0.01])

set(0,'DefaultFigurePaperPositionMode','auto')


% open message window
zmap_message_center;
% message_zmap
think
echo off
my_dir = hodi;
% open selection window
% startmen(mess)
done; %close(fi0)
%set(gcf,'Units','pixel','position', [100 200 300 250])
