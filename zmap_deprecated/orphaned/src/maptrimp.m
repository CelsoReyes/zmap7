function [lat,lon] = maptrimp(lat0,lon0,latlim,lonlim)

    %MAPTRIMP  Trims a patch map to a specified region
    %
    %  [lat,lon] = MAPTRIMP(lat0,lon0,latlim,lonlim) trims a patch map
    %  to a region specified by latlim and lonlim.  Latlim and lonlim
    %  are two element vectors, defining the latitude and longitude limits
    %  respectively.  The inputs lat0 and lon0 must be vectors representing
    %  patch map vector data.
    %
    %  See also MAPTRIMS, MAPTRIML

    %  Copyright 1996-2000 Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    %  Written by:  E. Byrns, E. Brown
    %   $Revision: 1399 $    $Date: 2006-08-11 11:19:27 +0200 (Fr, 11 Aug 2006) $

    report_this_filefun(mfilename('fullpath'));

    if nargin < 4;   error('Incorrect number of arguments');   end

    %  Test the inputs

    if  ~isequal(sort(size(latlim)),sort(size(lonlim)),[1 2])
        error('Lat and lon limit inputs must be 2 element vectors')
    end

    %  Test for real inputs

    if any([~isreal(lat0) ~isreal(lon0) ~isreal(latlim) ~isreal(lonlim)])
        warning('Imaginary parts of complex arguments ignored')
        lat0 = real(lat0);       lon0 = real(lon0);
        latlim = real(latlim);   lonlim = real(lonlim);
    end

    %  Get the corners of the submap region

    up    = max(latlim);   low  = min(latlim);
    right = max(lonlim);   left = min(lonlim);

    %  Copy the input data and ensure column vectors.

    lat = lat0(:);   lon = lon0(:);

    %  Get the vector of patch items and remove any NaN padding
    %  at the beginning or end of the column.  This eliminates potential
    %  multiple NaNs at the beginning and end of the patches.

    while isnan(lat(1)) | isnan(lon(1))
        lat(1) = [];   lon(1) = [];
    end
    while isnan(lat(length(lat))) | isnan(lon(length(lon)));
        lat(length(lat)) = [];   lon(length(lon)) = [];
    end

    %  Add a NaN to the end of the data vector.  Necessary for processing
    %  of multiple patches.

    lat(length(lat)+1) = NaN;   lon(length(lon)+1) = NaN;

    %  Find the individual patches and then trim the data

    indx = find(isnan(lon) | isnan(lat));
    if isempty(indx);   indx = length(lon)+1;   end

    for i = 1:length(indx)

        if i == 1;      startloc = 1;
        else;       startloc = indx(i-1)+1;
        end
        endloc   = indx(i)-1;


        indices = (startloc:endloc)';   %  Indices will be empty if NaNs are
        %  neighboring in the vector data.
        if ~isempty(indices)            %  Should not happen, but test just in case

            %  Patches which lie completely outside the trim window.  Replace
            %  with NaNs and then eliminate it entirely later.  Replacing with
            %  NaNs is useful so that the indexing with indices is not messed
            %  up if an entire patch is eliminated at this point.

            %  If at least one point of the patch edge does not lie with the
            %  specified window limits, then the entire patch is trimmed.

            if ~any(lon(indices) >= left & lon(indices) <= right  &&  ...
                    lat(indices) >= low  & lat(indices) <= up)
                lon(indices) = NaN;    lat(indices) = NaN;
            end

            %  Need to only test along edge since patch must lie somehow within the window.

            %  Points off the bottom

            loctn = find( lon(indices) < left );
            if ~isempty(loctn);  lon(indices(loctn)) = left;     end

            %  Points off the top

            loctn = find( lon(indices) > right );
            if ~isempty(loctn);   lon(indices(loctn)) = right;   end

            %  Points off the left

            loctn = find( lat(indices) < low );
            if ~isempty(loctn);   lat(indices(loctn)) = low;     end

            %  Points off the right

            loctn = find( lat(indices) > up );
            if ~isempty(loctn);   lat(indices(loctn)) = up;      end
        end
    end


    %  Eliminate multiple NaNs in the vector.  Will occur if a patch
    %  lies entirely outside the window of interest.

    if ~isempty(lat)
        nanloc = isnan(lat);	[r,c] = size(nanloc);
        nanloc = find(nanloc(1:r-1,:) & nanloc(2:r,:));
        lat(nanloc) = [];  lon(nanloc) = [];
    end
