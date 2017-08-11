%   "circle0"  selects events by :
%   the Ni closest earthquakes to the center
%   the maximum radius of a circle.
%   the center point can be interactively selected or fixed by given
%   coordinates (as given by incircle).
%   Resets ZG.newcat and ZG.newt2.     Operates on the map window on  "a".
%                                                  R.Z. 6/94
%

report_this_filefun(mfilename('fullpath'));

if exist('plos1','var')
    clear plos1
end
new = a;
figure_w_normalized_uicontrolunits(mess)
clf
set(gca,'visible','off')

if ic == 1 | ic == 0
    te = text(0.01,0.90,'\newlinePlease use the LEFT mouse button or the cursor to \newlineselect the center point. The coordinates of the center \newlinewill be displayed on the control window.\newline \newlineOperates on the main subset of the catalogue. \newlineEvents selected form the new subset to operate on (ZG.newcat).');
    set(te,'FontSize',12);

    % Input center of circle with mouse
    %
    axes(h1)

    [xa0,ya0]  = ginput(1);

    stri1 = [ 'Circle: ' num2str(xa0,6) '; ' num2str(ya0,6)];
    stri = stri1;
    pause(0.1)
    set(gcf,'Pointer','arrow')
    plot(xa0,ya0,'+c','EraseMode','back');
    incircle


elseif ic == 2
    figure_w_normalized_uicontrolunits(map)
    axes(h1)
    
    [mask, furthest_event_km] = eventsInRadius(ZG.a, ya0, xa0, rad);
    ZG.newt2 = ZG.a.subset(mask);
    %
    % plot events on map as 'x':

    hold on
    plos1 = plot(ZG.newt2.Longitude,ZG.newt2.Latitude,'xk','EraseMode','back');
    set(gcf,'Pointer','arrow')


    % Call program "timeplot to plot cumulative number
    %
    stri1 = [ 'Circle: ' num2str(xa0,6) '; ' num2str(ya0,6) '; R = ' num2str(rad) ' km'];
    stri = stri1;
    ZG.newt2.sort('Date');
    ZG.newcat = ZG.newt2;                   % resets ZG.newcat and ZG.newt2
    timeplot(ZG.newt2);

    ic = 1;

elseif ic == 3
    figure_w_normalized_uicontrolunits(map)
    axes(h1)
    %  calculate distance for each earthquake from center poin
    [mask, max_km] = closestEvents(ZG.a, ya0, xa0, ni);
    messtext = ['Radius of selected Circle: ' num2str(max_km)  ' km' ];
    disp(messtext)


    newt = ZG.a.subset(mask);          % take first ni and sort by time
    ZG.newt2.sort('Date')
    %
    % plot events on map as 'x':

    hold on
    plos1 = plot(ZG.newt2.Longitude,ZG.newt2.Latitude,'xk','EraseMode','back');
    set(gcf,'Pointer','arrow')

    ZG.newcat = ZG.newt2;                   % resets ZG.newcat

    % Call program "timeplot to plot cumulative number
    %
    stri1 = [ 'Circle: ' num2str(xa0,6) '; ' num2str(ya0,6)];
    stri = stri1;
    timeplot(ZG.newt2);

    ic = 1;

end      % if ic

