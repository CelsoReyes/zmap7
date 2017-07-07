function rang = distance(varargin)

    %DISTANCE  Calculates distances between points on a geoid
    %
    %  rang = DISTANCE(lat1,lon1,lat2,lon2) computes the great circle
    %  distance between the two points on the globe.  The inputs
    %  can be matrices of equal size.  The distance is reported as
    %  degrees of arc length on a sphere.
    %
    %  rang = DISTANCE(lat1,lon1,lat2,lon2,geoid) computes the great circle
    %  distance assuming that the points lie on the ellipsoid defined by
    %  the input geoid.  The geoid vector is of the form
    %  [semimajor axes, eccentricity].  The output range is reported in
    %  the same distance units as the semimajor axes of the geoid vector.
    %
    %  rang = DISTANCE(lat1,lon1,lat2,lon2,'units') uses the input string 'units'
    %  to define the angle units of the input and output data.  If
    %  'units' is omitted, 'degrees' are assumed.
    %
    %  rang = DISTANCE(lat1,lon1,lat2,lon2,geoid,'units') is a valid calling
    %  form.  In this case, the output range is in the same units as
    %  the semimajor axes of the geoid vector.
    %
    %  rang = DISTANCE('track',...) uses the input string 'track' to define
    %  either a great circle or rhumb line distance calculation.  If
    %  'track' = 'gc', then the great circle distances are computed.
    %  If 'track' = 'rh', then the rhumb line distances are computed.
    %  If omitted, 'gc' is assumed.
    %
    %  rang = DISTANCE(pt1,pt2) uses the input form pt1 = [lat1 lon1] and
    %  pt2 = [lat2 lon2], where lat1, lon1, lat2 and lon2 are column vectors.
    %
    %  rang = DISTANCE(pt1,pt2,geoid), rang = DISTANCE(pt1,pt2,'units')
    %  rang = DISTANCE(pt1,pt2,geoid,'units') and rang = DISTANCE('track',pt1,...)
    %  are all valid calling forms.
    %
    %  See also AZIMUTH, RECKON

    %  Copyright (c) 1996-98 by Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    %  Written by:  E. Byrns, E. Brown
    %   $Revision: 1399 $    $Date: 2006-08-11 11:19:27 +0200 (Fr, 11 Aug 2006) $

    %report_this_filefun(mfilename('fullpath'));

    %rang is also a random number generator function
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
        [rang,msg] = distgc(varargin{:});
    else
        validstr = ['gc';'rh'];
        indx     = strmatch(lower(str),validstr);
        if length(indx) ~= 1
            error('Unrecognized track string')
        elseif indx == 1
            [rang,msg] = distgc(varargin{:});
        elseif indx == 2
            [rang,msg] = distrh(varargin{:});
        end
    end

    %  Error out if necessary

    if ~isempty(msg);   error(msg);   end


    %**********************************************************************
    %**********************************************************************
    %**********************************************************************


