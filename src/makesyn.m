report_this_filefun(mfilename('fullpath'));

m = [];
m =0:0.1:max(newt2.Magnitude);
m2 =min(newt2.Magnitude):0.1:max(newt2.Magnitude);
m3 = 10.^(-(m2-min(newt2.Magnitude)));
m3 = m3*newt2.Count;

k = 0:0.1:min(newt2.Magnitude)-0.1;
m4 = k*8+newt2.Count;
m = [m4 m3];
clf
%plot(0:0.1:max(newt2.Magnitude),log10(m))
%grid
%hold on
newcat = newt2;

lepo = length(m) -1;
mm = [newt2.Count m(1:lepo) ];
bval = mm-m;
bvalfl = bval(length(bval):-1:1);
maxmag = max(newcat.Magnitude);
mima = min(newcat.Magnitude);
if mima > 0 ; mima = 0 ; end

% number of mag units
nmagu = (maxmag*10)+1;

bvalsum = zeros(1,nmagu);
bvalsum3 = zeros(1,nmagu);

bvalsum = m;
bvalsum3 = m(length(m):-1:1);
xt3 = (maxmag:-0.1:mima);


backg_be = log10(bvalsum);
backg_ab = log10(bvalsum3);
orient tall
rect = [0.2,  0.3, 0.70, 0.6];           % plot Freq-Mag curves
axes('position',rect);

semilogy(xt3,bvalsum3,'-.m')
hold on
semilogy(xt3,bvalsum3,'om')
difb = [0 diff(bvalsum3) ];
semilogy(xt3,difb,'xg')
semilogy(xt3,difb,'g')
grid

% Marks the point of maximum curvature
%
i = find(difb == max(difb));
te = semilogy(xt3(i),difb(i),'xk');
set(te,'LineWidth',2,'MarkerSize',ms10)
te = semilogy(xt3(i),bvalsum3(i),'xk');
set(te,'LineWidth',2,'MarkerSize',ms10)

% Estimate the b-value
%
i2 = round(i/3);
te = semilogy(xt3(i2),difb(i2),'xk');
set(te,'LineWidth',2,'MarkerSize',ms10)
te = semilogy(xt3(i2),bvalsum3(i2),'xk');
set(te,'LineWidth',2,'MarkerSize',ms10)

xlabel('Magnitude','FontWeight','bold','FontSize',fontsz.m)
ylabel('Cumulative Number','FontWeight','bold','FontSize',fontsz.m)
set(gca,'Color',[1 1 0.6])
set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on')


par2 = 0.1 * max(bvalsum3);
par3 = 0.12 * max(bvalsum3);
M1b = [];
M1b = [xt3(i) bvalsum3(i)];
tt3=num2str(fix(100*M1b(1))/100);
text( M1b(1),M1b(2),['|: M1=',tt3] )

M2b = [];
M2b =  [xt3(i2) bvalsum3(i2)];
tt4=num2str(fix(100*M2b(1))/100);
text( M2b(1),M2b(2),['|: M2=',tt4] )

ll = xt3 > M1b(1) & xt3 < M2b(1);
x = xt3(ll);

l = newcat.Magnitude > M1b(1) & newcat.Magnitude < M2b(1);
me = 0.4343/(sum(bval.*xt3)/(sum(bval))-M1b(1));
mer = 1.96*me/(sqrt(length(newcat(l,6))));


so = log10(bval(10*M1b(1)+2)) - log10(bval(10*M2b(1)));
me= so/( M2b(1)-0.2- M1b(1));

pause(0.1)

y = backg_ab(ll);
[p,s] = polyfit(x,y,1);                   % fit a line to background
f = polyval(p,x);
f = 10.^f;
hold on
ttm= semilogy(x,f,'b');                         % plot linear fit to backg
set(ttm,'LineWidth',2)
r = corrcoef(x,y);
r = r(1,2);
std_backg = std(y - polyval(p,x));      % standard deviation of fit

p=-p(1,1);
p=fix(100*p)/100;
std_backg=fix(100*std_backg)/100;
tt2=num2str(std_backg);
tt1=num2str(p);

global n les

n = length(x)+3;
l = b(:,6) > M1b(1) & b(:,6) <= M2b(1);
les = (mean(b(l,6)) - (M1b(1)+0.05))/0.1;
%les =  (sum(bvalfl.*xt3)/(sum(bval))-M1b(1))/0.1;
%so = fzero('y = les - ( x/(1-x) - n*x^n/(1-x^n) ); ',1);
so = fzero('sofu',1.0);
me2 = log(so)/(-2.3026*0.1)


rect=[0 0 1 1];
h2=axes('position',rect);
set(h2,'visible','off');

txt1=text(.16, .18,['B-Value(L2): ',tt1,'  B(eff): ',num2str(me), '  B(mean2)= ',num2str(me2)]);
set(txt1,'FontWeight','bold','FontSize',fontsz.m)
txt1=text(.16, .1,['Standard Deviation: ',tt2]);
set(txt1,'FontWeight','bold','FontSize',fontsz.m)
set(gcf,'visible','on');
zmap_message_center.set_info('  ','Done')
done





