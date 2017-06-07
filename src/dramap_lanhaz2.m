report_this_filefun(mfilename('fullpath'));

[lat,lon] = meshgrat(tmap,tmapleg);


ren = interp2(X2,Y2,Z,lon,lat);

l = ren < 0.01;
ren(l) = 0.01;
mi = min(min(ren));

l = isnan(ren);
ren(l) = mi-2;


figure_w_normalized_uicontrolunits('pos',[150 500 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[33.5 35 ],'MapLonLimit',[-117.3 -116])

meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',8);
tightmap
view([0 90])
% hl = lightangle(45,25);
hl = camlight
lighting phong
set(gca,'projection','perspective');

load worldlo
%h = displaym(POline); set(h(1),'color',[0.9 0.9 0.9],'Linewidth',1.7)
% h2 = displaym(PPpoint);
%   h = displaym(PPtext); trimcart(h);

plotm(faults(:,2), faults(:,1),'k','Linewidth',1.4);
% plotm(mainfault(:,2), mainfault(:,1),'m','Linewidth',3);

pl = plotm(a(:,2),a(:,1),'ok');
set(pl,'LineWidth',0.3,'MarkerSize',2,...
    'MarkerFaceColor','k','MarkerEdgeColor','k')
pl = plotm(main(:,2),main(:,1),'hw');
set(pl,'LineWidth',1,'MarkerSize',20,...
    'MarkerFaceColor','w','MarkerEdgeColor','k')


zdatam(handlem('allline'),10000) % keep line on surface
%zdatam(handlem('alltext'),10000) % keep line on surface
caxis([0.008 0.09])
j = jet;
%j = j(64:-1:1,:);
j = [ [ 0.85 0.9 0.9] ; j];

colormap(j); brighten(0.3);

axis off; set(gcf,'color','w')

setm(gca,'ffacecolor','w')
setm(gca,'fedgecolor','k','flinewidth',3);

setm(gca,'mlabellocation',0.5)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',0.5)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','k','Fontweight','bold','FontSize',14,'Labelunits','dm')

h5 = colorbar;
set(h5,'position',[0.7 0.15 0.01 0.3],'TickDir','out','Ycolor','k','Xcolor','k',...
    'Fontweight','bold','FontSize',14);
set(gcf,'Inverthardcopy','off');







