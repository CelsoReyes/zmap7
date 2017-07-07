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

re4 = re3;

ren = interp2(X,Y,re4,lon,lat);

mi = min(min(ren));
l =  isnan(ren);
ren(l) = mi-20;




figure_w_normalized_uicontrolunits('pos',[150 500 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[33.75 35.03],'MapLonLimit',[-116.8 -115.9])

meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',4);
tightmap
%view([10 30])
hl = camlight ; lighting phong
set(gca,'projection','perspective');

aa = a;

j = jet;
%j = j(64:-1:1,:);
j = [ [ 0.85 0.9 0.9] ; j];
caxis([ min(min(re4)) max(max(re4)) ]);

colormap(j);
caxis([0.60 1.5]);
axis off; set(gcf,'color','w')
ax = axis;
axis([ax(1:4) 0 5000])

setm(gca,'ffacecolor','w')
setm(gca,'fedgecolor','k','flinewidth',3);

setm(gca,'mlabellocation',0.5)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',0.5)
setm(gca,'parallellabel','on','Labelrotation','on')
setm(gca,'Fontcolor','k','Fontweight','bold','FontSize',14,'Labelunits','dm')

h5 = colorbar;
set(h5,'position',[0.65 .13 0.015 0.3],'TickDir','out','Ycolor','k','Xcolor','k',...
    'Fontweight','bold','FontSize',14,'Ticklength',[0.025 0.02]);
set(gcf,'Inverthardcopy','off');




a = aa;




