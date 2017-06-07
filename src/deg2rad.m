function R=deg2rad(D)

    %DEG2RAD Converts angles from degrees to radians
    %
    %  rad = DEG2RAD(deg) converts angles from degrees to radians.
    %
    %  See also RAD2DEG, DEG2DMS, ANGLEDIM, ANGL2STR

    %  Copyright (c) 1996-98 by Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    %  Written by:  E. Byrns, E. Brown
    %   $Revision: 1399 $    $Date: 2006-08-11 11:19:27 +0200 (Fr, 11 Aug 2006) $

    %report_this_filefun(mfilename('fullpath'));

    if nargin==0
        error('Incorrect number of arguments')
    elseif ~isreal(D)
        warning('Imaginary parts of complex ANGLE argument ignored')
        D = real(D);
    end

    R = D*pi/180;


