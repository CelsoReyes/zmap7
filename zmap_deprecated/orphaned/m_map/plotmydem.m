
figure
 l  = get(h1,'XLim');
   s1_east = l(2); s2_west = l(1);
   l  = get(h1,'YLim');
   s3_north = l(2); s4_south = l(1);
m_proj('lambert','long',[s2_west s1_east],'lat',[s4_south s3_north]);
%m_coast('patch',[1 .85 .7]);
%m_gshhs_i('patch',[.5 .6 .5]);
[cmap,clim] = demcmap(tmap);
[c2,m2] = m_contourf(mx(1:n),my(1:m),tmap,100);
%[c,m] = m_contourf(xx,yy,tmap,(clim(1)-10:100:clim(2)));
% [c,m] = m_contourf(xx,yy,tmap,100);
set(m2,'LineStyle','none');
%lico = m_line(coastline(:,1),coastline(:,2),'color','k');


demcmap(tmap,100);

m_grid('box','on','tickdir','in','linestyle','none','fontsize',10);
hold on

%if co == 'w' ; co = 'k'; end
%axes
%m_proj('lambert','long',[s2_west s1_east],'lat',[s4_south s3_north]);

%li = m_line(a.Longitude,a.Latitude,'Linestyle','none','Marker',ty1);
%axis off
%set(li,'Linestyle','none','Marker',ty1,'MarkerSize',ms6,'color','y')
%lifa = m_line(faults(:,1),faults(:,2),'color','r');
%livo = m_line(vo.Longitude,vo.Latitude,'color','r');
 %set(livo,'LineWidth',1.,'MarkerSize',8,'Linestyle','none',...
%    'MarkerFaceColor','w','MarkerEdgeColor','r','marker','^');

set(gcf,'Color','w')


