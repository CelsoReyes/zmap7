report_this_filefun(mfilename('fullpath'));

l = isnan(tmap);
tmap(l) = 1;

[lat,lon] = meshgrat(tmap,tmapleg);
%[lat,lon] = meshgrat(vlat,vlon);

%[smap,smapleg] = country2mtx('switzerland',100);
%[lat0, lon0] = meshgrat(smap,smapleg);


% tmap = km2deg(tmap/1);
[X , Y]  = meshgrid(gx,gy);

%sw = interp2(lon0,lat0,smap,lon,lat);



ren = interp2(X,Y,re4,lon,lat);

mi = min(min(ren));
l =  isnan(ren);
ren(l) = mi-0.05;


figure_w_normalized_uicontrolunits('pos',[150 500 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[s4_south s3_north],'MapLonLimit',[s2_west s1_east])

meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',50);
tightmap
view([0 90])
camlight; lighting phong
set(gca,'projection','perspective');

% load usalo
% h = displaym(usalo('state'));

%set(h(1),'color',[0.9 0.9 0.9],'Linewidth',2)
% h = displaym(gtlakevec); set(h(1),'color',[0.9 0.9 0.9],'Linewidth',2)

% h2 = displaym(PPpoint);
%h = displaym(PPtext); trimcart(h);

%pl = plotm(lima(:,2),lima(:,1),'hw');
%set(pl,'LineWidth',1.5,'MarkerSize',12,...
% 'MarkerFaceColor','y','MarkerEdgeColor','k')

pl = plotm(dam(:,2),dam(:,1),'^w');
set(pl,'LineWidth',1.5,'MarkerSize',12,...
    'MarkerFaceColor','w','MarkerEdgeColor','k')
pl = plotm(coastline(:,2), coastline(:,1),'w','Linewidth',2);
set(pl,'LineWidth',2);
zdatam(handlem('allline'),10000) % keep line on surface
%zdatam(handlem('alltext'),10000) % keep line on surface

j = jet;
%j = j(64:-1:1,:);
j = [ [ 0.85 0.9 0.9] ; j];

colormap(j); brighten(0.1);

axis off; set(gcf,'color','k')

setm(gca,'ffacecolor','k')
setm(gca,'fedgecolor','y','flinewidth',3);

setm(gca,'mlabellocation',2)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',2)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','w','Fontweight','bold','FontSize',12,'Labelunits','dm')

h5 = colorbar;
set(h5,'position',[0.82 0.35 0.01 0.3],'TickDir','out','Ycolor','w','Xcolor','w',...
    'Fontweight','FontSize',12);
set(gcf,'Inverthardcopy','off');






