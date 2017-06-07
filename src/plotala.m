% ZMAP script show_map.m. Creates Dialog boxes for Z-map calculation
% does the calculation and makes displays the map
% stefan wiemer 11/94
%
% make dialog interface and call maxzlta
%
% This is the info window text
%

report_this_filefun(mfilename('fullpath'));

doexist
watchon
think
ttlStr='The Alarm Cube Window                                ';
hlpStr1= ...
    ['  To be implemented                             '
    ' corners with the mouse                         '];
% Find out of figure already exists
watchon
if exist('iala')  == 0 ; iala = iwl2; end
if exist('abo2')  == 0 ; errordlg('No alarms with z >= Zmin detected!');return; end
if isempty(abo2)  == 1 ; errordlg('No alarms with z >= Zmin detected!');return; end

abo = abo2;


[existFlag,figNumber]=figure_exists('Alarm Display',1);
newCubeWindowFlag=~existFlag;

% Set up the Seismicity Map window Enviroment
%
if newCubeWindowFlag
    cube = figure_w_normalized_uicontrolunits( ...
        'Name','Alarm Display',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'Visible','off', ...
        'Position',[  200 200 400 600]);

    matdraw
    ter2 = 7.5;
    tresh = max(loc(:,3));
    

    uicontrol('Units','normal',...
        'Position',[.0 .65 .12 .06],'String','Refresh ',...
         'Callback','close,plotala')



    tre2 = max(abo(:,4)) - 0.5;
    new = uicontrol('style','edit','value',iwl2,...
        'string',num2str(tre2,3), 'background','y',...
        'Callback','tre2=str2num(get(new,''String''));''String'',num2str(tre2,3);',...
        'units','norm','pos',[.80 .01 .08 .06],'min',2.65,'max',10);

    newlabel = uicontrol('style','text','units','norm','pos',[.40 .00 .40 .08]);
    set(newlabel,'string','Alarm Threshold:','background',[c1 c2 c3]);

    mamo1 = uicontrol('Units','normal',...
        'Position',[.90 .01 .08 .06],'String','Go',...
         'Callback','abo = abo2;plotala ');

    mamo = uicontrol('Units','normal',...
        'Position',[.02 .01 .27 .10],'String','Make Movie',...
         'Callback','delete(mamo);delete(mamo1); delete(newlabel); mamovie ')

    nilabel2 = uicontrol('style','text','units','norm','pos',[.50 .92 .25 .06]);
    set(nilabel2,'string','MinRad (in km):','background',[c1 c2 c3]);
    set_ni2 = uicontrol('style','edit','value',tresh,'string',num2str(tresh,3),...
        'background','y');
    set(set_ni2,'Callback','tresh=str2double(get(set_ni2,''String'')); set(set_ni2,''String'',num2str(tresh,3))');
    set(set_ni2,'units','norm','pos',[.80 .92 .13 .06],'min',0.01,'max',10000);


    uicontrol('Units','normal',...
        'Position',[.93 .93 .07 .05],'String','Go ',...
         'Callback','think;pause(1); plotala')

    op3 = uimenu('Label','Tools');
    uimenu(op3,'Label','Find Anomalie Groups  ',...
        'Callback','agroup,cian');
    uimenu(op3,'Label','Display one Anomalie Group ',...
        'Callback','cian2');
    uimenu(op3,'Label','Determine Valarm/Vtotal(Zalarm) ',...
        'Callback','sucra');
    uimenu(op3,'Label','Determine # Alarmgroups (Zalarm) ',...
        'Callback','agz');



end   % if exist newCube

report_this_filefun(mfilename('fullpath'));

figure_w_normalized_uicontrolunits(cube)
delete(gca)
abo = abo2;
if isempty(abo);welcome(' ','No data above threshold'); return; end
rect= [0.2 0.2 0.6 0.6];
axes('pos',rect)
set(gca,'visible','off')
abo = abo2;
abo(:,5) = abo(:,5)* par1/365 + a(1,3);
l = abo(:,4) > tre2;
abo = abo(l,:);
if length(abo)  < 1  ; errordlg('No alarms with z >= Zmin detected!');return; end
l = abo(:,3) < tresh;
abo = abo(l,:);
if length(abo)  < 1  ; errordlg('No alarms with z >= Zmin detected!');return; end
hold on

if isempty(abo) == 0
    figure_w_normalized_uicontrolunits(map)
    subcata
    plot(abo(:,1),abo(:,2),'o',...
        'MarkerFaceColor','r','MarkerEdgeColor','y');

    figure_w_normalized_uicontrolunits(cube)
    plo  = plot3(abo(:,1),abo(:,2),abo(:,5),'ro');
    set(plo,'MarkerSize',6,'LineWidth',1.0)
    for i = 1:length(abo(:,1))
        li = [abo(i,1) abo(i,2) abo(i,5) ; abo(i,1) abo(i,2) abo(i,5)+iala];
        plot3(li(:,1),li(:,2),li(:,3),'b');
    end
end
view(3);

grid
hold on

if isempty(coastline) == 0
    l = coastline(:,1) < s1  & coastline(:,1) > s2 & coastline(:,2) < s3 & coastline(:,2) > s4| coastline(:,1) == inf | coastline(: ,1) == -inf;
    pl1 =plot3(coastline(l,1),coastline(l,2),ones(length(coastline(l,:)),1)*t0b,'k');
    pl1 =plot3(coastline(l,1),coastline(l,2),ones(length(coastline(l,:)),1)*teb,'k');
end
if isempty(faults) == 0
    l = faults(:,1) < s1  & faults(:,1) > s2 & faults(:,2) < s3 & faults(:,2) > s4| faults(:,1) == inf;
    pl1 =plot3(faults(l,1),faults(l,2),ones(length(faults(l,:)),1)*t0b,'k');
    pl4 =plot3(faults(l,1),faults(l,2),ones(length(faults(l,:)),1)*teb,'k');
end
if isempty(mainfault) ==0
    pl2 = plot3(mainfault(:,1),mainfault(:,2),ones(length(mainfault),1)*t0b,'m');
    pl2b =plot3(mainfault(:,1),mainfault(:,2),ones(length(mainfault),1)*teb,'m');
    set(pl2,'LineWidth',3.0)
    set(pl2b,'LineWidth',3.0)
end
if isempty(main) == 0
    pl3 =plot3(main(:,1),main(:,2),ones(length(main)-1,1)*teb,'xk');
    pl3b =plot3(main(:,1),main(:,2),ones(length(main)-1,1)*t0b,'xk');
    set(pl3,'LineWidth',3.0)
    set(pl3b,'LineWidth',3.0)
end
% end

if isempty(maepi) ==0
    pl8 =plot3(maepi(:,1),maepi(:,2),maepi(:,3),'*k');
    set(pl8,'LineWidth',2.0,'MarkerSize',10)
end

axis([ s2-0.1 s1+0.1 s4-0.1 s3+0.1 t0b teb+1  ])
strib4 = [  ' Alarm Cube of '  name '; wl =  '  num2str(iwl2,3) '; Zcut = ' num2str(tre2,3)  ];
title2(strib4,'FontWeight','bold',...
    'FontSize',fontsz.m,'Color','k')


set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',2.0,'visible','on')
%set(gca,'Color',[0.7 0.7 0.7])

viewer
watchoff
vie = gcf;
figure_w_normalized_uicontrolunits(cube)
if term == 1; whitebg; whitebg;end
watchoff
done;
figure_w_normalized_uicontrolunits(cube)

rotate3d
