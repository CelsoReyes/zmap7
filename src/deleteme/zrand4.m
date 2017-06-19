report_this_filefun(mfilename('fullpath'));

bz2 = []; z = [];
p1 = []; p1b=[];p99b=[];p50b=[];pmib=[];pmab=[];
p99 = []; zr =[];
p50 = [];pma=[]; pmi=[];
niv = 1:0.2:4;

tdiff = round((teb - t0b)*365/par1);

def = {'100','300'};
tit ='Random Zmax calculation';
prompt={'Number of events in each window?', 'Number of random samples drawn? (Grid-size)'};

ni2 = inputdlg(prompt,tit,1,def);
l = ni2{1};
nil = str2double(l);
l = ni2{2};
no = str2double(l);


%ni = str2double(prmptdlg('Number of events in each window?','100'));
%no = str2double(prmptdlg('Number of random samples drawn ?','30'));
iwl = iwl*365/par1;
zr = (-15:0.1:15)*0;
wai = waitbar(0,' Please Wait ...  ');
set(wai,'NumberTitle','off','Name','Makegrid  -Percent done');;
n0 = no;
na = no;


for iwl = 1.0:0.2:4
    iwl
    iwl = iwl*365/par1;
    zr = 0;
    na = n0; no = n0;
    while na+1000 > 1000;
        if na > 1000; na = 1000; end
        l = ceil(rand([ni na])*length(a(:,3)));
        [cumu, xt] = hist(reshape(a(l,3),ni,na),(t0b:par1/365:teb));
        for j = 2:tdiff-iwl
            cu = [cumu(1:j-1,:) ; cumu(j+iwl+1:length(cumu(:,1)),:)];
            mean1 = mean(cu);
            mean2 = mean(cumu(j:j+iwl,:));
            var1 = (std(cu)).^2;;
            var2 = (std(cumu(j:j+iwl,:)).^2);
            as = (mean1 - mean2)./(sqrt(var1/(length(cumu(:,1))-iwl)+var2/iwl));
            p1 = [p1 prctile2(as,1)];
            p99 = [p99 prctile2(as,99)];
            p50 = [p50 prctile2(as,50)];
            si =  [ si std(as)];
            pma = [pma max(as)];
            pmi = [pmi min(as)];
            [tmp, tmp2] = hist(as,-15:0.1:15);
            zr = [zr + tmp];
        end     % for j
        p1 = [p1 prctile2(as,1)];
        p99 = [p99 prctile2(as,99)];
        p50 = [p50 prctile2(as,50)];
        pma = [pma max(as)];
        pmi = [pmi min(as)];
        no = no - 1000;
        na = no;
    end % while na

    p1b = [p1b mean(p1) ];
    p99b = [p99b mean(p99) ];
    p50b = [p50b mean(p50) ];
    pmab = [pmab max(pma) ];
    pmib = [pmib min(pmi) ];
    z = [z , zr'];
    p1 = []; p99 = []; p50 = [];pma=[]; pmi=[];
    waitbar((iwl*par1/365)/max(niv));

end  % for iwl

close(wai)
figure
pl =plot(niv,p1b,'b')
hold on
set(pl,'LineWidth',2.0)
pl =plot(niv,p99b,'b')
set(pl,'LineWidth',2.0)
pl =plot(niv,p50b,'r')
pl =plot(niv,pmab,'g--')
set(pl,'LineWidth',2.0)
pl =plot(niv,pmib,'g--')
set(pl,'LineWidth',2.0)
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.2)
grid
xlabel('Windowlength in [years]')
ylabel('Range of z')
title(['ni  =  ' num2str(ni) ' events, ' num2str(n0) ' random samples'])

matdraw

figure
pcolor(z)
shading flat
colormap(jet)
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.2)
xlabel('Windowlength in [years]')
ylabel('Range of z')
title(['ni  =  ' num2str(ni) 'events, ' num2str(n0) ' random samples'])

matdraw
