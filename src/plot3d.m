% ZMAP script show_map.m. Creates Dialog boxes for Z-map calculation
% does the calculation and makes displays the map
% stefan wiemer 11/94
%
% make dialog interface and call maxzlta
%
% This is the info window text
%

report_this_filefun(mfilename('fullpath'));

watchon
think
ttlStr='3 D seismicity view                                  ';
hlpStr1= ...
    [' This plot is a 3 dimensional view of the seismicity '
    ' currently selected in the map window. Use the Viewer'
    ' to change the angle of perspective. To change the   '
    ' legend, recreate the plot with the desired legend   '
    ' legend as a function of depth/time) in the map      '
    ' window and recreate the 3D view.                    '];

% Find out of figure already exists
watchon


[existFlag,figNumber]=figure_exists('3 D View',1);
newmap3WindowFlag=~existFlag;

% Set up the Seismicity Map 3 D window Enviroment
%
if newmap3WindowFlag
    map3 = figure_w_normalized_uicontrolunits( ...
        'Name','3 D View',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'Visible','off', ...
        'Position',[  200 200 400 600]);

    matdraw

    uicontrol('Units','normal',...
        'Position',[.0 .93 .10 .06],'String','Print ',...
         'Callback','myprint')

    uicontrol('Units','normal',...
        'Position',[.2 .93 .10 .06],'String','Close ',...
         'Callback','close(map3); close(vie);welcome')

    uicontrol('Units','normal',...
        'Position',[.4 .93 .10 .06],'String','Info ',...
         'Callback','zmaphelp(ttlStr,hlpStr1)')

    uicontrol('Units','normal',...
        'Position',[.6 .93 .20 .06],'String','3D-Rotate',...
         'Callback','rotate3d')

end   % if exist newmap3


report_this_filefun(mfilename('fullpath'));

figure_w_normalized_uicontrolunits(map3)
delete(gca)
rect= [0.2 0.2 0.6 0.6];
axes('pos',rect)
set(gca,'visible','off')
hold on

% plot earthquakes according to depth
if typele == 'dep'
    depidx = a.Depth<=dep1;
    plo  = plot3(a.Longitude(depidx),a.Latitude(depidx),...
        -a.Depth(depidx),'xb');
    set(plo,'MarkerSize',6,'LineWidth',1.)
    depidx = a.Depth<=dep2&a.Depth>dep1;
    plo  = plot3(a.Longitude(depidx),a.Latitude(depidx),...
        -a.Depth(depidx),'xg');
    set(plo,'MarkerSize',3,'LineWidth',1.)
    depidx = a.Depth<=dep3&a.Depth>dep2;
    plo  = plot3(a.Longitude(depidx),a.Latitude(depidx),...
        -a.Depth(depidx),'xr');
    set(plo,'MarkerSize',6,'LineWidth',1.)

    % Plot a legend as a function of depth
    ls1 = sprintf('Depth < %3.1f km',dep1);
    ls2 = sprintf('Depth < %3.1f km',dep2);
    ls3 = sprintf('Depth < %3.1f km',dep3);
end % if ty == dep


%plot earthquakes according time
if typele == 'tim'
    timidx = a.Date<=tim2&a.Date>=tim1;
    plo =plot3(a.Longitude(timidx),a.Latitude(timidx),-a.Depth(timidx),'+b');
    set(plo,'MarkerSize',6,'LineWidth',1.)
    timidx = a.Date<=tim3&a.Date>tim2;
    plo =plot3(a.Longitude(timidx),a.Latitude(timidx),-a.Depth(timidx),'og');
    set(plo,'MarkerSize',6,'LineWidth',1.)
    timidx = a.Date<=tim4&a.Date>tim3;
    plo =plot3(a.Longitude(timidx),a.Latitude(timidx),-a.Depth(timidx),'xr');
    set(plo,'MarkerSize',6,'LineWidth',1.)

    ls1 = sprintf('%3.1f < t < %3.1f ',tim1,tim2);
    ls2 = sprintf('%3.1f < t < %3.1f ',tim2,tim3);
    ls3 = sprintf('%3.1f < t < %3.1f ',tim3,tim4);

end



%le =legend([,ls1,'og',ls2,'xr',ls3);
%set(le,'position',[ 0.65 0.02 0.32 0.12])


view(3);

grid
hold on

%if isempty(coastline) == 0
%l = coastline(:,1) < s1  & coastline(:,1) > s2 & coastline(:,2) < s3 & coastline(:,2) > s4| coastline(:,1) == inf;
%pl1 =plot3(coastline(l,1),coastline(l,2),ones(length(coastline(l,:)),1)*0,'k');
%end
if isempty(faults) == 0
    l = faults(:,1) < s1  & faults(:,1) > s2 & faults(:,2) < s3 & faults(:,2) > s4| faults(:,1) == inf;
    pl1 =plot3(faults(l,1),faults(l,2),ones(length(faults(l,:)),1)*0,'k');
end
if isempty(mainfault) ==0
    pl2 =plot3(mainfault(:,1),mainfault(:,2),ones(length(mainfault(:,1)),1)*0,'m');
    pl2b =plot3(mainfault(:,1),mainfault(:,2),ones(length(mainfault(:,1)),1)*0,'m');
    set(pl2,'LineWidth',3.0)
    set(pl2b,'LineWidth',3.0)
end
if isempty(main) ==0
    pl3 =plot3(main(:,1),main(:,2),ones(length(main(:,1)),1)*0,'xk');
    pl3b =plot3(main(:,1),main(:,2),ones(length(main(:,1)),1)*0,'xk');
    set(pl3,'LineWidth',3.0)
    set(pl3b,'LineWidth',3.0)
end

axis([ min(a.Longitude) max(a.Longitude) min(a.Latitude) max(a.Latitude) min(-a.Depth) max(-a.Depth)  ])
orient tall

set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'normal','FontSize',fontsz.s,'Linewidth',1.0,'visible','on')

if term > 1;set(gca,'Color',[0 0 0]);end
whitebg(gcf,[0 0 0]);
watchoff(map3)

watchoff
vie = gcf;
figure_w_normalized_uicontrolunits(map3)
watchoff
done;
