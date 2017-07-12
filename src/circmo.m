%   This subroutine "circle"  selects the Ni closest earthquakes
%   around a interactively selected point.  Resets ZG.newcat and ZG.newt2
%   Operates on "a".

%  Input Ni:
%
report_this_filefun(mfilename('fullpath'));
ZG=ZmapGlobal.Data;
try
    delete(plos1)
catch ME
    error_handler(ME,@do_nothing);
end


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
axes(hmo)
[xa0,ya0]  = ginput(1);

stri1 = [ 'Circle: ' num2str(xa0,5) '; ' num2str(ya0,4)];
stri = stri1;
pause(0.1)
%  calculate distance for each earthquake from center point
%  and sort by distance
%
l = sqrt(((ZG.a.Longitude-xa0)*cosd(ya0)*111).^2 + ((ZG.a.Latitude-ya0)*111).^2) ;
[s,is] = sort(l);
ZG.newt2 = a(is(:,1),:) ;

l =  sort(l);
messtext = ['Radius of selected Circle: ' num2str(l(ni))  ' km' ];
disp(messtext)
zmap_message_center.set_message('Message',messtext)
%
% take first ni and sort by time
%
ZG.newt2 = ZG.newt2(1:ni,:);
[st,ist] = sort(ZG.newt2);
ZG.newt2 = ZG.newt2(ist(:,3),:);
%
% plot Ni clostest events on map as 'x':

hold on
plos1 = plot(ZG.newt2.Longitude,ZG.newt2.Latitude,'xk','EraseMode','normal');
set(gcf,'Pointer','arrow')

% plot circle containing events as circle
x = -pi-0.1:0.1:pi;
%plot(xa0+sin(x)*l(ni)/(cosd(ya0)*111), ya0+cos(x)*l(ni)/(cosd(ya0)*111),'k','era','normal')

%
newcat = ZG.newt2;                   % resets ZG.newcat and ZG.newt2

% Call program "timeplot to plot cumulative number
%
clear l s is
timeplot(ZG.newt2);
