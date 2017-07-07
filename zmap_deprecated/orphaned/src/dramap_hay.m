report_this_filefun(mfilename('fullpath'));

l = isnan(tmap);
tmap(l) = 1;



%l = tmap< 0.1;
%tmap(l) = nan;


[lat,lon] = meshgrat(tmap,tmapleg);
%[smap,smapleg] = country2mtx('switzerland',100);
%[lat0, lon0] = meshgrat(smap,smapleg);


% tmap = km2deg(tmap/1);
[X , Y]  = meshgrid(gx,gy);

%sw = interp2(lon0,lat0,smap,lon,lat);



ren = interp2(X,Y,re4,lon,lat);

mi = min(min(ren));
l =  isnan(ren);
ren(l) = mi-100;




figure_w_normalized_uicontrolunits('pos',[150 500 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[s4 s3],'MapLonLimit',[s2 s1])

meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',10);
tightmap
view([0 90])
camlight; lighting phong
set(gca,'projection','perspective');

load worldlo
%h = displaym(POline); set(h(1),'color',[0.9 0.9 0.9],'Linewidth',1.7)
h2 = displaym(PPpoint);
%h = displaym(PPtext); trimcart(h);
plotm(mainfault(:,2), mainfault(:,1),'m','Linewidth',4);

pl = plotm(ma(:,2),ma(:,1),'hw');
set(pl,'LineWidth',1.5,'MarkerSize',12,...
    'MarkerFaceColor','y','MarkerEdgeColor','k')

zdatam(handlem('allline'),10000) % keep line on surface
%zdatam(handlem('alltext'),10000) % keep line on surface

j = jet;
j = j(64:-1:1,:);
j = [ [ 0.85 0.9 0.9] ; j];
caxis([ 95 2000]);

colormap(j); brighten(0.1);

axis off; set(gcf,'color','k')

setm(gca,'ffacecolor','k')
setm(gca,'fedgecolor','w','flinewidth',3);

setm(gca,'mlabellocation',0.5)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',0.5)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','w','Fontweight','bold','FontSize',15,'Labelunits','dm')

h5 = colorbar;
set(h5,'position',[0.8 0.35 0.01 0.3],'TickDir','out','Ycolor','w','Xcolor','w',...
    'Fontweight','bold','FontSize',15);
set(gcf,'Inverthardcopy','off');






