% This function selects events around a seismic
% station that fullfill certain criteria;

report_this_filefun(mfilename('fullpath'));

load /Seis/obelix/stefan/split_data2/ak8897.mat
ty1 = '+'
ty2 = 'o'
ty2 = 'x'
par1 = 100;minmag = 4;

los = input('Longitude: ')
las = input('Latitude: ')

pl = plot(los,las,'rs')
set(pl,'LineWidth',1.0,'MarkerSize',10,...
    'MarkerFaceColor','y','MarkerEdgeColor','k');


l = sqrt(((a.Longitude-los)*cos(pi/180*las)*111).^2 + ((a.Latitude-las)*111).^2) ;
l2 = a.Magnitude >= 0.0 & a.Depth >= l;
%l2 = a.Magnitude >=2.0 & a.Depth <= 30 & l < 100;
a = a.subset(l2);
mainmap_overview()
pl = plot(los,las,'rs')
set(pl,'LineWidth',1.0,'MarkerSize',10,...
    'MarkerFaceColor','r','MarkerEdgeColor','y');
