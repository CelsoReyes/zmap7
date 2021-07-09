
maxmag = ceil(10*max(newt2.Magnitude))/10;
mima = min(newt2.Magnitude);
if mima > 0 ; mima = 0 ; end

[bval,xt2] = hist(newt2.Magnitude,(mima:0.1:maxmag));
% normalise to annula rates
bval = bval/(max(newt2.Date)-min(newt2.Date));
bvalsum = cumsum(bval); % N for M <=
bval2 = bval(length(bval):-1:1);
bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
xt3 = (maxmag:-0.1:mima);

backg_ab = log10(bvalsum3);

figure;delete(gca);delete(gca); delete(gca); delete(gca)
rect = [0.22,  0.2, 0.65, 0.5];           % plot Freq-Mag curves
axes('position',rect);

%%
% plot the cum. sum in each bin  %%
%%

p1 =semilogy(xt3,bvalsum3,'sb');
set(p1,'LineWidth',1.0,'MarkerSize',6,...
    'MarkerFaceColor','w','MarkerEdgeColor','k');
hold on
%pl1 =semilogy(xt3,bval2,'^b');
%set(pl1,'LineWidth',1.0,'MarkerSize',4,...
%    'MarkerFaceColor',[0.7 0.7 .7],'MarkerEdgeColor','k');
ax1 = gca;
rect = [0.22,  0.74, 0.65, 0.2];           % plot Freq-Mag curves
axes('position',rect);
bv2 = [];bv3 = [] ; me = [];BV = [];
ni2 = 250;
BB = [];
TMC = [
    1300 6
    1600 6
    1600 5.5
    1750 5.5
    1750 4.1
    1878 4.1
    1878 3.5
    1975 3.5
    1975 1.8
    2001 1.8];


plot(TMC(:,1),TMC(:,2),'o');
hold on
plot(TMC(:,1),TMC(:,2),'k');
xlabel('Time')
ylabel('Completeness')
set(gca,'XAxisLocation','top');
set(gca,'Xlim',[min(newt2.Date) max(newt2.Date)]);
axes(ax1);

for i = 1:2:length(TMC)-1
    magco = TMC(i,2);
    nn2 = newt2;
    l = nn2(:,6) >= magco;  nn2 = nn2(l,:);
    l = nn2(:,3) >= TMC(i,1) & nn2(:,3) < TMC(i+1,1) ;  nn2 = nn2(l,:);
    if length(nn2(:,1)) >0;

        [bval,xt2] = hist(nn2(:,6),(mima:0.1:maxmag));
        % normalise to annual rates
        bval = bval/(TMC(i+1,1) - TMC(i,1));
        k = mima:0.1:magco;
        bval(1:length(k)) = nan;
        BB = [BB ; bval];
        bvalsum = cumsum(bval); % N for M <=
        bval2 = bval(length(bval):-1:1);
        bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
        hold on
        pl =semilogy(xt3,bvalsum3,'sb');
        set(pl,'LineWidth',1.0,'MarkerSize',4,...
            'MarkerFaceColor',[rand(1,1) rand(1,1) rand(1,1)],'MarkerEdgeColor',[rand(1,1) rand(1,1) rand(1,1)]);
        hold on
    end

end
l = isinf(BB); BB(l) = 0;
allsum = mean(BB, 'omitnan');
allsum2 = allsum(length(allsum):-1:1);
bvalsum3 = cumsum(allsum(length(allsum):-1:1));    % N for M >= (counted backwards)
p2 =semilogy(xt3,bvalsum3,'^b');
set(p2,'LineWidth',1.0,'MarkerSize',10,...
    'MarkerFaceColor','k','MarkerEdgeColor','k');
hold on
xlabel('Magnitude')
ylabel('Annual rate')
legend([p1 p2],'Overall','Mc adjusted');

%xt3 = xt3-0.1;
i = find(allsum2 == max(allsum2));
% now compute the b-value
magco = max(xt3(i));
y = (allsum2(1:i));
x = xt3(1:i);
l = y>0; miy = min(y(l));
y0 = y;
y = (y/miy);

mean_ml = sum(x.*y)/sum(y);
bw = (1/(mean_ml - magco + 0.05))*log10(exp(1));
aw = log10(sum(y0))+ bw*magco;



%l = xt3 >= M1b(1) & xt3 <= M2b(1); x2 = xt3(l);
%y2 = backg_ab(l);
%[aw bw,  ew] = wls(x2',y2');

p = [ -bw aw];
%[p,S] = polyfit(mag_zone,y,1);
f = polyval(p,x);
f = 10.^f;
hold on
ttm= semilogy(x,f,'r');                         % plot linear fit to backg
set(ttm,'LineWidth',1.5)


p=-p(1,1);
p=fix(100*p)/100;
tt1=num2str(bw,3);
tt2=num2str(nan,1);
tmc=num2str(magco,2);

rect=[0 0 1 1];
h2=axes('position',rect);
set(h2,'visible','off');

txt1=text(.16, .05,['b-value = ',tt1,' +/- ',tt2,',  a value = ',num2str(aw,3) ', Mc = ' num2str(magco) ],'FontSize',ZmapGlobal.Data.fontsz.s);
set(txt1,'FontWeight','normal')
set(gcf,'PaperPosition',[0.5 0.5 4.0 5.5])
text(.16, .09,'Adjusted completeness solution','FontSize',ZmapGlobal.Data.fontsz.s );
axes(ax1)
