ttcat = newt2;
mati = maepi(1,3);


bv = 0.89;
p =  1.19;
c =  0.05
A =  -1.4;


%[bv magco stan av me mer me2,  pr] =  bvalca3(newt2,1,1);
%[me, bv, si, av] = bmemag(newt2) ;

%A = log10(bv/av)
la = 0;
m0 = 7.0

m = 3.5
dt = 0.1;
t0 = 30;

la = [];ti = [];
for t = c:dt:t0
    la = [la (10^(A + bv*(m0-m)) * (t + c)^(-p))*dt ];
    ti = [ti t];
end

sum(la)
YI = interp1(cumsum(la),ti,1:le,'linear',c);
figure
plc2 = plot(ti,cumsum(la),'r');

synthb

ma = a.Magnitude;
ma2 = ma(randperm(length(a)));
le = length(ma2);



% makle synyth b here
T = datenum(2001,1,1,0,0,0);
T2 = T+YI;
[y,m,d,h,mi,s] = datevec(T2);

a.Longitude = 10 + randn(le,1)/4;
a.Latitude = 46 + randn(le,1)/9;
a.Date = 2001+YI'/365;
a.Date.Month = m';
a.Date.Day = d';
a.Magnitude = ma2;
a.Depth = ma2*0+5;
a.Date.Hour = h';
a.Date.Minute = mi';

a = [  10 46 2001 1 1 7 5 1 1 ; a];

mainmap_overview()

