% This files start up ZMAP.
%
% The matlab searchpathes are updated, existing windows closed.
%
%  Stefan Wiemer  12/94
%  Modified by Celso Reyes Spring/Summer 2017

global sys ZG
%system_dependent(14,'on')
disp('This is zmap.m - version 7.0')

%{
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
%}


% set some of the paths
set_zmap_paths();

ZG=ZmapGlobal.Data; % get zmap globals

% Set up the different compuer systems
sys = computer;

if verLessThan('matlab',ZG.min_matlab_version)
    baseMsg = 'You are running a version of MATLAB older than %s. ZMAP %s requires MATLAB %s or newer';
    messtext = sprintf(baseMsg, ZG.min_matlab_release, ZG.zmap_version, ZG.min_matlab_version);
    errordlg(messtext,'Warning!')
    pause(5)
end

tested_systems = {'MAC'};
prviously_tested_systems = {'PCW', 'SOL', 'SUN', 'HP7', 'LNX', 'MAC'};
if ~ismember( sys(1:3), tested_systems)
    errordlg(' Warning: ZMAP has not been tested on this computer type.','Warning!')
    pause(5)
end


% set some initial variables
ini_zmap


%Create the 5 data categories
main = [];
mainfault = [];
coastline = [];
well = [];
stat = [];
faults = [];

%{
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
%}

set(0,'DefaultAxesFontName','Arial');
set(0,'DefaultTextFontName','Arial');
set(0,'DefaultAxesTickLength',[0.01 0.01]);
set(0,'DefaultFigurePaperPositionMode','auto');

% open message window
zmap_message_center;
