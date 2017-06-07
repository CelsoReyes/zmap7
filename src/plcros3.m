report_this_filefun(mfilename('fullpath'));

% Now lets plot the color-map of the z-value
%
figure

%[afx, afy] =lc_xsec2(af(:,2)',af(:,1)',af(:,7),wi,leng,lat1,lon1,lat2,lon2);


set(gca,'visible','off','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','SortMethod','childorder')

rect = [0.18,  0.10, 0.7, 0.75];
rect1 = rect;

% set values greater tresh = nan
%
%re4 = ret;l = r > tresh; re4(l) = zeros(1,length(find(l)))*nan;

% plot image
%
orient portrait
set(gcf,'PaperPosition', [2. 1 7.0 5.0])

%l = isnan(re4);

axes('position',rect);hold on

l = newa(:,3) < maepi(1,3);
ploeqc = plot(newa(:,length(newa(1,:))),-newa(:,7),'+r');
set(ploeqc,'MarkerSize',2,'LineWidth',0.4)
hold on
ploeqc = plot(newa2(:,length(newa2(1,:))),-newa2(:,7),'xb');
set(ploeqc,'MarkerSize',2,'LineWidth',0.4)
axis([ min(gx) max(gx) min(gy) max(gy)]); axis image; hold on

%xlabel('Distance in [km]','FontWeight','bold','FontSize',fontsz.m)
%ylabel('Depth in [km]','FontWeight','bold','FontSize',fontsz.m)

set(gca,'XTickLabels',[])
set(gca,'YTickLabels',[  10 8 6 4 2 ])

if exist('maex') > 0
    pl = plot(maex,-maey,'*k');
    set(pl,'MarkerSize',8,'LineWidth',2)
    pl = plot(maex,-maey,'*m');
end

set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
set(gca,'Color',[cb1 cb2 cb3])
h1 = gca;hzma = gca;
%h5 = colorbar('horiz');
%set(h5,'Pos',[0.25 0.05 0.5 0.05],...
%'FontWeight','bold','FontSize',fontsz.m)

% Make the figure visible
%
set(gca,'visible','on','FontSize',10,'FontWeight','bold',...
    'FontWeight','normal','LineWidth',1.0,...
    'Box','on','TickDir','out')
