function [map,maplegend,Astruc] = usgsdem(varargin)

    %USGSDEM  USGS 1-Degree (3-arc-sec resolution) digital elevation data extraction
    %
    % [map,maplegend] = USGSDEM(filename,samplefactor) reads the specified
    % file and returns the data in a regular matrix map.  The data can be
    % read at full resolution (samplefactor = 1), or can be downsampled by
    % the samplefactor.  A samplefactor of 3 returns every third point,
    % giving 1/3 of the full resolution.  The grid for the digital elevation
    % maps is based on the World Geodetic System 1984 (WGS84).  Older DEMs
    % were based on WGS72.  Elevations are in meters relative to National
    % Geodetic Vertical Datum of 1929 (NGVD 29) in the continental U.S. and
    % local mean sea level in Hawaii.
    %
    % [map,maplegend] = USGSDEM(filename,samplefactor,latlim,lonlim) reads
    % data within the latitude and longitude limits. These limits are two
    % element vectors with the minimum and maximum values specified in
    % units of degrees.
    %
    % [map,maplegend,A] = USGSDEM(...) also returns the contents of the
    % A header in a structure. This header describes the contents of the
    % file.
    %
    % The digital elevation map data files are available from the U.S.
    % Geological Survey over the internet from
    % <ftp://edcftp.cr.usgs.gov/pub/data/DEM/250/>.
    %
    % See also USGSDEMS,GTOPO30,TBASE,ETOPO5

    %  Copyright 1996-2000 Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    %  $Revision: 1399 $ $Date: 2006-08-11 11:19:27 +0200 (Fr, 11 Aug 2006) $
    %  Written by:  A. Kim

    %  Ascii data file
    %  Data arranged in S-N rows by W-E columns
    %  Elevation in meters


    name = varargin{1};
    if ~ischar(name)
        if nargin < 3
            error('Samplefactor, latlim and lonlim required to read multiple files.')
        end
        [map,maplegend,Astruc] = usgsdemc(varargin{:});
    else
        [map,maplegend,Astruc] = usgsdemf(varargin{:});
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [map,maplegend,Astruc] = usgsdemf(fname,scalefactor,latlim,lonlim)

    if nargin==2
        subset = 0;
    elseif nargin==4
        subset = 1;
    else
        error('Incorrect number of arguments')
    end

    sf = scalefactor;
    arcsec3 = 3/60^2;
    celldim = sf*arcsec3;
    halfcell = celldim/2;

    fid = fopen(fname,'r');
    if fid==-1
        [fname, path] = uigetfile('', 'select the USGS-DEM file');
        if fname == 0 ; return; end
        fname = [path fname];
        fid = fopen(fname,'r');
    end

    %  --- Read Record Type A (Header Info) ---

    % Define the structure of the header records and data records

    Afield = Adescription;

    % Read the header record. Some fields may be empty, so assume
    % a fixed format as documented in the DEM Data User's Guide 5 (1993),
    % and read the header field-by-field.

    Astruc = readfields(fname,Afield,1,'native',fid);


    % Extract needed data from the header structure

    if Astruc.PlanimetricReferenceSystemCode==1									% dummy check
        error('Ground planimetric coordinates not in arc-seconds. Try USGS24KDEM')
    elseif Astruc.PlanimetricReferenceSystemCode~=0									% dummy check
        error('Ground planimetric coordinates not in arc-seconds')
    end

    corners = ( reshape(Astruc.BoundingBox,[2 4])' )/60^2;

    ncols = Astruc.NrowsCols(2);
    if ~subset
        if mod((ncols-1),sf)~=0	% check to see if ncols fit scalefactor
            error(['Scalefactor does not divide evenly into ' num2str(ncols) ' columns'])
        end
    end

    dy = arcsec3;
    switch ncols
        case 1201, dx = arcsec3;
        case 601,  dx = 2*arcsec3;
        case 401,  dx = 3*arcsec3;
        otherwise, error('Invalid ncols')
    end

    %  Define border of map
    maplatlim(1) = corners(1,2) - halfcell;
    maplatlim(2) = corners(2,2) + halfcell;
    maplonlim(1) = corners(1,1) - halfcell;
    maplonlim(2) = corners(4,1) + halfcell;

    if subset

        %  Check to see if latlim and lonlim within map limits
        errnote = 0;
        if latlim(1)>latlim(2)
            warning('First element of latlim must be less than second')
            errnote = 1;
        end
        if lonlim(1)>lonlim(2)
            warning('First element of lonlim must be less than second')
            errnote = 1;
        end
        if errnote
            error('Check limits')
        end

        tolerance = 0;
        linebreak = newline;

        if  latlim(1)>maplatlim(2)+tolerance | ...
                latlim(2)<maplatlim(1)-tolerance | ...
                lonlim(1)>maplonlim(2)+tolerance | ...
                lonlim(2)<maplonlim(1)-tolerance
            warning([ ...
                'Requested latitude or longitude limits are off the map' linebreak ...
                ' latlim for this dataset is ' ...
                mat2str( [maplatlim(1) maplatlim(2)],3) linebreak ...
                ' lonlim for this dataset is '...
                mat2str( [maplonlim(1) maplonlim(2)],3) ...
                ])
            map=[];maplegend = [];
            return
        end

        warn = 0;
        if latlim(1)<maplatlim(1)-tolerance ; latlim(1)=maplatlim(1);warn = 1; end
        if latlim(2)>maplatlim(2)+tolerance ; latlim(2)=maplatlim(2);warn = 1; end
        if lonlim(1)<maplonlim(1)-tolerance ; lonlim(1)=maplonlim(1);warn = 1; end
        if lonlim(2)>maplonlim(2)+tolerance ; lonlim(2)=maplonlim(2);warn = 1; end
        if warn
            warning([ ...
                'Requested latitude or longitude limits exceed map limits' linebreak ...
                ' latlim for this dataset is ' ...
                mat2str( [maplatlim(1) maplatlim(2)],3) linebreak ...
                ' lonlim for this dataset is '...
                mat2str( [maplonlim(1) maplonlim(2)],3) ...
                ])
        end

        %  Convert lat and lon limits to row and col limits
        halfdy = dy/2;
        halfdx = dx/2;
        ltlwr = corners(1,2)-halfdy:dy:corners(2,2)-halfdy;
        ltupr = corners(1,2)+halfdy:dy:corners(2,2)+halfdy;
        lnlwr = corners(1,1)-halfdx:dx:corners(4,1)-halfdx;
        lnupr = corners(1,1)+halfdx:dx:corners(4,1)+halfdx;
       if latlim(1)>=maplatlim(1)  && latlim(1)<=ltlwr(1)
            rowlim(1) = 1;
        else
            rowlim(1) = min(find(ltlwr<=latlim(1) & ltupr>=latlim(1)));
        end
       if latlim(2)<=maplatlim(2)  && latlim(2)>=ltupr(length(ltupr))
            rowlim(2) = 1201;
        else
            rowlim(2) = max(find(ltlwr<=latlim(2) & ltupr>=latlim(2)));
        end
        if lonlim(1)==maplonlim(1)
            collim(1) = 1;
        else
            collim(1) = min(find(lnlwr<=lonlim(1) & lnupr>=lonlim(1)));
        end
        if lonlim(2)==maplonlim(2)
            collim(2) = ncols;
        else
            collim(2) = max(find(lnlwr<=lonlim(2) & lnupr>=lonlim(2)));
        end

    end

    %  --- Read Record Type B (Elevation Data) ---

    startprofiles = 1029:8192:1029+(ncols-1)*8192;		% start profile position indicators
    sfmin = 1200/(ncols-1);
    if mod(sf,sfmin)~=0
        error(['Samplefactor must be multiple of ' num2str(sfmin)]);
    end
    if ~subset
        colindx = 1:sf/sfmin:ncols;
        maptop = maplatlim(2);
        mapleft = maplonlim(1);
    else
        colindx = collim(1):sf/sfmin:collim(2);
        maptop = corners(1,2) + dy*(rowlim(2)-1) + halfcell;
        mapleft = corners(1,1) + dx*(collim(1)-1) - halfcell;
    end
    scols = startprofiles(colindx);
    cols = length(scols);
    %  Read from left to right of map


    for n=1:cols
        fseek(fid,scols(n),'bof');
        fscanf(fid,'%s',[1 2]);							% data element 1  (don't need)
        profilenumrowscols = fscanf(fid,'%d',[1 2]);	% data element 2
        nrows = profilenumrowscols(1);
        switch ~subset
            case 1
                rowindx = 1:sf:nrows;
            otherwise
                rowindx = rowlim(1):sf:rowlim(2);
        end
        fscanf(fid,'%s',5);								% data elements 3-5
        profile = fscanf(fid,'%d',1201);				% data element 6
        if length(profile) ~= 1201; error('Couldn''t read a whole profile. DEM not conform to standard?'); end
        map(:,n) = profile(rowindx);
    end

    cellsize = 1/celldim;
    maplegend = [cellsize maptop mapleft];

    %  --- Read Record Type C (Statistical Data) ---
    %  Not yet.

    if nargout == 3
        Astruc = explainA(Astruc);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function A = Adescription

    % Data Set Identification (A) record contents

    % Data Set Identification (A) record contents

    A( 1).length = 40;    A( 1).name = 'Quadrangle name';
    A( 2).length = 40;    A( 2).name = 'Textual Info';
    A( 3).length = 55;    A( 3).name = 'Filler';
    A( 4).length = 1;     A( 4).name = 'Process Code';
    A( 5).length = 1;     A( 5).name = 'Filler2';
    A( 6).length = 3;     A( 6).name = 'Sectional Indicator';
    A( 7).length = 4;     A( 7).name = 'MC origin Code';
    A( 8).length = 1;     A( 8).name = 'DEM level Code'; 						A(8).type = '%6g';
    A( 9).length = 1;     A( 9).name = 'Elevation Pattern Code'; 				A(9).type = '%6g';
    A(10).length = 1;     A(10).name = 'Planimetric Reference System Code'; 	A(10).type = '%6g';
    A(11).length = 1;     A(11).name = 'Zone';      							A(11).type = '%6g';
    A(12).length = 15;    A(12).name = 'Projection Parameters'; 				A(12).type = '%24D';
    A(13).length = 1;     A(13).name = 'Horizontal Units';  					A(13).type = '%6g';
    A(14).length = 1;     A(14).name = 'Elevation Units';  						A(14).type = '%6g';
    A(15).length = 1;     A(15).name = 'N sides To Bounding Box'; 				A(15).type = '%6g';
    A(16).length = 8;     A(16).name = 'Bounding Box';     						A(16).type = '%24D';
    A(17).length = 2;     A(17).name = 'Min Max Elevations';        			A(17).type = '%24D';
    A(18).length = 1;     A(18).name = 'Rotation Angle';     					A(18).type = '%24D';
    A(19).length = 1;     A(19).name = 'Accuracy Code';       					A(19).type = '%6g';
    A(20).length = 3;     A(20).name = 'XYZ resolutions ';        				A(20).type = '%12E';
    A(21).length = 2;     A(21).name = 'Nrows Cols';      						A(21).type = '%6g';

    % Old format stops here

    A(22).length = 1;     A(22).name = 'MaxPcontourInt';      					A(22).type = '%5g';
    A(23).length = 1;     A(23).name = 'SourceMaxCintUnits';     				A(23).type = '%1g';
    A(24).length = 1;     A(24).name = 'Smallest Primary';        				A(24).type = '%5g';
    A(25).length = 1;     A(25).name = 'SourceMinCintUnits';      				A(25).type = '%1g';
    A(26).length = 1;     A(26).name = 'Data Source Date';        				A(26).type = '%4g';
    A(27).length = 1;     A(27).name = 'DataInspRevDate';       				A(27).type = '%4g';
    A(28).length = 1;     A(28).name = 'InspRev Flag';
    A(29).length = 1;     A(29).name = 'DataValidationFlag'; 	      			A(29).type = '%1g';
    A(30).length = 1;     A(30).name = 'SuspectVoidFlag';    	    			A(30).type = '%2g';
    A(31).length = 1;     A(31).name = 'Vertical Datum';       					A(31).type = '%2g';
    A(32).length = 1;     A(32).name = 'Horizontal Datum';        				A(32).type = '%2g';
    A(33).length = 1;     A(33).name = 'DataEdition';       					A(33).type = '%4g';
    A(34).length = 1;     A(34).name = 'Percent Void';      					A(34).type = '%4g';



    for i=1:ZG.a.Count;
        if isempty(A(i).type)
            A(i).type = 'char';
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function A = explainA(A)
    % Fill in text associated with numeric codes in the USGS DEM A record

    if ~isempty(A.ProcessCode)
        switch A.ProcessCode
            case '1' , A.ProcessCode = 'GPM';
            case '2' , A.ProcessCode = 'Manual Profile';
            case '3' , A.ProcessCode = 'DLG2DEM';
            case '4' , A.ProcessCode = 'DCASS';
        end
    end


    if ~isempty(A.ElevationPatternCode)
        switch A.ElevationPatternCode
            case 1, A.ElevationPatternCode = 'regular';
            case 2, A.ElevationPatternCode = 'random';
        end
    end

    if ~isempty(A.PlanimetricReferenceSystemCode)
        switch A.PlanimetricReferenceSystemCode
            case 0, A.PlanimetricReferenceSystemCode = 'Geographic';
            case 1, A.PlanimetricReferenceSystemCode = 'UTM';
            case 2, A.PlanimetricReferenceSystemCode = 'State Plane';
        end
    end

    if ~isempty(A.HorizontalUnits)
        switch A.HorizontalUnits
            case 0, A.HorizontalUnits = 'radians';
            case 1, A.HorizontalUnits = 'feet';
            case 2, A.HorizontalUnits = 'meters';
            case 3, A.HorizontalUnits = 'arc-seconds';
        end
    end

    if ~isempty(A.ElevationUnits)
        switch A.ElevationUnits
            case 1, A.ElevationUnits = 'feet';
            case 2, A.ElevationUnits = 'meters';
        end
    end

    if ~isempty(A.AccuracyCode)
        switch A.AccuracyCode
            case 0, A.AccuracyCode = 'unknown accuracy';
            case 1, A.AccuracyCode = 'accuracy information in record C';
        end
    end

    if ~isempty(A.SourceMaxCintUnits)
        switch A.SourceMaxCintUnits
            case 0, A.SourceMaxCintUnits = 'N.A.';
            case 1, A.SourceMaxCintUnits = 'feet';
            case 2, A.SourceMaxCintUnits = 'meters';
        end
    end

    if ~isempty(A.SourceMinCintUnits)
        switch A.SourceMinCintUnits
            case 1, A.SourceMinCintUnits = 'feet';
            case 2, A.SourceMinCintUnits = 'meters';
        end
    end

    if ~isempty(A.DataValidationFlag)
        switch A.DataValidationFlag
            case 0, A.DataValidationFlag = 'No validation performed';
            case 1, A.DataValidationFlag = 'TESDEM (record C added) no qualitative test (no DEM Edit System [DES] review)';
            case 2, A.DataValidationFlag = 'Water body edit and TESDEM run';
            case 3, A.DataValidationFlag = 'DES (includes water edit) no qualitiative test (no TESDEM)';
            case 4, A.DataValidationFlag = 'DES with record C added, qualitative and quantitative tests for level 1 DEM';
            case 5, A.DataValidationFlag = 'DES and TESTDEM qualitative and quantitative tests for levels 2 and 3 DEMs';
        end
    end

    if ~isempty(A.SuspectVoidFlag)
        switch A.SuspectVoidFlag
            case 0, A.SuspectVoidFlag = 'none';
            case 1, A.SuspectVoidFlag = 'suspect areas';
            case 2, A.SuspectVoidFlag = 'void areas';
            case 3, A.SuspectVoidFlag = 'suspect and void areas';
        end
    end

    if ~isempty(A.VerticalDatum)
        switch A.VerticalDatum
            case 1, A.VerticalDatum = 'local means sea level';
            case 2, A.VerticalDatum = 'National Geodetic Vertical Datum 1929 (NGVD 29)';
            case 3, A.VerticalDatum = 'North American Vertical Datum 1988 (NAVD 88)';
        end
    end

    if ~isempty(A.HorizontalDatum)
        switch A.HorizontalDatum
            case 1, A.HorizontalDatum = 'North American Datum 1927 (NAD27)';
            case 2, A.HorizontalDatum = 'World Geodetic System 1972 (WGS72)';
            case 3, A.HorizontalDatum = 'WGS84';
            case 4, A.HorizontalDatum = 'NAD83';
            case 5, A.HorizontalDatum = 'Old Hawaii Datum';
            case 6, A.HorizontalDatum = 'Puerto Rico Datum';
            case 7, A.HorizontalDatum = 'NAD 83 Provisional';
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [map,maplegend,Astruc] = usgsdemc(samplefactor,latlim,lonlim)

    %USGSDEMC  USGS 1-Degree (3-arc-sec resolution) digital elevation data extraction and
    %		   concatenation
    %
    % [MAP,MAPLEGEND] = USGSDEMC(SAMPLEFACTOR,LATLIM,LONLIM) generates
    % a matrix map from data from USGS digital elevation maps enclosing the specified
    % limits (LATLIM,LONLIM).  The USGS data can be read at full resolution (SAMPLEFACTOR = 1),
    % or can be downsampled by the samplefactor.  A samplefactor of 3 returns every
    % third point, giving 1/3 of the full resolution.  Use USGSDEMS to determine
    % the files required to generate the matrix map.  These files must exist in
    % the current directory or on a directory in the default MATLAB path.
    %
    % The digital elevation map data files are available from the U.S.
    % Geological Survey over the internet from
    % <ftp://edcftp.cr.usgs.gov/pub/data/DEM/250/>.
    %
    % See also: USGSDEMS, USGSDEMF

    %  Written by:  A. Kim, W. Stumpf, L. Job

    if nargin~=3
        error('Incorrect number of arguments')
    end

    latlim = latlim(:)';
    lonlim = lonlim(:)';

    if  isequal(size(latlim),[1 1])
        latlim = latlim*[1 1];
    elseif ~isequal(size(latlim),[1 2])
        error('Latitude limit input must be a scalar or 2 element vector')
    end

    if isequal(sort(size(lonlim)),[1 1])
        lonlim = lonlim*[1 1];
    elseif ~isequal(sort(size(lonlim)),[1 2])
        error('Longitude limit input must be a scalar or 2 element vector')
    end

    fid = fopen('usgsdems.dat','r');
    if fid==-1
        error('Couldn''t open usgsdems.dat')
    end

    % get the warning state
    [s,f] = warning;
    warning off

    % preallocate bounding rectangle data for speed

    YMIN = zeros(1,924); YMAX = YMIN;
    XMIN = YMIN; XMAX = YMIN;

    % read names and bounding rectangle limits

    for n=1:924
        fnames{n,1} = fscanf(fid,'%s',1);
        YMIN(n) = fscanf(fid,'%d',1);
        YMAX(n) = fscanf(fid,'%d',1);
        XMIN(n) = fscanf(fid,'%d',1);
        XMAX(n) = fscanf(fid,'%d',1);
        qnames{n,1} = fscanf(fid,'%s',1);
    end
    fclose(fid);


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

    if ~isempty(do)
        fname = fnames(do);
        mat = [YMIN(do); YMAX(do); XMIN(do); XMAX(do)]';
        % sort rows by  min longitude and then min latitude
        [nmat,i] = sortrows(mat,[3 1]);
        mat = nmat;
        for j = 1:max(i)
            nfnames{j} = fname{i(j)};
        end
        fname = nfnames;
    else
        fname = [];
        mat = [];
    end

    % check to see if the files exist within a directory on the MATLAB path
    fileexist = 1;
    if ~isempty(fname)
        for j = 1:max(i)
            if ~exist(fname{j})
                fileexist = 0;
                disp([fname{j},' does not exist or is not in a directory on the default path'])
            end
        end
    end

    if fileexist == 0
        return %break
    end

    Astruc = {};
    % generate the map
    if ~isempty(fname)

        % compute the number of files to be read
        uniquelons1 = unique(mat(:,3));
        uniquelons2 = unique(mat(:,4));
        uniquelons = union(uniquelons1,uniquelons2);
        uniquelats1 = unique(mat(:,1));
        uniquelats2 = unique(mat(:,2));
        uniquelats = union(uniquelats1,uniquelats2);
        numberfiles = (length(uniquelats)-1)*(length(uniquelons)-1);

        % read the first file (bottom left hand corner of map)
        [map{1},maplegend{1},Astruc{1,1}] = usgsdem(fname{1},samplefactor,latlim,lonlim);

        % exit after reading single file if data is contained within the file
        if numberfiles == 1
            fmap = map{1}; fmaplegend = maplegend{1};
            clear map maplegend
            map = fmap; maplegend = fmaplegend;
            return %break
        end

        if length(uniquelats)-1 > 1
            % read remaining files in 1st column (same longitude, increasing latitudes)
            for j = 2:length(uniquelats)-1
                [map{j},maplegend{j},Astruc{j,1}] = usgsdem(fname{j},samplefactor,latlim,lonlim);
                map{j}(1,:) = [];
            end
            fmaplegend = maplegend{j};
        else
            fmaplegend = maplegend{1};
        end

        % concatenate tiles in column wise direction
        tmap= [];
        for j = 1:length(uniquelats)-1
            tmap = [tmap; map{j}];
        end
        fmap{1} = tmap;

        % clear temporary data
        clear map maplegend

        if length(uniquelons)-1 > 1
            % read remaining files for remaining columns and rows
            for k = 2:length(uniquelons)-1
                % read file corresponding to bottom tile in the column
                [map{1},maplegend{1},Astruc{1,k}] = usgsdem(fname{j+1},samplefactor,latlim,lonlim);
                map{1}(:,1) = [];
                % read the remaining files
                for m = 2:length(uniquelats)-1
                    [map{m},maplegend{m},Astruc{m,k}] = usgsdem(fname{m+j},samplefactor,latlim,lonlim);
                    map{m}(1,:) = [];
                    map{m}(:,1) = [];
                end
                % concatenate tiles in column wise direction
                tmap= [];
                for j = 1:length(uniquelats)-1
                    tmap = [tmap; map{j}];
                end
                fmap{k} = tmap;
                j = j*(k);
                % clear temporary data
                clear map maplegend
            end
        else
            k = 1;
        end

        % concatenate all maps
        tmap = [];
        for i = 1:k
            tmap = [tmap fmap{i}];
        end
        map = tmap; maplegend = fmaplegend;
    else
        map = [];
        maplegend = [];
    end

    % reset the warning state
    eval(['warning ',s])
    eval(['warning ',f])

