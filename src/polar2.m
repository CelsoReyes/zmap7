function hpol = polar(theta,rho,line_style)
    %POLAR	Polar coordinate plot.
    %	POLAR(THETA, RHO) makes a plot using polar coordinates of
    %	the angle THETA, in radians, versus the radius RHO.
    %	POLAR(THETA,RHO,S) uses the linestyle specified in string S.
    %	See PLOT for a description of legal linestyles.
    %
    %	See also PLOT, LOGLOG, SEMILOGX, SEMILOGY.
    
    %	Copyright (c) 1984-94 by The MathWorks, Inc.
    
    %TODO move all the other ones to polar, and then delete this. first compare results
    
    if nargin < 1
        error('Requires 2 or 3 input arguments.')
    elseif nargin == 2
        if ischar(rho)
            line_style = rho;
            rho = theta;
            [mr,nr] = size(rho);
            if mr == 1
                theta = 1:nr;
            else
                th = (1:mr)';
                theta = th(:,ones(1,nr));
            end
        else
            line_style = 'auto';
        end
    elseif nargin == 1
        line_style = 'auto';
        rho = theta;
        [mr,nr] = size(rho);
        if mr == 1
            theta = 1:nr;
        else
            th = (1:mr)';
            theta = th(:,ones(1,nr));
        end
    end
    if ischar(theta)  ||  ischar(rho)
        error('Input arguments must be numeric.');
    end
    if any(size(theta) ~= size(rho))
        error('THETA and RHO must be the same size.');
    end
    
    % get hold state
    cax = newplot;
    next = lower(get(cax,'NextPlot'));
    hold_state = ishold;
    
    % get x-axis text color so grid is in same color
    tc = get(cax,'xcolor');
    
    % Hold on to current Text defaults, reset them to the
    % Axes' font attributes so tick marks use them.
    fAngle  = get(cax, 'DefaultTextFontAngle');
    fName   = get(cax, 'DefaultTextFontName');
    fSize   = get(cax, 'DefaultTextFontSize');
    fWeight = get(cax, 'DefaultTextFontWeight');
    set(cax, 'DefaultTextFontAngle',  get(cax, 'FontAngle'), ...
        'DefaultTextFontName',   get(cax, 'FontName'), ...
        'DefaultTextFontSize',   get(cax, 'FontSize'), ...
        'DefaultTextFontWeight', get(cax, 'FontWeight') )
    
    % only do grids if hold is off
    if ~hold_state
        
        % make a radial grid
        hold on;
        hhh=plot([0 max(theta(:))],[0 max(abs(rho(:)))]);
        v = [get(cax,'xlim') get(cax,'ylim')];
        ticks = length(get(cax,'ytick'));
        delete(hhh);
        % check radial limits and ticks
        rmin = 0; rmax = v(4); rticks = ticks-1;
        if rticks > 5	% see if we can reduce the number
            if rem(rticks,2) == 0
                rticks = rticks/2;
            elseif rem(rticks,3) == 0
                rticks = rticks/3;
            end
        end
        
        % define a circle
        th = 0:pi/50:2*pi;
        xunit = cos(th);
        yunit = sin(th);
        % now really force points on x/y axes to lie on them exactly
        inds = [1:(length(th)-1)/4:length(th)];
        xunits(inds(2:2:4)) = zeros(2,1);
        yunits(inds(1:2:5)) = zeros(3,1);
        
        rinc = (rmax-rmin)/rticks;
        for i=(rmin+rinc):rinc:rmax
            plot(xunit*i,yunit*i,'-','color',tc,'LineWidth',1);
            %	text(0,i+rinc/20,['  ' num2str(i)],'verticalalignment','bottom' );
        end
        
        % plot spokes
        th = (1:6)*2*pi/12;
        cst = cos(th); snt = sin(th);
        cs = [-cst; cst];
        sn = [-snt; snt];
        plot(rmax*cs,rmax*sn,'-','color',tc,'LineWidth',1);
        
        % annotate spokes in degrees
        rt = 1.1*rmax;
        for i = 1:max(size(th))
            %	text(rt*cst(i),rt*snt(i),int2str(i*30),'horizontalalignment','center' );
            if i == max(size(th))
                loc = int2str(0);
            else
                loc = int2str(180+i*30);
            end
            %	text(-rt*cst(i),-rt*snt(i),loc,'horizontalalignment','center' );
        end
        
        % set viewto 2-D
        view(0,90);
        % set axis limits
        axis(rmax*[-1 1 -1.1 1.1]);
    end
    
    % Reset defaults.
    set(cax, 'DefaultTextFontAngle', fAngle , ...
        'DefaultTextFontName',   fName , ...
        'DefaultTextFontSize',   fSize, ...
        'DefaultTextFontWeight', fWeight );
    
    % transform data to Cartesian coordinates.
    yy = rho.*cos(theta);
    xx = rho.*sin(theta);
    
    % plot data on top of grid
    if line_style == "auto"
        q = plot(xx,yy);
    else
        q = plot(xx,yy,line_style);
    end
    if nargout > 0
        hpol = q;
    end
    if ~hold_state
        axis('equal');axis('off');
    end
    
    % reset hold state
    if ~hold_state, set(cax,'NextPlot',next); end
end
