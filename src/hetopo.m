report_this_filefun(mfilename('fullpath'));

figure_w_normalized_uicontrolunits(gcf)
hold on
tox0 = -122.24;
toy0 = 46.16
tox = 0.1/257:0.1/257:0.1;
toy = 0.1/257:0.1/257:0.1;

contour(tox0+tox,toy0+toy,to,[1000  2000],'k')
axis('equal')
axis([-122.2 -122.18 46.19 46.21])
