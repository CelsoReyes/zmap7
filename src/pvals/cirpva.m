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
    disp(' ');
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

if met == 'ni'
    % take first ni and sort by time
    [mask, max_rad] = closestEvents(ZG.a, ya0, xa0, ni);
    ZG.newt2 = ZG.a.subset(mask);
    messtext = ['Radius of selected Circle:' num2str(maxrad)  ' km' ];
    disp(messtext)
    zmap_message_center.set_message('Message',messtext)
elseif  met == 'ra'
    mask = eventsInRadius(ZG.a, ya0, xa0, ra);
    ZG.newt2 = ZG.a.subset(mask);
    messtext = ['Number of selected events: ' num2str(ZG.newt2.Count())  ];
    disp(messtext)
    zmap_message_center.set_message('Message',messtext)
elseif met == 'ti'
    global t1 t2 t3 t4
    ZG.newt2 = ZG.a;
    lt =  ZG.newt2.Date >= t1 &  ZG.newt2.Date <t2 ;
    bdiff(ZG.newt2.subset(lt));
    ZG.hold_state=true;
    lt =  ZG.newt2.Date >= t3 &  ZG.newt2.Date <t4 ;
    bdiff(ZG.newt2.subset(lt));

end
R2 = ra;

%
% plot Ni clostest events on map as 'x':

hold on
plos1 = plot(ZG.newt2.Longitude,ZG.newt2.Latitude,'xk','EraseMode','normal');

% plot circle containing events as circle
x = -pi-0.1:0.1:pi;
pl = plot(xa0+sin(x)*R2/(cosd(ya0)*111), ya0+cos(x)*R2/(cosd(ya0)*111),'k','era','normal')


set(gcf,'Pointer','arrow')

%
newcat = ZG.newt2;                   % resets ZG.newcat and ZG.newt2

% Call program "timeplot to plot cumulative number
%
%bdiff(ZG.newt2)
timeplot(ZG.newt2)
pvalcat
