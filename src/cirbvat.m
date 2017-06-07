%   This subroutine "circle"  selects the Ni closest earthquakes
%   around a interactively selected point.  Resets newcat and newt2
%   Operates on "a".

%  Input Ni:
%
report_this_filefun(mfilename('fullpath'));
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

welcome(titStr,messtext);

% Input center of circle with mouse
%
[xa0,ya0]  = ginput(1);

stri1 = [ 'Circle: ' num2str(xa0,5) '; ' num2str(ya0,4)];
stri = stri1;
pause(0.1)
%  calculate distance for each earthquake from center point
%  and sort by distance
%
l = sqrt(((a(:,1)-xa0)*cos(pi/180*ya0)*111).^2 + ((a(:,2)-ya0)*111).^2) ;
[s,is] = sort(l);
newt2 = a(is(:,1),:) ;

l =  sort(l);
messtext = ['Radius of selected Circle:' num2str(l(ni))  ' km' ];
disp(messtext)
welcome('Message',messtext)
%

l3 = l <=ra;
newt2 = newt2(l3,:);
R2 = l(ni);
global t1 t2 t3 t4

lt =  newt2(:,3) >= t1 &  newt2(:,3) <t2 ;
bdiff(newt2(lt,:));
ho = 'hold';
lt =  newt2(:,3) >= t3 &  newt2(:,3) <t4 ;
bdiff(newt2(lt,:));

% end % <- A random END that either doesn't belong here or is meant to suppress the rest. -CGR
[st,ist] = sort(newt2);
newt2 = newt2(ist(:,3),:);
R2 = ra;

%
% plot Ni clostest events on map as 'x':

figure_w_normalized_uicontrolunits(bmap)
hold on
plos1 = plot(newt2(:,1),newt2(:,2),'ow','EraseMode','normal','markersize',3);

% plot circle containing events as circle
x = -pi-0.1:0.1:pi;
plot(xa0+sin(x)*R2/(cos(pi/180*ya0)*111), ya0+cos(x)*R2/(cos(pi/180*ya0)*111),'k','era','normal')
%plot(xa0+sin(x)*l(ni)/111, ya0+cos(x)*l(ni)/111,'w','era','normal')


set(gcf,'Pointer','arrow')

