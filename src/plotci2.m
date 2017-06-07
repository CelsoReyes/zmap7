%  plot a circle containing ni events
%  around each grid point

report_this_filefun(mfilename('fullpath'));

st = 2;
[X,Y] = meshgrid(gx,gy);
[m,n]= size(r);
hold on
x = -pi-0.1:0.1:pi;
for i = 1:st:m
    for k = 1:st:n
        if r(i,k) <= tresh;
            plot(X(i,k)+r(i,k)*sin(x)/(cos(pi/180*ya0)*111),Y(i,k)+r(i,k)*cos(x)/(cos(pi/180*ya0)*111) ,'k')
            plot(X(i,k),Y(i,k),'+k')
        end
    end
end
