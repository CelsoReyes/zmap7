report_this_filefun(mfilename('fullpath'));

bv2 = [];
bv3 = [] ;
me = [];
def = {'150'};
ni2 = inputdlg('Number of events in each window?','Input',1,def);
l = ni2{:};
ni = str2double(l);

think

for i = 1:ni/10:length(newt2)-ni
    % [bv magco,  stan] =  bvalcalc(newt2(i:i+ni,:));
    [bv magco stan ] =  bvalca2(newt2(i:i+ni,:));

    bv2 = [bv2 ; magco newt2(i,3)];
end

% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Mc with time',1);
newdepWindowFlag=~existFlag;
bdep= figNumber;

% Set up the window

if newdepWindowFlag
    Mcfig = figure_w_normalized_uicontrolunits( ...
        'Name','Mc with time',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','replace', ...
        'backingstore','on',...
        'Visible','on');

    
    uicontrol('Units','normal',...
        'Position',[.0 .85 .08 .06],'String','Info ',...
         'Callback','infoz(1)');
    matdraw
end

hold on
figure_w_normalized_uicontrolunits(Mcfig)
hold on
delete(gca)
delete(gca)
axis off

rect = [0.15 0.30 0.7 0.45];
axes('position',rect)
pl = plot(bv2(:,2),bv2(:,1),'^r');
set(pl,'LineWidth',1.5,'MarkerSize',10,...
    'MarkerFaceColor','y','MarkerEdgeColor','r')
hold on
pl = plot(bv2(:,2),bv2(:,1),'b')
set(pl,'LineWidth',1.0)

grid
set(gca,'Color',[cb1 cb2 cb3])
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.2)
%
ylabel('Mc')
%set(gca,'Xlim',[t0b teb]);

xlabel('Time')
tist = [  name ' - b(t), ni = ' num2str(ni) ];
title(tist)
done

nu = [];
for i = 1:length(bv2)
    l = newt2(:,3) >= bv2(i,2) &  newt2(:,6) >= bv2(i,1);
    nu = [nu length(newt2(l,1))];
end

figure
plot(bv2(:,2),nu,'o')
hold on
plot(bv2(:,2),nu)



figure
plot(bv2(:,1),nu,'o')
hold on
plot(bv2(:,1),nu)


