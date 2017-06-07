report_this_filefun(mfilename('fullpath'));


maxmag = max(newcat(:,6));
mima = min(newcat(:,6));
if mima > 0 ; mima = 0 ; end

% number of mag units
nmagu = (maxmag*10)+1;

bval = zeros(1,nmagu);
bvalsum = zeros(1,nmagu);
bvalsum3 = zeros(1,nmagu);

[bval,xt2] = hist(newcat(:,6),(mima:0.1:maxmag));
bvalsum = cumsum(bval);                        % N for M <=
bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
xt3 = (maxmag:-0.1:mima);


backg_be = log10(bvalsum);
backg_ab = log10(bvalsum3);

pl =semilogy(xt3,bvalsum3,'b');
set(pl,'LineWidth',1.0,'MarkerSize',4)
hold on
pl =semilogy(xt3,bvalsum3,'om')
set(pl,'LineWidth',1.0,'MarkerSize',4)
difb = [0 diff(bvalsum3) ];
pl =semilogy(xt3,difb,'g');
set(pl,'LineWidth',1.0)
semilogy(xt3,difb,'g')

% % Marks the point of maximum curvature
% %
% i = find(difb == max(difb));
% i = max(i);
% te = semilogy(xt3(i),difb(i),'xk');
% set(te,'LineWidth',1,'MarkerSize',6)
% te = semilogy(xt3(i),bvalsum3(i),'xk');
% set(te,'LineWidth',1,'MarkerSize',6)

% Estimate the b-value
%
i2 = 1 ;
te = semilogy(xt3(i2),difb(i2),'xk');
set(te,'LineWidth',1,'MarkerSize',6)
te = semilogy(xt3(i2),bvalsum3(i2),'xk');
set(te,'LineWidth',1,'MarkerSize',6)

xlabel('Magnitude','FontWeight','normal','FontSize',fontsz.m)
ylabel('Cumulative Number','FontWeight','normal','FontSize',fontsz.m)
set(gca,'Color',[cb1 cb2 cb3])
set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','normal',...
    'FontWeight','normal','LineWidth',1.5,...
    'Box','on')

cua = gca;


par2 = 0.1 * max(bvalsum3);
par3 = 0.12 * max(bvalsum3);
M1b = [];
M1b = [xt3(i) bvalsum3(i)];
tt3=num2str(fix(100*M1b(1))/100);
%text( M1b(1),M1b(2),['|: M1=',tt3],'Fontweight','normal' )

M2b = [];
M2b =  [xt3(i2) bvalsum3(i2)];
tt4=num2str(fix(100*M2b(1))/100);
%text( M2b(1),M2b(2),['|: M2=',tt4],'Fontweight','normal' )

ll = xt3 >= M1b(1) & xt3 <= M2b(1);
x = xt3(ll);

[ av, bv, si] = bmemag(newcat)  ;


pause(0.1)

y = backg_ab(ll);
%[p,s] = polyfit(x,y,1)                    % fit a line to background
[aw bw,  ew] = wls(x',y');
p = [bw aw];
f = polyval(p,x);
(teb-t0b)/(10.^ polyval(p,6.5))
f = 10.^f;
hold on
ttm= semilogy(x,f,'r');                         % plot linear fit to backg
set(ttm,'LineWidth',1)
set(gca,'XLim',[min(newcat(:,6))-0.5  max(newcat(:,6))+0.3])
r = corrcoef(x,y);
r = r(1,2);
%std_backg = std(y - polyval(p,x));      % standard deviation of fit
std_backg = ew;      % standard deviation of fit

p=-p(1,1);
p=fix(100*p)/100;
std_backg=fix(100*std_backg)/100;
tt1=num2str(p);
tt2=num2str(std_backg);
tt4=num2str(bv,2);
tt5=num2str(si,2);

rect=[0 0 1 1];
h2=axes('position',rect);
set(h2,'visible','off');

txt1=text(.60, .43,['b(wls, M  > ', num2str(M1b(1)) '): ',tt1, ' +/- ', tt2]);
set(txt1,'FontWeight','normal','FontSize',fontsz.m)
%txt1=text(.16, .12,['b-value (max lik, M > ', num2str(min(newcat(:,6))) '): ',tt4, ' +/- ', tt5]);
set(txt1,'FontWeight','normal','FontSize',fontsz.m)
set(gcf,'PaperPosition',[0.5 0.5 4.0 5.5])

