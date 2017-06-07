function az = azimuth(varargin)

    report_this_filefun(mfilename('fullpath'));

    %AZIMUTH  Calculates azimuth between points on a geoid
    %
    %  az = AZIMUTH(lat1,lon1,lat2,lon2) computes the great circle
    %  bearing between the two points on the globe.  The inputs
    %  can be matrices of equal size.  The azimuth is reported from
    %  0 to 360 degrees, clockwise from north, by convention.
    %
    %  az = AZIMUTH(lat1,lon1,lat2,lon2,geoid) computes the great circle
    %  bearing assuming that the points lie on the ellipsoid defined by
    %  the input geoid.  The geoid vector is of the form
    %  [semimajor axes, eccentricity].  If omitted, the unit sphere,
    %  geoid = [1 0], is assumed.
    %
    %  az = AZIMUTH(lat1,lon1,lat2,lon2,'units') uses the input string 'units'
    %  to define the angle units of the input and output data.  If
    %  'units' is omitted, 'degrees' is assumed.
    %
    %  az = AZIMUTH(lat1,lon1,lat2,lon2,geoid,'units') is a valid calling form.
    %
    %  az = AZIMUTH('track',...) uses the input string 'track' to define
    %  either a great circle bearing or rhumb line heading.  If 'track' = 'gc',
    %  then the great circle bearings are computed.  If 'track' = 'rh', then
    %  the rhumb line headings are computed.  If omitted, 'gc' is assumed.
    %
    %  az = AZIMUTH(pt1,pt2) uses the input form pt1 = [lat1 lon1] and
    %  pt2 = [lat2 lon2], where lat1, lon1, lat2 and lon2 are column vectors.
    %
    %  az = AZIMUTH(pt1,pt2,geoid), az = AZIMUTH(pt1,pt2,'units'),
    %  az = AZIMUTH(pt1,pt2,geoid,'units') and az = AZIMUTH('track',pt1,...)
    %  are all valid calling forms.
    %
    %  See also DISTANCE, RECKON

    %  Copyright (c)  1995 by Systems Planning and Analysis, Inc.
    %  Written by:  E. Byrns, E. Brown
    %   $Revision: 1399 $    $Date: 2006-08-11 11:19:27 +0200 (Fr, 11 Aug 2006) $

    if nargin < 1
        error('Incorrect number of arguments')
    else
        if ischar(varargin{1})
            str = varargin{1};    varargin(1) = [];
        else
            str = [];
        end
    end


    %  Test the track string and call the appropriate function

    if isempty(str)
        [az,msg] = bearing(varargin{:});
    else
        validstr = ['gc';'rh'];
        indx     = strmatch(lower(str),validstr);
        if length(indx) ~= 1
            error('Unrecognized track string')
        elseif indx == 1
            [az,msg] = bearing(varargin{:});
        elseif indx == 2
            [az,msg] = heading(varargin{:});
        end
    end

    %  Error out if necessary

    if ~isempty(msg);   error(msg);   end


    %************************************************************************
    %************************************************************************
    %************************************************************************


