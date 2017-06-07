report_this_filefun(mfilename('fullpath'));

g = ginput(1)

di = sqrt(((a(:,1)-x)*cos(pi/180*y)*111).^2 + ((a(:,2)-y)*111).^2 + (a(:,7)-z).^2) ;

l = di <=g(2);

newt2 = a(l,:);
timeplot
