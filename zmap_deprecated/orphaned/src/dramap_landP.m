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

l = re4 < -2.0;
re4(l) = -2.0;
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

cd /home2/stefan/ZMAP/agu99
load hec.mat

for i = 1:length(a)
    dep = interp2(lon,lat,tmap,a(i,1),a(i,2));

    pl =plot3m(a(i,2),a(i,1),dep+75,'ok');
    hold on
    fac = 64/max(a.Depth);

    facm = 6/max(a.Magnitude);
    sm = a(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm,'markerfacecolor','w');
end

load land.mat

for i = 1:length(a)
    dep = interp2(lon,lat,tmap,a(i,1),a(i,2));

    pl =plot3m(a(i,2),a(i,1),dep+75,'sk');
    ;
    hold on
    fac = 64/max(a.Depth);

    facm = 6/max(a.Magnitude);
    sm = a(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm,'markerfacecolor','w');
end
load bb.mat

for i = 1:length(a)
    dep = interp2(lon,lat,tmap,a(i,1),a(i,2));

    pl =plot3m(a(i,2),a(i,1),dep+75,'sk');

    hold on
    fac = 64/max(a.Depth);

    facm = 6/max(a.Magnitude);
    sm = a(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm,'markerfacecolor','w');
end

for i = 1:length(maepi(:,3))
    dep = interp2(lon,lat,tmap,maepi(i,1),maepi(i,2));

    pl =plot3m(maepi(i,2),maepi(i,1),dep+175,'^k');
    set(pl,'Markersize',14,'markerfacecolor','w');

end

load usahi
[plat,plon] = extractm(stateline,'california');
pl =plot3m(plat,plon,175,'linewidth',2);
set(pl,'color','w');

dep = interp2(lon,lat,tmap,faults(:,1),faults(:,2));

pl = plotm(faults(:,2), faults(:,1),dep+10,'k','Linewidth',1.0);

%zdatam(handlem('allline'),10000) % keep line on surface
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
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',1)
setm(gca,'parallellabel','on','Labelrotation','on')
setm(gca,'Fontcolor','w','Fontweight','bold','FontSize',14,'Labelunits','degrees')

h5 = colorbar;
set(h5,'position',[0.7 0.21 0.01 0.2],'TickDir','out','Ycolor','w','Xcolor','w',...
    'Fontweight','bold','FontSize',14);
set(gcf,'Inverthardcopy','off');




a = aa;




