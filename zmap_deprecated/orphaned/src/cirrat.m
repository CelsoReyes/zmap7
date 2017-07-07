%   This subroutine "circle"  selects the Ni closest earthquakes
%   around a interactively selected point.  Resets newcat and newt2
%   Operates on "a".

%  Input Ni:
%
report_this_filefun(mfilename('fullpath'));

try
    delete(plos1)
catch ME
    error_handler(ME,@do_nothing);
end


axes(h1)
%zoom off

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

stri1 = [ 'Circle: ' num2str(xa0,5) '; ' num2str(ya0,4)];
stri = stri1;
pause(0.1)
%  calculate distance for each earthquake from center point
%  and sort by distance
%
l = sqrt(((a.Longitude-xa0)*cos(pi/180*ya0)*111).^2 + ((a.Latitude-ya0)*111).^2) ;
[s,is] = sort(l);
newt2 = a(is(:,1),:) ;

l =  sort(l);

l3 = l <=ra;
newt2 = newt2(l3,:);
R2 = l(ni);

[st,ist] = sort(newt2);
newt2 = newt2(ist(:,3),:);
R2 = ra;

%
% plot Ni clostest events on map as 'x':

hold on
plos1 = plot(newt2.Longitude,newt2.Latitude,'xk','EraseMode','normal');

% plot circle containing events as circle
x = -pi-0.1:0.1:pi;
plot(xa0+sin(x)*R2/(cos(pi/180*ya0)*111), ya0+cos(x)*R2/(cos(pi/180*ya0)*111),'k','era','normal')
%plot(xa0+sin(x)*l(ni)/111, ya0+cos(x)*l(ni)/111,'k','era','normal')


set(gcf,'Pointer','arrow')

%
newt3 = newt2;                   % resets newcat and newt2

%
clear l s is

ho=true

l = sqrt(((fa(:,1)-xa0)*cos(pi/180*ya0)*111).^2 + ((fa(:,2)-ya0)*111).^2) ;
[s,is] = sort(l);
newt2 = fa(is(:,1),:) ;

l =  sort(l);

l3 = l <=ra;
newt2 = newt2(l3,:);
R2 = l(ni);

[st,ist] = sort(newt2);
newt2 = newt2(ist(:,3),:);
R2 = ra;

%
% plot Ni clostest events on map as 'x':

hold on
plos1 = plot(newt2.Longitude,newt2.Latitude,'+y','EraseMode','normal');


set(gcf,'Pointer','arrow')

%
%
clear l s is
timeplot

ho=true

newt2 = newt3;
timeplot

