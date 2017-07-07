report_this_filefun(mfilename('fullpath'));

l = a.Magnitude > 6.6;
maepi = a.subset(l);

lat1 = maepi(1,2);
lon1 = maepi(1,1);
dep = maepi(1,7);
[xsecx xsecy,  inde] =mysect(tmp1,tmp2,a.Depth,50,40,lat1,lon1,[122-90]);
global eq1

% this is rotate rect to the strike
a.Longitude= -eq1(2,:)';
a.Latitude = eq1(1,:)';

l = a.Magnitude > 6.5;
maepi = a.subset(l);
a.Depth = a.Depth-maepi(1,7);

% lets see what we got
figure
plot(a.Latitude,-a.Depth,'x')
hold on
sigma = (45)*pi/180
l = (0:0.1:30);
l = [l*sin(sigma)  ; l*cos(sigma)];
plot(l(1,:),l(2,:),'b');

% here are the tranformation matrixes
transf = [cos(sigma) sin(sigma)
    -sin(sigma) cos(sigma)];
% inverse transformation matrix to rotate the data coordinate back
invtransf = [cos(-sigma) sin(-sigma)
    -sin(-sigma) cos(-sigma)];


b = [a.Latitude -a.Depth];
b = b*transf;
lt = l'*transf;
figure
dist = abs(b(:,1)) < 5 ;
plot(b(:,1),b(:,2),'bx')
hold on
plot(b(dist,1),b(dist,2),'yx')
plot(lt(:,1),lt(:,2),'r');

c = [b(:,1)*0  b(:,2)];
plot(c(dist,1),c(dist,2),'gx')

c = c*invtransf;

figure
plot(a.Latitude,-a.Depth,'bx')
hold on
plot(l(1,:),l(2,:),'r');
plot(c(:,1),c(:,2),'g+')

% now get the whole thing back to the original; system
a.Latitude = c(:,1);
a.Depth = c(:,2)-dep;


