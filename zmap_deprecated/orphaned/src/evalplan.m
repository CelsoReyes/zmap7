% TODO delete this. looks like someone's play file. has error, undocumented
report_this_filefun(mfilename('fullpath'));

ttcat = newt2;
mati = maepi(1,3);
%[p,sdp] = mypval(3,mati);
% [p,sdp,c,sdc,dk,sdk,aa,bb]=mypval2(3, mati);

tmin1 = 0.05;

p0 = 1.44;
b0 = 0.96;
c0 = 1.1;
A0 = -1.62;

save_aspar2;
do = [ ' ! '  hodi '/aspar/myaspar' ];
eval(do)


load aspar3.out
re = aspar3;

bv = re(2,3);
p =  re(1,3)
c =  re(4,3);
A =  re(3,3);


%[bv magco stan av me mer me2,  pr] =  bvalca3(newt2,1,1);
%[me, bv, si, av] = bmemag(newt2) ;

%A = log10(bv/av)
la = 0;
m0 = maepi(1,6);


m = min(newt2.Magnitude);
dt = 0.5;

%t0 = ( max(newt2.Date) - mati)*365;
t0 = tlen;


la = [];ti = [];
for t = c:dt:t0
    la = [la (10^(A + bv*(m0-m)) * (t + c)^(-p))*dt ];
    ti = [ti mati+t/365];
end

la2 = [];ti2 = [];
for t = c0:dt:t0
    la2 = [la2 (10^(A + b0*(m0-m)) * (t + c0)^(-p0))*dt ];
    ti2 = [ti2 mati+t/365];
end
pla = 0; pla2 = 0;
M = max(a.Magnitude) - 5.;
for t = t0:dt:t0+365
    pla  = pla + (10^(A + bv*(M)) * (t + c)^(-p))  *dt;
    pla2 = pla2 + (10^(A + b0*(M)) * (t + c0)^(-p0))  *dt;
end

P = 1 - exp(-pla)
P0  = 1 - exp(-pla2);
figure_w_normalized_uicontrolunits(cum)

l = newt2.Date >= mati + c/365;
tmpn = newt2(l,:);
nu = (1:length(tmpn(:,3))+1); nu(length(tmpn(:,3))+1) = length(tmpn(:,3));
try delete(plc); catch ME, error_handler(ME,@do_nothing);end
try delete(plc2); catch ME, error_handler(ME,@do_nothing);end
try delete(plc3); catch ME, error_handler(ME,@do_nothing);end

hold on
plc = plot([tmpn(:,3) ; teb],nu,'k');

plc2 = plot(ti,cumsum(la),'r');
%plc3 = plot(ti2,cumsum(la2),'g');





