% This files start up ZMAP.
%
% The matlab searchpathes are updated, existing windows closed.
%
%  Stefan Wiemer  12/94
%  Modified by Celso Reyes Spring/Summer 2017

global sys ZG
disp('This is zmap.m - version 7.0')

% set up paths

% ZG (ZmapGlobal) provides access to all ZMAP's global variables
% When variables are accessed direclty via ZmapGlobal.Data.variablename, they
% should not modify the original.
% However, assigning ZmapGlobal.Data to a variable provides direct access to the variables.
% This allows assignment.  
%
%       ZmapGlobal.Data.ra = 100; % value is effectively ignored!
%       ZG=ZmapGlobal.Data; %provide read/write access to global data.
%       ZG.ra = 23  % changes ra globally
set_zmap_paths;
ZG=ZmapGlobal.Data;
% set some of the paths
ZG.out_dir = fullfile(hodi,'out');
ZG.data_dir = fullfile(hodi, 'eq_data');

% Set up the different computer systems
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


% set system dpendent initial variables
ini_zmap

%{
%Create the 5 data categories
main = [];
mainfault = [];
coastline = [];
well = [];
stat = [];
faults = [];
%}

% open message window
zmap_message_center;
