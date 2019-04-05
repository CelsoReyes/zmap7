report_this_filefun(mfilename('fullpath'));

[lat,lon] = meshgrat(tmap,tmapleg);
%gx = rex(1,:);
%gy = rey(:,1)';

% tmap = km2deg(tmap/1);
% [X , Y]  = meshgrid(gx,gy);

ren = interp2(XB,YB,ZB,lon,lat);

l = ren < -8.8; ren(l) = -8.8;
mi = min(min(ren));

l = isnan(ren);
ren(l) = mi-2;


figure_w_normalized_uicontrolunits('pos',[150 100 600 500])

hold on; axis off
axm1 = axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[s4_south s3_north],'MapLonLimit',[s2_west s1_east])

meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',3);
tightmap
view([0 90])
camlight; lighting phong
set(gca,'projection','perspective');

load worldlo
%h = displaym(POline); set(h(1),'color',[0.9 0.9 0.9],'Linewidth',1.7)
% h2 = displaym(PPpoint);
%   h = displaym(PPtext); trimcart(h);

pl = plotm(ms(:,1), ms(:,2),'ow','Linewidth',1.4);
set(pl,'LineWidth',1,'MarkerSize',3,...
    'MarkerFaceColor',[0.8 0.8 0.8 ],'MarkerEdgeColor',[ 0.8 0.8 0.8  ])


plmag = 4.
l = a.Date > t0+4/365 & a.Date < t0+34/365 & a.Magnitude >= plmag & a.Magnitude < 5;

pl = plotm(a(l,2),a(l,1),'ow','Markersize',9);
set(pl,'LineWidth',1,'MarkerSize',6,...
    'MarkerFaceColor',[1 1 1 ],'MarkerEdgeColor',[ 0 0 0  ])


l = a.Date > t0+4/365 & a.Date < t0+34/365 & a.Magnitude >= 5.0 ;
pl = plotm(a(l,2),a(l,1),'^w','Markersize',9);
set(pl,'LineWidth',1,'MarkerSize',10,...
    'MarkerFaceColor',[1 1 1 ],'MarkerEdgeColor',[ 0 0 0  ])



% pl = plotm(a.Latitude,a.Longitude,'+k');
%set(pl,'LineWidth',0.5,'MarkerSize',2,...
%   'MarkerFaceColor','k','MarkerEdgeColor','k')
pl = plotm(main(:,2),main(:,1),'hw');
set(pl,'LineWidth',1,'MarkerSize',20,...
    'MarkerFaceColor','w','MarkerEdgeColor','k')


zdatam(handlem('allline'),2000) % keep line on surface
%zdatam(handlem('alltext'),10000) % keep line on surface
caxis([0.0 0.22])
j = hsv;
%j = j(64:-1:1,:);
j = [ [ 0.9 0.9 0.9] ; j];

colormap(j); brighten(0.0);

axis off; set(gcf,'color','w')

setm(gca,'ffacecolor','w')
setm(gca,'fedgecolor','k','flinewidth',3);
setm(gca,'mlabellocation',0.25)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',0.25)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','k','Fontweight','normal','FontSize',10,'Labelunits','dm')

h5 = colorbar;
set(h5,'position',[0.71 0.44 0.017 0.45],'TickDir','out','Ycolor','k','Xcolor','k',...
    'Fontweight','bold','FontSize',14,'Ticklength',[0.02 0.08],'Yticklabel',[]);
set(gcf,'Inverthardcopy','off');

sc =   scaleruler('RulerStyle','lines','MajorTick',0:15:30,'Linewidth',1,'color','k',...
    'MajorTickLength',2,'XLoc',-0.003,'YLoc',0.5663,'Zloc',40000,'FontSize',9,'Fontweight','normal',...
    'MinorTick',0:5:10,'color',[0 0 0 ],'TickDir','down')


return

scaleruler

setm(handlem('scaleruler'),'XLoc',-0.0,'YLoc',0.566,'Zloc',4000)
setm(handlem('scaleruler'),'MajorTick',0:10:30,...
    'MinorTick',0:5:10,'TickDir','down',...
    'MajorTickLength',(3),...
    'MinorTickLength',(3),'Linewidth',8)
%setm(handlem('scaleruler'),'RulerStyle','ruler')
setm(handlem('scaleruler1'),'RulerStyle','lines')



