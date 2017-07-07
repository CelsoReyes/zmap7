%   This subroutine "circle"  selects the Ni closest earthquakes
%   around a interactively selected point.  Resets newcat and newt2
%   Operates on "a".

%  Input Ni:
%

global t1 t2 t3 t4
report_this_filefun(mfilename('fullpath'));
try
    delete(plos1)
catch
    disp(' ');
end


axes(h1)

titStr ='Selecting EQ in Circles                         ';
messtext= ...
    ['                                                '
    '  Please use the LEFT mouse button              '
    ' to select the center point.                    '
    ' The "ni" events nearest to this point          '
    ' will be selected and displayed in the map.     '];

zmap_message_center.set_message(titStr,messtext);

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
    zmap_message_center.set_message('Message',messtext)
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
    plos1 = plot(newt2(:,ma),-newt2.Depth,'xk','EraseMode','back');
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
    zmap_message_center.set_message('Message',messtext)
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
    plos1 = plot(newt2(:,ma),-newt2.Depth,'xk','EraseMode','back');
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


    lt =  newt2.Date >= t1 &  newt2.Date <t2 ;
    bdiff(newt2(lt,:));
    ho=true;
    lt =  newt2.Date >= t3 &  newt2.Date <t4 ;
    bdiff(newt2(lt,:));


end % if ic == 2
