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
iwl = iwl*365/par1;
zr = (-15:0.1:15)*0;
wai = waitbar(0,' Please Wait ...  ');
set(wai,'NumberTitle','off','Name','Makegrid  -Percent done');;
zr = [];
for k=1:nr
    l = ceil(rand([ni na])*a.Count);
    [cumu, xt] = hist(reshape(a(l,3),[ni,na]),(t0b:par1/365:teb));
    for ti = 1:ni
        mean1 = mean([cumu(1:ti-1,:) ; cumu(ti+iwl+1:ni,:)]);
        mean2 = mean(cumu(ti:ti+iwl,:));
        var1 = cov([cumu(1:ti-1,:) ; cumu(ti+iwl+1:ni,:)]);
        var2 = cov(cumu(ti:ti+iwl,:));
    end     % for i
    as = (mean1 - mean2)./(sqrt(var1/(len-iwl)+var2/iwl));




    pmab = [pmab max(pma) ];
    pma=[];
    waitbar(k/nr);
end


close(wai)
figure
histogram(pmab)
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
grid
xlabel('Windowlength in [years]')
ylabel('Range of z')
title(['ni  =  ' num2str(ni) 'events, ' num2str(na) ' random samples'])

matdraw

