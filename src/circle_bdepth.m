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
%l = sqrt(((a(:,1)-xa0)*111).^2 + ((a(:,2)-ya0)*111).^2) ;
[s,is] = sort(l);
newt2 = a(is(:,1),:) ;


%% Sort by depth so newt2 can be divided into depth ratio zones
[s,is] = sort(newt2(:,7));
adepth = newt2(is(:,1),:);

% find row index of ratio midpoint
for rowc = length(adepth):-1:1
    if adepth(rowc,7) >= bot_zoneb
        botb_index = rowc;
    else
        if adepth(rowc,7) >= bot_zonet
            bott_index = rowc;
        else
            if adepth(rowc,7) >= top_zoneb
                topb_index = rowc;
            else
                if adepth(rowc,7) >= top_zonet
                    topt_index = rowc;
                end
            end
        end
    end
end

top_zone = adepth(topt_index:topb_index,:);
bot_zone = adepth(bott_index:botb_index,:);

l =  sort(l);
messtext = ['Radius of selected Circle: ' num2str(l(ni))  ' km' ];
disp(messtext)
welcome('Message',messtext)
zone = 0;

% perform loop twice =-- first loop is top zone, second loop is bottom zone
for dloop = 1:2
    if dloop == 1
        zone = top_zone;
    elseif dloop == 2
        zone = bot_zone;
    end

    %
    % take first ni and sort by time
    %
    zone = zone(1:ni,:);
    [st,ist] = sort(zone);
    zone = zone(ist(:,3),:);
    %
    % plot Ni clostest events on map as 'x':

    hold on
    plos1 = plot(zone(:,1),zone(:,2),'xk','EraseMode','back');
    %set(gcf,'Pointer','arrow')

    % plot circle containing events as circle
    x = -pi-0.1:0.1:pi;
    %plot(xa0+sin(x)*l(ni)/(cos(pi/180*ya0)*111), ya0+cos(x)*l(ni)/(cos(pi/180*ya0)*111),'k','era','normal')
    %plot(xa0+sin(x)*l(ni)/111, ya0+cos(x)*l(ni)/111,'k','era','normal')

    %
    newcat = zone;                   % resets newcat and newt2??????????????????????

    % Call program "timeplot to plot cumulative number
    %
    clear l s is
    newt2 = zone
    timeplot
end
