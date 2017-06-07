function plot_srcColorbar(cmin,cmax)

colormap(abs((gui_Colormap_ReadPovRay('SRC-Discrete.pov'))))
set(gca,'CLim',[cmin cmax]);
colorbar('Location','EastOutside',...
    'YLim',[cmin cmax]);
