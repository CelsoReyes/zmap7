function [fname] = globedems(latlim,lonlim)

    %GLOBEDEMS (30-arc-sec resolution) DEM file names
    %
    % fname = GLOBEDEMS(LATLIM,LONLIM) returns a cellarray of the file
    % names covering the geographic region for GLOBEDEM digital elevation maps.
    % The region is specified by scalar latitude and longitude points, or two
    % element vectors of latitude and longitude limits in units of degrees.
    %
    % The data and some documentation is available over the World-Wide-Web from
    % <http://www.ngdc.noaa.gov/seg/topo/globe.shtml>. The data are available
    % by anonymous ftp from <ftp://ftp.ngdc.noaa.gov/GLOBE_DEM/data/elev/>. The
    % web site also sells copies of the data on CD-ROM.
    %
    % See also: GLOBEDEM

    %  Copyright 1996-2000 Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    %  Written by:  A. Kim, W. Stumpf, L. Job
    %  $Revision: 1399 $    $Date: 2006-08-11 11:19:27 +0200 (Fr, 11 Aug 2006) $

    if nargin~=2
        error('Incorrect number of arguments')
    end

    % ensure row vectors
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

    % read names and bounding rectangle limits

    [fnames,YMIN,YMAX,XMIN,XMAX,rtile,ctile] = textread('globedems.dat','%s %d %d %d %d %d %d');

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
    end

    if ~isempty(do)
        fname = fnames(do);
    else
        fname = [];
    end

