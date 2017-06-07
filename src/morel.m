% this script will plot the cumulative moment
% release as a function of time

%  Stefan Wiemer  2/95

report_this_filefun(mfilename('fullpath'));

figure
set(gcf,'PaperPosition',[2 1 5.5 7.5])

matdraw

%  Do the calculation
c = cumsum( 10.^(1.5*newt2(:,6) + 16.1));


pl = plot(newt2(:,3),c)
set(pl,'LineWidth',2.0)
xlabel('Time in years ','FontWeight','bold','FontSize',fontsz.m)
ylabel('Cumulative Moment ','FontWeight','bold','FontSize',fontsz.m)

%te = text(0.1,0.9,'log10(Mo) = 1.5Ms + 16.1;','Units','normalized','FontWeight','bold')

set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on')

hold on
grid


