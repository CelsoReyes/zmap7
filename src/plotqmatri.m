report_this_filefun(mfilename('fullpath'));



figure
axes('pos',[0.2 0.15 0.6 0.7])

M2 = M;
l = M2 > 0.01;
M2(l) = nan;
l = M2 < 10^-5;
M2(l) = 10^-5;


pcolor(Tw,R, log10(M2))

set(gca,'visible','on','FontSize',12,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')

[i,j] = find(M == min(min((M))));
hold on
plot(Tw(j),R(i),'+w','Markersize',10,'Linewidth',2)

xlabel('Tw [years]');
ylabel('Radius [km]');

str = ['Mainshock: ' num2str(an(:,3),6) '; M = ' num2str(an(:,6)) ];
title(str);


shading interp
caxis([-7 0]);
j = jet(64);
j = j(64:-1:1,:);
%j(34:55,:)  = j(34:55,:)*0 + 0.8 ;
colormap(j)
ax1= gca;

[mic, mac] = caxis;
vx =  (mic:0.1:mac);
v = [vx ; vx]; v = v';
rect = [0.85 0.15 0.015 0.25];
axes('position',rect)
pcolor((1:2),vx,v)
shading interp
set(gca,'XTickLabels',[])
set(gca,'FontSize',12,'FontWeight','bold',...
    'LineWidth',1.0,'YAxisLocation','right',...
    'Box','on','SortMethod','childorder','TickDir','out')
ax3 = gca;
clim = caxis;

M2 = 1-M;
l = M2 > 0.01;
M2(l) = nan;
l = M2 < 10^-7;
M2(l) = 10^-7;


axes('pos',[0.2 0.15 0.7 0.7]); axis off

pcolor(Tw,R, log10(M2)); axis off

set(gca,'visible','on','FontSize',14,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')

[i,j] = find(M == max(max((M))));
hold on
plot(Tw(j),R(i),'ko','Markersize',10,'Linewidth',2)

xlabel('Tw [years]');
ylabel('Radius [km]');
shading interp
caxis([-7 0]);
j = jet(64);
j = j(64:-1:1,:);
%j(34:55,:)  = j(34:55,:)*0 + 0.8 ; colormap(j)
axis off
ax2 = gca;

[mic, mac] = caxis;
vx =  (mic:0.1:mac);
v = [vx ; vx]; v = v';
rect = [0.85 0.5 0.015 0.25];
axes('position',rect)
pcolor((1:2),vx,v)
shading interp
set(gca,'XTickLabels',[])
set(gca,'FontSize',12,'FontWeight','bold',...
    'LineWidth',1.0,'YAxisLocation','right',...
    'Box','on','SortMethod','childorder','TickDir','out')
ax4 = gca;
clim = caxis;

uicontrol('Units','normal',...
    'Position',[.0 .88 .08 .06],'String','getP',...
     'Callback','getqmatri')


clim2 = caxis;

co = [gray(64) ; j ];
colormap(co)

set(ax1,'CLim',newclim(65,128,clim(1),clim(2),128))
set(ax2,'CLim',newclim(2,64,clim(1),clim(2),128))
set(ax3,'CLim',newclim(65,128,clim(1),clim(2),128))

set(ax4,'CLim',newclim(2,64,clim(1),clim(2),128))


