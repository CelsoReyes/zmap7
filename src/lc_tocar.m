function [x,y] = LC_tocart(phi,lambda,maxlat,minlat,maxlon,minlon)
    
    %LC_TO_CARTESIAN
    %
    %	[x,y] = LC_to_cartesian(phi,lambda,maxlat,minlat,maxlon,minlon)
    %
    %	Function to compute the cartesian coordinates X and Y from the
    %	angular coordinates phi (latitude) and lambda (longitude)
    %	given the MAXLAT, MINLAT, MAXLON & MINLON of the Lambert
    %	conformal map on which these points have to be mapped.
    %
    %	where * phi: current location latitude in degrees
    %	      * lambda: current location longitude in degrees
    %	      * maxlat: maximum latitude limit of the map
    %	      * minlat: minimum latitude limit of the map
    %	      * maxlon: maximum longitude limit of the map
    %	      * minlon: minimum longitude limit of the map
    %	               (remember: West longitude is < 0!)
    %
    %	If the LC_MAP function has been called before this function
    %	AND the same map limits are used, then it is not neccessary to
    %	enter the last 4 arguments:
    %
    %	[x,y] = LC_to_cartesian(phi,lambda)
    %
    %       Source: Equations taken from "Map Projections Used by the
    %               U.S. Geological Survey" by John P. Snyder
    %               Geological Survey Bulletin 1532, pg: 101-109.
    
    report_this_filefun(mfilename('fullpath'));
    
    % set the global variables
    global torad Re scale
    global sine_phi0 phi0 lambda0 phi1 phi2
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
        scale = 1;
        
        % get the Standard Parallels and Center Coordinates
        phi2 = (minlat + ((maxlat - minlat) / 4)) * torad;
        phi1 = (maxlat - ((maxlat - minlat) / 4)) * torad;
        phi0 = (phi1 + phi2) / 2;
        lambda0 = ((minlon + maxlon) / 2) * torad;
    else
        disp('This function requires 2 or 6 input arguments!')
        help LC_to_cartesian
        return
    end
    
    % convert phi & lambda from degrees to radians
    phi = phi * torad;
    lambda = lambda * torad;
    
    % convert the data longitudes into differences in longitudes between the
    % center longitude, and the data longitudes
    d_lambda = (lambda - lambda0);
    
    % compute the constant of the cone: sine_phi0
    tan1 = tan((pi/4) + (phi1/2));
    tan2 = tan((pi/4) + (phi2/2));
    sine_phi0 = log(cos(phi1)/cos(phi2)) / log(tan2/tan1);
    
    % compute the polar angles: theta
    theta = d_lambda * sine_phi0;
    
    % compute the auxiliary function: psi
    psi = cos(phi1) * (tan1^sine_phi0) / sine_phi0;
    
    % compute the polar radius to the origin: rho0
    tan0 = tan((pi/4) + (phi0/2));
    rho0 = Re * psi / (tan0^sine_phi0);
    
    % compute the polar radius to each latitude phi: rho
    rho = Re * psi ./ (tan((pi/4) + (phi/2)).^sine_phi0);
    
    % store the data in output variables
    x = scale * rho .* sin(theta);
    y = scale * (rho0 - (rho .* cos(theta)));
    
end