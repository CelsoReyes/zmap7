report_this_filefun(mfilename('fullpath'));

%[tmap, tmapleg] = gtopo30('test',1);


[lat,lon] = meshgrat(tmap,tmapleg);

l = isnan(tmap);
tmap(l) = -10;


figure_w_normalized_uicontrolunits('pos',[50 50 900 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[s4 s3],'MapLonLimit',[s2 s1])

surflm(lat,lon,tmap)

daspectm('m',2);
%tightmap
view([0 90])
camlight ; lighting phong
material([0.9 0.4 0.1]);shading interp

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


%pl = plotm(a(:,2), a(:,1),'.r','Linewidth',1);
%set(pl,'LineWidth',1,'MarkerSize',1);
pl = plotm(coastline(:,2), coastline(:,1),'w','Linewidth',2);
set(pl,'LineWidth',2);
%pl = plotm(faults(:,2), faults(:,1),'b','Linewidth',1);
%set(pl,'LineWidth',1);
trimcart(pl)

zdatam(handlem('allline'),10000) % keep line on surface
g = gray;
g = [0 0 1 ; g];


colormap(g)

axis off; set(gcf,'color','k')

setm(gca,'ffacecolor','k')
setm(gca,'fedgecolor','y','flinewidth',3);

setm(gca,'mlabellocation',2)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',2)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','w','Fontweight','bold','FontSize',12,'Labelunits','dm')



set(gcf,'Inverthardcopy','off');






