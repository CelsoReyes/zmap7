report_this_filefun(mfilename('fullpath'));

% drap a colormap onto topography
%l = isnan(tmap);
%tmap(l) = 1;

%l = tmap< 1;
%tmap(l) = 1;


[lat,lon] = meshgrat(tmap,tmapleg);
%[smap,smapleg] = country2mtx('switzerland',100);
%[lat0, lon0] = meshgrat(smap,smapleg);


% tmap = km2deg(tmap/1);
[X , Y]  = meshgrid(gx,gy);

%sw = interp2(lon0,lat0,smap,lon,lat);

l = re4 < 0.82;
re4(l) = 0.72;
l = re4 > 1.95;
re4(l) = 1.95;


ren = interp2(X,Y,re4,lon,lat);

mi = min(min(ren));
l =  isnan(ren);
ren(l) = mi-20;




figure_w_normalized_uicontrolunits('pos',[150 500 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[10 55],'MapLonLimit',[55 120])


ll = tmap < 0 & ren < 0;
ren(ll) = ren(ll)*0 + 20;
meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',35);
tightmap
camlight; lighting phong
set(gca,'projection','perspective');

load worldlo
hl = displaym(POline);
set(hl(1),'color',[0.9 0.9 0.9],'Linewidth',1.)
delete(hl(2));
% h2 = displaym(PPpoint);
% h = displaym(PPtext);



% pl = plotm(ma(:,2),ma(:,1),'hw');
%  set(pl,'LineWidth',1.5,'MarkerSize',12,...
% 'MarkerFaceColor','w','MarkerEdgeColor','k')
%load coast.mat
%c = coast;
%  plotm(cu(:,2), cu(:,1),'w','Linewidth',2);

zdatam(handlem('allline'),10000) % keep line on surface
% zdatam(handlem('alltext'),10000) % keep line on surface




j = jet;
%j = j(64:-1:1,:);
j = [ [ 0.9 0.9 0.9 ] ; j; [ 0.5 0.5 0.5] ];
caxis([ 0.8 1.90]);

colormap(j);

axis off; set(gcf,'color','w')

setm(gca,'ffacecolor','k')
setm(gca,'fedgecolor','k','flinewidth',3);

setm(gca,'mlabellocation',15)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',15)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','k','Fontweight','bold','FontSize',16,'Labelunits','degrees')

h5 = colorbar;
set(h5,'position',[0.8 0.35 0.01 0.3],'TickDir','out','Ycolor','k','Xcolor','k',...
    'Fontweight','bold','FontSize',16);
set(gcf,'Inverthardcopy','off');







