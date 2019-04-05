report_this_filefun(mfilename('fullpath'));

l = isnan(tmap);
tmap(l) = 1;



l = tmap< 0.1;
tmap(l) = 0;


[lat,lon] = meshgrat(tmap,tmapleg);
%[smap,smapleg] = country2mtx('switzerland',100);
%[lat0, lon0] = meshgrat(smap,smapleg);


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

% pl = plotm(ma(:,2),ma(:,1),'hw');
%  set(pl,'LineWidth',1.5,'MarkerSize',12,...
% 'MarkerFaceColor','w','MarkerEdgeColor','k')

%plotm(coastline(:,2), coastline(:,1),'k','Linewidth',1);
zdatam(handlem('allline'),10000) % keep line on surface
%zdatam(handlem('alltext'),10000) % keep line on surface


cd /home2/stefan/ZMAP/agu99
load hec.mat

for i = 1:length(a)
    pl =plotm(a(i,2),a(i,1),'sk');
    hold on
    fac = 64/max(a.Depth);

    facm = 5/max(a.Magnitude);
    sm = a(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm,'markerfacecolor','y');
end

load land.mat

for i = 1:length(a)
    pl =plotm(a(i,2),a(i,1),'sk');
    hold on
    fac = 64/max(a.Depth);

    facm = 5/max(a.Magnitude);
    sm = a(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm,'markerfacecolor','w');
end
load bb.mat

for i = 1:length(a)
    pl =plotm(a(i,2),a(i,1),'sk');
    hold on
    fac = 64/max(a.Depth);

    facm = 5/max(a.Magnitude);
    sm = a(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm,'markerfacecolor','w');
end
zdatam(handlem('allline'),10000) % keep line on surface
j = jet;
%j = j(64:-1:1,:);
j = [ [ 0.85 0.9 0.9] ; j];
caxis([ min(min(re4)) max(max(re4)) ]);

colormap(j); brighten(0.1);

axis off; set(gcf,'color','k')

setm(gca,'ffacecolor','k')
setm(gca,'fedgecolor','w','flinewidth',3);

setm(gca,'mlabellocation',1)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',1)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','w','Fontweight','bold','FontSize',16,'Labelunits','dm')

h5 = colorbar;
set(h5,'position',[0.8 0.35 0.01 0.3],'TickDir','out','Ycolor','w','Xcolor','w',...
    'Fontweight','bold','FontSize',16);
set(gcf,'Inverthardcopy','off');






