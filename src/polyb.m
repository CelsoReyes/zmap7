%function crosssel
% crosssel.m                      Alexander Allmann
% function to select earthquakes in a cross-section and make them the
% current catalog in the main map windo
% Last change    8/95
%

report_this_filefun(mfilename('fullpath'));

global bmapc h2 newa

report_this_filefun(mfilename('fullpath'));

[existFlag,figNumber]=figure_exists('b-value cross-section',1);
figure_w_normalized_uicontrolunits(figNumber)

%loop to pick points
%axes(h2)
hold on
ax = findobj('Tag','main_map_ax');
[x,y, mouse_points_overlay] = select_polygon(ax);

plot(x,y,'b-','era','xor');
YI = -newa(:,7);          % this substitution just to make equation below simple
XI = newa(:,length(newa(1,:)));
    ll = polygon_filter(x,y, XI, YI, 'inside');

%plot the selected eqs and mag freq curve
newa2 = newa.subset(ll);
newt2 = newa2;
newcat = newa.subset(ll);
pl = plot(newa2(:,length(newa2(1,:))),-newa2(:,7),'xk');
set(pl,'MarkerSize',5,'LineWidth',1)
bdiff(newa2)

