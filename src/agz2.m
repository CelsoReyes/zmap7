% This script evaluates the percentage of space time coevered by
%alarms
%
re = [];

% Stefan Wiemer    4/95

report_this_filefun(mfilename('fullpath'));

global abo;
abo = abo2;

for tre2 = min(abo(:,4))+1.5:0.2:max(abo(:,4)-0.1)
    tre2
    abo = abo2;
    abo(:,5) = abo(:,5)* par1/365 + a(1,3);
    l = abo(:,4) >= tre2;
    abo = abo(l,:);
    l = abo(:,3) < tresh;
    abo = abo(l,:);
    size(abo)
    hold on

    j = 0;
    tmp = abo;

    while length(abo) > 1
        j = j+1;
        global iala
        [k,m] = findnei(1);
        po = [k];
        for i = 1:length(k)
            [k2,m2]  = findnei(k(i));
            po = [po ; k2];
            po = sort(po);
            po2 = [0;  po(1:length(po)-1)] ;
            l = find(po-po2 > 0) ;
            po = [po(l) ] ;
        end
        do = ['an' num2str(j) ' = abo(po3,:);'];
        disp([num2str(j) '  Anomalie groups  found'])
        eval(do)
        abo(po3,:) =[];
    end   % while j


    re = [re ; tre2 j ];
end   % for tre2


figure

matdraw
axis off

uicontrol('Units','normal',...
    'Position',[.0 .65 .08 .06],'String','Save ',...
     'Callback',{@calSave9, re(:,1), re(:,2)})

rect = [0.20,  0.10, 0.70, 0.60];
axes('position',rect)
hold on
pl = plot(re(:,1),re(:,2),'r');
set(pl,'LineWidth',1.5)
pl = plot(re(:,1),re(:,2),'ob');
set(pl,'LineWidth',1.5,'MarkerSize',10)

set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on')
grid

ylabel('Number of Alarm Groups')
xlabel('Zalarm ')
watchoff

