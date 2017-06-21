report_this_filefun(mfilename('fullpath'));

[lat,lon] = meshgrat(tmap,tmapleg);


figure_w_normalized_uicontrolunits('pos',[150 500 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[s4 s3],'MapLonLimit',[s2 s1])

surflm(lat,lon,tmap)

daspectm('m',5);
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

load worldlo;

ci = worldlo('PPpoint');
cx = ci(1).long;
cy = ci(1).lat;
hold on
plotm(cy,cx,'sr','Markersize',12,'Markerfacecolor',[1 1 1 ])

%pl = plotm(faults(:,2), faults(:,1),'m','Linewidth',2);
%set(pl,'LineWidth',2);

c = hsv;

cd /home2/stefan/ZMAP/agu99
load hec.mat

for i = 1:length(a)
    pl =plotm(a(i,2),a(i,1),'sk');
    hold on
    fac = 64/max(a.Depth);

    facm = 10/max(a.Magnitude);
    sm = a(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm,'markerfacecolor','y');
end

load nori.mat

for i = 1:length(a)
    pl =plotm(a(i,2),a(i,1),'sk');
    hold on
    fac = 64/max(a.Depth);

    facm = 10/max(a.Magnitude);
    sm = a(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm,'markerfacecolor','b');
end

load land.mat

for i = 1:length(a)
    pl =plotm(a(i,2),a(i,1),'sk');
    hold on
    fac = 64/max(a.Depth);

    facm = 10/max(a.Magnitude);
    sm = a(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm,'markerfacecolor','m');
end
load bb.mat

for i = 1:length(a)
    pl =plotm(a(i,2),a(i,1),'sk');
    hold on
    fac = 64/max(a.Depth);

    facm = 10/max(a.Magnitude);
    sm = a(i,6)* facm;
    if sm < 1; sm = 1; end

    co = ceil(a(i,7)*fac)+1; if co > 63; co = 63; end
    set(pl,'Markersize',sm,'markerfacecolor','c');
end

zdatam(handlem('allline'),10000) % keep line on surface
zdatam(handlem('allline'),10000) % keep line on surface

%zdatam(handlem('alltext'),10000) % keep line on surface

colormap(gray)

axis off; set(gcf,'color','k')

setm(gca,'ffacecolor','b')
setm(gca,'fedgecolor','y','flinewidth',3);

setm(gca,'mlabellocation',1)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',0.5)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','w','Fontweight','bold','FontSize',12,'Labelunits','dm')



set(gcf,'Inverthardcopy','off');






