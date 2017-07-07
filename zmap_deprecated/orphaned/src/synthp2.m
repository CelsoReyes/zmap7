
bv = 0.91;
p =  1.08;
c =  0.45
A =  -1.67;

dt = 0.01;
t0 = 30;

la = 0;
m = 3;
m0 = 7.0

la = [];ti = [];
for t = c:dt:t0
    la = [la (10^(A + bv*(m0-m)) * (t + c)^(-p))*dt ];
    ti = [ti t];
end

sum(la)

figure
plc2 = plot(ti,cumsum(la),'r');

xlabel('Time in days')
ylabel('Cumulative number')



