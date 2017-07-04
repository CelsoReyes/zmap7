report_this_filefun(mfilename('fullpath'));

figure
rect = [0.15,  0.60, 0.75, 0.35];
axes('position',rect)

l = newa2(:,10) == 1;
pl =plot(newa2(l,11),-newa2(l,7),'ro');
set(pl,'Linewidth',1.,'MarkerSize',2)
hold on

l = newa2(:,10) == 3;
pl =plot(newa2(l,11),-newa2(l,7),'og');
set(pl,'Linewidth',1.,'MarkerSize',1)

l = newa2(:,10) == 2;
pl =plot(newa2(l,11),-newa2(l,7),'ob');
set(pl,'Linewidth',1.,'MarkerSize',2)


l = newa2(:,10) == 4;
pl =plot(newa2(l,11),-newa2(l,7),'hm');
set(pl,'LineWidth',1.5,'MarkerSize',12,...
    'MarkerFaceColor','w','MarkerEdgeColor','k')


set(gca,'Ylim',[-12 0])
set(gca,'Color',[color_bg([1,2]) 0.7])
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',12,'Linewidth',1.2)
ylabel('Depth in [km]')

set(gca,'XTickLabel',[]);

ax = axis;


rect = [0.15,  0.15, 0.75, 0.35];
axes('position',rect)

hold on
pco1 = pcolor(gx,gy,re4);
hold on

l = newa2(:,10) == 4;
pl =plot(newa2(l,11),-newa2(l,7),'hm');
set(pl,'LineWidth',1.5,'MarkerSize',12,...
    'MarkerFaceColor','w','MarkerEdgeColor','k')


shading interp

if fre == 1
    caxis([fix1 fix2])
end

axis([ax]);
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',12,'Linewidth',1.2)

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

