report_this_filefun(mfilename('fullpath'));

[lat,lon] = meshgrat(tmap,tmapleg);
gx = X2(1,:);
gy = Y2(:,1)';

% tmap = km2deg(tmap/1);
[X , Y]  = meshgrid(gx,gy);


ren = interp2(X,Y,Z,lon,lat);

l = ren < -8.8; ren(l) = -8.8;
mi = min(min(ren));

l = isnan(ren);
ren(l) = mi-2;


figure_w_normalized_uicontrolunits('pos',[150 500 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[s4_south s3_north],'MapLonLimit',[s2_west s1_east])

meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',10);
tightmap
view([0 90])
camlight; lighting phong
set(gca,'projection','perspective');

load worldlo
%h = displaym(POline); set(h(1),'color',[0.9 0.9 0.9],'Linewidth',1.7)
% h2 = displaym(PPpoint);
%   h = displaym(PPtext); trimcart(h);

plotm(faults(:,2), faults(:,1),'w','Linewidth',1);
pl = plotm(ms(:,1), ms(:,2),'sw','Linewidth',[1.4]','Markersize',6);
set(pl,'LineWidth',1,'MarkerSize',4,...
    'MarkerFaceColor',[0.8 0.8 0.8],'MarkerEdgeColor',[0.8 0.8 0.8])




% pl = plotm(a.Latitude,a.Longitude,'+k');
%set(pl,'LineWidth',0.5,'MarkerSize',2,...
%   'MarkerFaceColor','k','MarkerEdgeColor','k')
pl = plotm(main(:,2),main(:,1),'hw');
set(pl,'LineWidth',1,'MarkerSize',20,...
    'MarkerFaceColor','w','MarkerEdgeColor','k')


zdatam(handlem('allline'),2000) % keep line on surface
%zdatam(handlem('alltext'),10000) % keep line on surface
caxis([0.0 0.12])
j = jet;
%j = j(64:-1:1,:);
j = [ [ 0.9 0.9 0.9] ; j];

colormap(j); brighten(0.0);

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
    'Fontweight','bold','FontSize',14,'Ticklength',[0.02 0.08]);
set(gcf,'Inverthardcopy','off');






