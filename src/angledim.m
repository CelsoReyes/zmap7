function angmat = angledim(angmat,from,to)

    %ANGLEDIM  Converts angles from one unit system to another
    %
    %  ang = ANGLEDIM(angin,'from','to') converts angles between
    %  recognized units.  Input and output units are entered as strings.
    %  This function allows access to all angle conversions based upon input
    %  unit strings.  Allowable units string are:  'degrees' or 'deg' for
    %  degrees; 'dm' for deg:min; 'dms' for deg:min:sec;  'radians' or
    %  'rad' for radians.
    %
    %  See also DEG2RAD, DEG2DMS, DEG2DM, RAD2DEG, RAD2DMS, RAD2DM,
    %           DMS2DEG, DMS2RAD, DMS2DM

    %  Copyright (c) 1996-98 by Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    %  Written by:  E. Byrns, E. Brown
    %   $Revision: 1399 $    $Date: 2006-08-11 11:19:27 +0200 (Fr, 11 Aug 2006) $

    %report_this_filefun(mfilename('fullpath'));

    if nargin ~= 3;    error('Incorrect number of arguments');    end

    % %  Complex input test
    %
    if ~isreal(angmat)
        %     warning('Imaginary parts of complex ANGLE argument ignored')
        angmat = real(angmat);
    end

    % Handle the most common cases as fast as possible. If no
    % unit changes, simply return.

    switch from
        case 'degrees'
            switch to
                case 'radians'
                    angmat = angmat*pi/180; return
                case 'degrees'
                    return;
            end

        case 'radians'
            switch to
                case 'degrees'
                    angmat = angmat*180/pi; return
                case 'radians'
                    return
            end
    end


    % normalize units strings

    [from,msg] = unitstr(from,'angles');    %  Test the input strings for recognized units
    if ~isempty(msg);   error(msg);  end

    [to,msg] = unitstr(to,'angles');        %  Return the full name in lower case
    if ~isempty(msg);   error(msg);  end

    % test indentity operations

    if strcmp(to,from); return; end

    %  Find the appropriate string matches and transform the angles

    switch from          %  Switch statment faster that if/elseif
        case 'degrees'
            switch to
                case 'dm',        angmat = deg2dm(angmat);
                case 'dms',       angmat = deg2dms(angmat);
                case 'radians',   angmat = deg2rad(angmat);
                otherwise,        error('Unrecognized angle units string')
            end

        case 'radians'
            switch to
                case 'degrees',   angmat = rad2deg(angmat);
                case 'dm',        angmat = rad2dm(angmat);
                case 'dms',       angmat = rad2dms(angmat);
                otherwise,        error('Unrecognized angle units string')
            end

        case 'dm'
            switch to
                case 'degrees',   angmat = dms2deg(angmat);
                case 'dms',       angmat = angmat;
                case 'radians',   angmat = dms2rad(angmat);
                otherwise,        error('Unrecognized angle units string')
            end

        case 'dms'
            switch to
                case 'degrees',   angmat = dms2deg(angmat);
                case 'dm',        angmat = dms2dm(angmat);
                case 'radians',   angmat = dms2rad(angmat);
                otherwise,        error('Unrecognized angle units string')
            end

        otherwise
            error('Unrecognized angle units string')
    end


