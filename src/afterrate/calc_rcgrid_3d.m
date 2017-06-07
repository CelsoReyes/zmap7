function [RCREL,x,y,z,time] = calc_rcgrid_3d(a,dx,dy,dz,r,deltat,mintime,maxtime,timestep,nmineqnr)
    % function [RCREL,x,y,z,time] = calc_rcgrid_3d(a,dx,dy,dz,r,deltat,mintime,maxtime,timestep,nmineqnr)
    % -------------------------------------------------------------------------
    % Determines ratechanges in sub-catalogs at grid points.
    %
    % Incoming variables:
    % a        : EQ catalog
    % dx       : Lon. spacing
    % dy       : Lat. spacing
    % dz       : Depth spacing
    % r        : Radius
    % deltat   : forecast period
    % mintime  : minimal learning period
    % maxtime  : maximal learning period
    % timestep : Timesteps for the learning period
    % nmineqnr : Minimum number of eqs in subcatalog
    %
    % Outgoing variables:
    % RCREL    : matrix of the relative rate changes on the gridnode
    % x        : x-coordinates
    % y        : y-coordinates
    % z        : z-coordinates
    % time     : learning periods
    %
    % last update: 25.07.03
    % S. Neukomm

report_this_filefun(mfilename('fullpath'));
    warning off

    % get coordinates
    lon = a(:,1); lat = a(:,2); depth = a(:,7);

    % calculate delay times in days after mainshock
    [m_main, main] = max(a(:,6));
    date_matlab = datenum(floor(a(:,3)),a(:,4),a(:,5),a(:,8),a(:,9),zeros(size(a,1),1));
    date_main = date_matlab(main);
    time_aftershock = date_matlab-date_main;

    maepi = a(main,:);
    % cut catalogue at mainshock
    l = time_aftershock(:) > 0;
    tas = time_aftershock(l);
    eqcatalogue = a(l,:);

    % define grid
    xmax = round(10*max(lon))/10+dx;
    xmin = round(10*min(lon))/10-dx;
    ymax = round(10*max(lat))/10+dy;
    ymin = round(10*min(lat))/10-dy;
    zmax = round(10*max(depth))/10+dz;
    zmin = 0;

    x = (xmin:dx:xmax)';
    y = (ymin:dy:ymax)';
    z = (zmin:dz:zmax)';
    zz = repmat(z,length(x)*length(y),1);
    yy = repmat(reshape((repmat(y,1,length(z)))',length(z)*length(y),1),length(x),1);
    xx = reshape((repmat(x,1,length(z)*length(y)))',length(z)*length(y)*length(x),1);
    gp = [xx yy zz]; % gp is N*3 matrix containing the N grid coordinates

    time = (mintime:timestep:maxtime)';

    % define result matrix
    dim1 = length(x);     % 'lon'
    dim2 = length(y);     % 'lat'
    dim3 = length(z);     % 'depth'
    dim4 = length(time);  % 'time'
    RCREL = zeros(dim1,dim2,dim3,dim4);

    hWaitbar1 = waitbar(0,'have a cigar...');
    set(hWaitbar1,'Numbertitle','off','Name','3D GRID')
    % compose sub-catalogs and determine ratechanges
    for i = 1:length(gp)
        l = ((eqcatalogue(:,1)-gp(i,1)).^2+(eqcatalogue(:,2)-gp(i,2)).^2+(km2deg(eqcatalogue(:,7)-gp(i,3))).^2).^0.5 < r;
        gpi = eqcatalogue(l,:); % new sub-catalog
        % determine ratechanges
        if length(gpi) >= nmineqnr
            for j = 1:dim4
                rc = calc_ratechangeF(gpi,time(j),time(j)+deltat,50,maepi); % calc_ratechangeF.m is called
                if isnan(rc(1)) == 0 % check if rc isn't NaN
                    % transform i into matrix dimensions xloc/yloc/zloc
                    xloc = ceil(i/dim2/dim3);
                    if mod(i,dim2*dim3) ~= 0
                        yloc = ceil(mod(i,dim2*dim3)/dim3);
                    else
                        yloc = dim2;
                    end
                    if mod(i,dim3) ~= 0
                        zloc = mod(i,dim3);
                    else
                        zloc=dim3;
                    end
                    % fill result matrix
                    if rc(3) ~= 0
                        RCREL(xloc,yloc,zloc,j) = rc(2)/rc(3);
                    end
                end
            end
        end
        waitbar(i/length(gp))
    end
    close(hWaitbar1)
