report_this_filefun(mfilename('fullpath'));

% drap a colormap onto topography
%l = isnan(tmap);
%tmap(l) = 1;

l = tmap< 2;
tmap(l) = 2;


[lat,lon] = meshgrat(tmap,tmapleg);
%[smap,smapleg] = country2mtx('switzerland',100);
%[lat0, lon0] = meshgrat(smap,smapleg);

l = re4 < 0.55;
re4(l) = 0.55;
l = re4 > 1.14;
re4(l) = 1.14;

% tmap = km2deg(tmap/1);
[X , Y]  = meshgrid(gx,gy);

%sw = interp2(lon0,lat0,smap,lon,lat);



ren = interp2(X,Y,re4,lon,lat);

mi = min(min(ren));
l =  isnan(ren);
ren(l) = mi-20;




figure_w_normalized_uicontrolunits('pos',[150 500 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[s4_south s3_north ],'MapLonLimit',[s2_west s1_east])

meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',4);
tightmap
view([-25 35])
li =  camlight;
lighting phong
set(gca,'projection','perspective');

load worldlo
h = displaym(POline); set(h(1),'color',[0.9 0.9 0.9],'Linewidth',1.7)
h2 = displaym(PPpoint);
h = displaym(PPtext); trimcart(h);



% pl = plotm(ma(:,2),ma(:,1),'hw');
%  set(pl,'LineWidth',1.5,'MarkerSize',12,...
% 'MarkerFaceColor','w','MarkerEdgeColor','k')
%load coast.mat
%c = coast;
% plotm(c(:,1), c(:,2),'k','Linewidth',1);
% zdatam(handlem('allline'),10000) % keep line on surface
%zdatam(handlem('alltext'),10000) % keep line on surface


dep = interp2(lon,lat,tmap,faults(:,1),faults(:,2));

pl = plotm(faults(:,2), faults(:,1),dep+10,'k','Linewidth',2.0);

dep = interp2(lon,lat,tmap,main(1,1),main(1,2));

pl =plot3m(main(1,2),main(1,1),dep+55,'^k');
set(pl,'Markersize',14,'markerfacecolor','w');




j = hsv(64);
j = j(62:-1:1,:);
j = [ [ 0.9  0.9 0.8 ] ; j];
caxis([  0.57 1.15]);

colormap(j);
axis off; set(gcf,'color','w')

setm(gca,'ffacecolor','b')
setm(gca,'fedgecolor','k','flinewidth',3);

setm(gca,'mlabellocation',0.5)
setm(gca,'meridianlabel','off')
setm(gca,'plabellocation',0.5)
setm(gca,'parallellabel','off')
setm(gca,'Fontcolor','k','Fontweight','bold','FontSize',16,'Labelunits','dm')

h5 = colorbar;
set(h5,'position',[0.8 0.35 0.01 0.3],'TickDir','out','Ycolor','k','Xcolor','k',...
    'Fontweight','bold','FontSize',16);
% set(gcf,'Inverthardcopy','off');







