
%% ZMAP Version 7.0
%
% This files start up ZMAP.
%
% MAJOR CHANGES to ZMAP from v 6.0:
%  - event catalog is now a ZmapCatalog instead of a variable-sized array
%  - dates/times are handled by MATLAB's built-in datetime and duration data types
%  - duplicated code has been removed or consolidated
%  - scripts have been turned into functions and classes (allowing zmap functions to be run programmatically)
%  - GUI elements have been consolidated, updated
%  - unreachable code (& scripts not appearing in any menus) have been removed
%  - ability to import catalogs from FDSN web services.
%  - global variables have been minimized. Data sharing occurs through one class.
%  - only result variables should appear in the base workspace.
%  - requires minimum of matlab v 2017a,
%
%
%  see README.md and the help for individual parts of ZMAP for other change details
%
% ADDING CUSTOM FUNCTIONS to ZMAP:
% -
%

% The matlab searchpaths are updated, existing windows closed.
%
%  Stefan Wiemer  12/94
%  Modified by Celso Reyes Spring-Fall 2017
%
% see also: ZmapCatalog, ZmapCatalogView, MainInteractiveMap, ZmapMessageCenter

global ZG
% ZG (ZmapGlobal) provides access to all ZMAP's global variables
% When variables are accessed directly via ZmapGlobal.Data.variablename, they
% should not modify the original.
% However, assigning ZmapGlobal.Data to a variable first, provides direct [read/write] access to
% the variables.
% This allows assignment.  
%
%       ZmapGlobal.Data.ra = 100; % value is effectively ignored!
%       ZG=ZmapGlobal.Data; %provide read/write access to global data.
%       ZG.ra = 23  % changes ra globally


disp('This is zmap.m - version 7.0')

% advise matlab where it can find everything zmap
set_zmap_paths;
ZG = ZmapGlobal.Data;
ZG.out_dir = fullfile(hodi,'out');
ZG.data_dir = fullfile(hodi, 'eq_data');

% Set up the different computer systems
sys = computer;

if verLessThan('matlab',ZG.min_matlab_version)
    baseMsg = 'You are running a version of MATLAB older than %s. ZMAP %s requires MATLAB %s or newer';
    messtext = sprintf(baseMsg, ZG.min_matlab_release, ZG.zmap_version, ZG.min_matlab_version);
    errordlg(messtext,'Warning!')
    pause(5)
    exit
end

tested_systems = {'MAC'};
prviously_tested_systems = {'PCW', 'SOL', 'SUN', 'HP7', 'LNX', 'MAC'};
if ~ismember( sys(1:3), tested_systems)
    warndlg(' Warning: ZMAP has not been tested on this computer type.','Warning!')
    pause(5)
end

% set local preference variables
ini_zmap

% set system dependent initial variables
ini_zmap_sys

% open message window
ZmapMessageCenter;
