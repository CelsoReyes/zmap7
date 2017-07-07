% make a x-section plus topography...

report_this_filefun(mfilename('fullpath'));

% make a track
lis1 = linspace(lat1,lat2,1000);
lis2 = linspace(lon1,lon2,1000);

tr = [lis2 ; lis1]; tr = tr';
z = [];
% get the topo at each point

for i = 1:length(tr)
    x = find(abs(vlon - tr(i,1)) == min(abs(vlon - tr(i,1))) );
    y = find(abs(vlat - tr(i,2)) == min(abs(vlat - tr(i,2))) );
    z = [z tmap(y,x)  ];
end

figure
axes('pos',[0.1 0.4 0.75 0.3])
plot(xsecx,-xsecy,'or');
hold on

axes('pos',[0.1 0.7 0.75 0.15])
pl = plot(z,'k'); hold on
l = z >= 0; l2 = find(z >= 0);
pl = plot(l2, z(l),'ks');
set(pl,'Markersize',6,'markerfacecolor','k')
l = z < 0; l2 = find(z < 0);
pl = plot(l2, z(l),'bs');
set(pl,'Markersize',6,'markerfacecolor','b')

set(pl,'Linewidth',2)
set(gca,'XTick',[])
grid

axes('pos',[0.1 0.1 0.75 0.3])
pcolor(gx,gy,re3);
