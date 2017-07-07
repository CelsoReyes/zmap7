report_this_filefun(mfilename('fullpath'));

figure
rect = [0.15,  0.60, 0.75, 0.35];
axes('position',rect)

pl =plot(bg(:,10),-bg(:,7),'gx');
set(pl,'Linewidth',1.5,'MarkerSize',7)
hold on

pl =plot(aft(:,12),-aft(:,7),'bx');
set(pl,'LineWidth',1.5,'MarkerSize',7)

pl =plot(maex,-maey,'hm');
set(pl,'LineWidth',1.5,'MarkerSize',15,...
    'MarkerFaceColor','w','MarkerEdgeColor','k')


set(gca,'Ylim',[-14 0])
set(gca,'Xlim',[ 0 48 ])

set(gca,'Color',[color_bg([1,2]) 0.7])
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',16,'Linewidth',1.2)
ylabel('Depth in [km]')

set(gca,'XTickLabel',[]);

ax = axis;


rect = [0.15,  0.15, 0.75, 0.35];
axes('position',rect)

hold on
pco1 = pcolor(gx,gy,re4);
hold on


pl =plot(maex,-maey,'hm');
set(pl,'LineWidth',1.5,'MarkerSize',15,...
    'MarkerFaceColor','w','MarkerEdgeColor','k')


colormap(hsv)

shading interp

if fre == 1
    caxis([fix1 fix2])
end

axis([ax]);
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',16,'Linewidth',1.8)

ylabel('Depth in  [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
xlabel('Distance along projection in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)

vx =  (min(min(re3)):0.1:max(max(re3)));
if fre == 1; vx =  (fix1:0.1:fix2); end
v = [vx ; vx]; v = v';
rect = [0.94 0.15 0.01 0.35];
axes('position',rect)
pcolor((1:2),vx,v)
shading interp
set(gca,'XTickLabels',[])
set(gca,'FontSize',12,'FontWeight','bold',...
    'LineWidth',1.0,'YAxisLocation','right',...
    'Box','on','SortMethod','childorder','TickDir','out')
ax3 = gca;

whitebg(gcf,[0 0 0])
set(gcf,'Color','k','InvertHardcopy','off')



matdraw

