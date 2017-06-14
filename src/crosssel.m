%function crosssel
% crosssel.m                      Alexander Allmann
% function to select earthquakes in a cross-section and make them the
% current catalog in the main map windo
% Last change    8/95
%

global xsec_fig h2 newa newa2

report_this_filefun(mfilename('fullpath'));

figure_w_normalized_uicontrolunits(xsec_fig)

%loop to pick points
%axes(h2)
hold on
ax = findobj('Tag','main_map_ax');
[x,y, mouse_points_overlay] = select_polygon(ax);

plot(x,y,'b-','era','xor');
YI = -newa(:,7);          % this substitution just to make equation below simple
XI = newa(:,length(newa(1,:)));
    ll = polygon_filter(x,y, XI, YI, 'inside');

newa2 = newa(ll,:);
plot( newa2(:,length(newa2(1,:))), -newa2(:,7),'xk','era','back')
