report_this_filefun(mfilename('fullpath'));

figure


l  = get(h1,'XLim');
s1 = l(2); s2 = l(1);
l  = get(h1,'YLim');
s3 = l(2); s4 = l(1);

cl =  get(h1,'Clim');

m_proj('lambert','long',[s2 s1],'lat',[s4 s3]);

l = re4 >= cl(2);
re4(l) = re4(l)*0+cl(2)-0.01;
l = re4 <= cl(1);
re4(l) = re4(l)*0+cl(1)+0.01;

cstep = abs(cl(2) - cl(1))/5 ;
[m,c] = m_contourf(gx,gy,re4,(cl(1):cstep:cl(2)));
%set(c,'LineColor','r');

hold on

if isempty(coastline) ==  0
    lico = m_line(coastline(:,1),coastline(:,2),'color','k','LineWidth',0.5);
end

if isempty(faults) == 0
    %lifa = m_line(faults(:,1),faults(:,2),'color','k');
end


m_grid('box','on','linestyle','none','tickdir','out','color','k','linewidth',2,...
    'fontsize',10,'fontname','Helveticabold');
hold on
shading flat

caxis([cl(1) cl(2)-cstep])

hold on

%li = m_line(a.Longitude,a.Latitude);
%set(li,'Linestyle','none','Marker',ty1,'MarkerSize',ms6,'color',co)
set(gcf,'Color','w')

vx =  (cl(1):cstep:cl(2));
v = [vx ; vx]; v = v';
rect = [0.93 0.4 0.015 0.25];
axes('position',rect)
pcolor((1:2),vx,v)
shading flat
set(gca,'XTickLabels',[])
set(gca,'FontSize',10,'FontWeight','normal',...
    'LineWidth',1.0,'YAxisLocation','right',...
    'Box','on','SortMethod','childorder','TickDir','out')



g = gray;
g = g(60:-1:1,:);

colormap(g)
brighten(0.2)
caxis([cl(1) cl(2)-cstep])
