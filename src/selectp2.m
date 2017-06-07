%  This .m file selects the earthquakes within a polygon
%  and plots them. Sets "a" equal to the catalogue produced after the
%  general parameter selection. Operates on "org2", replaces "a"
%  with new data and makes "a" equal to newcat
echo on
% ___________________________________________________________
%  Please use the left mouse button or the cursor to select
%  the polygon vertexes.
%
%  Use the right mouse button to select the final point.
%_____________________________________________________________
report_this_filefun(mfilename('fullpath'));
echo off
%zoom off
newt2 = [ ];           % reset catalogue variables
%a = org2;              % uses the catalogue with the pre-selected main
% general parameters
newcat = a;

% delete old drwn events - if exist
try
    delete(plos1,plos2)
catch ME
    error_handler(ME, ' ');
end


messtext=...
    ['To select events inside a polygon.        '
    'Please use the LEFT mouse button or the   '
    'character P to select the polygon vertexes'
    'Use the RIGHT mouse button for the final  '
    'point.  Mac Users: use the keybord:       '
    ' p: more points, l: lst point             '
    'Operates on the original catalogue        '
    'producing a reduced  subset which in turn '
    'the other routines operate on.            '];

welcome('Select EQ in Polygon',messtext);


axes(h1)
hold on
x = [];
y = [];

n = 0;

% Loop, picking up the points.
%
but = 1;
while but == 1 | but == 112
    [xi,yi,but] = ginput(1);
    %mark1 =    plot(xi,yi,'o','era','back'); % doesn't matter what erase mode is
    mark1 =    plot(xi,yi,'ok','era','xor');  % used so long as its not NORMAL
    set(mark1,'MarkerSize',10,'LineWidth',2.0)
    n = n + 1;
    % mark2 =     text(xi,yi,[' ' int2str(n)],'era','back');
    % set(mark2,'FontSize',15,'FontWeight','bold')

    x = [x; xi];
    y = [y; yi];
end

welcome('Message',' Thank you .... ')
think
x = [x ; x(1)];
y = [y ; y(1)];      %  closes polygon

figure_w_normalized_uicontrolunits(cufi)
plos2 = plot(x,y,'b-','era','xor');        % plot outline
sum3 = 0.;
pause(0.3)
% calculate points with a polygon

XI = a(:,1);          % this substitution just to make equation below simple
YI = a(:,2);
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

newt2 = a(ll,:);                % newcat is created
%a = newcat;                      % a and newcat now equal to reduced catalogue
%newt2 = newcat;                  % resets newt2

% clear XI YI l ll;
%
% Plot of new catalog
%
plos1 = plot(newt2(:,1),newt2(:,2),'xg','era','xor'); %change from back to xor
%there was a
%selection problem if
%a second polygon was
%added.

xy = [x y ];
%save polcor.dat xy -ascii

name2 = name(1:length(name)-4);
do = [ ' save /home/stefan/ZMAP/outm2/' name2 'pol.dat xy -ascii ' ];
%eval(do)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%
%   The new catalog (newcat) with points only within the
%   selected Polygon is created and resets the original
%   "a" .
disp(' The selected polygon was save in the file polcor.dat')
%
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if exist('ho')
    bdiff(newt2,ho);
else
    bdiff(newt2)
end
