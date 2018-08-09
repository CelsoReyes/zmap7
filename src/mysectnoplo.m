function [xsecx,xsecy, inde] = mysectnoplo(eqlat,eqlon,depth,width,length,...
        lat1,lon1,lat2,lon2)
% mysectnoplo
% [probably] based off of LC_XSECTION [LC_xsect]

    report_this_filefun();
    
    
    %TODO untangle the global situation, incoming parameters cannot match globals directly. -CGR
    global  torad
    global sine_phi0 lambda0  sw eq1
    global maxlatg minlatg maxlong minlong
    global eq0p
    todeg = 180 / pi;
    eq1 =[];
    
    
    if nargin == 8	% method 2: given lat & lon of center point and angle
        
    elseif nargin == 9	% method 1: given lat & lon of the two end points
        %figure(mapl);
        [x1, y1] = lc_tocart(lat1,lon1);
        [x2, y2] = lc_tocart(lat2,lon2);
        
        if x1 > x2
            xtemp = x1; ytemp = y1;
            x1 = x2; y1 = y2;
            x2 = xtemp; y2 = ytemp;
            sw = 'on';
        else
            sw = 'of';
        end
        
        x0 = (x1 + x2) / 2;
        y0 = (y1 + y2) / 2;
        [lat0, lon0] = lc_froca(x0,y0);
        dx = x2 - x1;
        dy = y2 - y1;
        
        alpha = 90 - (atan(dy/dx)*todeg);
        length = sqrt(dx^2 + dy^2);
        
    else
        
        disp('ERROR: incompatible number of arguments')
        help LC_XSECTION
        return
        
    end
    
    % correction factor to correct for longitude away from the center meridian
    theta0 = ((lon0*torad - lambda0) * sine_phi0) * todeg;
    
    % correct the XY azimuth of the Xsection line with the above factor to obtain
    % the true azimuth
    azimuth = alpha + theta0;
    if azimuth < 0, azimuth = azimuth + 180; end
    
    % convert XY coordinate azimuth to a normal angle like we used to deal with
    sigma = 90 - alpha;
    
    % transformation matrix to rotate the data coordinate w.r.t the Xsection line
    transf = [cos(sigma*torad) sin(sigma*torad)
        -sin(sigma*torad) cos(sigma*torad)];
    
    % inverse transformation matrix to rotate the data coordinate back
    invtransf = [cos(-sigma*torad) sin(-sigma*torad)
        -sin(-sigma*torad) cos(-sigma*torad)];
    
    % convert the map coordinate of the events to cartesian coordinates
    idx_map = find(minlatg < eqlat & eqlat < maxlatg & ...
        minlong < eqlon & eqlon < maxlong);
    [eq(1,:) eq(2,:)] = lc_tocart(eqlat,eqlon);
    % create new coordinate system at center of Xsection line
    eq0(1,:) = eq(1,:) - x0;
    eq0(2,:) = eq(2,:) - y0;
    
    % rotate this last coordinate system so that X-axis correspond to Xsection line
    eq0p = transf * eq0;
    % project the event data to the Xsection line
    eq1(1,:) = eq0p(1,:);
    eq1(2,:) = eq0p(2,:) ;
    
    % convert back to the original coordinate system
    eq1p = invtransf * eq1;
    eq2(1,:) = eq1p(1,:) + x0;
    eq2(2,:) = eq1p(2,:) + y0;
    
    % find index of all events which are within the given box width
    idx_box = find(abs(eq0p(2,:)) <= width/2 & abs(eq0p(1,:)) <= length/2);
    inde = idx_box;
    
    
    % Plot events on cross section figure
    xdist = eq1(1,idx_box) + (length / 2);
    %eq1(1,:) = eq1(1,:) + (length / 2);
    
    global Xwbz Ywbz
    Xwbz = xdist;
    Ywbz = depth(idx_box);
    
    xsecx = xdist;
    xsecy = depth(idx_box);
end