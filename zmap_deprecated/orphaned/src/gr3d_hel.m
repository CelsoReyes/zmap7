report_this_filefun(mfilename('fullpath'));

clf
sl1 = slice(X,Y,-Z+1.1,bvg,0,0,[ -2 -6 ]);
hold on
plot3(a.Latitude,a.Longitude,-a.Depth+1.1,'wo','MarkerSize',2)
rotate3d on
%caxis([0.8 1.7])
set(gca,'XLim',[-1.5 1.5 ],'xgrid','off')
set(gca,'YLim',[-1.5 1.5 ],'ygrid','off')
set(gca,'ZLim',[  -8 3 ],'zgrid','off')
colormap(nc)
shading interp
%cob = colorbar('vert')
%set(cob,'TickDir','out','pos',[0.8 0.3 0.07 0.3])
set(gca,'Box','on','vis','on')
tmp = ra*nan;
tmp(1,1,1) = 0;
tmp(1,1,2) = 1;
hold on
sl = slice(X,Y,-Z+1.1,tmp,0,0,[  -2 -6  ]);
set(sl(:),'EdgeColor','w','LineWidth',0.1)
caxis([0.8 1.8])
view([-147 5])
ax1 = gca;

axes
axis('off')
hold on
su = surfl(hx,hy,h)
shading interp
view([-147 5])
set(gca,'XLim',[-1.5 1.5 ],'xgrid','off')
set(gca,'YLim',[-1.5 1.5 ],'ygrid','off')
set(gca,'ZLim',[  -8 3 ],'zgrid','off')
caxis([0.8 1.8])
ax2 = gca;
set(ax1,'Clim',[0.8 1.8])
set(ax2,'Clim',[-2 1])


