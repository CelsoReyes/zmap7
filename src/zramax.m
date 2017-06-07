report_this_filefun(mfilename('fullpath'));

bz2 = [];
p1 = []; p1b=[];p99b=[];p50b=[];pmib=[];pmab=[];
p99 = [];
p50 = [];pma=[]; pmi=[];
niv = 1:0.2:4;

tdiff = round((teb - t0b)*365/par1);
ni = str2double(prmptdlg('Number of events in each window?','100'));
na = str2double(prmptdlg('Number of random samples drawn ?','30'));
nr = str2double(prmptdlg('Number of repeats ?','30'));
iwl = str2double(prmptdlg('windowlength ?','2'));
iwl0 = iwl;
iwl = iwl*365/par1;
zr = (-15:0.1:15)*0;
wai = waitbar(0,' Please Wait ...  ');
set(wai,'NumberTitle','off','Name','Makegrid  -Percent done');;
zr = [];
for k=1:nr
    for i = 1:na;
        l = ceil(rand([ni 1])*length(a(:,3)));
        [cumu, xt] = hist(a(l,3),(t0b:par1/365:teb));
        for j = 2:tdiff-iwl
            cu = [cumu(1:j-1) cumu(j+iwl+1:length(cumu))];
            mean1 = mean(cu);
            mean2 = mean(cumu(j:j+iwl));
            var1 = cov(cu);
            var2 = cov(cumu(j:j+iwl));
            as(j) = (mean1 - mean2)/(sqrt(var1/(length(cumu)-iwl)+var2/iwl));
        end     % for j
        pma = [pma max(as)];
    end
    pmab = [pmab max(pma) ];
    pma=[];
    waitbar(k/nr);
end


close(wai)
figure
histogram(pmab)
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.2)
grid
xlabel('Zmax')
ylabel('Number ')
title(['ni  =  ' num2str(ni) ', #samples = ' num2str(na) ', #repeats=' num2str(nr) ', Tw= ' num2str(iwl0)]);

matdraw

