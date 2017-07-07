report_this_filefun(mfilename('fullpath'));

figure

[xx,yy]=meshgrid(vlon,vlat);
surfl(yy,xx,tmap/1000),shading interp;

li = light('Position',[ 0 0 100],'Style','infinite');
material shiny
lighting gouraud
% axis([ min(vlat) max(vlat) min(vlon) max(vlon) ]);

set(gca,'FontSize',12,'FontWeight','bold',...
    'LineWidth',1.5,...
    'Box','on','SortMethod','childorder','TickDir','out')
axis ij
view([ -90 90])
colormap(gray)

set(gca,'Ylim',[min(vlon) max(vlon)]);
set(gca,'Xlim',[min(vlat) max(vlat)]);

hold on

%pl = plot3(a.Latitude,a.Longitude,a.Longitude*0+6000,'or');


