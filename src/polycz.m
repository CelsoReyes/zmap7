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
x = [];
y = [];

n = 0;

% Loop, picking up the points.
%
but = 1;
while but == 1 | but == 112
    [xi,yi,but] = ginput(1);
    mark1 =    plot(xi,yi,'ok','era','back'); % doesn't matter what erase mode is
    % used so long as its not NORMAL
    set(mark1,'MarkerSize',10,'LineWidth',2.0)
    n = n + 1;
    x = [x; xi];
    y = [y; yi];
end

x = [x ; x(1)];
y = [y ; y(1)];      %  closes polygon

plot(x,y,'b-','era','xor');
YI = -newa(:,7);          % this substitution just to make equation below simple
XI = newa(:,length(newa(1,:)));
m = length(x)-1;      %  number of coordinates of polygon
l = 1:length(XI);
l = (l*0)';
lb = l;               %  Algorithm to select points inside a closed
%  polygon based on Analytic Geometry    R.Z. 4/94
for i = 1:m;

    l= ((y(i)-YI < 0) & (y(i+1)-YI >= 0)) & ...
        (XI-x(i)-(YI-y(i))*(x(i+1)-x(i))/(y(i+1)-y(i)) < 0) | ...
        ((y(i)-YI >= 0) & (y(i+1)-YI < 0)) & ...
        (XI-x(i)-(YI-y(i))*(x(i+1)-x(i))/(y(i+1)-y(i)) < 0);

    if i ~= 1
        lb(l) = 1 - lb(l);
    else
        lb = l;
    end;         % if i

end;         %  for

%plot the selected eqs and mag freq curve
newt2 = newa(lb,:);
newcat = newa(lb,:);
pl = plot(newt2(:,length(newt2(1,:))),-newt2(:,7),'xk');
set(pl,'MarkerSize',8,'LineWidth',1)
timeplot

