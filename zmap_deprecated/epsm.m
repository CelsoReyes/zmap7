function epsilon = epsm(units)

    %EPSM  Calculate the accuracy of the map computations
    %
    %  e = EPSM returns the accuracy of computations performed in
    %  the Mapping Toolbox.  The accuracy returned is in degrees.
    %
    %  e = EPSM('units') returns the accuracy in the units specified
    %  by the string 'units'.  If omitted, 'degrees' are assumed.
    %
    %  See also EPS

    %  Copyright 1996-2000 Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    %  Written by:  E. Byrns, E. Brown
    %   $Revision: 1399 $    $Date: 2006-08-11 11:19:27 +0200 (Fr, 11 Aug 2006) $

    %  Define the limit in degrees

    %report_this_filefun(mfilename('fullpath'));

    degepsilon = 1.0E-6;

    if nargin == 0
        epsilon = degepsilon;   return

        %  Speed up function with special unit string tests

    elseif strcmp(units,'degrees')
        epsilon = degepsilon;   return

    elseif strcmp(units,'radians')
        epsilon = degepsilon*pi/180;   return

    else
        [units,msg] = unitstr(units,'angles');
        if ~isempty(msg);   error(msg);   end
        epsilon = angledim(degepsilon,'degrees',units);
    end

