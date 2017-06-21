bz2 = [];
p1 = [];
p95 = [];
p90 = [];
p50 = [];
pmab = [];
pma = [];
pmi = [];
pmib = [];
si = [];

tdiff = round((teb - t0b)*365/par1);
def = {'100','300','100','2'};
tit ='Random Zmax calculation';
prompt={'-----------------------------------', 'Number of random samples drawn? (Grid-size)',...
    'Number of repeats?','------------------------'};

ni2 = inputdlg(prompt,tit,1,def);
l = ni2{4};
iwl = str2double(l);
l = ni2{3};
nr = str2double(l);
l = ni2{2};
no = str2double(l);
n02 = no;
l = ni2{1};
ni = str2double(l);

y = 50:20:250;
x = 0.5:0.250:4;
si = length(x) * length(y);
co1 = 0;
for ni = 50:20:250;
    for dt = 0.5:0.25:4;
        ni
        dt
        co1 = co1+1;

        tic
        pmab = [];
        pmib = [];
        pma = [];
        pmi = [];

        iwl = floor(dt*365/par1);
        zr = (-15:0.1:15)*0;
        n0 = no;
        na = no;


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
            pmib = [pmib min(pmi)];
        end   % for k
        no = n02;

        ti = toc;
        togo = ((si-co1)*ti)/(60*60);
        disp(['Time to go: ' num2str(togo) ' hours'])

        p95 = [p95 ; prctile2(pmab,95) dt ni prctile2(pmib,5) ];
        p90 = [p90 ; prctile2(pmab,90) dt ni prctile2(pmib,10) ];
        p50 = [p50 ; prctile2(pmab,90) dt ni prctile2(pmib,50)];

    end   %  for iwl
end   % for bi



figure

re = reshape(p95(:,1),length(x),length(y));
ma = ceil(max(max(re)));
mi = floor(min(min(re)));
contourf(y,x,re,(mi:0.5:ma));

g = gray(15);
g = g(15:-1:1,:);

colormap(g)

c = contourc(y,x,re,(mi:0.5:ma))
clabel(c)

brighten(0.7)
set(gca,'FontSize',fontsz.m,'FontWeight','normal',...
    'FontWeight','bold','LineWidth',3.0,...
    'Box','on','SortMethod','childorder','TickDir','out')
set(gcf,'PaperPosition', [2. 1 5.0 4.0])
colorbar
title('JMA Kanto, 95% Zmax values')
xlabel('Sample size (N)')
ylabel('Window length in yrs')


figure
re = reshape(p95(:,4),length(x),length(y));
ma = ceil(max(max(re)));
mi = floor(min(min(re)));
mi = -15;
contourf(y,x,re,(mi:1.0:ma));

g = gray(15);
colormap(g)
caxis([mi ma])

c = contourc(y,x,re,(mi:1.0:ma))
clabel(c)

brighten(0.7)
set(gca,'FontSize',fontsz.m,'FontWeight','normal',...
    'FontWeight','bold','LineWidth',3.0,...
    'Box','on','SortMethod','childorder','TickDir','out')
set(gcf,'PaperPosition', [2. 1 5.0 4.0])
colorbar
title('JMA Kanto, 95% Zmin values')
xlabel('Sample size (N)')
ylabel('Window length in yrs')
matdraw


