%function crosssel
% crosssel.m                      Alexander Allmann
% function to select earthquakes in a cross-section and make them the
% current catalog in the main map windo
% Last change    8/95
%

global xsec_fig h2 newa newa2

report_this_filefun(mfilename('fullpath'));

figure_w_normalized_uicontrolunits(gcf)

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
    mark1 =    plot(xi,yi,'ob','era','back'); % doesn't matter what erase mode is
    % used so long as its not NORMAL
    set(mark1,'MarkerSize',8,'LineWidth',2.0)
    n = n + 1;
    % mark2 =     text(xi,yi,[' ' int2str(n)],'era','normal');
    % set(mark2,'FontSize',15,'FontWeight','bold')

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
ll = l;               %  Algorithm to select points inside a closed
%  polygon based on Analytic Geometry    R.Z. 4/94
for i = 1:m;

    l= ((y(i)-YI < 0) & (y(i+1)-YI >= 0)) & ...
        (XI-x(i)-(YI-y(i))*(x(i+1)-x(i))/(y(i+1)-y(i)) < 0) | ...
        ((y(i)-YI >= 0) & (y(i+1)-YI < 0)) & ...
        (XI-x(i)-(YI-y(i))*(x(i+1)-x(i))/(y(i+1)-y(i)) < 0);

    if i ~= 1
        ll(l) = 1 - ll(l);
    else
        ll = l;
    end;         % if i

end;         %  for

newa2 = newa(ll,:);
plot( newa2(:,length(newa2(1,:))), -newa2(:,7),'xk','era','normal')
newt2=newa2;newcat=newa2;timeplot

