report_this_filefun(mfilename('fullpath'));


l = isnan(tmap);
tmap(l) = 1;



l = tmap < 150;
tmap(l) = 150;


[lat,lon] = meshgrat(tmap,tmapleg);
%[smap,smapleg] = country2mtx('switzerland',100);
%[lat0, lon0] = meshgrat(smap,smapleg);


% tmap = km2deg(tmap/1);
[X , Y]  = meshgrid(gx,gy);

%sw = interp2(lon0,lat0,smap,lon,lat);

re4 = re3;

l = re4 < -0.5;
re4(l) = -0.5;
l = re4 > 0.5;
re4(l) = 0.5;

ren = interp2(X,Y,re4,lon,lat);

mi = min(min(ren));
l =  isnan(ren);
ren(l) = mi-20;




figure_w_normalized_uicontrolunits('pos',[150 500 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[33.1 35.8],'MapLonLimit',[-117.7 -115.3])

meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',5);
tightmap
view([10 30])
hl = camlight ; lighting phong
set(gca,'projection','perspective');

aa = a;

cd /alaskah2/stefan/ZMAP/agu99
load hec.mat

for i = 1:length(a)
    dep = interp2(lon,lat,tmap,a(i,1),a(i,2));

    pl =plot3m(a(i,2),a(i,1),dep+55,'ok');
    hold on
    fac = 64/max(a.Depth);

    facm = 7/max(a.Magnitude);
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

    facm = 7/max(a.Magnitude);
    sm = a(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm,'markerfacecolor','w');
end
load bb.mat

for i = 1:length(a)
    dep = interp2(lon,lat,tmap,a(i,1),a(i,2));

    pl =plot3m(a(i,2),a(i,1),dep+55,'sk');

    hold on
    fac = 64/max(a.Depth);

    facm = 7/max(a.Magnitude);
    sm = a(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm,'markerfacecolor','w');
end

for i = 1:length(maepi(:,3))
    dep = interp2(lon,lat,tmap,maepi(i,1),maepi(i,2));
    % pl =plot3m(maepi(i,2),maepi(i,1),dep+10,'hk');
    % set(pl,'Markersize',8,'markerfacecolor','w');
end

%zdatam(handlem('allline'),10000) % keep line on surface
j = hot;
%j = j(64:-1:1,:);
j = [ [ 0.85 0.9 0.9] ; j];
caxis([ min(min(re4)) max(max(re4)) ]);

colormap(j); brighten(0.1);
%caxis([-8.3 7]);
axis off; set(gcf,'color','k')

setm(gca,'ffacecolor','k')
setm(gca,'fedgecolor','w','flinewidth',3);

setm(gca,'mlabellocation',1)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',1)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','w','Fontweight','bold','FontSize',10,'Labelunits','dm')

h5 = colorbar;
set(h5,'position',[0.7 0.25 0.01 0.2],'TickDir','out','Ycolor','w','Xcolor','w',...
    'Fontweight','bold','FontSize',12);
set(gcf,'Inverthardcopy','off');



a = aa;




