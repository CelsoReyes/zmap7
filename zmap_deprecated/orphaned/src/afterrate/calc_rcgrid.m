function [RCREL,x,y] = calc_rcgrid(a,dx,dy,r,step,mintime,maxtime,timestep,nmineqnr)
    % function [RCREL,x,y] = calc_rcgrid(a,dx,dy,r,step,mintime,maxtime,timestep,nmineqnr)
    % ---------------------------------------------------------------------
    % Determines ratechanges at grid points. Input and output
    % added and changed, original script is rcgrid.m by S. Neukomm.
    %
    % Incoming variables:
    % a        : EQ catalog
    % dx       : Lon. spacing
    % dy       : Lat. spacing
    % r        : Radius
    % step    : forecast period
    % mintime : start time
    % maxtime : time after mainshock up to Omori parameters are fitted in the learning period
    % timestep : Timesteps for the learning period
    % nmineqnr : Minimum number of eqs in subcatalog
    %
    % Outgoing variables:
    % RCREL: matrix of the relative rate changes on the gridnode
    % x   : x-coordinates
    % y   : y coordinates
    %
    % last update: 09.07.03
    % J. Woessner

    % get longitude / latitude
    lon = a.Longitude; lat = a.Latitude;

    % determine mainshock
    [m_main, main] = max(a.Magnitude);
    % calculate delay times in days after mainshock
    date_matlab = datenum(a.Date.Year,a.Date.Month,a.Date.Day,a.Date.Hour,a.Date.Minute,zeros(size(a,1),1));
    date_main = date_matlab(main);
    time_aftershock = date_matlab-date_main;

    % cut catalogue at mainshock
    l = time_aftershock(:) > 0;
    tas = time_aftershock(l);
    eqcatalogue = a.subset(l);

    % get M5+ aftershocks
    l = eqcatalogue(:,6) >= 5;
    largeas = eqcatalogue(l,:);
    largetime = tas(l);

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
    dim3 = maxtime;                     % 't'
    RCREL = zeros(dim2,dim1,dim3);      % normalized ratechanges

    % get quakes nearer r [deg] and determine ratechanges
    for i = 1:length(gp)
        % select events belonging to grid point
        %r = 0.1;
        l = ((eqcatalogue(:,1)-gp(i,1)).^2+(eqcatalogue(:,2)-gp(i,2)).^2).^0.5 < r;
        gpi = eqcatalogue(l,:); % new sub-catalog
        time_as = tas(l);
        % determine ratechanges
        if length(gpi) >= nmineqnr % minimal number of eqs
            rc = calc_ratechange(gpi,time_as,step,mintime,maxtime, timestep); % ratechange.m is called
            if size(rc,1) >= 1 % check if rc isn't empty
                for j = 1:dim3 % rc is sorted into matrices
                    l = rc(:,1) == j;
                    if sum(l) ~= 0
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
                        if rc(l,3) ~= 0
                            RCREL(imatrix,jmatrix,j) = rc(l,2)/rc(l,3);
                        end
                    end
                end
                do = ['ratechange' num2str(i) '=rc; gridnode' num2str(i) '=gpi;'];
                eval(do)
            end
        end
    end
