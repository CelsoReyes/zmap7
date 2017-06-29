report_this_filefun(mfilename('fullpath'));

% TODO delete this, probably. -CGR
% Now lets plot the color-map of the z-value
%
figure

set(gca,'visible','off','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','SortMethod','childorder')

rect = [0.18,  0.10, 0.7, 0.75];
rect1 = rect;

% set values greater tresh = nan
%
re4 = ret;l = r > tresh; re4(l) = zeros(1,length(find(l)))*nan;

% plot image
%
orient portrait
set(gcf,'PaperPosition', [2. 1 7.0 5.0])

l = isnan(re4);

axes('position',rect);hold on

pco1 = pcolor(gx,gy,(re4))
caxis([ 25 150]);
shading interp
axis([ min(gx) max(gx) min(gy) max(gy)]);
axis image;
hold on
h = cool(64);h = [  h]; colormap(h)

set(gca,'Color',[0.9 0.9 0.9])
set(gca,'YTickLabels',[  10 8  6 4  2])

%xlabel('Distance in [km]','FontWeight','bold','FontSize',fontsz.m)
%ylabel('depth in [km]','FontWeight','bold','FontSize',fontsz.m)

if exist('maex', 'var')
    pl = plot(maex,-maey,'*y');
    set(pl,'MarkerSize',6,'LineWidth',2)
end
overlay

set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','normal','LineWidth',1.5,...
    'Box','on','TickDir','out')
h1 = gca;hzma = gca;

% Create a colobar
%
% h5 = colorbar('horiz');
%set(h5,'Pos',[0.25 0.05 0.5 0.05],...
%'FontWeight','bold','FontSize',fontsz.m)

% Make the figure visible
%
set(gca,'visible','on','FontSize',10,'FontWeight','bold',...
    'FontWeight','normal','LineWidth',1.0,...
    'Box','on','TickDir','out')

axes(h1)
