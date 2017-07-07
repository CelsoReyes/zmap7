report_this_filefun(mfilename('fullpath'));


dy = 0.15;
dx = 0.15 ;
dz = 0.30 ;
ni = 150;

%a.Longitude = (a.Longitude - mean(a.Longitude))*111;
%a.Latitude = (a.Latitude - mean(a.Latitude))*111;
xc = 0; yc = 0; zc =0 ;
x0 = min(a.Longitude); x1 = max(a.Longitude);
y0 = min(a.Latitude); y1 = max(a.Latitude);
z0 = min(a.Depth); z1 = max(a.Depth);
xv = x0:dx:x1;yv= y0:dy:y1;zv = z0:dz:z1;
bvg = ones(length(x0:dx:x1),length(y0:dy:y1),length(z0:dz:z1));
ra = ones(length(x0:dx:x1),length(y0:dy:y1),length(z0:dz:z1));
itotal = length(x0:dx:x1)*length(y0:dy:y1)*length(z0:dz:z1)

wai = waitbar(0,' Please Wait ...  ');
set(wai,'NumberTitle','off','Name','b-value grid - percent done');;
drawnow

allcount = 0;
i2 = 0;
for x = x0:dx:x1
    xc = xc+1;
    for y = y0:dy:y1
        yc = yc+1;
        for z = z0:dz:z1
            zc = zc+1;
            allcount = allcount + 1.;
            i2 = i2+1;

            % calculate distance from center point and sort wrt distance
            l = sqrt(((a.Longitude - x)).^2 + ((a.Latitude - y).^2 + ((a.Depth - z)).^2)) ;
            [s,is] = sort(l);
            b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise

            % take first ni points
            b = b(1:ni,:);      % new data per grid point (b) is sorted in distance

            % call the b-value function
            [bv magco stan av me mer me2,  pr] =  bvalca3(b,inb1,inb2);
            l2 = sort(l);
            b2 = b;
            %if inb2 ==  1
            %l = b(:,6) >= magco;
            %b2 = b(l,:);
            %end
            %[av2 bv2 stan2 ] =  bmemag(b2);
            bvg(xc,yc,zc) = bv;
            ra(xc,yc,zc) = l2(ni);
            waitbar(allcount/itotal)
        end   % for z
        zc = 0;
    end   % for y
    yc = 0;
end   % for x
xc = 0;

close(wai)

bv2 = bvg;
bvg = bv2;
l = ra > 2.500;
bvg(l)=nan;
figure
[X,Y,Z] = meshgrid(yv,xv,zv);
zs = [z0:4*dz:z1]
sl = slice(X,Y,Z,bvg,[x0+3*dx],[y0+4*dy],zs)
clf
sl1 = slice(X,Y,Z,bvg,x1-6*dx,y1-6*dy,[ z0+4*dz 9 14])
hold on
%plot3(a.Latitude,a.Longitude,a.Depth,'k.','MarkerSize',2)
rotate3d on
caxis([1.8 2.8])
set(gca,'XLim',[-3 3 ],'xgrid','off')
set(gca,'YLim',[-3 3 ],'ygrid','off')
set(gca,'ZLim',[  -1 20 ],'zgrid','off')
colormap(h)
shading interp
cob = colorbar('vert')
set(cob,'TickDir','out','pos',[0.8 0.3 0.07 0.3])
set(gca,'Box','on','vis','on')
tmp = ra*nan;
tmp(1,1,1) = 0;
tmp(1,1,2) = 1;
hold on
sl = slice(X,Y,Z,tmp,x1-6*dx,y1-6*dy,[ z0+4*dz 9 14 ])
set(sl(:),'EdgeColor','w')
caxis([1.8 2.8])
view([-36 10])

