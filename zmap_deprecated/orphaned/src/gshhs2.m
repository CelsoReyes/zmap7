function struc = gshhs(varargin)

    %GSHHS  Extracts Global Self-consistent Hierarchical High-resolution Shoreline data
    %
    %  struc = GSHHS(filename) reads the specified gshhs file and extracts data
    %  for the entire world.  The result is returned as a geographic data
    %  structure.  Each element of struc represents a unique polygon.  The tag
    %  field for each element contains the topographic level represented by the
    %  polygon, and will be either 'land', 'lake', 'island' for an island in a
    %  lake, or 'pond' for a pond on an island in a lake.  GSHHS files have
    %  filenames of the form 'gshhs_X.b', where X is one of the letters c, l, i, h
    %  and f, corresponding to increasing resolution (and file size).
    %
    %  struc = GSHHS(filename,latlim,lonlim) reads the data for the part of the
    %  world within the latitude and longitude limits.  The limits must be
    %  two-element vectors in units of degrees. Longitude limits should be
    %  between [-180 195].
    %
    %  GSHHS(filename,'createindex') creates an index file for faster
    %  reading.  The index file has the same name the GSHHS data file, but with
    %  the extension 'i', instead of 'b'.  The file is written in the present
    %  working directory, which can be identified with the command PWD.  This file
    %  is needed for acceptable performance with the larger datasets.  No map data
    %  is returned while creating the index.
    %
    %  The GSHHS data in various resolutions is available over the Internet from
    %  <ftp://ftp.ngdc.noaa.gov/MGG/shorelines> and
    %  <ftp://kiawe.soest.hawaii.edu/pub/wessel/gshhs/>
    %
    %  Information on the datasets is available from
    %  <http://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html>
    %
    % See also: EXTRACTM, VMAP0DATA, DCWDATA, TGRLINE, TIGERMIF, TIGERP
    %

    % Copyright 1996-2000 Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    % $Revision 0.0 $
    % Written by:  T.Debole, W. Stumpf

    report_this_filefun(mfilename('fullpath'));

    create_index = 0;

    % Input checks.
    if nargin == 1
        filename = varargin{1};
        subset = 0;
        latlim = [];
        lonlim = [];
        inindex = [];
    elseif nargin == 3
        filename = varargin{1};
        latlim = varargin{2};
        lonlim = varargin{3};
        if (~isequal(sort(size(latlim)),[1 2])) | (~isequal(sort(size(lonlim)),[1,2]))
            error('latlim and lonlim must be two-element vectors.');
        elseif latlim(1) > latlim(2)
            error('First element of latlim must be less than second.');
        elseif lonlim(1) > lonlim(2)
            error('First element of lonlim must be less than second.');
        end
        subset = 1;
        inindex = [];
    elseif nargin == 2
        filename = varargin{1};
        if ischar(varargin{2})  &&  strmatch('createindex',varargin{2})
            create_index = 1;
        else
            error('Did you mean to type GSHHS(filename,''createindex'') ? ')
        end
        subset = 0;
        latlim = [];
        lonlim = [];
        inindex = [];
    else
        error('Incorrect number of arguments.')
    end

    % Initialize output structure.
    struc = [];

    % Open the data file in binary mode, with big endian byte ordering.
    FileID = fopen(filename,'rb','ieee-be');
    if FileID==-1
        [filename, path] = uigetfile('*', 'Select the GSHHS data file.');
        if filename == 0
            return;
        end
        filename = [path filename];
        FileID = fopen(filename,'rb','ieee-be');
    end

    %  Verify that we can open index file

    ifilename = [];
    iFileID = [];
    if ~create_index

        ifilename = filename;
        ifilename(end) = 'i';

        iFileID = fopen(ifilename,'rb','ieee-be');
        if iFileID==-1

            ifilename(end) = 'I'; % case senstivity on some platforms?
            iFileID = fopen(ifilename,'rb','ieee-be');

            if iFileID==-1
                warning(sprintf(['Can''t find index file. Will read entire file ' ...
                    'sequentially.\n Use the ''createindex'' option to '...
                    'generate an index file']));
                iFileID = [];
                ifilename = [];
            end
            fclose(iFileID);
        end
    end


    % Read all of the file keeping only parts within limits if no index
    % array is provided, or use the index array to read only data within
    % limits.
    if isempty(ifilename) | create_index  ||  ~subset
        [struc,index] = readall(FileID,latlim,lonlim,create_index,subset,filename);
    else
        struc = readsome(FileID,latlim,lonlim,ifilename,subset);
    end


    % Drop unused portions of index array

    if create_index
        index(isnan(index)) = [];
        index = reshape(index,length(index(:))/5,5);
    end

    %  Close file
    fclose(FileID);

    return

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [struc,index] = readall(FileID,latlim,lonlim,create_index,subset,filename)
    % READALL reads all records in gshhs file, saving some and saving index array

    % Constants
    BOHOffset = 4;  % Beginning of Header Offset (to skip the first header field)
    EOHOffset = 8;  % End of Header Offset (to skip the last three header fields)

    % Initialize output variables.
    lat = [];
    lon = [];
    index = [];
    struc = [];

    if create_index
        % 	indexlength = 2000;
        % 	index = repmat(NaN,indexlength,5);

        filename(end) = 'i'; % filename goes from something.b to something.i
        warning(['Creating index file ''' filename ''''])
        fidindx = fopen(filename,'w','ieee-be');
        if fidindx == -1
            fclose(FileID);
            error('Error opening new indx file for writing.  Read-only?')
        end
    end

    % Get the end of file position.
    status = fseek(FileID,0,'eof');
    if status == -1
        error(ferror(FileID));
    end
    EOF = ftell(FileID);

    % Go back to the beginning of the file.
    status = fseek(FileID,0,'bof');
    if status == -1
        error(ferror(FileID));
    end
    FilePosition = ftell(FileID);

    % For each polygon, read header block, and if within limits
    % read the coordinates

    k = 1;
    l = 1;
    while FilePosition ~= EOF

        % Read header info.
        status = fseek(FileID,BOHOffset,'cof');  % 'int32' (Skip the first field.) /* Unique polygon id number, starting at 0 */
        if status == -1
            error(ferror(FileID));
        end
        [H,Count] = fread(FileID,7,'int32');
        n     = H(1); % Number of points in this polygon
        level = H(2); % 1 land, 2 lake, 3 island_in_lake, 4 pond_in_island_in_lake
        west  = H(3) * 1.0E-06; % degrees
        east  = H(4) * 1.0E-06;
        south = H(5) * 1.0E-06;
        north = H(6) * 1.0E-06;
        area  = H(7) * 10; % Area of polygon in km^2
        if create_index; fwrite(fidindx,H([1 3:6]),'int32'); end

        [H,Count] = fread(FileID,2,'int16');
        gcross = H(1); % 1 if Greenwich is crossed
        source = H(2); % 0 = CIA WDBII, 1 = WVS

        % Determine if any of the data in the current block falls within the input limits.
        % If so, read the data.  If not, move to the end of the block.
        if subset
            DataWithinLimits = CheckDataLimits(west,east,south,north,latlim,lonlim);
        else
            DataWithinLimits = 1;
        end

       if DataWithinLimits  && ~create_index
            %       % Move past the header to the data for this block.
            %       status = fseek(FileID,EOHOffset,'cof');
            %       if status == -1
            %          error(ferror(FileID));
            %       end
            % Read the data.
            [Data,Count] = fread(FileID,[2,n],'int32');
            lon = 1E-06*Data(1,:)';
            lat = 1E-06*Data(2,:)';
            % If necessary, trim the data to the input latitude and longitude limits.
            if subset
                % Check for big jumps in longitude, indicating a branch cut crossing.
                % The data west of 0 seems to have 360 degrees added to it. This results in
                % funny jumps that maptrimp won't handle.

                if gcross
                    indx = find(lon>200);
                    lon(indx) = lon(indx)-360;

                    tlatlim = latlim;
                    tlonlim = zero22pi(lonlim);
                end

                [lattrim,lontrim] = maptrimp(lat,lon,tlatlim,tlonlim);

                % Reduce the data by removing unneccesary colinear points.
                [newlat,newlon] = removepts(lattrim,lontrim);
                lat = newlat;  lon = newlon;

            end

            % Assign the tag string.
            switch level
                case 1
                    tagstr = 'land';
                case 2
                    tagstr = 'lake';
                case 3
                    tagstr = 'island';
                case 4
                    tagstr = 'pond';
                otherwise
                    tagstr = 'other';
            end

            % Write the data to the output geographic data structure.
            struc(k).type          = 'patch';
            struc(k).tag           = tagstr;
            struc(k).lat           = lat;
            struc(k).long          = lon;
            struc(k).altitude      = [];
            struc(k).otherproperty = {};

            % Increment the element counter for the output structure.
            % The if test is here because cruder resolutions of the data
            % sometimes contain no points that fall within latlim and lonlim,
            % even though the west, east, south and north values indicate
            % that there should be data points within those limits.  This
            % check prevents a patch segment consisting of just a NaN, which
            % would cause problems with displaym.
            if length(struc(k).lat) ~= 1
                k = k + 1;
            end
        else
            % Move to the end of this data block.
            Offset = n*8; %EOHOffset +
            status = fseek(FileID,Offset,'cof');
            if status == -1
                error(ferror(FileID));
            end
        end
        FilePosition = ftell(FileID);

    end  % end while loop

    if create_index; fclose(fidindx); end

    return

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function struc = readsome(FileID,latlim,lonlim,ifilename,subset)

    % Constants
    BOHOffset = 4;  % Beginning of Header Offset (to skip the first header field)
    EOHOffset = 8;  % End of Header Offset (to skip the last three header fields)

    % count number of records in index file

    [extractindx,npolypts] = inlimitpolys(ifilename,latlim,lonlim);

    tlonlim = npi2pi(lonlim);
    tlatlim = latlim;

    % Initialize output variables.
    lat = [];
    lon = [];
    index = [];
    % For each polygon within limits, read header block and coordinates

    k = 1;
    l = 1;
    for i=1:length(extractindx)
        % Read header info.
        bytesbefore = (extractindx(i)-1)*36 + sum( npolypts(1:extractindx(i)-1,1) )*8; % Skip data from preceeding polyons
        if isempty(bytesbefore); bytesbefore = 0; end
        status = fseek(FileID,bytesbefore+BOHOffset,'bof');  % (Skip the first field.)
        if status == -1
            error(ferror(FileID));
        end

        [H,Count] = fread(FileID,7,'int32');
        n     = H(1); % Number of points in this polygon
        level = H(2); % 1 land, 2 lake, 3 island_in_lake, 4 pond_in_island_in_lake
        west  = H(3) * 1.0E-06; % degrees
        east  = H(4) * 1.0E-06;
        south = H(5) * 1.0E-06;
        north = H(6) * 1.0E-06;
        area  = H(7) * 10; % Area of polygon in km^2

        [H,Count] = fread(FileID,2,'int16');
        gcross = H(1); % 1 if Greenwich is crossed
        source = H(2); % 0 = CIA WDBII, 1 = WVS

        % Read the data.
        if n > 1e6
            [lat,lon] = readbigone(FileID,n,tlatlim,tlonlim);
        else
            [Data,Count] = fread(FileID,[2,n],'int32');
            lon = 1E-06*Data(1,:)';
            lat = 1E-06*Data(2,:)';
        end

        % wrap the data to the -180 to +190 system

        if ~isempty(lat)  &&  n < 1e6

            lon = smoothlong(npi2pi(lon)) ;
            if any(lon<-200)
                lon = npi2pi(lon); %antarctica
            end


            % Reduce the data by triming and removing unneccesary colinear points.
            % 	if ~gcross
            [lattrim,lontrim] = maptrimp(lat,lon,tlatlim,tlonlim);
            [newlat,newlon] = removepts(lattrim,lontrim);
            lat = newlat;  lon = newlon;
            % 	end
        end

        % Assign the tag string.
        switch level
            case 1
                tagstr = 'land';
            case 2
                tagstr = 'lake';
            case 3
                tagstr = 'island';
            case 4
                tagstr = 'pond';
            otherwise
                tagstr = 'other';
        end

        % Write the data to the output geographic data structure.
        struc(k).type          = 'patch';
        if n > 1000000
            struc(k).type          = 'line';
        end
        struc(k).tag           = tagstr;
        struc(k).lat           = lat;
        struc(k).long          = lon;
        struc(k).altitude      = [];
        struc(k).otherproperty = {};

        % Increment the element counter for the output structure.
        % The if test is here because cruder resolutions of the data
        % sometimes contain no points that fall within latlim and lonlim,
        % even though the west, east, south and north values indicate
        % that there should be data points within those limits.  This
        % check prevents a patch segment consisting of just a NaN.
        if length(struc(k).lat) > 1
            k = k + 1;
        end

    end  % end while loop

    return



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DataInLimits = CheckDataLimits(west,east,south,north,latlim,lonlim)
    % CheckDataLimits returns 0 if the data in the current data block falls
    % entirely outside the input limits (latlim & lonlim), and 1 if any part
    % of the data falls inside the input limits.

    %if ((west >= lonlim(1)  && east <= lonlim(2))    | ...  % data region is entirely within lonlim
    %     (west <= lonlim(1) & east >= lonlim(2))    | ...  % lonlim is entirely within data region
    %     (west  < lonlim(1) & east  > lonlim(1))    | ...  % lonlim(1) falls within data region
    %     (west  < lonlim(2) & east  > lonlim(2)))     ...  % lonlim(2) falls within data region
    %    & ...
    %    ((south >= latlim(1) & north <= latlim(2))  | ...  % data region is entirely within latlim
    %     (south <= latlim(1) & north >= latlim(2))  | ...  % latlim is entirely within data region
    %     (south  < latlim(1) & north  > latlim(1))  | ...  % latlim(1) falls within data region
    %     (south  < latlim(2) & north  > latlim(2)))   ...  % latlim(2) falls within data region
    %    DataInLimits = 1;
    % else
    %    DataInLimits = 0;
    % end

    % if abs(diff(lonlim)) = 360; lonlim = [0 360]
    % if any(lonlim < 0); lonlim = lonlim+360; end

    west = npi2pi(west);
    east = npi2pi(east);
    east(east < west) = east(east < west) + 360;

    DataInLimits = ...
        ((west >= lonlim(1) & east <= lonlim(2))   | ...  % data region is entirely within lonlim
        (west <= lonlim(1) & east >= lonlim(2))    | ...  % lonlim is entirely within data region
        (west  < lonlim(1) & east  > lonlim(1))    | ...  % lonlim(1) falls within data region
        (west  < lonlim(2) & east  > lonlim(2)))     ...  % lonlim(2) falls within data region
        & ...
        ((south >= latlim(1) & north <= latlim(2))  | ...  % data region is entirely within latlim
        (south <= latlim(1) & north >= latlim(2))  | ...  % latlim is entirely within data region
        (south  < latlim(1) & north  > latlim(1))  | ...  % latlim(1) falls within data region
        (south  < latlim(2) & north  > latlim(2)));        % latlim(2) falls within data region

    return


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [newlat,newlon] = removepts(latin,lonin)
    % This function removes unneccessary colinear points from the input
    % latitude and longitude vectors.

    patchpts = [latin(:) lonin(:)];
    epsilon = epsm('degrees');

    if length(patchpts) > 3
        i = 1;
        j = 2;
        k = 3;
        while k <= length(patchpts)
            % Assign three consecutive data points to A, B and C.
            A = patchpts(i,:);
            B = patchpts(j,:);
            C = patchpts(k,:);
            if k == 3
                % Keep first point.
                NewPatch = A;
            end
            % This is based on taking the cross product of A-B and A-C.
            % If the last term in the resulting vector (u1v2-u2v1) is zero,
            % then the points are colinear.  But it's faster to just code
            % that one term, instead of calling cross.
            AB = A-B;
            AC = A-C;
            if abs( AB(1).*AC(2) - AB(2).*AC(1) ) <= epsilon
                % A, B and C are colinear.  Remove B.
                j = j + 1;
                k = k + 1;
            else
                % Keep B.
                NewPatch = [NewPatch; B];
                i = j;
                j = j + 1;
                k = k + 1;
            end
        end % end while
        % Keep last point.
        NewPatch = [NewPatch; C];

        % Assign output variables.
        newlat = NewPatch(:,1);
        newlon = NewPatch(:,2);

    else
        newlat = latin;
        newlon = lonin;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [extractindx,npolypts] = inlimitpolys(ifilename,latlim,lonlim)



    % Open the index file again and get the file size
    iFileID = fopen(ifilename,'rb','ieee-be');
    status = fseek(iFileID,0,'eof');
    ifilelength = ftell(iFileID);
    fclose(iFileID);

    % number of polygons in the file

    npoly = ifilelength/(32*5/8); %total bytes in index file/( bits per number * number of numbers per record / bits/byte)



    extractindx = [];
    blocksize = 2000;
    startblock = 0;
    nrows  = npoly;
    ncols = 5; % npts, latlim,lonlim


    % read number of points in each polygon from the index file
    readcols = [1 1];
    readrows = [1 npoly];
    npolypts = readmtx(ifilename,nrows,ncols,'int32',readrows,readcols,'ieee-be');

    % identify polygons in latlim. Do this in blocks to reduce memory requirements
    readcols = [2 5];
    while 1

        readrows = [startblock*blocksize+1 min((startblock+1)*blocksize,npoly)];

        bbox = readmtx(ifilename,nrows,ncols,'int32',readrows,readcols,'ieee-be');

        bbox = bbox * 1.0E-06; % degrees (west east south north)

        % identify polygons that fall within the limits
        extractindx = ...
            [extractindx; ...
            (startblock*blocksize + ...
            find(CheckDataLimits( bbox(:,1),bbox(:,2),bbox(:,3),bbox(:,4),...
            latlim,lonlim)) ) ...
            ];

        if max(readrows) == npoly; break; end

        startblock = startblock+1;

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [savelat,savelon] = readbigone(FileID,n,tlatlim,tlonlim)
    % READBIGONE read a really, really big polygon

    % GSHHS at fill resolution has the continents as fillable polygons with millions
    % (yes, millions) of points.

    blocksize = 50000;
    readblock = blocksize;
    block = 0;

    savelat = [];
    savelon = [];
    while 1

        readtopoint = block*blocksize;
        if readtopoint > n
            if block == 0
                readblock = n;
            else
                readblock = n - (block-1)*blocksize;
            end
        end

        [Data,Count] = fread(FileID,[2,readblock],'int32');
        lon = 1E-06*Data(1,:)';
        lat = 1E-06*Data(2,:)';

        % wrap the data to the -180 to +190 system

        lon = npi2pi(lon);
        if any(lon<-200)
            lon = npi2pi(lon); %antarctica
        end


        % Reduce the data by triming and removing unneccesary colinear points.
        [lat,lon] = maptriml(lat,lon,tlatlim,tlonlim);

        savelat = [savelat; lat];
        savelon = [savelon; lon];

        if readblock ~= blocksize; break; end

        block = block+1;
    end

    [savelat,savelon] = singleNaN(savelat,savelon);

   if length(savelat) == 1  && isnan(lat)
        lat = []; lon = [];
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lat,lon] = singleNaN(lat,lon)

    % SINGLENAN removes duplicate nans in lat-long vectors

    if ~isempty(lat)
        nanloc = isnan(lat);	[r,c] = size(nanloc);
        nanloc = find(nanloc(1:r-1,:) & nanloc(2:r,:));
        lat(nanloc) = [];  lon(nanloc) = [];
    end
