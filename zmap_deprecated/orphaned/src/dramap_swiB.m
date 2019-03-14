report_this_filefun(mfilename('fullpath'));

[lat,lon] = meshgrat(tmap,tmapleg);
[X , Y]  = meshgrid(gx,gy);

ren = interp2(X,Y,re3,lon,lat);
mi = 0;

figure_w_normalized_uicontrolunits('pos',[150 100 1000 700])

hold on; axis off
axesm('MapProjection','mercator',...
    'MapLatLimit',[s4_south s3_north],'MapLonLimit',[s2_west s1_east])

meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',5);
tightmap
view([0 90])
camlight; lighting phong
% set(gca,'projection','perspective');

plotm(coastline(:,2), coastline(:,1),'w','Linewidth',2);
zdatam(handlem('allline'),10000) % keep line on surface

j = jet(64);
%j = j(64:-1:1,:);
j = [ [ 0.85 0.9 0.9] ; j];

colormap(j); brighten(0.3);
%caxis([mi 1.4])

set(gcf,'color','w')

setm(gca,'ffacecolor','w')
setm(gca,'fedgecolor','w','flinewidth',1);

setm(gca,'mlabellocation',1)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',1)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','w','Fontweight','bold','FontSize',12)

h5 = colorbar;
set(h5,'position',[0.82 0.35 0.01 0.3])


set(gcf,'Inverthardcopy','off');







