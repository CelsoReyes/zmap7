%  This .m file selects the earthquakes within a polygon
%  and plots them.
%  Operates on "a", replaces "a" with new data
%  and creates   newcat
echo on
report_this_filefun(mfilename('fullpath'));
% ___________________________________________________________
%  Please use the left mouse button or the cursor to select
%  the polygon vertexes.
%
%  Use the right mouse button to select the final point.
%_____________________________________________________________
echo off
figure_w_normalized_uicontrolunits(1)
axes(h1)
x = [];
y = [];

% start with the original catalog
n = 0;

% Loop, picking up the points.
%
x = input('Input polygon: (e.g [ -178 53 ; -164 52 ; ...]  ')
wai = uicontrol('Units','normal','Position',[.4 .50 .2 .06],'String','Wait ... ')
disp('Data is being processed - please wait...  ')
y = [x(:,2) ; x(1,2)];      %  closes polygon
x = [x(:,1) ; x(1,1)];

plot(x,y,'b-','era','normal');
sum3 = 0.;
pause(0.3)
%a(:,7) = a(:,6).*0;

XI = a(:,1);          % this substitution just to make equation below simple
YI = a(:,2);
    ll = polygon_filter(x,y, XI, YI, 'inside');

newcat = a(ll,:);      % newcat is created

clear XI YI l ll;
%
% Plot of new catalog
%
disp('Done!')
delete(wai)
plot(newcat(:,1),newcat(:,2),'.m','era','normal')

a = newcat;

timeplot
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%
%   The new catalog (newcat) with points only within the
%   selected Polygon is created and replaces the original
%   "a" .
%
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++
