report_this_filefun(mfilename('fullpath'));


% drap a colormap onto topography
l = isnan(tmap);
tmap(l) = -10;

%l = tmap< 0.1;
%tmap(l) = 0;


[lat,lon] = meshgrat(tmap,tmapleg);
%[smap,smapleg] = country2mtx('switzerland',100);
%[lat0, lon0] = meshgrat(smap,smapleg);


% tmap = km2deg(tmap/1);
[X , Y]  = meshgrid(gx,gy);

%sw = interp2(lon0,lat0,smap,lon,lat);
l = re4 < 1.2;
re4(l) = 1.2;
l = re4 > 2.6;
re4(l) = 2.6;


ren = interp2(X,Y,re4,lon,lat);

mi = min(min(ren));
l =  isnan(ren);
ren(l) = mi-20;


figure_w_normalized_uicontrolunits('pos',[150 500 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[s4_south s3_north],'MapLonLimit',[s2_west s1_east])


l = tmap  == -10 &  ren < mi -10;
tmap(l) = nan;


meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',4);
tightmap
view([0 90])
camlight; lighting phong
set(gca,'projection','perspective');

load worldlo
%h = displaym(POline); set(h(1),'color',[0.9 0.9 0.9],'Linewidth',1.7)
h2 = displaym(PPpoint);
h = displaym(PPtext); trimcart(h);


load usahi
[la , lo ] = extractm(stateline,'california');

plotm(la, lo,'w','Linewidth',1.4);
zdatam(handlem('allline'),10000) % keep line on surface
zdatam(handlem('alltext'),10000) % keep line on surface




% pl = plotm(ma(:,2),ma(:,1),'hw');
%  set(pl,'LineWidth',1.5,'MarkerSize',12,...
% 'MarkerFaceColor','w','MarkerEdgeColor','k')
plotm(faults(:,2), faults(:,1),'k','Linewidth',2);
zdatam(handlem('allline'),10000) % keep line on surface
%zdatam(handlem('alltext'),10000) % keep line on surface


j = hsv;
%j = j(64:-1:1,:);
j = [ [ 0.9 0.9 0.9 ] ; j];
caxis([ 1.15 2.7])

colormap(j);

axis off; set(gcf,'color','k')

setm(gca,'ffacecolor','k')
setm(gca,'fedgecolor','w','flinewidth',3);

setm(gca,'mlabellocation',2.5)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',2.5)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','w','Fontweight','bold','FontSize',16,'Labelunits','dm')

h5 = colorbar;
set(h5,'position',[0.8 0.35 0.01 0.3],'TickDir','out','Ycolor','w','Xcolor','w',...
    'Fontweight','bold','FontSize',16);
set(gcf,'Inverthardcopy','off');







