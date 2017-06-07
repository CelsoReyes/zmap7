report_this_filefun(mfilename('fullpath'));

bv2 = [];
bv3 = [];
mag = [];
me = [];
av2=[];
def = {'150'};
ni2 = inputdlg('Number of events in each window?','Input',1,def);
l = ni2{:};
ni = str2double(l);
think
[s,is] = sort(newt2(:,7));
newt1 = newt2(is(:,1),:) ;
watchon;

for tt = 1:ni/4:length(newt1)-ni
    % calculate b-value based an weighted LS
    [bv av stan ] =  bvalca2(newt1(tt:tt+ni,:));
    bv2 = [bv2 ; bv newt1(tt,7) ; bv newt1(tt+ni,7) ; inf inf];
    bv3 = [bv3 ; bv newt1(tt+round(ni/2),7) stan ];
    mag = [mag ; av newt1(tt+round(ni/2),7)];

    % calculate b-value based on maximum likelihood
    [av bv stan ] =  bmemag(newt1(tt:tt+ni,:));
    av2 = [av2 ;   av  newt1(t+round(ni/2),7) stan bv];

    % calculate b-value based on maximum likelihood

    %n   = (max(newt1(t:t+ni,6)+0.05) - (min(newt1(t:t+ni,6))-0.05))/0.1;
    %les = (mean(newt1(t:t+ni,6)) - (min(newt1(t:t+ni,6)+0.05)))/0.1;
    %global n les
    %so = fzero('sofu',1.0);
    %bv = log(so)/(-2.3026*0.1);

end

watchoff

% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('b-value with depth',1);
newdepWindowFlag=~existFlag;
bdep= figNumber;

% Set up the Cumulative Number window

if newdepWindowFlag
    bdep = figure_w_normalized_uicontrolunits( ...
        'Name','b-value with depth',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','add', ...
        'backingstore','on',...
        'Visible','on', ...
        'Position',[ 150 150 winx-50 winy-20]);

    
    uicontrol('Units','normal',...
        'Position',[.0 .85 .08 .06],'String','Info ',...
         'Callback','infoz(1)');

    matdraw
end

figure_w_normalized_uicontrolunits(bdep)
delete(gca)
delete(gca)
delete(gca)
delete(gca)
hold off

axis off
hold on
orient tall
%rect = [0.15 0.65 0.7 0.25];
rect = [0.15 0.65 0.7 0.25];
axes('position',rect)
errorbar(bv3(:,2),bv3(:,1),bv3(:,3),bv3(:,3))
hold on
pl = plot(bv2(:,2),bv2(:,1),'b');
set(pl,'LineWidth',0.5)
grid
%set(gca,'Color',[cb1 cb2 cb3])
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.2)

bax = gca;
strib = [name ', ni = ' num2str(ni), ', Mmin = ' num2str(min(newt2(:,6))) ];
set(gca,'XTickLabels',[])
ylabel('b(LS)')
%xlabel('Depth in [km]')
title2(strib,'FontWeight','bold',...
    'FontSize',fontsz.l,...
    'Color','k')

xl = get(gca,'Xlim');

%return

%rect = [0.15 0.40 0.7 0.25];
%axes('position',rect)

%pl = plot(av2(:,2),av2(:,1),'b');
%set(pl,'LineWidth',1.5)
%errorbar(av2(:,2),av2(:,1),av2(:,3))
%hold on


%pl = plot(av2(:,2),av2(:,1)+av2(:,3)/2,'r')
%set(pl,'LineWidth',1.0)
%pl = plot(av2(:,2),av2(:,1)-av2(:,3)/2,'r')
%set(pl,'LineWidth',1.5)
%set(gca,'Xlim',xl)
%grid
%set(gca,'Color',[cb1 cb2 cb3])
%set(gca,'box','on',...
%'SortMethod','childorder','TickDir','out','FontWeight',...
%'bold','FontSize',fontsz.m,'Linewidth',1.2)

% set(gca,'XTickLabels',[])
%ylabel('mean mag')


rect = [0.15 0.40 0.7 0.25];
axes('position',rect)

errorbar(av2(:,2),av2(:,4),av2(:,3))
%set(pl,'LineWidth',1.5)
hold on
grid
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.2)

set(gca,'Xlim',xl)
xlabel('depth')
ylabel('b based on mean')
axes(bax)
done
