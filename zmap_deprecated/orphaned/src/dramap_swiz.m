report_this_filefun(mfilename('fullpath'));

% drap a colormap onto topography
l = isnan(tmap);
tmap(l) = 1;

%l = tmap< 0.1;
%tmap(l) = 0;


[lat,lon] = meshgrat(tmap,tmapleg);
[smap,smapleg] = country2mtx('switzerland',100);
[lat0, lon0] = meshgrat(smap,smapleg);


% tmap = km2deg(tmap/1);
[X , Y]  = meshgrid(gx,gy);

sw = interp2(lon0,lat0,smap,lon,lat);

l =  isnan(sw) == 1 | sw == 2 ;



ren = interp2(X,Y,re4,lon,lat);

mi = min(min(ren));
%l =  isnan(ren);
ren(l) = mi-0.01;




figure

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[45 48.5],'MapLonLimit',[5.3 11.5])

ll = tmap < 0 & ren < 0;
ren(ll) = ren(ll)*0 + 20;
meshm(ren,tmapleg,size(tmap),tmap);
meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',6);
tightmap
view([0 90])
camlight; lighting phong
set(gca,'projection','perspective');

%   load worldlo
%   h = displaym(POline); set(h(1),'color',[0.9 0.9 0.9],'Linewidth',1.7)
%   h2 = displaym(PPpoint);
%   h = displaym(PPtext); trimcart(h);



pl = plotm(ma(:,2),ma(:,1),'hw');
set(pl,'LineWidth',1.5,'MarkerSize',12,...
    'MarkerFaceColor','w','MarkerEdgeColor','k')
%load coast.mat
%c = coast;
% plotm(c(:,1), c(:,2),'k','Linewidth',1);
zdatam(handlem('allline'),10000) % keep line on surface
%zdatam(handlem('alltext'),10000) % keep line on surface




j = jet;
%j = j(64:-1:1,:);
j = [ [ 0.9 0.9 0.9 ] ; j; [ 0.5 0.5 0.5] ];
caxis([ min(min(re4)) max(max(re4)) ]);

colormap(j); brighten(0.1);

axis off; set(gcf,'color','k')

setm(gca,'ffacecolor','k')
setm(gca,'fedgecolor','w','flinewidth',3);

setm(gca,'mlabellocation',2)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',2)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','w','Fontweight','bold','FontSize',12,'Labelunits','dm')

h5 = colorbar;
set(h5,'position',[0.8 0.35 0.01 0.3],'TickDir','out','Ycolor','w','Xcolor','w',...
    'Fontweight','bold','FontSize',12);
set(gcf,'Inverthardcopy','off');







