report_this_filefun(mfilename('fullpath'));

clf
[X,Y,Z] = meshgrid(gx,gy,gz);
v = [];
i = 0.05
ii = 0.05
for i3 = 1:2:length(gx)
    i3 = gx(i3);
    l = loc(1,:) == i3;
    re3 = reshape(as(l),length(gz),length(gy));
    r = reshape(loc(4,l),length(gz),length(gy));
    l = r > tresh;
    re3(l) = zeros(1,length(find(l)))*nan;
    rect = [i ii 0.15 0.15];
    i = i+0.20;
    if i > 0.9 ; i = 0.05 ; ii = ii + 0.20; end
    axes('position',rect)
    pcolor(gy,-gz,re3)
    caxis([min(as) max(as)])
    colormap(jet)
    title([ 'Long=' num2str(i3) ' km'],'FontSize',8)
    set(gca,'FontSize',8')
    hold on
    l = a(:,1) > i3-dx/2 & a(:,1) < i3+dx/2;
    plot3(a(l,2),-a(l,7),a(l,7)*0,'k.')
    shading interp
    % axis('off')
    hold on
end
%colorbar
