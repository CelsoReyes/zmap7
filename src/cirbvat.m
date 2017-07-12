%   This subroutine "circle"  selects the Ni closest earthquakes
%   around a interactively selected point.  Resets ZG.newcat and ZG.newt2
%   Operates on "a".

%  Input Ni:
%
report_this_filefun(mfilename('fullpath'));
ZG=ZmapGlobal.Data;
try
    delete(plos1)
catch
    disp(' ')
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
l = sqrt(((ZG.a.Longitude-xa0)*cosd(ya0)*111).^2 + ((ZG.a.Latitude-ya0)*111).^2) ;
[s,is] = sort(l);
ZG.newt2 = a(is(:,1),:) ;

l =  sort(l);
messtext = ['Radius of selected Circle:' num2str(l(ni))  ' km' ];
disp(messtext)
zmap_message_center.set_message('Message',messtext)
%

l3 = l <=ra;
ZG.newt2 = ZG.newt2(l3,:);
R2 = l(ni);
global t1 t2 t3 t4

lt =  ZG.newt2.Date >= t1 &  ZG.newt2.Date <t2 ;
bdiff(ZG.newt2(lt,:));
ZG.hold_state=true;
lt =  ZG.newt2.Date >= t3 &  ZG.newt2.Date <t4 ;
bdiff(ZG.newt2(lt,:));

% end % <- A random END that either doesn't belong here or is meant to suppress the rest. -CGR
[st,ist] = sort(ZG.newt2);
ZG.newt2 = ZG.newt2(ist(:,3),:);
R2 = ra;

%
% plot Ni clostest events on map as 'x':

figure_w_normalized_uicontrolunits(bmap)
hold on
plos1 = plot(ZG.newt2.Longitude,ZG.newt2.Latitude,'ow','EraseMode','normal','markersize',3);

% plot circle containing events as circle
x = -pi-0.1:0.1:pi;
plot(xa0+sin(x)*R2/(cosd(ya0)*111), ya0+cos(x)*R2/(cosd(ya0)*111),'k','era','normal')
%plot(xa0+sin(x)*l(ni)/111, ya0+cos(x)*l(ni)/111,'w','era','normal')


set(gcf,'Pointer','arrow')

