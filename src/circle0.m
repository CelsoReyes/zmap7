%   "circle0"  selects events by :
%   the Ni closest earthquakes to the center
%   the maximum radius of a circle.
%   the center point can be interactively selected or fixed by given
%   coordinates (as given by incircle).
%   Resets ZG.newcat and ZG.newt2.     Operates on the map window on  "a".
%                                                  R.Z. 6/94
% last change 8/95

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
    %  calculate distance for each earthquake from center point
    %  and sort by distance
    %
    ll = sqrt(((ZG.a.Longitude-xa0)*cosd(ya0)*111).^2 + ((ZG.a.Latitude-ya0)*111).^2) ;

    l = ll < rad;
    ZG.newt2 = ZG.a.subset(l);
    %
    % plot events on map as 'x':

    hold on
    plos1 = plot(ZG.newt2.Longitude,ZG.newt2.Latitude,'xk','EraseMode','back');
    set(gcf,'Pointer','arrow')


    % Call program "timeplot to plot cumulative number
    %
    stri1 = [ 'Circle: ' num2str(xa0,6) '; ' num2str(ya0,6) '; R = ' num2str(rad) ' km'];
    stri = stri1;

    [s,is] = sort(ZG.newt2.Date);
    ZG.newt2 = ZG.newt2(is(:,1),:) ;
    ZG.newcat = ZG.newt2;                   % resets ZG.newcat and ZG.newt2
    timeplot

    ic = 1;

elseif ic == 3
    figure_w_normalized_uicontrolunits(map)
    axes(h1)
    %  calculate distance for each earthquake from center point
    %  and sort by distance
    %
    l = sqrt(((ZG.a.Longitude-xa0)*cosd(ya0)*111).^2 + ((ZG.a.Latitude-ya0)*111).^2) ;

    [s,is] = sort(l);            % sort by distance
    new = a(is(:,1),:) ;
    l =  sort(l);
    messtext = ['Radius of selected Circle: ' num2str(l(ni))  ' km' ];
    disp(messtext)


    newt = new(1:ni,:);          % take first ni and sort by time
    [st,ist] = sort(newt);
    ZG.newt2 = newt(ist(:,6),:);
    %
    % plot events on map as 'x':

    hold on
    plos1 = plot(ZG.newt2.Longitude,ZG.newt2.Latitude,'xk','EraseMode','back');
    set(gcf,'Pointer','arrow')

    ZG.newcat = ZG.newt2;                   % resets ZG.newcat and ZG.newt2

    % Call program "timeplot to plot cumulative number
    %
    stri1 = [ 'Circle: ' num2str(xa0,6) '; ' num2str(ya0,6)];
    stri = stri1;
    timeplot

    ic = 1;

end      % if ic

