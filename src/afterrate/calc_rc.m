function [RCREL,x,y,time] = calc_rc(a,dx,dy,r,z,dt,mintime,maxtime,timestep,bootloops)
    % function [RCREL,x,y,time] = calc_rc(a,dx,dy,r,z,dt,mintime,maxtime,timestep,bootloops)
    % ---------------------------------------------------------------------
    % Determines ratechanges at grid points for different learning periods.
    % Radius and forecast interval are given. Depth is specified.
    %
    % Input variables:
    % a        : EQ catalog (complete in magnitude!)
    % dx       : Lon. spacing
    % dy       : Lat. spacing
    % r        : Radius
    % z        : Analysis depth [km]
    % dt       : forecast period
    % mintime  : minimal learning period
    % maxtime  : maximal learning period
    % timestep : Timesteps for the learning period
    % bootloops: number of boostrap samples
    %
    % Output variables:
    % RCREL: matrix of the relative rate changes on the gridnode
    % x    : x-coordinates
    % y    : y coordinates
    % time : learning periods
    %
    % last update: 17.03.04
    % Samuel Neukomm

report_this_filefun(mfilename('fullpath'));
    lon = a.Longitude; lat = a.Latitude;

    [m_main, main] = max(a.Magnitude);
    maepi = a.subset(main);

    if size(a,2) == 9
        date_matlab = datenum(a.Date.Year,a.Date.Month,a.Date.Day,a.Date.Hour,a.Date.Minute,zeros(size(a,1),1));
    else
        date_matlab = datenum(a.Date.Year,a.Date.Month,a.Date.Day,a.Date.Hour,a.Date.Minute,a(:,10));
    end
    date_main = date_matlab(main);
    time_aftershock = date_matlab-date_main;
    l = time_aftershock(:) > 0;
    tas = time_aftershock(l);
    eqcatalogue = a.subset(l);

    % define grid
    xmax = round(10*max(lon))/10+dx;
    xmin = round(10*min(lon))/10-dx;
    ymax = round(10*max(lat))/10+dy;
    ymin = round(10*min(lat))/10-dy;

    x = (xmin:dx:xmax)';
    y = (ymin:dy:ymax)';
    yy = repmat(y,length(x),1);
    xx = reshape((repmat(x,1,length(y)))',length(yy),1);
    gp = [xx yy]; % gp is N*2 matrix containing grid coordinates

    % define matrix containing normalized ratechanges
    dim1 = round((xmax-xmin)/dx)+1;     % 'lon'
    dim2 = round((ymax-ymin)/dy)+1;     % 'lat'
    dim3 = (maxtime-mintime)/timestep+1;% 't'
    RCREL = zeros(dim2,dim1,dim3);      % normalized ratechanges

    % get quakes nearer r [deg] and determine ratechanges
    for i = 1:length(gp)
        disp(num2str(i/length(gp)))
        % select events belonging to grid point
        l = ((eqcatalogue(:,1)-gp(i,1)).^2+(eqcatalogue(:,2)-gp(i,2)).^2+(km2deg(eqcatalogue(:,7)-z)).^2).^0.5 < r;
        gpi = eqcatalogue(l,:); % new sub-catalog
        time_as = tas(l);
        % determine ratechanges
        rc = []; t0 = mintime;
        while t0 <= maxtime
            [change,numreal,nummod,sigma] = calc_optrc(gpi,time_as,t0,t0+dt,bootloops,maepi);
            rc = [rc; change];
            t0 = t0 + timestep;
        end
        % transform i into matrix dimensions imatrix/jmatrix
        if i > dim2
            if mod(i,dim2) ~= 0
                imatrix = dim2+1-(i-floor(i/dim2)*dim2);
            else
                imatrix = 1;
            end
        else
            imatrix = dim2+1-i;
        end
        jmatrix = ceil(i/dim2);
        RCREL(imatrix,jmatrix,:) = rc(:);
    end

    time=(mintime:timestep:maxtime)';
