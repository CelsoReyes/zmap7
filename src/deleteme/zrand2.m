report_this_filefun(mfilename('fullpath'));

niv = 0.6:0.2:4;
bz2 = [];

tdiff = round((teb - t0b)*365/par1);
wai = waitbar(0,' Please Wait ...  ');
set(wai,'NumberTitle','off','Name','Makegrid  -Percent done');;
ni = str2double(prmptdlg('Number of events in each window?','100'));
na = str2double(prmptdlg('Number of random samples drawn ?','30'));
for iwl = 0.6:0.2:4
    iwl = iwl*365/par1
    zr = [];
    for i = 1:na;
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
    [len,len2] = size(bz2);
    waitbar(len/length(niv))
end
close(wai)
figure
pl =plot(niv,prctile2(bz2',50),'b');
set(pl,'LineWidth',2.0)
hold on
pl=plot(niv,prctile2(bz2',99),'b');
set(pl,'LineWidth',2.0)
pl=plot(niv,max(bz2'),'b-.');
set(pl,'LineWidth',2.0)
pl=plot(niv,prctile2(bz2',1),'b');
set(pl,'LineWidth',2.0)
pl=plot(niv,min(bz2'),'b-.');
set(pl,'LineWidth',2.0)
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.2)
grid
xlabel('Windowlength in [years]')
ylabel('Range of z')
title(['ni  =  ' num2str(ni) 'events, ' num2str(na) ' random samples'])

matdraw


