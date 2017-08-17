function [map,maplegend] = gtopo302(varargin)
    
    % Modifikation von GTOPO30 aus der Matlab Map Toolbox
    % Unterschiede im Bezug auf den Aufbau der Pfadangaben
    % wird von pltopo benoetigt
    
    %GTOPO30 30-Arc-Sec global digital elevation data extraction
    %
    % [map,maplegend] = GTOPO30(filename,scalefactor) reads the GTOPO30
    % files and returns the result as a regular matrix map.  The filename is
    % given as a string which does not include the extension.  If the
    % files are not found on the Matlab path, they may be selected interactively.
    % Scalefactor is an integer, which when equal to 1 gives the data
    % at its full resolution.  When scalefactor is an integer n larger
    % than one, every nth point is returned. The map data is returned as an
    % array of elevations and associated regular matrix map legend. Elevations
    % are given in meters above mean sea level using WGS 84 as a horizontal datum.
    %
    % [map,maplegend] = GTOPO30 data to be read. The limits of the desired
    % data are specified as vectors of latitude and longitude in degrees.
    % The elements of latlim and lonlim must be in ascending order.
    %
    % [map,maplegend] = GTOPO30(dirname,scalefactor,latlim,lonlim) reads and
    % concatenates data from multiple files within a GTOPO30 CD-ROM or directory
    % structure. The dirname input is a string with the name of the directory
    % which contains the GTOPO30 tile directories. Within the tile directories
    % are the uncompressed files data files. The dirname for CD-ROMs distributed
    % by the USGS is the device name of the CD-ROM drive.
    %
    % The data is available over the Internet via anonymous ftp from
    % <ftp://edcftp.cr.usgs.gov/pub/data/gtopo30/global>. The data and
    % some documentation is also available over the World-Wide-Web from
    % <http://edcwww.cr.usgs.gov/landdaac/gtopo30/gtopo30.html> and
    % <http://edcwww.cr.usgs.gov/landdaac/gtopo30/README.html>. These
    % web site also sell copies of the data on CD-ROM.
    %
    % GTOPO30 files are binary. No line ending conversion should be performed
    % during transfer or decompression.
    %
    % See also: GTOPO30 GTOPO30S, GLOBEDEM, DTED, SATBATH, TBASE, USGSDEM
    
    %  Copyright 1996-2000 Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    %  $Revision: 1399 $ $Date: 2006-08-11 11:19:27 +0200 (Fr, 11 Aug 2006) $
    %  Written by:  A. Kim, W. Stumpf, L. Job
    
    %  Ascii header file, binary
    %  Data arranged in W-E columns by N-S rows
    %  Elevation in meters
    
    
    global pgt30
    cd (pgt30)
    name = varargin{1};
    % disp('enter')
    % pause
    if exist([name '.DEM'],'file') == 2
        [map,maplegend] = gtopo30f(varargin{:});
    elseif exist(name,'dir') == 7
        if nargin < 4
            error('Latlim and lonlim required for directory calling form')
        end
        [map,maplegend] = gtopo30c(varargin{:});
        ans
    else
        [map,maplegend] = gtopo30f(varargin{:});
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
function [map,maplegend] = gtopo30c(rd,samplefactor,latlim,lonlim)
    
    %GTOPO30C read and concatenate GTOPO30 (30-arc-sec resolution) digital
    %  elevation files
    
    
    % error checking for input arguments
    
    if nargin < 1; error('Incorrect number of input arguments'); end
    if nargin < 2; samplefactor = 1; end
    if nargin < 3; latlim = []; end
    if nargin < 4; lonlim = []; end
    
    % get the warning state
    [s,f] = warning;
    warning off
    
    fid = fopen('gtopo30s.dat','r');
    if fid==-1
        error('Couldn''t open gtopo30s.dat')
    end
    
    % preallocate bounding rectangle data for speed
    
    YMIN = zeros(1,33); YMAX = YMIN;
    XMIN = YMIN; XMAX = YMIN;
    
    % read names and bounding rectangle limits
    
    for n=1:33
        fnames{n,1} = upper(fscanf(fid,'%s',1));
        YMIN(n) = fscanf(fid,'%d',1);
        YMAX(n) = fscanf(fid,'%d',1);
        XMIN(n) = fscanf(fid,'%d',1);
        XMAX(n) = fscanf(fid,'%d',1);
    end
    fclose(fid);
    
    % case where dateline is not crossed
    if lonlim(1) <= lonlim(2)
        do = ...
            find( ...
            (...
            (latlim(1) <= YMIN & latlim(2) >= YMAX) | ... % tile is completely within region
            (latlim(1) >= YMIN & latlim(2) <= YMAX) | ... % region is completely within tile
            (latlim(1) >  YMIN & latlim(1) <  YMAX) | ... % min of region is on tile
            (latlim(2) >  YMIN & latlim(2) <  YMAX)   ... % max of region is on tile
            ) ...
            &...
            (...
            (lonlim(1) <= XMIN & lonlim(2) >= XMAX) | ... % tile is completely within region
            (lonlim(1) >= XMIN & lonlim(2) <= XMAX) | ... % region is completely within tile
            (lonlim(1) >  XMIN & lonlim(1) <  XMAX) | ... % min of region is on tile
            (lonlim(2) >  XMIN & lonlim(2) <  XMAX)   ... % max of region is on tile
            )...
            );
    end
    
    % case where the dateline is crossed
    if lonlim(1) > lonlim(2)
        lmin = lonlim(1); lmax = lonlim(2);
        lonlim(2) = 180;
        % do eastern side of the dateline first
        doEAST = ...
            find( ...
            (...
            (latlim(1) <= YMIN & latlim(2) >= YMAX) | ... % tile is completely within region
            (latlim(1) >= YMIN & latlim(2) <= YMAX) | ... % region is completely within tile
            (latlim(1) >  YMIN & latlim(1) <  YMAX) | ... % min of region is on tile
            (latlim(2) >  YMIN & latlim(2) <  YMAX)   ... % max of region is on tile
            ) ...
            &...
            (...
            (lonlim(1) <= XMIN & lonlim(2) >= XMAX) | ... % tile is completely within region
            (lonlim(1) >= XMIN & lonlim(2) <= XMAX) | ... % region is completely within tile
            (lonlim(1) >  XMIN & lonlim(1) <  XMAX) | ... % min of region is on tile
            (lonlim(2) >  XMIN & lonlim(2) <  XMAX)   ... % max of region is on tile
            )...
            );
        % do western side of the dateline second
        lonlim(1) = -180; lonlim(2) = lmax;
        doWEST = ...
            find( ...
            (...
            (latlim(1) <= YMIN & latlim(2) >= YMAX) | ... % tile is completely within region
            (latlim(1) >= YMIN & latlim(2) <= YMAX) | ... % region is completely within tile
            (latlim(1) >  YMIN & latlim(1) <  YMAX) | ... % min of region is on tile
            (latlim(2) >  YMIN & latlim(2) <  YMAX)   ... % max of region is on tile
            ) ...
            &...
            (...
            (lonlim(1) <= XMIN & lonlim(2) >= XMAX) | ... % tile is completely within region
            (lonlim(1) >= XMIN & lonlim(2) <= XMAX) | ... % region is completely within tile
            (lonlim(1) >  XMIN & lonlim(1) <  XMAX) | ... % min of region is on tile
            (lonlim(2) >  XMIN & lonlim(2) <  XMAX)   ... % max of region is on tile
            )...
            );
        % concatenate indices
        do = [doEAST doWEST];
        % restore original values for lonlim
        lonlim(1) = lmin; lonlim(2) = lmax;
    end
    
    if ~isempty(do)
        fname = fnames(do);
    else
        fname = [];
    end
    
    % append root directory and check to see if required files exist
    for i = 1:length(do)
        %	ffname{i} = [rd,fname{i},filesep,fname{i}];
        ffname{i}=[rd,filesep,fname{i}];
    end
    
    % assume files exist
    fileexist = 1;
    for i = 1:length(do)
        if ~exist([ffname{i},'.DEM'],'file')
            warning([ffname{i},'.dem does not exist'])
            fileexist = 0;
        end
    end
    
    if ~fileexist
        error('GTOPO30 file not found.')
    end
    
    % sort order over which files will be read
    lon = []; lat = [];
    for i = 1:length(do)
        lond = fname{i}(1);
        if lond == 'W'
            lonv = -1*str2double(fname{i}(2:4));
        else
            lonv = str2double(fname{i}(2:4));
        end
        lon = [lon lonv];
        latd = fname{i}(5);
        if latd == 'S'
            latv = -1*str2double(fname{i}(6:7));
        else
            latv = str2double(fname{i}(6:7));
        end
        lat = [lat latv];
    end
    
    % unique latitudes and longitudes
    uniquelons = sort(unique(lon));
    uniquelats = fliplr(sort(unique(lat)));
    antarc_chk = find(uniquelats == -60);
    
    if lonlim(1) > lonlim(2)
        dateline = 1; % tiles  cross dateline
    else
        dateline = 0; % tile do not cross dateline
    end
    
    %====Start==== Tiles do not include antartica, and do not cross dateline =========
    if isempty(antarc_chk)  &&  dateline == 0
        
        for i = 1:length(uniquelats)
            for j = 1:length(uniquelons)
                switch sign(uniquelons(j))
                    case 1
                        lonh = 'E';
                    case 0
                        lonh = 'W';
                    case -1
                        lonh = 'W';
                end
                lonv = num2str(uniquelons(j));
                lonv = strrep(lonv,'-','');
                if length(lonv) < 3; lonv = ['0',lonv]; end
                % create part of the file name referring to the longitude
                lonh = [lonh,lonv];
                switch sign(uniquelats(i))
                    case 1
                        lath = 'N';
                    case -1
                        lath = 'S';
                end
                latv = num2str(uniquelats(i));
                latv = strrep(latv,'-','');
                % create part of the file name referring to the latitude
                lath = [lath,latv];
                % create full file name
                nfile{i,j} = [lonh,lath];
                %   	nfile{i,j} = [rd,nfile{i,j},filesep,nfile{i,j}];
                %     nfile(i,j) = [rd,nfile{i,j}]
            end
        end
        
        % single tile
        if length(uniquelats) == 1  && length(uniquelons) == 1
            [map,maplegend] = gtopo302(nfile{1,1},samplefactor,latlim,lonlim);
        end
        
        % single row
        if length(uniquelats) == 1  && length(uniquelons) > 1
            tmap = [];
            [map,maplegend] = gtopo302(nfile{1,1},samplefactor,latlim,lonlim);
            tmap = [tmap map]; tmaplegend = maplegend;
            for j = 2:length(uniquelons)
                [map,maplegend] = gtopo302(nfile{1,j},samplefactor,latlim,lonlim);
                tmap = [tmap map];
            end
            clear map maplegend
            map = tmap; maplegend = tmaplegend;
        end
        
        % single column
        if length(uniquelats) > 1  && length(uniquelons) == 1
            tmap = [];
            for j = 1:length(uniquelats)
                [map{j},maplegend{j}] = gtopo302(nfile{j,1},samplefactor,latlim,lonlim);
                % need to flip matrix since we're starting in the top and working down
                tmap = [tmap;flipud(map{j})];
            end
            tmaplegend = maplegend{1};
            clear map maplegend
            % flip the matrix again to get the correct orientation
            map = flipud(tmap); maplegend = tmaplegend;
        end
        
        % matrix
        if length(uniquelats) > 1  && length(uniquelons) > 1
            [map,maplegend] = gtopo302(nfile{1,1},samplefactor,latlim,lonlim);
            tmaplegend = maplegend;
            tmapcolumn = [];
            for i = 1:length(uniquelats)
                tmaprow = [];
                for j = 1:length(uniquelons)
                    [map,maplegend] = gtopo302(nfile{i,j},samplefactor,latlim,lonlim);
                    tmaprow = [tmaprow map];
                end
                tmapcolumn = [tmapcolumn;flipud(tmaprow)];
            end
            clear map maplegend
            map = flipud(tmapcolumn); maplegend = tmaplegend;
        end
        
    end
    %====End====== Tiles do not include antartica, and do not cross dateline =========
    
    %====Start === Tiles include antartica and do not cross dateline =================
    if ~isempty(antarc_chk)  &&  dateline == 0
        
        antarc_latindx = find(uniquelats == -60);
        antarc_lonindx = find(uniquelons == -180 | ...
            uniquelons == -120 | ...
            uniquelons ==  -60 | ...
            uniquelons ==    0 | ...
            uniquelons ==   60 | ...
            uniquelons == 120);
        wld_latindx = find(uniquelats == -10 | uniquelats == 40 | uniquelats == 90);
        wld_lonindx = find(uniquelons == -180 | ...
            uniquelons == -140 | ...
            uniquelons == -100 | ...
            uniquelons ==  -60 | ...
            uniquelons ==  -20 | ...
            uniquelons ==   20 | ...
            uniquelons ==   60 | ...
            uniquelons ==  100 | ...
            uniquelons ==  140);
        antarc_lat = uniquelats(antarc_latindx);
        antarc_lon = uniquelons(antarc_lonindx);
        wld_lat = uniquelats(wld_latindx);
        wld_lon = uniquelons(wld_lonindx);
        
        % antartica tiles
        for i = 1:length(antarc_lat)
            for j = 1:length(antarc_lon)
                switch sign(antarc_lon(j))
                    case 1
                        lonh = 'E';
                    case 0
                        lonh = 'W';
                    case -1
                        lonh = 'W';
                end
                lonv = num2str(antarc_lon(j));
                lonv = strrep(lonv,'-','');
                if length(lonv) < 3; lonv = ['0',lonv]; end
                % create part of the file name referring to the longitude
                lonh = [lonh,lonv];
                switch sign(antarc_lat(i))
                    case 1
                        lath = 'N';
                    case -1
                        lath = 'S';
                end
                latv = num2str(antarc_lat(i));
                latv = strrep(latv,'-','');
                % create part of the file name referring to the latitude
                lath = [lath,latv];
                % create full file name
                antarcfile{i,j} = [lonh,lath];
                antarcfile{i,j} = [rd,antarcfile{i,j},filesep,antarcfile{i,j}];
            end
        end
        
        % world tiles
        if ~isempty(wld_lat)
            for i = 1:length(wld_lat)
                for j = 1:length(wld_lon)
                    switch sign(wld_lon(j))
                        case 1
                            lonh = 'E';
                        case 0
                            lonh = 'W';
                        case -1
                            lonh = 'W';
                    end
                    lonv = num2str(wld_lon(j));
                    lonv = strrep(lonv,'-','');
                    if length(lonv) < 3; lonv = ['0',lonv]; end
                    % create part of the file name referring to the longitude
                    lonh = [lonh,lonv];
                    switch sign(wld_lat(i))
                        case 1
                            lath = 'N';
                        case -1
                            lath = 'S';
                    end
                    latv = num2str(wld_lat(i));
                    latv = strrep(latv,'-','');
                    % create part of the file name referring to the latitude
                    lath = [lath,latv];
                    % create full file name
                    wldfile{i,j} = [lonh,lath];
                    wldfile{i,j} = [rd,wldfile{i,j},filesep,wldfile{i,j}];
                end
            end
        end
        
        % single tile
        if isempty(wld_lat)  &&  size(antarcfile,1) == 1  &&  size(antarcfile,2) == 1
            [map,maplegend] = gtopo302(antarcfile{1,1},samplefactor,latlim,lonlim);
        end
        
        % single row
        if isempty(wld_lat)  &&  size(antarcfile,1) == 1  &&  size(antarcfile,2) > 1
            tmap = [];
            [map,maplegend] = gtopo302(antarcfile{1,1},samplefactor,latlim,lonlim);
            tmap = [tmap map]; tmaplegend = maplegend;
            for j = 2:size(antarcfile,2)
                [map,maplegend] = gtopo302(antarcfile{1,j},samplefactor,latlim,lonlim);
                tmap = [tmap map];
            end
            clear map maplegend
            map = tmap; maplegend = tmaplegend;
        end
        
        % single column
        if ~isempty(wld_lat)  && size(antarcfile,1) == 1  &&  size(antarcfile,2) == 1
            tmap = [];
            % read tiles from world section first
            for j = 1:size(wldfile,1)
                [map{j},maplegend{j}] = gtopo302(wldfile{j,1},samplefactor,latlim,lonlim);
                % need to flip matrix since we're starting in the top and working down
                tmap = [tmap;flipud(map{j})];
            end
            tmaplegend = maplegend{1};
            clear map maplegend
            % read tile from antartica section
            [map,maplegend] = gtopo302(antarcfile{1,1},samplefactor,latlim,lonlim);
            tmap = [tmap;flipud(map)];
            clear map maplegend
            % flip the matrix again to get the correct orientation
            map = flipud(tmap); maplegend = tmaplegend;
        end
        
        % matrix
        if ~isempty(wld_lat)  && size(antarcfile,1) == 1  &&  size(antarcfile,2) > 1
            [map,maplegend] = gtopo302(wldfile{1,1},samplefactor,latlim,lonlim);
            tmaplegend = maplegend;
            tmapcolumn = [];
            % read and concatenate world tiles first
            for i = 1:size(wldfile,1)
                tmaprow = [];
                for j = 1:size(wldfile,2)
                    [map,maplegend] = gtopo302(wldfile{i,j},samplefactor,latlim,lonlim);
                    tmaprow = [tmaprow map];
                end
                tmapcolumn = [tmapcolumn;flipud(tmaprow)];
            end
            clear map maplegend
            % read and concatenate antartica tiles
            for i = 1:size(antarcfile,1)
                tmaprow = [];
                for j = 1:size(antarcfile,2)
                    [amap,amaplegend] = gtopo302(antarcfile{i,j},samplefactor,latlim,lonlim);
                    tmaprow = [tmaprow amap];
                end
                tmapcolumn = [tmapcolumn;flipud(tmaprow)];
            end
            clear map maplegend
            map = flipud(tmapcolumn); maplegend = tmaplegend;
        end
        
        
    end
    %====End  === Tiles include antartica and do not cross dateline =================
    
    %====Start=== Tiles cross dateline =================
    if dateline == 1
        
        % redefine sort order for longitudes
        % Eastern Longitudes
        lon = []; lat = [];
        
        Efile = fnames(doEAST);
        Wfile = fnames(doWEST);
        
        for i = 1:length(doEAST)
            lond = Efile{i}(1);
            if lond == 'W'
                lonv = -1*str2double(Efile{i}(2:4));
            else
                lonv = str2double(Efile{i}(2:4));
            end
            lon = [lon lonv];
        end
        
        % unique latitudes and longitudes
        uniqueElons = sort(unique(lon));
        
        % Western Longitudes
        lon = []; lat = [];
        for i = 1:length(doWEST)
            lond = Wfile{i}(1);
            if lond == 'W'
                lonv = -1*str2double(Wfile{i}(2:4));
            else
                lonv = str2double(Wfile{i}(2:4));
            end
            lon = [lon lonv];
        end
        
        % unique longitudes
        uniqueWlons = sort(unique(lon));
        uniquelons = [uniqueElons uniqueWlons];
        
        % indices for antartica tiles and world tiles
        antarc_latindx = find(uniquelats == -60);
        antarc_lonindx = find(uniquelons == -180 | ...
            uniquelons == -120 | ...
            uniquelons ==  -60 | ...
            uniquelons ==    0 | ...
            uniquelons ==   60 | ...
            uniquelons == 120);
        wld_latindx = find(uniquelats == -10 | uniquelats == 40 | uniquelats == 90);
        wld_lonindx = find(uniquelons == -180 | ...
            uniquelons == -140 | ...
            uniquelons == -100 | ...
            uniquelons ==  -60 | ...
            uniquelons ==  -20 | ...
            uniquelons ==   20 | ...
            uniquelons ==   60 | ...
            uniquelons ==  100 | ...
            uniquelons ==  140);
        antarc_lat = uniquelats(antarc_latindx);
        antarc_lon = uniquelons(antarc_lonindx);
        wld_lat = uniquelats(wld_latindx);
        wld_lon = uniquelons(wld_lonindx);
        
        % antartica tiles
        if ~isempty(antarc_lat)
            for i = 1:length(antarc_lat)
                for j = 1:length(antarc_lon)
                    switch sign(antarc_lon(j))
                        case 1
                            lonh = 'E';
                            alonlims{i,j} = [lonlim(1) 180];
                        case 0
                            lonh = 'W';
                            alonlims{i,j} = [-180 lonlim(2)];
                        case -1
                            lonh = 'W';
                            alonlims{i,j} = [-180 lonlim(2)];
                    end
                    lonv = num2str(antarc_lon(j));
                    lonv = strrep(lonv,'-','');
                    if length(lonv) < 3; lonv = ['0',lonv]; end
                    % create part of the file name referring to the longitude
                    lonh = [lonh,lonv];
                    switch sign(antarc_lat(i))
                        case 1
                            lath = 'N';
                        case -1
                            lath = 'S';
                    end
                    latv = num2str(antarc_lat(i));
                    latv = strrep(latv,'-','');
                    % create part of the file name referring to the latitude
                    lath = [lath,latv];
                    % create full file name
                    antarcfile{i,j} = [lonh,lath];
                    antarcfile{i,j} = [rd,antarcfile{i,j},filesep,antarcfile{i,j}];
                end
            end
        end
        
        % world tiles
        if ~isempty(wld_lat)
            for i = 1:length(wld_lat)
                for j = 1:length(wld_lon)
                    switch sign(wld_lon(j))
                        case 1
                            lonh = 'E';
                            wlonlims{i,j} = [lonlim(1) 180];
                        case 0
                            lonh = 'W';
                            wlonlims{i,j} = [-180 lonlim(2)];
                        case -1
                            lonh = 'W';
                            wlonlims{i,j} = [-180 lonlim(2)];
                    end
                    lonv = num2str(wld_lon(j));
                    lonv = strrep(lonv,'-','');
                    if length(lonv) < 3; lonv = ['0',lonv]; end
                    % create part of the file name referring to the longitude
                    lonh = [lonh,lonv];
                    switch sign(wld_lat(i))
                        case 1
                            lath = 'N';
                        case -1
                            lath = 'S';
                    end
                    latv = num2str(wld_lat(i));
                    latv = strrep(latv,'-','');
                    % create part of the file name referring to the latitude
                    lath = [lath,latv];
                    % create full file name
                    wldfile{i,j} = [lonh,lath];
                    wldfile{i,j} = [rd,wldfile{i,j},filesep,wldfile{i,j}];
                end
            end
        end
        
        % single row - world tiles
        if ~isempty(wld_lat)  &&  isempty(antarc_lat)
            if length(wld_lat) == 1
                tmap = [];
                [map,maplegend] = gtopo302(wldfile{1,1},samplefactor,latlim,wlonlims{1,1});
                tmap = [tmap map]; tmaplegend = maplegend;
                for j = 2:size(wldfile,2)
                    [map,maplegend] = gtopo302(wldfile{1,j},samplefactor,latlim,wlonlims{1,j});
                    tmap = [tmap map];
                end
                clear map maplegend
                map = tmap; maplegend = tmaplegend;
            end
        end
        
        % single row - antartica tiles
        if isempty(wld_lat)  &&  ~isempty(antarc_lat)
            tmap = [];
            [map,maplegend] = gtopo302(antarcfile{1,1},samplefactor,latlim,alonlims{1,1});
            tmap = [tmap map]; tmaplegend = maplegend;
            for j = 2:size(wldfile,2)
                [map,maplegend] = gtopo302(antarcfile{1,j},samplefactor,latlim,alonlims{1,j});
                tmap = [tmap map];
            end
            clear map maplegend
            map = tmap; maplegend = tmaplegend;
        end
        
        % matrix world and antartica tiles
        if ~isempty(wld_lat)  &&  ~isempty(antarc_lat)
            [map,maplegend] = gtopo302(wldfile{1,1},samplefactor,latlim,wlonlims{1,1});
            tmaplegend = maplegend;
            tmapcolumn = [];
            % read and concatenate world tiles first
            for i = 1:size(wldfile,1)
                tmaprow = [];
                for j = 1:size(wldfile,2)
                    [map,maplegend] = gtopo302(wldfile{i,j},samplefactor,latlim,wlonlims{i,j});
                    tmaprow = [tmaprow map];
                end
                tmapcolumn = [tmapcolumn;flipud(tmaprow)];
            end
            clear map maplegend
            % read and concatenate antartica tiles
            for i = 1:size(antarcfile,1)
                tmaprow = [];
                for j = 1:size(antarcfile,2)
                    [amap,amaplegend] = gtopo302(antarcfile{i,j},samplefactor,latlim,alonlims{i,j});
                    tmaprow = [tmaprow amap];
                end
                tmapcolumn = [tmapcolumn;flipud(tmaprow)];
            end
            clear map maplegend
            map = flipud(tmapcolumn); maplegend = tmaplegend;
        end
        
        % matrix world tiles only
        if ~isempty(wld_lat)  &&  isempty(antarc_lat)
            if length(wld_lat) > 1
                disp('im here')
                [map,maplegend] = gtopo302(wldfile{1,1},samplefactor,latlim,wlonlims{1,1});
                tmaplegend = maplegend;
                tmapcolumn = [];
                % read and concatenate world tiles first
                for i = 1:size(wldfile,1)
                    tmaprow = [];
                    for j = 1:size(wldfile,2)
                        [map,maplegend] = gtopo302(wldfile{i,j},samplefactor,latlim,wlonlims{i,j});
                        tmaprow = [tmaprow map];
                    end
                    tmapcolumn = [tmapcolumn;flipud(tmaprow)];
                end
                clear map maplegend
                map = flipud(tmapcolumn); maplegend = tmaplegend;
            end
        end
        
    end
    %====End  === Tiles cross dateline =================
    
    % reset the warning state
    eval(['warning ',s])
    eval(['warning ',f])
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [map,maplegend] = gtopo30f(fname,scalefactor,latlim,lonlim)
    %GTOPO30F 30-Arc-Sec global digital elevation data extraction from file
    
    
    
    if nargin < 1; fname = ''; end
    if nargin < 2; scalefactor = 20; end
    if nargin < 3; latlim = [-90 90]; end
    if nargin < 4; lonlim = [-180 180]; end
    
    %  ---------- Header Information ----------
    
    %  Open ascii header file and read information
    
    filename = [fname '.HDR'];
    fid = fopen(filename,'r');
    
    if fid==-1
        [filename, path] = uigetfile('*.HDR', 'select the GTOPO30 header file (*.HDR)');
        if filename == 0 ; return; end
        filename = [path filename];
        fid = fopen(filename,'r');
        fname = filename(1:length(filename)-4);
    end
    
    nrows = [];
    ncols = [];
    nodata = [];
    ulxmap = [];
    ulymap = [];
    xdim = [];
    ydim = [];
    
    eof = 0;
    while ~eof
        str = fscanf(fid,'%s',1);
        switch lower(str)
            case 'nrows', nrows = fscanf(fid,'%d',1);
            case 'ncols', ncols = fscanf(fid,'%d',1);
            case 'nodata', nodata = fscanf(fid,'%d',1);
            case 'ulxmap', ulxmap = fscanf(fid,'%f',1);
            case 'ulymap', ulymap = fscanf(fid,'%f',1);
            case 'xdim', xdim = fscanf(fid,'%f',1);
            case 'ydim', ydim = fscanf(fid,'%f',1);
            case '', eof = 1;
            otherwise, fscanf(fid,'%s',1);
        end
    end
    fclose(fid);
    
    % Some of the data we wanted wasn't in the hdr file.
    % Read the world file  to get it
    
    if length([nrows ncols nodata ulxmap ulymap xdim ydim]) < 7
        filename = [fname '.BLW'];
        fid = fopen(filename,'r');
        if fid==-1
            filename = [fname '.DMW'];
            fid = fopen(filename,'r');
            if fid==-1
                [filename, path] = uigetfile('*', 'select the GTOPO30 world file (*.BLW or *.DMW)');
                if filename == 0 ; return; end
                filename = [path filename];
                fid = fopen(filename,'r');
            end
        end
        
        xdim = fscanf(fid,'%f',1);
        fscanf(fid,'%f',1);
        fscanf(fid,'%f',1);
        ydim = fscanf(fid,'%f',1); ydim = -ydim;
        ulxmap = fscanf(fid,'%f',1);
        ulymap = fscanf(fid,'%f',1);
    end
    
    % Any information still missing?
    
    if length([nrows ncols nodata ulxmap ulymap xdim ydim]) < 7
        error('Incomplete header file or change in header file format')
    end
    
    % other information about the file
    
    precision = 'int16';
    machineformat = 'ieee-be';
    
    
    % lato = yllcorner + nrows*cellsize;
    % lono = xllcorner;
    lato = ulymap;
    lono = ulxmap;
    
    dlat = -ydim;
    dlon = xdim;
    
    % convert lat and lonlim to column and row indices
    
    [clim,rlim] = yx2rc(lonlim(:),latlim(:),lono,lato,dlon,dlat);
    
    % ensure matrix coordinates are within limits
    
    rlim = [max([1,min(rlim)]) min([max(rlim),nrows])];
    clim = [max([1,min(clim)]) min([max(clim),ncols])];
    
    rlim = sort(flipud(rlim(:))');
    
    readrows = rlim(1):scalefactor:rlim(2);
    readcols = clim(1):scalefactor:clim(2);
    
    readcols = mod(readcols,ncols); readcols(readcols == 0) = ncols;
    
    % extract the map matrix
    filename = [fname '.DEM'];
    map = readmtx(filename,nrows,ncols,precision,readrows,readcols,machineformat);
    map = flipud(map);
    map(map==nodata) = NaN;
    
    % Construct the map legend.
    [la1,lo1] = rc2yx(rlim,clim,lato,lono,dlat,dlon);
    
    maplegend = [abs(1/(dlat*scalefactor)) la1(1)-dlat/2 lo1(1)-dlon/2 ];
    
    
    
