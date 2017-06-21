report_this_filefun(mfilename('fullpath'));


%l = isnan(tmap);
%tmap(l) = 1;



%l = tmap < 1;
%tmap(l) = 1;


[lat,lon] = meshgrat(tmap,tmapleg);
%[smap,smapleg] = country2mtx('switzerland',100);
%[lat0, lon0] = meshgrat(smap,smapleg);


% tmap = km2deg(tmap/1);
[X , Y]  = meshgrid(gx,gy);

%sw = interp2(lon0,lat0,smap,lon,lat);

%  re4 = re3;

l = re4 < -2.0;
re4(l) = -2.0;
l = re4 > 2.0;
re4(l) = 2.0;
re4 = re4+1200;

ren = interp2(X,Y,re4,lon,lat);

mi = min(min(ren));
l =  isnan(ren);
ren(l) = mi-20;




figure_w_normalized_uicontrolunits('pos',[150 500 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[33.0 36.2],'MapLonLimit',[-118.1 -115.3])

meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',1.5);
tightmap
%view([10 30])
hl = camlight ; lighting phong
set(gca,'projection','perspective');

aa = a;



l = aa(:,6) > 1.5 & aa(:,3) < 1992.2;
a = aa.subset(l);
for i = 1:length(a)

    dep = interp2(lon,lat,tmap,a(i,1),a(i,2));

    pl =plot3m(a(i,2),a(i,1),dep+55,'or');
    hold on
    fac = 64/max(a.Depth);

    facm = 9/max(a.Magnitude);
    sm = aa(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm);
end

l = aa(:,6) > 1.5 & aa(:,3) > 1992.55;
a = aa.subset(l);
for i = 1:length(a)

    dep = interp2(lon,lat,tmap,a(i,1),a(i,2));

    pl =plot3m(a(i,2),a(i,1),dep+55,'^b');
    hold on
    fac = 64/max(a.Depth);

    facm = 9/max(a.Magnitude);
    sm = aa(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm);
end
cd /alaskah2/stefan/ZMAP/agu99
load hec.mat

for i = 1:length(a)
    dep = interp2(lon,lat,tmap,a(i,1),a(i,2));

    pl =plot3m(a(i,2),a(i,1),dep+55,'ok');
    hold on
    fac = 64/max(a.Depth);

    facm = 6/max(a.Magnitude);
    sm = a(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm,'markerfacecolor','y');
end

load land.mat

for i = 1:length(a)
    dep = interp2(lon,lat,tmap,a(i,1),a(i,2));

    pl =plot3m(a(i,2),a(i,1),dep+55,'sk');
    ;
    hold on
    fac = 64/max(a.Depth);

    facm = 6/max(a.Magnitude);
    sm = a(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm,'markerfacecolor','y');
end
load bb.mat

for i = 1:length(a)
    dep = interp2(lon,lat,tmap,a(i,1),a(i,2));

    pl =plot3m(a(i,2),a(i,1),dep+55,'sk');

    hold on
    fac = 64/max(a.Depth);

    facm = 6/max(a.Magnitude);
    sm = a(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm,'markerfacecolor','y');
end

for i = 1:length(maepi(:,3))
    pl =plotm(maepi(i,2),maepi(i,1),'hk');
    set(pl,'Markersize',18,'markerfacecolor','w');
end


plotm(faults(:,2), faults(:,1),'k','Linewidth',1.0);

zdatam(handlem('allline'),10000) % keep line on surface
j = jet;
%j = j(64:-1:1,:);
j = [ [ 0.85 0.9 0.9] ; j;  [ 0.85 0.9 0.9] ]
%caxis([ min(min(re4)) max(max(re4)) ]);

colormap(j); brighten(0.1);
caxis([-2.10 2.10]);
axis off; set(gcf,'color','k')

setm(gca,'ffacecolor','k')
setm(gca,'fedgecolor','w','flinewidth',3);

setm(gca,'mlabellocation',1)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',1)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','w','Fontweight','bold','FontSize',12,'Labelunits','dm')

set(gcf,'Inverthardcopy','off');



a = aa;




