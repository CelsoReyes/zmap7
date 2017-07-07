report_this_filefun(mfilename('fullpath'));

g = ginput(1)

di = sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2 + (a.Depth-z).^2) ;

l = di <=g(2);

newt2 = a.subset(l);
timeplot
