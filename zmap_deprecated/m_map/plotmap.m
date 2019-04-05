
   figure


   l  = get(h1,'XLim');
   s1_east = l(2); s2_west = l(1);
   l  = get(h1,'YLim');
   s3_north = l(2); s4_south = l(1);

cl =  get(h1,'Clim');

%m_proj('lambert','long',[s2_west s1_east],'lat',[s4_south s3_north]);
m_proj('lambert','long',[s2_west s1_east],'lat',[s4_south s3_north]);

%m_coast('patch',[1 .85 .7]);

cstep = abs(cl(2) - cl(1))/25;
[m,c] = m_contourf(gx,gy,re4,(cl(1):cstep:cl(2)));
set(c,'LineStyle','none');

hold on

if ~isempty(coastline)
  lico = m_line(coastline(:,1),coastline(:,2),'color','k');
end

if ~isempty(faults)
  lifa = m_line(faults(:,1),faults(:,2),'color','k');
end

 m_grid('box','on','linestyle',':');
hold on
shading flat

%li = m_line(ZG.primeCatalog.Longitude,ZG.primeCatalog.Latitude);
%set(li,'Linestyle','none','Marker',ty1,'MarkerSize',ZG.ms6,'color',co)
set(gcf,'Color','w')

vx =  (cl(1):cstep:cl(2));
 v = [vx ; vx]; v = v';
 rect = [0.93 0.4 0.015 0.25];
 axes('position',rect)
pcolor((1:2),vx,v)
shading flat
set(gca,'XTickLabels',[])
set(gca,'FontSize',12,'FontWeight','normal',...
    'LineWidth',1.0,'YAxisLocation','right',...
    'Box','on','SortMethod','childorder','TickDir','out')


