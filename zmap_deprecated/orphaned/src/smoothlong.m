function lon = smoothlong(lon,units)
    %SMOOTHLONG remove discontinuities in longitude data
    %
    %  ang = SMOOTHLONG(angin) removes discontinuities in longitude data.  The
    %  resulting angles may cover more than one revolution.
    %
    %  ang = SMOOTHLONG(angin,'units') uses the units defined by the input string
    %  'units'.  If omitted, default units of 'degrees' are assumed.
    %
    % See also NPI2PI, ZERO22PI, EASTOF, INTERPM

    %
    %  Copyright 1996-2000 Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    %  Written by: W. Stumpf
    %   $Revision: 1399 $    $Date: 2006-08-11 11:19:27 +0200 (Fr, 11 Aug 2006) $

    report_this_filefun(mfilename('fullpath'));

    if nargin == 1
        units = 'degrees';
    elseif nargin == 2
        if ~ischar(units); error('Units must be a string'); end
    elseif nargin ~= 2
        error('Incorrect number of arguments')
    end

    maxjump = angledim(185,'degrees',units);
    onerev = angledim(360,'degrees',units);

    % ensure column vector

    sz = size(lon);
    lon = lon(:);

    % remove NaNs to detect islands in the wrong quadrant

    firstnan = 0;lastnan = 0;
    if isnan(lon(1)); firstnan = 1; lon(1) = [];end
    if isnan(lon(end)); lastnan = 1; lon(end) = [];end

    splitvec = find(isnan(lon));
    lon = lon(~isnan(lon));


    % detect jumps in longitude and remove them
    dif = diff(lon);
    indx = find(abs(dif) > maxjump);

    while ~isempty(indx)
        lon(indx+1:end) = lon(indx+1:end)-sign(dif(indx(1)))*onerev;
        dif = diff(lon);
        indx = find(abs(dif) > maxjump);
    end


    % Restore NaNs
    for j = 1:length(splitvec)

        lowerindx = 1:splitvec(j)-1;
        upperindx = splitvec(j):length(lon);

        lon = [lon(lowerindx);  NaN; lon(upperindx)];
    end

    if firstnan; lon = [NaN; lon]; end
    if lastnan;  lon = [lon; NaN]; end

    lon = reshape(lon,sz);


