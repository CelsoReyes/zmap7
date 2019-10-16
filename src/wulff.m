function wulff() 
    % wulff -- Program for plotting a Wulff net
    % to plot points, first calculate theta = pi*(90-azimuth)/180
    % then rho = tan(pi*(90-dip)/360), and finally the components
    % xp = rho*cos(theta) and yp = rho*cos(theta)
    % turned into function by Celso G Reyes 2017
    
    N = 50;
    cx = cos(0:pi/N:2*pi);                           % points on circle
    cy = sin(0:pi/N:2*pi);
    xh = [-1 1];                                     % horizontal axis
    yh = [0 0];
    xv = [0 0];                                      % vertical axis
    yv = [-1 1];
    axis([-1 1 -1 1]);
    axis('square');
    plot(xh,yh,'-k',xv,yv,'-k');                     %plot green axes
    axis off;
    set(gca,'NextPlot','add');
    plot(cx,cy,'-k');                                %plot white circle
    psi = 0:pi/N:pi;
    for i = 1:8                                      %plot great circles
        rdip = i*(pi/18);                             %at 10 deg intervals
        radip = atan(tan(rdip)*sin(psi));
        rproj = tan((pi/2 - radip)/2);
        x1 = rproj .* sin(psi);
        x2 = rproj .* (-sin(psi));
        y = rproj .* cos(psi);
        plot(x1,y,':k',x2,y,':k');
    end
    for i = 1:8                                     %plot small circles
        alpha = i*(pi/18);
        xlim = sin(alpha);
        % ylim = cos(alpha);
        x = -xlim:0.01:xlim;
        d = 1/cos(alpha);
        rd = d*sin(alpha);
        y0 = sqrt(rd*rd - (x .* x));
        y1 = d - y0;
        y2 = - d + y0;
        plot(x,y1,':k',x,y2,':k');
    end
    axis('square');
    set(gcf,'color','w');
end
