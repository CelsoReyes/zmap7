report_this_filefun(mfilename('fullpath'));


% plot the results
% old and re3 (initially ) is the b-value matrix
%
re3=zvg;
r=ra;


zv2 = zvg;
l = ra > 30.00;
zvg(l)=nan;
figure
clf
[X,Y,Z] = meshgrid(gy,gx,gz);
zs = [-16 -12 -7 -1];
sl = slice(X,Y,Z,zvg,[mean(gy)] ,[ mean(gx)],[-20 -50]);

clf
sl = slice(X,Y,Z,pro,X2,Y2,Z2);
hold on
sl = slice(X,Y,Z,pro,X2,Y2,Z2);


hold on
rotate3d on
caxis([0 0.3])
%set(gca,'XLim',[s1_east s2_west],'xgrid','off')
%set(gca,'YLim',[s4_south s3_north],'ygrid','off')
%set(gca,'ZLim',[ -max(a.Depth)-2 0 ],'zgrid','off')

shading interp
cob = colorbar('vert')
set(cob,'TickDir','out','pos',[0.8 0.3 0.07 0.3])
set(gca,'Box','on','vis','on')
tmp = ra*nan;
tmp(1,1,1) = 0;
tmp(1,1,2) = 1;
hold on
sl = slice(X,Y,Z,tmp,[mean(gy)] ,[ -118.6],zs);
caxis([0 0.4])
set(sl(:),'EdgeColor',[0.5 0.5 0.5]);
view([-36 10])
axis([min(gy) max(gy) min(gx) max(gx) min(gz) max(gz)]);
grid off
plot3(a.Latitude,a.Longitude,-a.Depth,'yo','MarkerSize',2)
hold on

main =  [ -118.5370   34.2133   94.0453    1.0000   17.0000    6.7000   18.4010];

epimax = plot3(main(:,2),main(:,1),-main(:,7),'hm');
set(epimax,'LineWidth',2.5,'MarkerSize',18,...
    'MarkerFaceColor','w','MarkerEdgeColor','r')
hold on
aft1 = [ -118.6700   34.3692   97.3163    4.0000   26.0000    5.1000   16.4510];
epimax = plot3(aft1(:,2),aft1(:,1),-aft1(:,7),'^m');
set(epimax,'LineWidth',2.5,'MarkerSize',16,...
    'MarkerFaceColor','w','MarkerEdgeColor','m')