function [az,msg] = bearing(in1,in2,in3,in4,in5,in6)

    %BEARING:  Calculates great circle azimuth between points on a geoid
    %
    %  Purpose
    %
    %  Computes the great circle bearing between two
    %  points on a globe.  The default angle input
    %  is degrees.  The default output is in degrees.
    %  The default geoid is a sphere, but this can be
    %  redefined to an ellipsoid using the geoid input.
    %
    %  Synopsis
    %
    %       az = bearing(pt1,pt2)
    %       az = bearing(pt1,pt2,geoid)
    %       az = bearing(pt1,pt2,'units')
    %       az = bearing(pt1,pt2,geoid,'units')
    %
    %       az = bearing(lat1,lon1,lat2,lon2)
    %       az = bearing(lat1,lon1,lat2,lon2,geoid)
    %       az = bearing(lat1,lon1,lat2,lon2,'units')
    %       az = bearing(lat1,lon1,lat2,lon2,geoid,'units')
    %
    %       [az,errmsg] = bearing(....
    %            If two output arguments are supplied, then error condition
    %            messages are returned to the calling function for processing.

    %   REFERENCES:
    %   For the ellipsoid:  D. H. Maling, Coordinate Systems and
    %   Map Projections, 2nd Edition Pergamon Press, 1992, pp. 74-76.
    %   This forumula can be shown to be equivalent for a sphere to
    %   J. P. Snyder,  "Map Projections - A Working Manual,"  US Geological
    %   Survey Professional Paper 1395, US Government Printing Office,
    %   Washington, DC, 1987,  pp. 29-32.

    %  Copyright (c)  1995 by Systems Planning and Analysis, Inc.
    %  Written by:  E. Byrns, E. Brown
    %  Revision 1.0:  11/7/95
    %  Revision 1.1:  11/26/95  elliptical calcs added   EVB


    %  Initialize outputs

    if nargout ~= 0;  az = [];   msg = [];  end

    %  Test inputs

    if nargin == 2
      if size(in1,2) == 2  && size(in2,2) == 2  && ...
                ndims(in1) == 2 & ndims(in2) == 2
            lat1 = in1(:,1);	lon1 = in1(:,2);
            lat2 = in2(:,1);	lon2 = in2(:,2);
        else
            msg = 'Incorrect latitude and longitude data matrices';
            if nargout < 2;  error(msg);  end
            return
        end

        geoid = [];      units  = [];

    elseif nargin == 3
      if size(in1,2) == 2  && size(in2,2) == 2  && ...
                ndims(in1) == 2 & ndims(in2) == 2
            lat1 = in1(:,1);	lon1 = in1(:,2);
            lat2 = in2(:,1);	lon2 = in2(:,2);
        else
            msg = 'Incorrect latitude and longitude data matrices';
            if nargout < 2;  error(msg);  end
            return
        end

        if ischar(in3)
            units  = in3;               geoid = [];
        else
            units  = [];                geoid = in3;
        end

    elseif nargin == 4

        if ischar(in4)
          if size(in1,2) == 2  && size(in2,2) == 2  && ...
                    ndims(in1) == 2 & ndims(in2) == 2
                lat1 = in1(:,1);	lon1 = in1(:,2);
                lat2 = in2(:,1);	lon2 = in2(:,2);
            else
                msg = 'Incorrect latitude and longitude data matrices';
                if nargout < 2;  error(msg);  end
                return
            end

            geoid = in3;     units  = in4;

        else
            lat1 = in1;	             lon1 = in2;
            lat2 = in3;	             lon2 = in4;
            geoid = [];              units = [];
        end

    elseif nargin == 5

        lat1 = in1;	    lon1 = in2;
        lat2 = in3;	    lon2 = in4;
        if ischar(in5)
            units  = in5;             geoid = [];
        else
            units  = [];              geoid = in5;
        end

    elseif nargin == 6

        lat1 = in1;	    lon1 = in2;
        lat2 = in3;	    lon2 = in4;
        geoid = in5;    units  = in6;

    else
        msg = 'Incorrect number of arguments';
        if nargout < 2;  error(msg);  end
        return
    end

    %  Empty argument tests.  Allows users to pass in an empty argument
    %  and still not crash.

    if isempty(units);   units = 'degrees';   end
    if isempty(geoid)         %  Unlike related functions reckongc
        geoid = [1 0];     %  and distgc, the first argument of geoid
    elseif geoid(1) == 0      %  can not be zero.  Calculations blow up
        geoid(1) = 1;     %  (1/0) if geoid(1) = 0
    end

    %  Dimension tests

    if ~isequal(size(lat1),size(lon1),size(lat2),size(lon2))
        msg = 'Inconsistent dimensions for latitude and longitude';
        if nargout < 2;  error(msg);  end
        return
    end

    %  Angle unit conversion

    lat1 = angledim(lat1,units,'radians');
    lon1 = angledim(lon1,units,'radians');
    lat2 = angledim(lat2,units,'radians');
    lon2 = angledim(lon2,units,'radians');

    %  Test the geoid parameter

    [geoid,msg] = geoidtst(geoid);
    if ~isempty(msg)
        if nargout < 2;  error(msg);  end
        return
    end

    az = zeros(size(lat1));     % Preallocate memory for output
    epsilon = epsm('radians');      % Set tolerance to the pole

    % Identify those cases where a pole is a starting
    % point or a destination, and those cases where it is not

    indx1 = find(lat1 >= pi/2-epsilon); % north pole starts
    indx2 = find(lat1 <= epsilon-pi/2); % south pole starts
    indx3 = find(lat2 >= pi/2-epsilon); % north pole ends
    indx4 = find(lat2 <= epsilon-pi/2); % south pole ends

    indx=1:numel(az);           % All cases,
    indx([indx1;indx2;indx3;indx4])=[];  %   less the special ones

    % Handle the special cases.  For example, anything starting
    % at the north pole must go south (pi).  Starting point
    % has priority in degenerate cases; i.e. when going from
    % north pole to north pole, result will be pi, not zero.

    if ~isempty(indx4);  az(indx4) = pi;   end  %  Arrive going south
    if ~isempty(indx3);  az(indx3) = 0;    end  %  Arrive going north
    if ~isempty(indx2);  az(indx2) = 0;    end  %  Depart going north
    if ~isempty(indx1);  az(indx1) = pi;   end  %  Depart going south

    %  Compute the bearing for either a spherical or elliptical geoid.
    %  Note that for a sphere, ratio = 1, par1 = lat1, par2 = lat2
    %  and fact4 = 0.

    if ~isempty(indx)
        par1 = geod2par(lat1(indx),geoid,'radians');    %  Parametric latitudes
        par2 = geod2par(lat2(indx),geoid,'radians');

        ratio = minaxis(geoid) / geoid(1);  %  Semiminor/semimajor (b/a)
        ratio = ratio^2;

        fact1 = cos(lat2(indx)) .* sin(lon2(indx)-lon1(indx));
        fact2 = ratio * cos(lat1(indx)) .* sin(lat2(indx));
        fact3 = sin(lat1(indx)) .* cos(lat2(indx)) .* cos(lon2(indx)-lon1(indx));
        fact4 = (1-ratio) * sin(lat1(indx)) .* cos(lat2(indx)) .* ...
            cos(par1) ./ cos(par2);

        az(indx) = atan2(fact1,fact2-fact3+fact4);
    end

    %  Transform the bearing data to the proper range and units

    az = zero22pi(az,'radians','exact');
    az = angledim(az,'radians',units);


    %************************************************************************
    %************************************************************************
    %************************************************************************


function [course,msg] = heading(in1,in2,in3,in4,in5,in6)

    %HEADING:  Calculates rhumb-line direction between points on a geoid
    %
    %  Purpose
    %
    %  Computes the rhumb line direction between two
    %  points on a globe.  The rhumb line is a line of
    %  constant angular direction, a "course to steer".
    %  The default angle input is degrees.  The default output
    %  is in degrees. The default geoid is a sphere, but this
    %  can be redefined to an ellipsoid using the geoid input.
    %
    %  Synopsis
    %
    %       course = heading(pt1,pt2)
    %       course = heading(pt1,pt2,geoid)
    %       course = heading(pt1,pt2,'units')
    %       course = heading(pt1,pt2,geoid,'units')
    %
    %       course = heading(lat1,lon1,lat2,lon2)
    %       course = heading(lat1,lon1,lat2,lon2,geoid)
    %       course = heading(lat1,lon1,lat2,lon2,'units')
    %       course = heading(lat1,lon1,lat2,lon2,geoid,'units')
    %
    %       [course,errmsg] = heading(....
    %            If two output arguments are supplied, then error condition
    %            messages are returned to the calling function for processing.


    %  Copyright (c)  1995 by Systems Planning and Analysis, Inc.
    %  Written by:  E. Brown, E. Byrns
    %  Revision 1.0:  11/7/95
    %  Revision 1.1:  11/28/95  V5 matrix assignment.  Mercalc calls.  EVB


    %  Initialize outputs

    if nargout ~= 0;  course = [];   msg = [];  end

    %  Test inputs

    if nargin == 2
        if size(in1,2) == 2 && size(in2,2) == 2 && ...
                ndims(in1) == 2 && ndims(in2) == 2
            lat1 = in1(:,1);	lon1 = in1(:,2);
            lat2 = in2(:,1);	lon2 = in2(:,2);
        else
            msg = 'Incorrect latitude and longitude data matrices';
            if nargout < 2;  error(msg);  end
            return
        end

        geoid = [];    units  = [];

    elseif nargin == 3
        if size(in1,2) == 2 && size(in2,2) == 2 && ...
                ndims(in1) == 2 && ndims(in2) == 2
            lat1 = in1(:,1);	lon1 = in1(:,2);
            lat2 = in2(:,1);	lon2 = in2(:,2);
        else
            msg = 'Incorrect latitude and longitude data matrices';
            if nargout < 2;  error(msg);  end
            return
        end

        if ischar(in3)
            units  = in3;      geoid = [];
        else
            units  = [];       geoid = in3;
        end

    elseif nargin == 4

        if ischar(in4)
            if size(in1,2) == 2 && size(in2,2) == 2 && ...
                    ndims(in1) == 2 && ndims(in2) == 2
                lat1 = in1(:,1);	lon1 = in1(:,2);
                lat2 = in2(:,1);	lon2 = in2(:,2);
            else
                msg = 'Incorrect latitude and longitude data matrices';
                if nargout < 2;  error(msg);  end
                return
            end

            geoid = in3;    units  = in4;

        else
            lat1 = in1;	              lon1 = in2;
            lat2 = in3;	              lon2 = in4;
            geoid = [];               units = [];
        end

    elseif nargin == 5

        lat1 = in1;	    lon1 = in2;
        lat2 = in3;	    lon2 = in4;
        if ischar(in5)
            units  = in5;         geoid = [];
        else
            units  = [];          geoid = in5;
        end

    elseif nargin == 6

        lat1 = in1;	    lon1 = in2;
        lat2 = in3;	    lon2 = in4;
        geoid = in5;    units  = in6;

    else
        msg = 'Incorrect number of arguments';
        if nargout < 2;  error(msg);  end
        return
    end


    %  Empty argument tests.  Allows users to pass in an empty argument
    %  and still not crash.

    if isempty(units);   units = 'degrees';   end
    if isempty(geoid)         %  Unlike related functions reckonrh
        geoid = [1 0];     %  and distrh, the first argument of geoid
    elseif geoid(1) == 0      %  can not be zero.  Merccalc always returns
        geoid(1) = 1;     %  [x,y] = 0 if geoid(1) = 0
    end


    %  Dimension tests

    if  ~isequal(size(lat1),size(lon1),size(lat2),size(lon2))
        msg = 'Inconsistent dimensions for latitude and longitude';
        if nargout < 2;  error(msg);  end
        return
    end

    %  Angle unit conversion

    lat1 = angledim(lat1,units,'radians');
    lon1 = angledim(lon1,units,'radians');
    lat2 = angledim(lat2,units,'radians');
    lon2 = angledim(lon2,units,'radians');

    %  Test the geoid parameter

    [geoid,msg] = geoidtst(geoid);
    if ~isempty(msg)
        if nargout < 2;  error(msg);  end
        return
    end


    course=zeros(size(lat1));     % Preallocate memory for output
    epsilon=epsm('radians');      % Set tolerance to the pole


    % Identify those cases where a pole is a starting
    % point or a destination, and those cases where it is not

    indx1 = find(lat1 >= pi/2-epsilon); % north pole starts
    indx2 = find(lat1 <= epsilon-pi/2); % south pole starts
    indx3 = find(lat2 >= pi/2-epsilon); % north pole ends
    indx4 = find(lat2 <= epsilon-pi/2); % south pole ends

    indx=1:numel(course);           % All cases,
    indx([indx1;indx2;indx3;indx4])=[];  %   less the special ones

    % Handle the special cases.  For example, anything starting
    % at the north pole must go south (pi).  Starting point
    % has priority in degenerate cases; i.e. when going from
    % north pole to north pole, result will be pi, not zero.

    if ~isempty(indx4);  course(indx4) = pi;   end  %  Arrive going south
    if ~isempty(indx3);  course(indx3) = 0;    end  %  Arrive going north
    if ~isempty(indx2);  course(indx2) = 0;    end  %  Depart going north
    if ~isempty(indx1);  course(indx1) = pi;   end  %  Depart going south

    %  Now find the course for the general cases by calculating the
    %  heading angle in a Mercator coordinate system.  The function
    %  MERCCALC handles both spherical and elliptical geoids

    if ~isempty(indx)
        [x1,y1] = merccalc(lat1(indx),lon1(indx),'forward','radians',geoid);
        [x2,y2] = merccalc(lat2(indx),lon2(indx),'forward','radians',geoid);

        %  Find points greater than 180 deg apart.  Take shorter distance route
        %  Allow for some roundoff error

        epsilon = 1E-10;
        shift = find( abs((x2-x1)) > pi*geoid(1)-epsilon);
        if ~isempty(shift)
            x1(shift) = x1(shift) + sign(x2(shift))*2*pi*geoid(1);
        end

        course(indx) = atan2(x2-x1, y2-y1);
    end

    %  Transform the heading data to the proper range and units

    course = zero22pi(course,'radians','exact');
    course = angledim(course,'radians',units);



