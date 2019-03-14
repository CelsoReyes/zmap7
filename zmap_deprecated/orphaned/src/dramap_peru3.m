report_this_filefun(mfilename('fullpath'));

l = isnan(tmap);
tmap(l) = 1;

%l = tmap <  0;
%tmap(l) = 0;

%l = Z < 0.12;
%Z(l) = 0.14;

[lat,lon] = meshgrat(tmap,tmapleg);
%[lat,lon] = meshgrat(vlat,vlon);

%[smap,smapleg] = country2mtx('peru',100);
%[lat0, lon0] = meshgrat(smap,smapleg);

%sw = interp2(lon0,lat0,smap,lon,lat);
%l =  isnan(sw) == 1 | sw == 2 ;


ren = interp2(X,Y,Z,lon,lat);

mi = min(min(ren));

ren(l) = mi-0.01;



% ren = interp2(X,Y,Z,lon,lat);

% mi = min(min(ren));
l =  isnan(ren);
ren(l) = 0;


figure_w_normalized_uicontrolunits('pos',[150 500 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[s4_south s3_north],'MapLonLimit',[s2_west s1_east])

meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',10);
tightmap
view([0 90])
camlight; lighting phong
set(gca,'projection','perspective');

load worldlo
% h = displaym(POline); set(h(1),'color',[0.9 0.9 0.9],'Linewidth',2)
% h2 = displaym(PPpoint);
%h = displaym(PPtext); trimcart(h);

%pl = plotm(lima(:,2),lima(:,1),'hw');
%set(pl,'LineWidth',1.5,'MarkerSize',12,...
% 'MarkerFaceColor','y','MarkerEdgeColor','k')

pl = plotm(dam(:,2),dam(:,1),'^w');
set(pl,'LineWidth',1.5,'MarkerSize',12,...
    'MarkerFaceColor','w','MarkerEdgeColor','k')
%pl = plotm(coastline(:,2), coastline(:,1),'w','Linewidth',2);

ci = worldlo('PPpoint');
cx = ci(1).long;
cy = ci(1).lat;
hold on
%  plotm(cy,cx,'sk','Markersize',12,'Markerfacecolor',[ 1 1 1])


ri = worldlo('DNline');
hold on

rx = [ri(1).long ; ri(2).long];
ry = [ri(1).lat ; ri(2).lat ];
hold on
% plotm(ry,rx,'b','Linewidth',2);


zdatam(handlem('allline'),10000) % keep line on surface
%zdatam(handlem('alltext'),10000) % keep line on surface

j = jet;
%j = j(64:-1:1,:);
j = [ [ 0.93 0.9 0.9] ; j];

caxis([0.20 0.28])
colormap(j);

axis off; set(gcf,'color','w')

setm(gca,'ffacecolor','k')
setm(gca,'fedgecolor','k','flinewidth',3);

setm(gca,'mlabellocation',1)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',1)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','k','Fontweight','bold','FontSize',12,'Labelunits','dm')

h5 = colorbar;
set(h5,'position',[0.76 0.35 0.01 0.3],'TickDir','out','Ycolor','k','Xcolor','k',...
    'Fontweight','bold','FontSize',12);
%set(gcf,'Inverthardcopy','off');






