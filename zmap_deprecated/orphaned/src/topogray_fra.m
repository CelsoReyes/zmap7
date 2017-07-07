report_this_filefun(mfilename('fullpath'));

[lat,lon] = meshgrat(tmap,tmapleg);


figure_w_normalized_uicontrolunits('pos',[150 500 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[s4 s3],'MapLonLimit',[s2 s1])

surflm(lat,lon,tmap)

daspectm('m',2);
%tightmap
view([0 90])
camlight ; lighting phong
material([0.9 0.4 0.4]);shading interp

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

pl = plotm(coastline(:,2), coastline(:,1),'w','Linewidth',2);
set(pl,'LineWidth',2);
trimcart(pl)

c = hsv;


for i=1:length(am)
    if am(i,4) > 0
        pl=plot3m(am(i,2),am(i,3),10000,'r+')
        hold on
        set(pl,'markersize',am(i,4)*25+4,'linewidth', 3)
    else
        pl=plot3m(am(i,2),am(i,3),10000,'go')
        set(pl,'markersize',-am(i,4)*25+4,'linewidth', 3)
        hold on
    end %if
end %for


zdatam(handlem('allline'),10000) % keep line on surface
%zdatam(handlem('alltext'),10000) % keep line on surface

colormap(gray)

axis off; set(gcf,'color','w')

setm(gca,'ffacecolor','w')
setm(gca,'fedgecolor','k','flinewidth',3);

setm(gca,'mlabellocation',1)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',1)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','k','Fontweight','bold','FontSize',12,'Labelunits','dm')



set(gcf,'Inverthardcopy','off');






