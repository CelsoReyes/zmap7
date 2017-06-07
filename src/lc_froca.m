function [phi,lambda] = LC_froca(x,y,maxlat,minlat,maxlon,minlon)

    %LC_FROM_CARTESIAN
    %
    %	[phi,lambda] = LC_from_cartesian(x,y,maxlat,minlat,maxlon,minlon)
    %
    %	Function to compute the angular coordinates PHI (latitude) and
    %	LAMBDA (longitude) from the cartesian coordinates X and Y
    %	given the MAXLAT, MINLAT, MAXLON & MINLON of the Lambert
    %	conformal map on which these points have to be mapped.
    %
    %	where * phi: current location latitude
    %	      * lambda: current location longitude
    %	      * x & y : current cartesian coordinates
    %	      * maxlat: maximum latitude limit of the map
    %	      * minlat: minimum latitude limit of the map
    %	      * maxlon: maximum longitude limit of the map
    %	      * minlon: minimum longitude limit of the map
    %	               (remember: West longitude is < 0!)
    %
    %	If the LC_plot_map function has been called before this function
    %	AND the same map limits are used, then it is not neccessary to
    %	enter the last 4 arguments:
    %
    %	[phi,lambda] = LC_to_cartesian(x,y)
    %
    %	Source: Equations taken from "Map Projections Used by the
    %	        U.S. Geological Survey" by John P. Snyder
    %	        Geological Survey Bulletin 1532, pg: 101-109.

    global bDebug
    if bDebug
        report_this_filefun(mfilename('fullpath'));
    end

    todeg = 180 / pi;

    % set the global variables
    global torad Re scale
    global phi0 lambda0 phi1 phi2
    global maxlatg minlatg maxlong minlong

    if nargin == 2
        %get data from global variables
        maxlat = maxlatg; minlat = minlatg;
        maxlon = maxlong; minlon = minlong;
    elseif nargin == 6
        % set the global variable for later use
        maxlatg = maxlat; minlatg = minlat;
        maxlong = maxlon; minlong = minlon;

        % set some constants
        torad = pi / 180;
        Re = 6378.137;
        scale = 1;

        % get the Standard Parallels and Center Coordinates
        phi2 = (minlat + ((maxlat + minlat) / 4)) * torad;
        phi1 = (maxlat - ((maxlat + minlat) / 4)) * torad;
        phi0 = (phi1 + phi2) / 2;
        lambda0 = ((minlon + maxlon) / 2) * torad;
    else
        disp('This function requires 2 or 6 input arguments!')
        help LC_to_cartesian
        return
    end

    % compute the constant of the cone: sine_phi0
    tan1 = tan((pi/4) + (phi1/2));
    tan2 = tan((pi/4) + (phi2/2));
    sine_phi0 = log(cos(phi1)/cos(phi2)) / log(tan2/tan1);

    % compute the auxiliary function: psi
    psi = (cos(phi1) * (tan1^sine_phi0)) / sine_phi0;

    % compute the polar radius to the origin: rho0
    tan0 = tan((pi/4) + (phi0/2));
    rho0 = (Re * psi) / (tan0^sine_phi0);

    % compute the polar angles: theta
    theta = atan(x ./ (rho0 - y));

    % compute rho (inverse)
    rho = sign(sine_phi0) * sqrt((x.^2) + (rho0 - y).^2);

    % store the latitudes and longitudes in output variables
    arctan = atan((Re * psi ./ rho).^(1/sine_phi0));
    phi = ((2 * arctan) - (pi/2)) * todeg;
    lambda = ((theta / sine_phi0) + lambda0) * todeg;
