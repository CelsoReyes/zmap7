function [map,maplegend] = usgsdem(fname,scalefactor,latlim,lonlim)

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
    % The digital elevation map data files are available from the U.S.
    % Geological Survey over the internet from
    % <ftp://edcftp.cr.usgs.gov/pub/data/DEM/250/>.
    %
    % See also USGSDEMS,DCWDEM,TBASE,ETOPO5

    %  Copyright (c) 1996-97 by Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    % $Revision: 1399 $
    %  Written by:  A. Kim

    %  Ascii data file
    %  Data arranged in S-N rows by W-E columns
    %  Elevation in meters

    report_this_filefun(mfilename('fullpath'));

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
        error('USGSDEM file not found')
    end

    %  --- Read Record Type A (Header Info) ---

    %  Read header information - dummy checks
    fseek(fid,48,'bof');
    quadname = fscanf(fid,'%s',1);						% data element 1
    fscanf(fid,'%s',[1 4]);								% data elements 2-5  (don't need)
    fscanf(fid,'%s',[1 15]);							% data element 6  (don't need)
    unitscode = fscanf(fid,'%d',[1 2]);					% data elements 7-8
    if unitscode(1)~=3									% dummy check
        disp(['unitscode = [' num2str(unitscode) ']'])
        error('Ground planimetric coordinates not in arc-seconds')
    end
    if unitscode(2)~=2									% dummy check
        disp(['unitscode = [' num2str(unitscode) ']'])
        warning('Elevation data not in meters')
    end
    numsides = fscanf(fid,'%d',1);						% data element 9
    if numsides~=4										% dummy check
        disp(['numsides = ' num2str(numsides)])
        error('Not a quadrangle')
    end
    for n=1:4											% data element 10
        corners(n,1) = str2num(fscanf(fid,'%s',1))/60^2;
        corners(n,2) = str2num(fscanf(fid,'%s',1))/60^2;
    end
    for n=1:2											% data element 11
        minmaxelev(n) = str2double(fscanf(fid,'%s',1));
    end
    fscanf(fid,'%s',1);									% data element 12  (don't need)
    fseek(fid,815,'bof');
    fread(fid,1,'bit2');								% data element 13  (don't need)
    for n=1:3											% data element 14
        spatialres(n) = str2double(char(fread(fid,12,'uchar'))');
    end
   if any(spatialres~=[3 3 1])  && ...					% dummy check
            any(spatialres~=[6 3 1]) & ...
            any(spatialres~=[9 3 1])
        disp(['spatialres = [' num2str(spatialres) ']'])
        error('Spacial resolution not [3 3 1], [6 3 1], or [9 3 1]')
    end
    numrowscols = fscanf(fid,'%d',[1 2]);				% data element 15
    ncols = numrowscols(2);
   if any(numrowscols~=[1 1201])  && ...					% dummy check
            any(numrowscols~=[1 601]) & ...
            any(numrowscols~=[1 401])
        disp(['numrowscols = [' num2str(numrowscols) ']'])
        error('Rows and columns not [1 1201], [1 601], or [1 401]')
    else
        if ~subset
            if mod((ncols-1),sf)~=0	% check to see if ncols fit scalefactor
                error('Scalefactor does not fit ncols')
            end
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
        if  latlim(1)>maplatlim(2)+tolerance | ...
                latlim(2)<maplatlim(1)-tolerance | ...
                lonlim(1)>maplonlim(2)+tolerance | ...
                lonlim(2)<maplonlim(1)-tolerance
            warning([ ...
                'Requested latitude or longitude limits are off the map' char(13) ...
                ' latlim for this dataset is ' ...
                mat2str( [maplatlim(1) maplatlim(2)],3) char(13) ...
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
                'Requested latitude or longitude limits exceed map limits' char(13) ...
                ' latlim for this dataset is ' ...
                mat2str( [maplatlim(1) maplatlim(2)],3) char(13) ...
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
        fscanf(fid,'%d',[1 2]);							% data element 1  (don't need)
        profilenumrowscols = fscanf(fid,'%d',[1 2]);	% data element 2
        nrows = profilenumrowscols(1);
        switch ~subset
            case 1
                rowindx = 1:sf:nrows;
            otherwise
                rowindx = rowlim(1):sf:rowlim(2);
        end
        % 	if any(profilenumrowscols~=[1201 1])
        % 		error('Rows and columns not [1201 1]')
        % 	else
        % 		if ~subset
        % 			if mod((nrows-1),sf)~=0					% check to see if nrows fit scalefactor
        % 				error(['samplefactor must divide evenly into ' num2str(nrows) ...
        % 		       ' rows and ' num2str(ncols) ' columns'])
        % 			end
        % 			rowindx = 1:sf:nrows;
        % 		else
        % 			rowindx = rowlim(1):sf:rowlim(2);
        % 		end
        % 	end
        fscanf(fid,'%s',2);								% data element 3  (don't need)
        fscanf(fid,'%f',1);								% data element 4  (don't need)
        fscanf(fid,'%s',2);								% data element 5  (don't need)
        profile = fscanf(fid,'%d',1201);				% data element 6
        map(:,n) = profile(rowindx);
    end

    cellsize = 1/celldim;
    maplegend = [cellsize maptop mapleft];

    %  --- Read Record Type C (Statistical Data) ---
    %  Nothing important to read
