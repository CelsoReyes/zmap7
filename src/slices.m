report_this_filefun(mfilename('fullpath'));

figure_w_normalized_uicontrolunits(slice)
clf
hold off
set(gca,'visible','off')

rect = [0.1 0.1 0.4 0.4];
orient landscape
axes('position',rect)
hold on
surf(gx,gy,re4)
view(3)
axis([-155.7 -155.2 19 19.5  -20 1000])
colormap(jet)
shading interp
hold on
grid
set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')

return


rect = [0.1 0.3 0.4 0.4];
axes('position',rect)
hold on
surf(gx,gy,re4+900)
view(3)
axis([-155.7 -155.2 19 19.5  -20 1000])
colormap(jet)
shading interp
hold on
set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')

