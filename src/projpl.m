report_this_filefun(mfilename('fullpath'));

l = a(:,6) > 6.6;
maepi = a(l,:);

lat1 = maepi(1,2);
lon1 = maepi(1,1);
dep = maepi(1,7);
[xsecx xsecy,  inde] =mysect(tmp1,tmp2,a(:,7),50,40,lat1,lon1,[122-90]);
global eq1

% this is rotate rect to the strike
a(:,1)= -eq1(2,:)';
a(:,2) = eq1(1,:)';

l = a(:,6) > 6.5;
maepi = a(l,:);
a(:,7) = a(:,7)-maepi(1,7);

% lets see what we got
figure
plot(a(:,2),-a(:,7),'x')
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


b = [a(:,2) -a(:,7)];
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
plot(a(:,2),-a(:,7),'bx')
hold on
plot(l(1,:),l(2,:),'r');
plot(c(:,1),c(:,2),'g+')

% now get the whole thing back to the original; system
a(:,2) = c(:,1);
a(:,7) = c(:,2)-dep;


