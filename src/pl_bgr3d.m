report_this_filefun(mfilename('fullpath'));

bvg = bv2;
l = ra > 4.000;
bvg(l)=nan;

%gz = -gz;


figure
clf
[X,Y,Z] = meshgrid(gy,gx,gz);
zs = [   -14 -9 -5 -1] ;
sl1 = 0;
sl2 = [mean(gx)];
sl = slice(X,Y,Z,bvg,sl1, sl2,zs);

hold on
shading interp
rotate3d on
caxis([0.9 1.9])

cob = colorbar('vert')
set(cob,'TickDir','out','pos',[0.8 0.3 0.07 0.3])
set(gca,'Box','on','vis','on')

tmp = ra*nan;
tmp(1,1,1) = 0;
tmp(1,1,2) = 1;
hold on
%sl = slice(X,Y,Z,tmp,sl1, sl2,zs);
%caxis([0.9 1.9])
%set(sl(:),'EdgeColor',[0.4 0.4 0.4],'Linestyle','-','LineWidth',0.1);
colormap(hot)
grid off
brighten(0.5)
view([70 8])
axis([min(gy) max(gy) min(gx) max(gx) min(gz) max(gz)]);
grid off
% plot3(a(:,2),a(:,1),-a(:,7),'wo','MarkerSize',2)


