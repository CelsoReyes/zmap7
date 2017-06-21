%   This subroutine "circle"  selects the Ni closest earthquakes
%   around a interactively selected point.  Resets newcat and newt2
%   Operates on "a".

%  Input Ni:
%
global dloop

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
%


%% Sort by depth so newt2 can be divided into depth ratio zones
[s,is] = sort(newt2.Depth);
adepth = newt2(is(:,1),:);

if tgl1 == 0   % take point within r
    l3 = l <= ra;
    newt2 = newt2(l3,:);      % new data per grid point (b) is sorted in distanc  (from center point)
    circle_r = num2str(ra);
else
    newt2 = newt2(1:ni,:)
    circle_r = num2str(l(ni));
end

%% newt2 = newt2(1:ni,:);



messtext = ['Radius of selected Circle:' circle_r  ' km' ];
disp(messtext)
zmap_message_center.set_message('Message',messtext)

hold on

plot(newt2.Longitude,newt2.Latitude,'xk');

l = newt2.Depth >= top_zonet & newt2.Depth <  top_zoneb;
top_zone = newt2(l,:);

l = newt2.Depth >= bot_zonet & newt2.Depth <  bot_zoneb;
bot_zone = newt2(l,:);


ho = 'noho' ; dloop = 1;
bdiff_bdepth(top_zone);
ho = 'hold'; dloop = 2;
bdiff_bdepth(bot_zone);

set(gcf,'Pointer','arrow')

%
