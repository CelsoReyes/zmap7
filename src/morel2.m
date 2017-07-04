% this script will plot the cumulative moment
% release as a function of time

%  Stefan Wiemer  2/95

report_this_filefun(mfilename('fullpath'));

% open a new figure
figure
set(gcf,'PaperPosition',[2 1 5.5 7.5])

% create the buttons

matdraw

%  Do the calculation
%  newt2 is the currently selected catalog, newt2.Magnitude is the
% vextor containing the magnitudes
c = cumsum( 10.^(1.5*newt2.Magnitude + 16.1));


% plot the results in an xy plot
pl = plot(newt2.Date,c);
set(pl,'LineWidth',2.0)
xlabel('Time in years ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
ylabel('Cumulative Moment ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)

% add text -  maybe
%te = text(0.1,0.9,'log10(Mo) = 1.5Ms + 16.1;','Units','normalized','FontWeight','bold')

% change the layout of the axes slightly
set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on')

hold on
grid


