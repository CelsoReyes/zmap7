% File : subzoom.m
% Written by : Doug Harriman
%              Graduate Student Researcher
%              Mechanical Engineering
%              UC Berkeley
%              harriman@euler.berkeley.edu
% Written on : 10/20/95
%
% Purpose : Allows a zoomed in
%           subplot in main plot.
%
% Sytax   : >>subzoom
%   edited to work with eztools, but requires a second click when making
%   the rubber band box. (?)                          rcobb 11/95

% Subplot title
tit = 'Zoomed Region' ;

% Move to correct figure
figure(gcf); ;

% Disable any widowbutton down functions
wbdnfcn=get(gcf,'windowbuttondownfcn');
set(gcf,'windowbuttondownfcn',' ') ;

% Get zoom box
disp('Select Region to Zoom')  ;
waitforbuttonpress            ;
pnt = get(gcf,'currentpoint') ;
xy1 = get(gca,'currentpoint') ;
rbbox([pnt 0 0],pnt)          ;
waitforbuttonpress ;
xy2 = get(gca,'currentpoint') ;

% Clean up data
xy1 = xy1(1,1:2) ;
xy2 = xy2(1,1:2) ;
xx  = [xy1(1) xy2(1)] ;
yy  = [xy1(2) xy2(2)] ;

% Get new plot area
disp('Select Area for Subplot') ;
waitforbuttonpress ;
pnt1 = get(gcf,'currentpoint') ;
rbbox([pnt1 0 0],pnt1) ;
waitforbuttonpress ;
pnt2 = get(gcf,'currentpoint') ;

% Clean up data
pntx = [pnt1(1) pnt2(1)] ;
pnty = [pnt1(2) pnt2(2)] ;

% Create axes
mainaxhan = gca ;
pos = get(gcf,'position') ;
corner = [min(pntx)/pos(3) min(pnty)/pos(4)];
width  = [abs(diff(pntx))/pos(3) abs(diff(pnty))/pos(4)] ;
axhan = axes('position',[corner width],'box','on') ;

% Set fontsize
factor = 2/3 ;
size = get(mainaxhan,'fontsize') ;
set(axhan,'fontsize',factor*size) ;

% Set Limits
axis([min(xx) max(xx) min(yy) max(yy)]) ;

% Set aspectratio
% Comment this out if you want to set you own aspect ratio
aspect = get(mainaxhan,'aspectratio') ;
set(axhan,'aspectratio',aspect) ;

% Get Data to plot
kids = get(mainaxhan,'children') ;
hold on
for i = 1:length(kids)

    xdata = get(kids(i),'xdata') ;
    ydata = get(kids(i),'ydata') ;
    color = get(kids(i),'color') ;
    linestyle = get(kids(i),'linestyle') ;
    linewidth = get(kids(i),'linewidth') ;

    plothan = plot(xdata,ydata) ;

    set(plothan,'color',color) ;
    set(plothan,'linestyle',linestyle) ;
    set(plothan,'linewidth',linewidth) ;

end
hold off

% Put box around zoomed region in main plot
% comment out if you don't like this

% Swith to correct axes
axes(mainaxhan) ;

% Vertical lines
lh(1) = line([1 1]*min(xx),[max(yy) min(yy)]) ;
lh(2) = line([1 1]*max(xx),[max(yy) min(yy)]) ;

% Horizontal lines
lh(3) = line([max(xx) min(xx)],[1 1]*min(yy)) ;
lh(4) = line([max(xx) min(xx)],[1 1]*max(yy)) ;

% Set colors
set(lh,'color','w') ;

% Label it
titlehan = get(axhan,'tit') ;
set(titlehan,'string',tit,...
    'fontsize',size*factor+3) ;

set(gcf,'windowbuttondownfcn',wbdnfcn);
% End of file
