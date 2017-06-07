report_this_filefun(mfilename('fullpath'));


%l = isnan(tmap);
%tmap(l) = 1;


l = tmap < 100;
tmap(l) = 100;


[lat,lon] = meshgrat(tmap,tmapleg);
%[smap,smapleg] = country2mtx('switzerland',100);
%[lat0, lon0] = meshgrat(smap,smapleg);


% tmap = km2deg(tmap/1);
%  [X , Y]  = meshgrid(gx,gy);

%sw = interp2(lon0,lat0,smap,lon,lat);

re4 = re3;

l = re4 < -5.5;
re4(l) = -5.5;
l = re4 > -3;
re4(l) = -3;

ren = interp2(X2,Y2,re4,lon,lat);

mi = min(min(ren));
l =  isnan(ren);
ren(l) = mi-20;




figure_w_normalized_uicontrolunits('pos',[150 500 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[33.4 35.4],'MapLonLimit',[-117.5 -115.5])

meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',6);
tightmap
view([0 90])
hl = camlight ; lighting phong
set(gca,'projection','perspective');

aa = a;

for i = 1:length(maepi(:,3))
    dep = interp2(lon,lat,tmap,maepi(i,1),maepi(i,2));

    pl =plot3m(maepi(i,2),maepi(i,1),dep+175,'^k');
    set(pl,'Markersize',14,'markerfacecolor','w');

end

load usahi
[plat,plon] = extractm(stateline,'california');
pl =plot3m(plat,plon,175,'linewidth',2);
set(pl,'color','w');

%dep = interp2(lon,lat,tmap,faults(:,1),faults(:,2));
%pl = plotm(faults(:,2), faults(:,1),dep+10,'k','Linewidth',1.0);

dep = interp2(lon,lat,tmap,mainfault(:,1),mainfault(:,2));
pl = plotm(mainfault(:,2), mainfault(:,1),dep+10,'y','Linewidth',2.0);

%zdatam(handlem('allline'),10000) % keep line on surface
j = jet;
j = j(64:-1:1,:);
j = [ [ 0.85 0.9 0.9] ; j ; [0.9 0.9 0.9] ];
caxis([ -5.4 -3.1]);

colormap(j);
axis off; set(gcf,'color','k')
ax = axis;
axis([ax(1:4) 0 5000])

setm(gca,'ffacecolor','k')
setm(gca,'fedgecolor','w','flinewidth',3);

setm(gca,'mlabellocation',1)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',1)
setm(gca,'parallellabel','on','Labelrotation','on')
setm(gca,'Fontcolor','w','Fontweight','bold','FontSize',14,'Labelunits','degrees')

h5 = colorbar;
set(h5,'position',[0.7 0.21 0.01 0.2] ,'TickDir','out','Ycolor','w','Xcolor','w',...
    'Fontweight','bold','FontSize', 14 );
set(gcf,'Inverthardcopy','off');




a = aa;




