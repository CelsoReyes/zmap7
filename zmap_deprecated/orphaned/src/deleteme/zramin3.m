report_this_filefun(mfilename('fullpath'));

bz2 = [];
p1 = [];
p99 = [];
p50 = [];
pmab = [];
pma = [];
pmib = [];
pmi = [];
si = [];

tdiff = round((teb - t0b)*365/par1);
def = {'100','300','100','2'};
tit ='Random Zmax calculation';
prompt={'Number of bins in each time series?', 'Number of random samples drawn? (Grid-size)',...
    'Number of repeats?','Window length in years ?'};

ni2 = inputdlg(prompt,tit,1,def);
l = ni2{4};
iwl = str2double(l);
l = ni2{3};
nr = str2double(l);
l = ni2{2};
no = str2double(l);
l = ni2{1};
ni = str2double(l);

iwl0 = iwl;
iwl = floor(iwl*365/par1);
zr = (-15:0.1:15)*0;
n0 = no;
na = no;

titStr ='Warning!                                        ';

messtext= ...
    ['                                                '
    ' This rotine sometimes takes a long time!       '
    '  and may run out of memory. You can interupt   '
    ' the calculation with a ^C. The results         '
    ' calculated so far are stored in the variable   '
    ' pmab and save to a *.mat file                  '];

zmap_message_center.set_message(titStr,messtext);
figure_w_normalized_uicontrolunits(mess)

[newmatfile, newpath] = uiputfile([hodi '/*.mat'], 'Filename for saving of intermediate results ');

wai = waitbar(0,' Please Wait ...  ');
set(wai,'NumberTitle','off','Name','Percent done');;
watchon
think

con = 0;
rng('shuffle')
for k=1:nr
    na = n0; no = n0;
    while na+100 > 100;
        if na  > 100 ; na == 100; end
        con = con+1;
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
            pma = [pma max(as)];
            pmi = [pmi min(as)];
        end     % for j
        pmab = [pmab max(pma) ];
        pmib = [pmib min(pmi) ];
        pma = [];pmi =[];
        no = no - 100;
        na = no;
    end   % while na
    pmab = [pmab max(pma) ];
    pmib = [pmib min(pmi) ];
    waitbar(k/nr);
    do = ['save '  newpath newmatfile  ' pmab pma pmib pmi iwl0  con n0 nr ni '];
    eval(do,'disp(''Error while trying to save intermediate results! Permission? '') ')
end   % for k

close(wai)

figure

histogram(pmab)
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
grid
xlabel('Zmax')
ylabel('Number ')
clear title
title(['ni =' num2str(ni) ', #samples = ' num2str(n0) ', #repeats=' num2str(con*nr), ', Tw= ' num2str(iwl0)]) ;


matdraw

figure

histogram(pmib)
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
grid
xlabel('Zmin')
ylabel('Number ')
clear title
title(['ni =' num2str(ni) ', #samples = ' num2str(n0) ', #repeats=' num2str(con*nr), ', Tw= ' num2str(iwl0)]) ;


matdraw
