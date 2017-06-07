function angout = npi2pi(angin,units,approach)

    %NPI2PI Truncates angles into the -180 deg to 180 deg range
    %
    %
    %  ang = NPI2PI(angin) transforms input angles into the
    %  -180 to 180 degree range.
    %
    %  ang = NPI2PI(angin,'units') uses the units defined by the
    %  input string 'units'.  If omitted, default units of 'degrees'
    %  are assumed.
    %
    %  ang = NPI2PI(angin,'units','method') uses the method
    %  defined by the corresponding input string.  Valid methods are:
    %  'exact' for the exact transformation; 'inward' where all angles
    %  are shifted epsilon towards the origin before the -180 to 180 degree
    %  transformation; 'outward' where all angles are shifted epsilon
    %  away from the origin before the -180 to 180 degree transformation.
    %  If omitted, default method of 'exact' is assumed.
    %
    %  See also ZERO22PI, ANGLEDIM

    %  Copyright 1996-2000 Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    %  Written by:  E. Byrns, E. Brown
    %   $Revision: 1399 $    $Date: 2006-08-11 11:19:27 +0200 (Fr, 11 Aug 2006) $

    %report_this_filefun(mfilename('fullpath'));

    if nargin == 0
        error('Incorrect number of arguments')
    elseif nargin == 1
        units = [];     approach = [];
    elseif nargin == 2
        approach = [];
    end

    %  Empty argument tests

    if isempty(approach);   approach = 'exact';    end
    if isempty(units);      units    = 'degrees';  end

    %  Convert inputs to radians

    angin = angledim(angin,units,'radians');

    %  Exact approach -- Eliminates the use of ATAN2 function.

    %  Approximate approach -- Some inconsistencies with ATAN2 function
    %  across platforms when an exact multiple of -pi is used.  Some platforms
    %  atan2(-1,0) = -pi, and for some platforms atan2(-1,0) = pi;

    switch lower(approach)
        case 'exact'

            %  Exact approach is not straightforward because of this mapping behavior:
            %       -3pi maps to -pi;   -2pi maps to -pi;  -pi maps to -pi;
            %        pi  maps to pi;     2pi maps to pi;   3pi maps to pi
            %  Note that the mapping point changes when the sign on pi changes.

            angout = pi*((abs(angin)/pi) - ...
                2*ceil(((abs(angin)/pi)-1)/2)) .* sign(angin);

        case 'inward'

            %  Move data epsilon towards (inward) the origin.  Eliminates any
            %  points which start identically on a multiple of pi.  Then
            %  use the atan2 function.

            epsilon = epsm('radians');
            angin   = angin*(1 - epsilon);
            angout  = atan2(sin(angin),cos(angin));

        case 'outward'

            %  Move data epsilon towards (away from) the origin.  Eliminates any
            %  points which start identically on a multiple of pi.  Then
            %  use the atan2 function.

            epsilon = epsm('radians');
            angin   = angin * (1 + epsilon);
            angout  = atan2(sin(angin),cos(angin));

        otherwise
            error('Unrecognized approach string')
    end

    angout = angledim(angout,'radians',units);  %  Convert to the original units
