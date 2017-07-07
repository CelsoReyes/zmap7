report_this_filefun(mfilename('fullpath'));

X = reshape(c(:,1),281,221);
Y = reshape(c(:,2),281,221);
Z = reshape(c(:,3),281,221);



figure
pcolor(X,Y,(Z));shading interp

