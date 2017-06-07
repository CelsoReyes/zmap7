% Script: symbol_faultingtype.m
% Plot eqs according to faulting style using rake as discriminator
% -180 <= Rake <= 180
% This is an approximation!
% last update: J. Woessner, jowoe@gps.caltech.edu
report_this_filefun(mfilename('fullpath'));

% Load colormap
load rakec.mat
c = rakec;

% Loop over events
for i = 1:length(a)
    pl =plot(a(i,1),a(i,2),'ow');
    hold on
    fac = 64/max(a(:,12));
    col = floor(a(i,12)+180/360*63);
    col = ceil(abs(a(i,12)*fac))+1;
    if col > 63; col = 63; end ;
    if col < 1; col = 1 ; end
    set(pl,'Markersize',6,'markerfacecolor',[c(col,:)],'markeredgecolor','k');
end
h1 = gca;
drawnow
watchon;

% make a faulting style legend
vx =  (-180:1:180);
v = [vx ; vx]; v = v';
rect = [0.86 0.22 0.02 0.4];
axes('position',rect)
pcolor((1:2),vx,v)
shading flat
set(gca,'XTickLabels',[],'Ytick',[-180 -90 0 90 180])
set(gca,'FontSize',8,'FontWeight','normal',...
    'LineWidth',1.0,'YAxisLocation','right',...
    'Box','on','SortMethod','childorder','TickDir','out')
xlabel('   Rake ');
colormap(rakec)
axes(h1)
set(h1,'pos',[0.12 0.2 0.65 0.6])
watchoff;
%typele = 'dep';


axes('pos',[0 0 1 1 ]);
axis off

text(0.92,0.22,'right lat.','FontSize',8);
text(0.92,0.34,'normal','FontSize',8);
text(0.92,0.42,'left lat.','FontSize',8);
text(0.92,0.5,'thrust','FontSize',8);
text(0.92,0.62,'right lat.','FontSize',8);
axes(h1)

