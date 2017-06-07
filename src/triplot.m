function triplot
    % triplot plots a triangular diagram
    % points on it are plotted by tripts
    % written by Gerry Middleton, 1995
    xscale = 2/sqrt(3);
    x = [0 xscale/2 xscale 0];		 % define coordinates of apices
    y = [-1 0 -1 -1];
    plot(x,y,'k');
    axis('equal');
    axis off;						 % turn off rectangular axes
    hold on;						 % hold, to permit adding to plot later
    for i = 1:9						 % plot dotted lines parallel to sides,
        x1 = i*xscale/20;			 % at 10 percent intervals
        x2 = (20-i)*xscale/20;
        x3 = i*xscale/10;
        y1 = -1 + i/10;
        y2 = -i/10;
        xx = [x1 x2];
        yy = [y1 y1];
        xx2 = [x1 x3];
        yy2 = [y1 -1];
        xx3 = [x3 (xscale/2 + x1)];
        yy3 = [-1 y2];
        plot(xx,yy,'k:',xx2,yy2,'k:',xx3,yy3,'k:');
    end
    set(gcf,'color','w')

