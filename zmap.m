function zmap(varargin)
    %% run ZMAP Version 7.X
    %
    % This files start up ZMAP.
    %
    % Options:
    %   -debug    : enables debugging functionality
    %   -restart  : clear all windows and variables, then restart zmap
    %   -initonly : set up zmap paths and prefs, but don't open a window
    %   -RT       : implement real-time mode
    %   -catalog alt_cat: use alt_cat as the prime catalog instead. It may be a variable name, a
    %               ZmapCatalog, or a value that canbe converted by ZmapCatalog
    %               
    %
    % Options to be probably implemented
    %   -grid :
    %   -selector :
    %   -shape :
    %   -state :
    %   -bordersonly :
    %   
    %
    %
    % MAJOR CHANGES to ZMAP from v 6.0:
    %  - event catalog is now a ZmapCatalog instead of a variable-sized array
    %  - dates/times are handled by MATLAB's built-in datetime and duration data types
    %  - duplicated code has been removed or consolidated
    %  - scripts have been turned into functions and classes (allowing zmap functions to be run programmatically)
    %  - GUI elements have been consolidated, updated
    %  - unreachable code (& scripts not appearing in any menus) have been removed
    %  - added ability to import catalogs from FDSN web services.
    %  - global variables have been minimized. Data sharing occurs through one class.
    %  - only result variables should appear in the base workspace.
    %  - requires minimum of matlab v 2018a,
    %
    %
    %  see README.md and the help for individual parts of ZMAP for other change details
    %
    
    % The matlab searchpaths are updated, existing windows closed.
    %
    %  Originally created by: Stefan Wiemer  12/94
    %  Modified by: Celso Reyes Spring 2017 - Winter 2018
    %
    % see also: ZmapCatalog, ZmapMainWindow
    
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
    
    
    % advise matlab where it can find everything zmap
    if ~exist('set_zmap_paths','var')
        p = mfilename('fullpath'); 
        p(end-length(mfilename) : end)=[];
        addpath(fullfile(p,'src'));
    end
    set_zmap_paths;
    
    constructor_options = struct();
    startWindow      = true;
    
    possible_options = varargin(cellfun(@ischarlike,varargin));
    options          = lower(possible_options(startsWith(possible_options,'-')));
    for option = string(options)
        switch option
            case "-debug"
                msg.infodisp('debug mode enabled','initialization')
                constructor_options.debug = true;
                
            case "-restart"
                msg.infodisp('Restarting ZMAP','initialization')
                restartZmap('restart');
                return
                
            case "-quit"
                msg.infodisp('Quitting ZMAP','initialization')
                restartZmap('quit');
                return
                
            case "-initonly"
                msg.infodisp('Initializing Zmap without starting the default main window','initialization')
                startWindow = false;
                
            case "-rt"
                msg.infodisp('RealTimeMode enabled','initialization');
                constructor_options.RealTimeMode = true;
                
            case "-cartesian"
                constructor_options.CoordinateSystem = CoordinateSystems.cartesian;
                
                %{ 
                
            case {"-catalog"} % must be modified to handle ZmapBaseCatalog classes
                vaa = varargin; 
                notstrings =cellfun(@(x)~ischarlike(x),varargin);
                vaa(notstrings)={''};
                idx = find(vaa == "-catalog",1,'last'); %requres all members of vaa be strings
                c = varargin{idx+1};
                if ischarlike(c) && isvarname(c)
                    v=evalin('base',"whos('"+ c +"')");
                    if isempty(v)
                        msg.errordisp("cannot find the variable " + c, 'catalog specified');
                        return
                    end
                    alt_cat = evalin('base',"ZmapCatalog(" + v.name + ")");
                    if isa(alt_cat, 'ZmapBaseCatalog')
                        constructor_options.primeCatalog = alt_cat;
                    end
                    msg.infodisp("set primary catalog to the value from : " + v.name, 'catalog specified');
                else
                    constructor_options.primeCatalog = ZmapCatalog(c);
                    msg.infodisp("set primary catalog from a : " + class(c), 'catalog specified');
                end
                    %}
                
            otherwise
                msg.errordisp('Unknown ZMAP option: ' + option, 'Unknown ZMAP option, stopping');
                return
        end
        
    end
    setappdata(groot,'zmapdataconstructoroptions',constructor_options);
    ZG = ZmapGlobal.Data;
    
    disp(['This is zmap.m - version ', ZmapGlobal.Data.zmap_version])
    % Set up the different computer systems
    sys = computer;
    
    if verLessThan('matlab',ZG.min_matlab_version)
        baseMsg = 'You are running a version of MATLAB older than %s. ZMAP %s requires MATLAB %s or newer';
        messtext = sprintf(baseMsg, ZG.min_matlab_release, ZG.zmap_version, ZG.min_matlab_version);
        msg.errordisp(messtext,  'Incompatible MATLAB Version');
        errordlg(messtext,'Warning!')
        pause(5)
        return
    end
    
    
    tested_systems = {'MAC','PCW'};
    if ~ismember( sys(1:3), tested_systems)
        msg.warndisp('ZMAP has not been tested on this computer type', 'Untested System')
        warndlg('Warning: ZMAP has not been tested on this computer type.','Untested System')
        pause(5)
    end
    
    assignin('base','ZG',ZmapGlobal.Data);
    
    % set local preference variables
    ini_zmap
    
    % set system dependent initial variables
    ini_zmap_sys
    
    % start the main zmap program
    if startWindow
        
        %get rid of message box that would exist if zmap was already opened without a catalog
        delete(findall(groot,'Tag','Msgbox_No Active Catalogs'));
        
        zw = findall(allchild(groot),'Tag','Zmap Main Window');
        s=sprintf('%d ZMAP windows exist\n', numel(zw));
        if ~isempty(zw)
            emptyzw = arrayfun(@(x)~isstruct(x.UserData) || isempty(x.UserData.catalog), zw);
            delete(zw(emptyzw));
            s = s + "... of which " + sum(emptyzw) + " were empty";
        end
        msg.dbdisp(s)
        cw = get(groot,'CurrentFigure');
        if isempty(cw)
            msg.dbdisp('No Figure currently exists');
        else
            switch cw.Tag
                case 'Zmap Main Window'
                    msg.dbdisp('ZMAP Window Exists, and is active')
                otherwise
                    % do nothing
            end
        end
        cw = figure;
        if ~isempty(ZG.primeCatalog) && questdlg('Open previous catalog?','ZMAP','Yes')=="Yes"
            ZmapMainWindow(cw, ZG.primeCatalog);
        else
            ZmapMainWindow(cw, ZmapCatalog);
        end
        show_a_tip();
    end
end
