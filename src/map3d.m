report_this_filefun(mfilename('fullpath'));

clf
[X,Y,Z] = meshgrid(gx,gy,gz);
v = [];
main = [ -174.83 51.412 33];
i = 0.05
ii = 0.05
for i3 = z0:1*dz:z1
    l = loc(3,:) == i3;
    re3 = reshape(as(l),length(gy),length(gx));
    r = reshape(loc(4,l),length(gy),length(gx));
    l = r > tresh;
    re3(l) = zeros(1,length(find(l)))*nan;
    rect = [i ii 0.15 0.15];
    i = i+0.20;
    if i > 0.9 ; i = 0.05 ; ii = ii + 0.20; end
    axes('position',rect)
    pcolor(gx,gy,re3)
    caxis([min(as) max(as)])
    colormap(jet)
    title([ 'Depth ' num2str(i3) ' km'], 'FontSize',8)
    set(gca,'FontSize',8')

    hold on
    l = a(:,7) > i3-dz/2 & a(:,7) < i3+dz/2;
    plot3(a(l,1),a(l,2),a(l,7)*0,'k.')
    shading interp
    % axis('off')
    pl =plot3(main(:,1),main(:,2),main(:,3)*0,'xk');
    set(pl,'LineWidth',2)
    hold on

end

