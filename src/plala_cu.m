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
         'Callback','close,plala_cu')



    tre2 = max(abo(:,4)) - 0.5;
    new = uicontrol('style','edit','value',iwl2,...
        'string',num2str(tre2,3), 'background','y',...
        'Callback','tre2=str2num(get(new,''String''));''String'',num2str(tre2,3);',...
        'units','norm','pos',[.80 .01 .08 .06],'min',2.65,'max',10);

    newlabel = uicontrol('style','text','units','norm','pos',[.40 .00 .40 .08]);
    set(newlabel,'string','Alarm Threshold:','background',[c1 c2 c3]);

    mamo1 = uicontrol('Units','normal',...
        'Position',[.90 .01 .08 .06],'String','Go',...
         'Callback','abo = abo2;plala_cu ');

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
         'Callback','think;pause(1); plala_cu')

    op3 = uimenu('Label','Tools');
    uimenu(op3,'Label','Find Anomalie Groups  ',...
        'Callback','agroupc,cian');
    uimenu(op3,'Label','Display one Anomalie Group ',...
        'Callback','cian2');
    uimenu(op3,'Label','Determine Valarm/Vtotal(Zalarm) ',...
        'Callback','sucrac');
    uimenu(op3,'Label','Determine # Alarmgroups (Zalarm) ',...
        'Callback','agzc');



end   % if exist newCube

report_this_filefun(mfilename('fullpath'));

figure_w_normalized_uicontrolunits(cube)
delete(gca)
abo = abo2;
if isempty(abo)
    welcome(' ','No data above threshold');
    return;
end
rect= [0.2 0.2 0.6 0.6];
axes('pos',rect)
set(gca,'visible','off')
abo = abo2;
abo(:,5) = abo(:,5)* par1/365 + a(1,3);
l = abo(:,4) > tre2;
abo = abo(l,:);
if length(abo)  < 1  
    errordlg('No alarms with z >= Zmin detected!');
    return;
end
l = abo(:,3) < tresh;
abo = abo(l,:);
if length(abo)  < 1  ; errordlg('No alarms with z >= Zmin detected!');
    return;
end
hold on

if isempty(abo) == 0
    figure_w_normalized_uicontrolunits(map)
    mainmap_overview()
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
%end

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
if term == 1
    whitebg;
    whitebg;
end
watchoff
done;
figure_w_normalized_uicontrolunits(cube)

rotate3d on
