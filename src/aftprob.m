report_this_filefun(mfilename('fullpath'));

p=round(p*100)/100;
sdp=round(sdp*100)/100;
c=round(c*1000)/1000;
sdc=round(sdc*1000)/1000;
dk=round(dk*100)/100;
sdk= round(sdk*100)/100;
aa=round(aa*100)/100;
bb=round(bb*100)/100;



ttcat = newt2;
[p,sdp,c,sdc,dk,sdk,aa,bb]=mypval2(var1, mati);

aa = -1.67;
bb = 0.91;
p = 1.08;
c = 0.05;
Mm = 6.5;
M = Mm -1; %
M = 6.5;   %WARNING overrides previous value.


% Lets integrate...
la = 0;
dm = 0.1;
dt = 0.01;

for t = 0.01:dt:365
    la = la + (10^(aa + bb*(Mm-M)) * (t + c)^(-p))  *dt;
end

P = 1- exp(-la)


