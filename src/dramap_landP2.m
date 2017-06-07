report_this_filefun(mfilename('fullpath'));

%l = isnan(tmap);
%tmap(l) = 1;



l = tmap < 100;
tmap(l) = 100;


[lat,lon] = meshgrat(tmap,tmapleg);
%[smap,smapleg] = country2mtx('switzerland',100);
%[lat0, lon0] = meshgrat(smap,smapleg);


% tmap = km2deg(tmap/1);
[X , Y]  = meshgrid(gx,gy);

%sw = interp2(lon0,lat0,smap,lon,lat);

%  re4 = re3;

l = re4 < -1.5;
re4(l) = -1.5;
l = re4 > 1.5;
re4(l) = 1.5;

ren = interp2(X,Y,re4,lon,lat);

mi = min(min(ren));
l =  isnan(ren);
ren(l) = mi-20;




figure_w_normalized_uicontrolunits('pos',[150 500 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[32.7 36.],'MapLonLimit',[-118.0 -115.4])

meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',8);
tightmap
view([12 22])
hl = camlight ; lighting phong
set(gca,'projection','perspective');

aa = a;

j = jet;
%j = j(64:-1:1,:);
j = [ [ 0.85 0.9 0.9] ; j];
caxis([ min(min(re4)) max(max(re4)) ]);

colormap(j);
caxis([-1.6 1.6]);
axis off; set(gcf,'color','k')
ax = axis;
axis([ax(1:4) 0 5000])

setm(gca,'ffacecolor','k')
setm(gca,'fedgecolor','w','flinewidth',3);

setm(gca,'mlabellocation',1)
setm(gca,'meridianlabel','off')
setm(gca,'plabellocation',1)
setm(gca,'parallellabel','off','Labelrotation','on')
setm(gca,'Fontcolor','w','Fontweight','bold','FontSize',14,'Labelunits','degrees')

set(gcf,'Inverthardcopy','off');




a = aa;




