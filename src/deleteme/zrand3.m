report_this_filefun(mfilename('fullpath'));

bz2 = [];
p1 = [];
p99 = [];
p50 = [];
pma = [];
pmi = [];
si = [];
si0 = [];

tdiff = round((teb - t0b)*365/par1);


def = {'100','300','2'};
tit ='Random Zmax calculation';
prompt={'Number of events in each window?', 'Number of random samples drawn? (Grid-size)',...
    'Window length in years ?'};

ni2 = inputdlg(prompt,tit,1,def);
l = ni2{1};
ni = str2double(l);
l = ni2{2};
no = str2double(l);
l = ni2{3};
iwl= str2double(l);

%ni = str2double(prmptdlg('Number of events in each window?','100'));
%no = str2double(prmptdlg('Number of random samples drawn ?','30'));
%iwl = str2double(prmptdlg('Window length in years ?','1.5'));
iwl = iwl*365/par1;
zr = (-15:0.1:15)*0;
n0 = no;
na = no;

while na+1000 > 1000;
    if na > 1000; na = 1000; end
    l = ceil(rand([ni na])*a.Count);
    [cumu, xt] = hist(reshape(a(l,3),ni,na),(t0b:par1/365:teb));
    for j = 2:tdiff-iwl
        cu = [cumu(1:j-1,:) ; cumu(j+iwl+1:length(cumu(:,1)),:)];
        mean1 = mean(cu);
        mean2 = mean(cumu(j:j+iwl,:));
        %var1 = diag(cov(cu));
        var1 = (std(cu)).^2;;
        var2 = (std(cumu(j:j+iwl,:)).^2);
        as = (mean1 - mean2)./(sqrt(var1/(length(cumu(:,1))-iwl)+var2/iwl));
        p1 = [p1 prctile2(as,1)];
        p99 = [p99 prctile2(as,99)];
        p50 = [p50 prctile2(as,50)];
        si0 =  [ si0 std(as)];
        pma = [pma max(as)];
        pmi = [pmi min(as)];
        [tmp, tmp2] = hist(as,-15:0.1:15);
        zr = [zr + tmp];
    end     % for j
    no = no - 1000;
    na = no
end   % while na

figure
whitebg(gcf,[1.0 1  1   ])
fillbar(tmp2,zr,'k')
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
grid
xlabel('z-value')
ylabel('Number')
title([ num2str(ni) ' events, ' num2str(n0) ' random samples,  Tw = ' num2str(iwl*par1/365) ])
p1 = mean(p1);
p99 = mean(p99);
p50 = mean(p50);
pma = max(pma);
pmi = min(pmi);
si = mean(si0);

te = text(0.6,0.8,['  99 percentile: ' num2str(p99)],'Units','normalized');
te = text(0.6,0.85,['   1 percentile: ' num2str(p1)],'Units','normalized');
te = text(0.6,0.9,['  50 percentile: ' num2str(p50)],'Units','normalized');
te = text(0.6,0.75,['  Max : ' num2str(pma)],'Units','normalized');
te = text(0.6,0.70,['  Min : ' num2str(pmi)],'Units','normalized');
te = text(0.6,0.65,['  STD : ' num2str(si)],'Units','normalized');
te = text(0.6,0.60,['  # samples : ' num2str(max(cumsum(zr)))],'Units','normalized');

drawnow
disp('Plotting normal distribution for comparison....')
n = normrnd(p50,si,max(cumsum(zr)),1);
hold on
[n1,x1] = hist(n,(-15:0.1:15));
stairs(x1,n1)
clear n
disp('Done!')

matdraw

