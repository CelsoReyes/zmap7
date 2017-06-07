report_this_filefun(mfilename('fullpath'));

z = peaks;
cmap1 = jet;
cmap2 = cool;
cmap = [cmap1;cmap2];
colormap(cmap)

clf
subplot(211), pcolor(z);
shading interp
z2 = z + (max(z(:))-min(z(:)));
h1 = gca;

subplot(212), pcolor(z2)
shading interp
ax = findobj(gcf,'Type','axes');
set(ax,'CLim', [min(z(:)) max(z2(:))])
hc = colorbar('vert');
set(hc,'YLim',[min(z2(:)) max(z2(:))],'Pos',[0.90 0.2 0.03 0.2])
%set(hc,'YTickLabels'
axes(h1)
hc2 = colorbar('vert');
set(hc2,'YLim',[min(z(:)) max(z(:))],'Pos',[0.90 0.6 0.03 0.2])

yt = get(hc2,'YTickLabels')
set(hc,'YTickLabels',[yt])

