% This file plots the resuklts of threepoint
%
% Uses the m_map matlab extanesion availanble free on the internet

report_this_filefun(mfilename('fullpath'));

figure
axes('pos',[ 0.15 0.15 0.7 0.7])
m_proj('Azimuthal Equal-area','lat',0,'long',90,'radius',90);

long = d1(:,3);
lat = d1(:,2)+90;
l = lat > 90 & lat < 270;
long(l) = -long(l);
l1 = m_line([ long ],[ lat ]);
set(l1,'Linestyle','none','Marker','x','MarkerSize',13,'color','k')
hold on

long = d1(:,7);
lat = d1(:,6)+90;
l = lat > 90 & lat < 270;
long(l) = -long(l);
l1 = m_line([ long ],[ lat ]);
set(l1,'Linestyle','none','Marker','x','MarkerSize',13,'color','b')
hold on

long = d1(:,5);
lat = d1(:,4)+90;
l = lat > 90 & lat < 270;
long(l) = -long(l);
l1 = m_line([ lat ],[ lon ]);
set(l1,'Linestyle','none','Marker','x','MarkerSize',13,'color','r')
hold on


l1 = m_line([ 80 ],[ 10 ]);
set(l1,'Linestyle','none','Marker','x','MarkerSize',13,'color','r')
hold on




set(gca,'visible','on','FontSize',12,'FontWeight','bold',...
    'LineWidth',0.1,'Box','on','TickDir','out','SortMethod','childorder');


m_grid('xtick',12,'tickdir','out','ytick',12,'linest','-','xticklabel',[],...
    'FontName','HelveticaBold',...
    'ylabeldir','middle');

figure
plot(long,lat,'o')

