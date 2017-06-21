% crosssel.m                      Alexander Allmann
% function to select earthquakes in a cross-section and make them the
% current catalog in the main map windo
% Last change    8/95
%

global bmapc h2 newa zmap

report_this_filefun(mfilename('fullpath'));

[existFlag,figNumber]=figure_exists('Z-Value-Cross-section',1);

figure_w_normalized_uicontrolunits(figNumber)

%loop to pick points
%axes(h2)
hold on
ax = findobj('Tag','main_map_ax');
[x,y, mouse_points_overlay] = select_polygon(ax);

plot(x,y,'b-','era','xor');
YI = -newa(:,7);          % this substitution just to make equation below simple
XI = newa(:,length(newa(1,:)));
    lb = polygon_filter(x,y, XI, YI, 'inside');

%plot the selected eqs and mag freq curve
newt2 = newa.subset(lb);
newcat = newa.subset(lb);
pl = plot(newt2(:,length(newt2(1,:))),-newt2.Depth,'xk');
set(pl,'MarkerSize',8,'LineWidth',1)
timeplot

