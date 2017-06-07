function distmat = distdim(distmat,from,to,radius)

    %DISTDIM  Converts distances from one unit system to another
    %
    %  d = DISTDIM(din,'from','to') converts distances between
    %  recognized units.  Input and output units are entered as strings.
    %  This function allows access to all angle conversions based upon input
    %  unit strings.  Allowable units string are:  'degrees' or 'deg' for
    %  degrees; 'kilometers' or 'km' for kilometers; 'nauticalmiles' or
    %  'nm'  for nautical miles; 'radians' or 'rad' for radians;
    %  'statutemiles', 'sm', 'miles'  or 'mi'  for statute miles;
    %  'meters' or 'm' for meters; 'feet' or 'ft' for feet.
    %
    %  d = DISTDIM(din,'from','to',radius) uses the third input to determine
    %  the radius of the sphere.  If radius is a string, then it is evaluated
    %  as an ALMANAC body to determine the spherical radius.  If numerical,
    %  it is the radius of the desired sphere in appropriate units.
    %  If omitted, the default radius of the Earth is used.
    %
    %  See also  DEG2KM, DEG2NM, DEG2SM, KM2DEG, KM2NM, KM2RAD,
    %            KM2SM,  NM2DEG, NM2KM,  NM2RAD, NM2SM, RAD2KM,
    %            RAD2NM, RAD2SM, SM2DEG, SM2KM,  SM2NM, SM2RAD

    %  Copyright (c) 1996-98 by Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    %  Written by:  E. Brown, E. Byrns
    %   $Revision: 1399 $    $Date: 2006-08-11 11:19:27 +0200 (Fr, 11 Aug 2006) $

    %report_this_filefun(mfilename('fullpath'));

    if nargin < 3
        error('Incorrect number of arguments')
    elseif nargin == 3
        radius = 'earth';
    end


    [from,msg] = unitstr(from,'distance');   %  Test the input strings for recognized units
    if ~isempty(msg);   error(msg);  end

    [to,msg] = unitstr(to,'distance');       %  Return the full name in lower case
    if ~isempty(msg);   error(msg);  end

    %  Complex input test

    if ~isreal(distmat)
        warning('Imaginary parts of complex DISTANCE argument ignored')
        distmat = real(distmat);
    end

    %  If no unit changes, then simply return

    if strcmp(from,to);	  return;    end

    %  Find the appropriate string matches and transform the angles

    switch from          %  Switch statment faster that if/elseif
        case 'degrees'
            switch to
                case 'kilometers',        distmat = deg2km(distmat,radius);
                case 'nauticalmiles',     distmat = deg2nm(distmat,radius);
                case 'radians',           distmat = deg2rad(distmat);
                case 'statutemiles',      distmat = deg2sm(distmat,radius);
                case 'meters',            distmat = 100*deg2km(distmat,radius);
                case 'feet',              distmat = 5280*deg2sm(distmat,radius);
                otherwise,                error('Unrecognized distance units string')
            end

        case 'kilometers'
            switch to
                case 'degrees',           distmat = km2deg(distmat,radius);
                case 'nauticalmiles',     distmat = km2nm(distmat);
                case 'radians',           distmat = km2rad(distmat,radius);
                case 'statutemiles',      distmat = km2sm(distmat);
                case 'meters',            distmat = 1000*distmat;
                case 'feet',              distmat = 5280*km2sm(distmat);
                otherwise,                error('Unrecognized distance units string')
            end

        case 'meters'
            switch to
                case 'degrees',           distmat = km2deg(distmat/1000,radius);
                case 'nauticalmiles',     distmat = km2nm(distmat/1000);
                case 'radians',           distmat = km2rad(distmat/1000,radius);
                case 'statutemiles',      distmat = km2sm(distmat/1000);
                case 'kilometers',        distmat = distmat/1000;
                case 'feet',              distmat = 5280*km2sm(distmat/1000);
                otherwise,                error('Unrecognized distance units string')
            end

        case 'nauticalmiles'
            switch to
                case 'degrees',           distmat = nm2deg(distmat,radius);
                case 'kilometers',        distmat = nm2km(distmat);
                case 'meters',            distmat = 1000*nm2km(distmat);
                case 'radians',           distmat = nm2rad(distmat,radius);
                case 'statutemiles',      distmat = nm2sm(distmat);
                case 'feet',              distmat = 5280*nm2sm(distmat);
                otherwise,                error('Unrecognized distance units string')
            end

        case 'radians'
            switch to
                case 'degrees',           distmat = rad2deg(distmat);
                case 'kilometers',        distmat = rad2km(distmat,radius);
                case 'meters',            distmat = 1000*rad2km(distmat,radius);
                case 'nauticalmiles',     distmat = rad2nm(distmat,radius);
                case 'statutemiles',      distmat = rad2sm(distmat,radius);
                case 'feet',              distmat = 5280*rad2sm(distmat,radius);
                otherwise,                error('Unrecognized distance units string')
            end

        case 'statutemiles'
            switch to
                case 'degrees',           distmat = sm2deg(distmat,radius);
                case 'kilometers',        distmat = sm2km(distmat);
                case 'meters',            distmat = 1000*sm2km(distmat);
                case 'nauticalmiles',     distmat = sm2nm(distmat);
                case 'radians',           distmat = sm2rad(distmat,radius);
                case 'feet',              distmat = 5280*distmat;
                otherwise,                error('Unrecognized distance units string')
            end

        case 'feet'
            switch to
                case 'degrees',           distmat = sm2deg(distmat/5280,radius);
                case 'nauticalmiles',     distmat = sm2nm(distmat/5280);
                case 'radians',           distmat = sm2rad(distmat/5280,radius);
                case 'statutemiles',      distmat = distmat/5280;
                case 'kilometers',        distmat = sm2km(distmat/5280);
                case 'meters',            distmat = 1000*sm2km(distmat/5280);
                otherwise,                error('Unrecognized distance units string')
            end

        otherwise
            error('Unrecognized distance units string')
    end