function [rang,msg] = distgc(in1,in2,in3,in4,in5,in6)

    %DISTGC:  Calculates great circle distance between points on a geoid
    %
    %  Purpose
    %
    %  Computes the great circle distance between two
    %  points on a globe.  The default input angle units
    %  are degrees.  The default range output is the angular
    %  distance in the same units as the input angles.
    %  The default geoid is a sphere, but this can be
    %  redefined to an ellipsoid using the geoid input.
    %
    %  Synopsis
    %
    %       rang = distgc(pt1,pt2)
    %       rang = distgc(pt1,pt2,geoid)
    %       rang = distgc(pt1,pt2,'units')
    %       rang = distgc(pt1,pt2,geoid,'units')
    %
    %       rang = distgc(lat1,lon1,lat2,lon2)
    %       rang = distgc(lat1,lon1,lat2,lon2,geoid)
    %       rang = distgc(lat1,lon1,lat2,lon2,'units')
    %       rang = distgc(lat1,lon1,lat2,lon2,geoid,'units')
    %
    %       [rang,errmsg] = distgc(....
    %            If two output arguments are supplied, then error condition
    %            messages are returned to the calling function for processing.


    %   REFERENCES:
    %   For the sphere:  J. P. Snyder,  "Map Projections - A
    %   Working Manual,"  US Geological Survey Professional Paper 1395,
    %   US Government Printing Office, Washington, DC, 1987,  pp. 29-32.
    %   For the ellipsoid:  D. H. Maling, Coordinate Systems and
    %   Map Projections, 2nd Edition Pergamon Press, 1992, pp. 74-76.


    %  Copyright (c) 1996-98 by Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    %  Written by:  E. Byrns, E. Brown




    %  Initialize outputs

    if nargout ~= 0;  rang = [];   msg = [];  end

    %  Input tests

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
        geoid = [];     units  = [];

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
            units  = in3;      geoid = [];
        else
            units  = [];       geoid = in3;
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
            units  = in5;            geoid = [];
        else
            units  = [];             geoid = in5;
        end

    elseif nargin == 6

        lat1 = in1;	      lon1 = in2;
        lat2 = in3;	      lon2 = in4;
        geoid = in5;      units  = in6;

    else
        msg = 'Incorrect number of arguments';
        if nargout < 2;  error(msg);  end
        return
    end


    %  Empty argument tests

    if isempty(geoid);   geoid = [0 0];       end
    if isempty(units);   units = 'degrees';   end

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


    %  Compute the range

    if geoid(2) == 0                   %  Spherical geoid
        temp1 = sin(lat1).*sin(lat2);
        temp2 = cos(lat1).*cos(lat2).*cos(lon2-lon1);
        temp3 = temp1+temp2;
        rang   = acos(temp3);

        %  Transform the range to the desired units

        if geoid(1) == 0;    rang = angledim(rang,'radians',units);
        else;            rang = rang * geoid(1);
        end

    else                              %  Elliptical geoid
        if geoid(2) > 0.2
            warning('Great Circle distance approximation weakens with eccentricity > 0.2')
        end

        par1 = geod2par(lat1,geoid,'radians');
        par2 = geod2par(lat2,geoid,'radians');

        b = minaxis(geoid);        %  Semiminor axis

        %  Compute the cartesian coordinates of the points on the ellipsoid
        %  (Note that because of the z calculation, this is not a simple sph2cart calc)

        x1 = geoid(1) * cos(par1) .* cos(lon1);
        y1 = geoid(1) * cos(par1) .* sin(lon1);
        z1 = b * sin(par1);

        x2 = geoid(1) * cos(par2) .* cos(lon2);
        y2 = geoid(1) * cos(par2) .* sin(lon2);
        z2 = b * sin(par2);

        %  Compute the chord length.  Can't use norm function because
        %  x1, x2, etc may already be vectors or matrices

        k = sqrt( (x1-x2).^2 +  (y1-y2).^2 +  (z1-z2).^2 );

        %  Now compute the correction factor, and then the range
        %  The correction factor breaks down as the eccentricity gets
        %  large for an ellipsoid.  (ie:  exceeds 0.2)

        r = rsphere('euler',lat1,lon1,lat2,lon2,geoid,'radians');
        delta = k.^3 ./ (24*r.^2) + 3*k.^5 ./ (640*r.^4);
        rang = k + delta;

    end


    %**********************************************************************
    %**********************************************************************
    %**********************************************************************


function [rang,msg] = distrh(in1,in2,in3,in4,in5,in6)

    %DISTRH:  Calculates rhumb line distance between points on a geoid
    %
    %  Purpose
    %
    %  Computes the rhumb line distance between two
    %  points on a globe.  The default input angle units
    %  are degrees.  The default range output is the angular
    %  distance in the same units as the input angles.
    %  The default geoid is a sphere, but this can be
    %  redefined to an ellipsoid using the geoid input.
    %
    %  Synopsis
    %
    %       rang = distrh(pt1,pt2)
    %       rang = distrh(pt1,pt2,geoid)
    %       rang = distrh(pt1,pt2,'units')
    %       rang = distrh(pt1,pt2,geoid,'units')
    %
    %       rang = distrh(lat1,lon1,lat2,lon2)
    %       rang = distrh(lat1,lon1,lat2,lon2,geoid)
    %       rang = distrh(lat1,lon1,lat2,lon2,'units')
    %       rang = distrh(lat1,lon1,lat2,lon2,geoid,'units')
    %
    %       [rang,errmsg] = distrh(....
    %            If two output arguments are supplied, then error condition
    %            messages are returned to the calling function for processing.


    %  Copyright (c) 1996-98 by Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    %  Written by:  E. Brown, E. Byrns



    %  Initialize outputs

    if nargout ~= 0;  rang = [];   msg = [];  end

    %  Input tests

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
        geoid = [];     units  = [];

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
            units  = in3;      geoid = [];
        else
            units  = [];       geoid = in3;
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
            units  = in5;            geoid = [];
        else
            units  = [];             geoid = in5;
        end

    elseif nargin == 6

        lat1 = in1;	      lon1 = in2;
        lat2 = in3;	      lon2 = in4;
        geoid = in5;      units  = in6;

    else
        msg = 'Incorrect number of arguments';
        if nargout < 2;  error(msg);  end
        return
    end


    %  Empty argument tests

    if isempty(geoid);   geoid = [0 0];       end
    if isempty(units);   units = 'degrees';   end

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

    %  Compute the rectifying sphere latitudes and radius

    rec1    = geod2rec(lat1,geoid,'radians');
    rec2    = geod2rec(lat2,geoid,'radians');
    radius  = rsphere('rectifying',geoid);


    rang=zeros(size(lat1));        % Preallocate memory for output
    epsilon=epsm('radians');      % Set tolerance

    % Latitudes cannot lie beyond a pole

    indx=find(abs(lat1)>pi/2);     lat1(indx) = pi/2 * sign(lat1(indx));
    indx=find(abs(lat2)>pi/2);     lat2(indx) = pi/2 * sign(lat2(indx));

    %  Compute the range

    course=azimuth('rh',lat1,lon1,lat2,lon2,geoid,'radians');
    coscourse=cos(course);

    indx1=find(abs(coscourse)<=epsilon);     % find degenerate cases
    % i.e. cos(course)=0
    indx=1:numel(rang);  %  identify non-degenerate cases
    indx(indx1)=[];

    % handle the degenerate cases:

    rang(indx1) = abs( (lon2(indx1)-lon1(indx1)) .* cos(lat1(indx1)) );
    rang(indx1) = rang(indx1) ./ sqrt( 1 - (geoid(2)*sin(lat1(indx1))).^2);

    % handle the general case:

    rang(indx)=abs( (rec1(indx)-rec2(indx)) ./ coscourse(indx) );

    %  Transform the range to the desired units

    if geoid(1) == 0;    rang = angledim(rang,'radians',units);
    else;            rang = rang * radius;
    end


