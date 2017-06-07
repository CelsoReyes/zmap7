report_this_filefun(mfilename('fullpath'));

ti = [];
ret = [];
figure_w_normalized_uicontrolunits(bmapc)
[px,py]  = ginput(1)
hold on
plot(px,py,'w+','era','normal')
drawnow
for ra = 1:0.25:15
    ra
    retpoint
    l = isnan(ret);
    ret(l) = [];

    [i,j] = find(ret == min(min(ret)));
    if isempty(ret) == 1; ret = nan;end

    tru = (teb-t0b)/(10^(bvg(i,8)-(bvg(i,1)-1.3*bvg(i,9))*6));
    trl = (teb-t0b)/(10^(bvg(i,8)-(bvg(i,1)+1.3*bvg(i,9))*6));

    ti = [ti ; min(ret) ra bvg(i,1)  bvg(i,9)  bvg(i,6) bvg(i,8)  -tru+min(ret) trl-min(ret)];
end

figure
rect = [0.20, 0.70, 0.6, 0.25];
axes('position',rect)
%pl = plot(ti(:,2),ti(:,3))
errorbar(ti(:,2),ti(:,3),ti(:,4),ti(:,4))
%set(pl,'LineWidth',2)
hold on
pl = plot(ti(:,2),ti(:,3),'o')
set(pl,'LineWidth',2)
ylabel('b-value')
xl = get(gca,'Xlim');
xl = [0 16];
set(gca,'Xlim',xl);
matdraw


rect = [0.20, 0.40, 0.6, 0.25];
axes('position',rect)
errorbar(ti(:,2),ti(:,6),2*ti(:,4),2*ti(:,4))
%pl = plot(ti(:,2),ti(:,6))
%set(pl,'LineWidth',2)
hold on
pl = plot(ti(:,2),ti(:,6),'o')
set(pl,'LineWidth',2)
ylabel('a-value')
set(gca,'Xlim',xl);

rect = [0.20, 0.10, 0.6, 0.25];
axes('position',rect)
errorbar(ti(:,2),ti(:,1),ti(:,7),ti(:,8))
%pl = plot(ti(:,2),ti(:,1))
set(pl,'LineWidth',2)
set(gca,'Xlim',xl,'Ylim',[0 150]);
hold on
pl = plot(ti(:,2),ti(:,1),'o')
set(pl,'LineWidth',2)
ylabel('Tr [yrs.]')

xlabel('Radius in [km]')
