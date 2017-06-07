%   This subroutine "circle"  selects the Ni closest earthquakes
%   around a interactively selected point.  Resets newcat and newt2
%   Operates on "a".

%  Input Ni:
%
report_this_filefun(mfilename('fullpath'));


axes(h1)

titStr ='Selecting EQ in Circles                         ';
messtext= ...
    ['                                                '
    '  Please use the LEFT mouse button              '
    ' to select the center point.                    '
    ' The "ni" events nearest to this point          '
    ' will be selected and displayed in the map.     '];

welcome(titStr,messtext);

% Input center of circle with mouse
%
[xa0,ya0]  = ginput(1);

stri1 = [ 'Circle: lon = ' num2str(xa0) '; lat= ' num2str(ya0)];
stri = stri1;
pause(0.1)
%  calculate distance for each earthquake from center point
%  and sort by distance
%
l = sqrt(((xsecx' - xa0)).^2 + ((xsecy + ya0)).^2) ;
[s,is] = sort(l);
newt2 = newa(is(:,1),:) ;

if ic == 1 % select  N clostest events

    l =  sort(l);
    messtext = ['Radius of selected Circle:' num2str(l(ni))  ' km' ];
    disp(messtext)
    welcome('Message',messtext)
    %
    % take first ni and sort by time
    %
    newt2 = newt2(1:ni,:);
    [st,ist] = sort(newt2);
    newt2 = newt2(ist(:,3),:);
    %
    % plot Ni clostest events on map as 'x':

    hold on
    [na,ma] = size(newt2);
    plos1 = plot(newt2(:,ma),-newt2(:,7),'xk','EraseMode','back');
    set(gcf,'Pointer','arrow')
    %
    % plot circle containing events as circle
    x = -pi-0.1:0.1:pi;
    plot(xa0+sin(x)*l(ni), ya0+cos(x)*l(ni),'w','era','back')
    l(ni)

    %
    newcat = newt2;                   % resets newcat and newt2

    % Call program "timeplot to plot cumulative number
    %
    clear l s is
    bdiff(newt2)

end % if ic = 1

if ic == 2 % select  events within ra

    l =  sort(l);
    ll = l <=ra;
    messtext = ['Number of events in Circle :' num2str(length(newt2(ll,1))) ];
    disp(messtext)
    welcome('Message',messtext)
    %
    % take first ni and sort by time
    %
    newt2 = newt2(ll,:);
    [st,ist] = sort(newt2);
    newt2 = newt2(ist(:,3),:);
    %
    % plot Ni clostest events on map as 'x':

    hold on
    [na,ma] = size(newt2);
    plos1 = plot(newt2(:,ma),-newt2(:,7),'xk','EraseMode','back');
    set(gcf,'Pointer','arrow')
    %
    % plot circle containing events as circle
    x = -pi-0.1:0.1:pi;
    plot(xa0+sin(x)*ra, ya0+cos(x)*ra,'w','era','back')
    l(ni)

    %
    newcat = newt2;                   % resets newcat and newt2

    % Call program "timeplot to plot cumulative number
    %
    clear l s is
    bdiff(newt2)

end % if ic == 2

if ic == 3 % select  events within ra

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
        set(mark1,'MarkerSize',5,'LineWidth',1.5)
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
    ll = l;               %  Algorithm to select points inside a closed
    %  polygon based on Analytic Geometry    R.Z. 4/94
    for i = 1:m

        l= ((y(i)-YI < 0) & (y(i+1)-YI >= 0)) & ...
            (XI-x(i)-(YI-y(i))*(x(i+1)-x(i))/(y(i+1)-y(i)) < 0) | ...
            ((y(i)-YI >= 0) & (y(i+1)-YI < 0)) & ...
            (XI-x(i)-(YI-y(i))*(x(i+1)-x(i))/(y(i+1)-y(i)) < 0);

        if i ~= 1
            ll(l) = 1 - ll(l);
        else
            ll = l;
        end         % if i

    end         %  for

    %plot the selected eqs and mag freq curve
    newa2 = newa(ll,:);
    newt2 = newa2;
    newcat = newa(ll,:);
    pl = plot(newa2(:,length(newa2(1,:))),-newa2(:,7),'xk');
    set(pl,'MarkerSize',5,'LineWidth',1)
    bdiff(newa2)

end % if ic == 3
