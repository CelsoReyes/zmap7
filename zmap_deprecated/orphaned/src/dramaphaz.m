report_this_filefun(mfilename('fullpath'));

load swhaz.mat

[lat,lon] = meshgrat(tmap,tmapleg);
[smap,smapleg] = country2mtx('switzerland',100);
[lat0, lon0] = meshgrat(smap,smapleg);


% tmap = km2deg(tmap/1);

gx = rex(:,1);
gy = rey(1,:)';
[X , Y]  = meshgrid(gx,gy);

sw = interp2(lon0,lat0,smap,lon,lat);

l =  isnan(sw) == 1 | sw == 2 ;


ren = interp2(X,Y,re',lon,lat);

mi = min(min(ren));

ren(l) = mi-0.01;


figure_w_normalized_uicontrolunits('pos',[150 500 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[s4_south s3_north],'MapLonLimit',[s2_west s1_east])

meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',5);
tightmap
view([0 90])
camlight; lighting phong
set(gca,'projection','perspective');

load worldlo
%h = displaym(POline); set(h(1),'color',[0.9 0.9 0.9],'Linewidth',1.7)
h2 = displaym(PPpoint);
%h = displaym(PPtext); trimcart(h);

%plotm(coastline(:,2), coastline(:,1),'k','Linewidth',1);
zdatam(handlem('allline'),10000) % keep line on surface
%zdatam(handlem('alltext'),10000) % keep line on surface

j = jet;
%j = j(64:-1:1,:);
j = [ [ 0.85 0.9 0.9] ; j];

colormap(j); brighten(0.3);

axis off; set(gcf,'color','k')

setm(gca,'ffacecolor','k')
setm(gca,'fedgecolor','w','flinewidth',3);

setm(gca,'mlabellocation',1)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',1)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','w','Fontweight','bold','FontSize',12)

h5 = colorbar;
set(h5,'position',[0.82 0.35 0.01 0.3],'TickDir','out','Ycolor','w','Xcolor','w',...
    'Fontweight','FontSize',12);
set(gcf,'Inverthardcopy','off');






