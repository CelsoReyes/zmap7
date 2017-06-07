function [map,maplegend] = tbase(scalefactor,latlim,lonlim)

    %TBASE  TerrainBase Global 5-Min digital terrain data extraction
    %
    % [map,maplegend] = TBASE(scalefactor) reads the data for the entire
    % world, downsampling the data by the scale factor. The result is
    % returned as a regular matrix map and associated map legend.
    % Elevations and depths are given in meters above or below mean sea level.
    %
    % [map,maplegend] = TBASE(scalefactor,latlim,lonlim) reads the data for
    % the part of the world within the latitude and longitude limits. The
    % limits must be two-element vectors in units of degrees.
    %
    % The TerrainBase dataset is available over the Internet at
    % (ftp://ftp.ngdc.noaa.gov/Solid_Earth/CD_ROMS/TerrainBase_94/data/)
    %
    % See also DCWDEM, ETOPO5, USGSDEM

    %  Copyright (c) 1996-97 by Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    % $Revision: 1399 $
    %  Written by:  A. Kim, W. Stumpf

    %  Binary data file (byteorder - little endian)
    %  Data arranged in W-E columns (-180 to 180) by N-S rows (90 to -90).
    %  Elevation in meters

    report_this_filefun(mfilename('fullpath'));

    if nargin==1
        subset = 0;
    elseif nargin==3
        subset = 1;
    else
        error('Incorrect number of arguments')
    end

    sf = scalefactor;
    dcell = 5/60;			% 5 minute grid
    shift = 0;

    if ~subset

        %  Check to see if scalefactor fits matrix dimensions
        if mod(1080,sf)~=0 | mod(4320,sf)~=0
            error('Cannot use this scalefactor')
        end

    else

        %  Check to see if data needs to be shifted (0 to 2pi)
        if lonlim(2)>180
            shift = 1;
        end

        %  Check lat and lon limits
        errnote = 0;
        if latlim(1)>latlim(2)
            warning('1st element of latlim must be greater than 2nd')
            errnote = 1;
        end
        if lonlim(1)>lonlim(2)
            warning('1st element of lonlim must be greater than 2nd')
            errnote = 1;
        end
        if latlim(1)<-90 | latlim(2)>90
            warning('latlim must be between -90 and 90')
            errnote = 1;
        end
        if ~shift  &&  (lonlim(1)<-180 | lonlim(2)>180)
            warning('lonlim must be between -180 and 180')
            errnote = 1;
        end
        if shift & (lonlim(1)<0 | lonlim(2)>360)
            warning('lonlim must be between 0 and 360')
            errnote = 1;
        end
        if errnote
            error('Check limits')
        end

        %  Convert lat and lon limits to row and col limits
        if latlim(2)==90
            rowlim(1) = 1;
        else
            rowlim(1) = floor(-12*(latlim(2)-90)) + 1;
        end
        if latlim(1)==-90
            rowlim(2) = 2160;
        else
            rowlim(2) = ceil(-12*(latlim(1)-90));
        end
        if ~shift
            lon0 = -180;
        else
            lon0 = 0;
        end
        if (~shift & lonlim(1)==-180) | (shift & lonlim(1)==0)
            collim(1) = 1;
        else
            collim(1) = floor(12*(lonlim(1)-lon0)) + 1;
        end
        if (~shift & lonlim(2)==180) | (shift & lonlim(2)==360)
            collim(2) = 4320;
        else
            collim(2) = ceil(12*(lonlim(2)-lon0));
        end

    end

    %  Read TBASE binary image file
    fid = fopen('tbase.bin','rb','ieee-le');
    if fid==-1
        error('tbase.bin file not found')
    end
    if ~subset
        firstrow = 0;
        lastrow = 2*sf*floor(2159/sf)*4320;
        colindx = 1:sf:sf*floor(4319/sf)+1;
        maptop = 90;
        mapleft = -180;
    else
        firstrow = 2*(rowlim(1)-1)*4320;
        lastrow = firstrow + 2*sf*floor((rowlim(2)-rowlim(1))/sf)*4320;
        colindx = collim(1):sf:collim(1)+sf*floor((collim(2)-collim(1))/sf);
        maptop = 90 - dcell*(rowlim(1)-1);
        mapleft = -180 + dcell*(collim(1)-1);
        if shift
            mapleft = dcell*(collim(1)-1);
        end
    end
    srow = firstrow:2*sf*4320:lastrow;			% start row position indicators
    rows = length(srow);
    %  Read from bottom to top of map (first row of matrix is bottom of map)
    for m=rows:-1:1
        %	if mod(m,10)==0
        %		disp(m)
        %	end
        fseek(fid,srow(m),'bof');
        temp = fread(fid,[1 4320],'int16');
        if shift
            temp = [temp(2161:4320) temp(1:2160)];
        end
        map(rows-m+1,:) = temp(colindx);
    end
    cellsize = 1/(sf*dcell);
    maplegend = [cellsize maptop mapleft];
