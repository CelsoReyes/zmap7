function D=rad2deg(R)

    %RAD2DEG Converts angles from radians to degrees
    %
    %  deg = RAD2DEG(rad) converts angles from radians to degrees.
    %
    %  See also DEG2RAD, RAD2DMS, ANGLEDIM, ANGL2STR

    %  Copyright 1996-2000 Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    %  Written by:  E. Byrns, E. Brown
    %   $Revision: 570 $    $Date: 2003-03-26 13:30:45 +0100 (Mi, 26 MÃ¤r 2003) $

    if nargin==0
        error('Incorrect number of arguments')
    elseif ~isreal(R)
        warning('Imaginary parts of complex ANGLE argument ignored')
        R = real(R);
    end

    D = R*180/pi;
