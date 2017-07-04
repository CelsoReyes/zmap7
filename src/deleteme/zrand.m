report_this_filefun(mfilename('fullpath'));

niv = 50:10:300;
for ni = 50:10:300
    ni
    zr = [];
    for i = 1:100;
        l = ceil(rand([ni 1])*a.Count);
        [cumu, xt] = hist(a(l,3),(t0b:par1/365:teb));
        for j = 2:tdiff-iwl
            cu = [cumu(1:j-1) cumu(j+iwl+1:length(cumu))];
            mean1 = mean(cu);
            mean2 = mean(cumu(j:j+iwl));
            var1 = cov(cu);
            var2 = cov(cumu(j:j+iwl));
            as(j) = (mean1 - mean2)/(sqrt(var1/(length(cumu)-iwl)+var2/iwl));
        end     % for j
        zr = [zr as];
    end
    bz2 = [bz2 ; zr];
end
figure
pl =plot(niv,prctile2(bz2',50),'b')
set(pl,'LineWidth',2.0)
hold on
pl=plot(niv,prctile2(bz2',99),'b')
set(pl,'LineWidth',2.0)
pl=plot(niv,max(bz2'),'b-.')
set(pl,'LineWidth',2.0)
pl=plot(niv,prctile2(bz2',1),'b')
set(pl,'LineWidth',2.0)
pl=plot(niv,min(bz2'),'b-.')
set(pl,'LineWidth',2.0)
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
grid
xlabel('Number of eqs')
ylabel('Range of z')
title('wl = 2 years')


