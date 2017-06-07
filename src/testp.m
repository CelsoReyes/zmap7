report_this_filefun(mfilename('fullpath'));

bv = 0.91;
p =  1.8
c =  1.05;
A =  -1.67

la = 0;
m0 = 7.1

m = 2.5

dt = 0.1;


la = [];ti = [];
for t = c:dt:7
    la = [la (10^(A + bv*(m0-m)) * (t + c)^(-p))*dt ];
    ti = [ti t ];
end

figure
plot(ti,cumsum(la),'b');
hold on

dt = 1;

la = [];ti = [];
for t = c:dt:7
    la = [la (10^(A + bv*(m0-m)) * (t + c)^(-p))*dt ];
    ti = [ti t ];
end
plot(ti,cumsum(la),'r');

tic
dt = 0.001;
la = [];ti = [];
for t = c:dt:7
    la = [la (10^(A + bv*(m0-m)) * (t + c)^(-p))*dt ];
    ti = [ti t ];
end
plot(ti,cumsum(la),'g');
toc

tic

tv = logspace(-3,log10(7.0),300);

la = [];ti = [];
for i = 2:length(tv)-1
    t = c+tv(i);
    dt = tv(i) - tv(i-1);

    la = [la (10^(A + bv*(m0-m)) * (t + c)^(-p))*dt ];
    ti = [ti t ];
end
plot(ti,cumsum(la),'k');

toc






