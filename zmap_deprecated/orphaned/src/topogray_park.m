report_this_filefun(mfilename('fullpath'));

[lat,lon] = meshgrat(tmap,tmapleg);



figure_w_normalized_uicontrolunits('pos',[150 500 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[s4_south s3_north],'MapLonLimit',[s2_west s1_east])

surflm(lat,lon,tmap)

daspectm('m',3);
%tightmap
view([12 20])
camlight ; lighting phong
material([0.9 0.4 0.4]);shading interp


c = hsv;
depf = [];

for i = 1:length(faults);
    depf = [depf ; interp2(lon,lat,tmap,faults(i,1),faults(i,2))];
end

pl = plot3m(faults(:,2),faults(:,1),depf+5,'r','Linewidth',2);




for i = 1:length(a)

    dep = interp2(lon,lat,tmap,a(i,1),a(i,2));

    pl =plot3m(a(i,2),a(i,1),dep+100,'sk');


    hold on
    fac = 64/max(a.Depth);

    facm = 8/max(a.Magnitude);
    sm = a(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm,'markerfacecolor','y');
    trimcart(pl)
end

dep = interp2(lon,lat,tmap,main(1,1),a(1,2));
pl =plot3m(main(1,2),main(1,1),dep+500,'hk');
set(pl,'Markersize',16,'markerfacecolor','w','Linewidth',2);



%zdatam(handlem('alltext'),10000) % keep line on surface

g = gray(64);

colormap(g)

axis off; set(gcf,'color','w')

setm(gca,'ffacecolor','w')
setm(gca,'fedgecolor','k','flinewidth',3);

setm(gca,'mlabellocation',0.5)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',0.5)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','k','Fontweight','bold','FontSize',12,'Labelunits','dm')



set(gcf,'Inverthardcopy','off');






