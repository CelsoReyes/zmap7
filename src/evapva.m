report_this_filefun(mfilename('fullpath'));

ttcat = newt2;
mati = maepi(1,3);
%[p,sdp] = mypval(3,mati);
% [p,sdp,c,sdc,dk,sdk,aa,bb]=mypval2(3, mati);

tmin1 = 0.05;


save_aspar2;
do = [ ' ! '  hodi '/aspar/myaspar' ];
eval(do)


load aspar3.out
re = aspar3;

bv = re(2,2);
p =  re(1,2)
c =  re(4,2);
A =  re(3,2);


%[bv magco stan av me mer me2,  pr] =  bvalca3(newt2,1,1);
%[me, bv, si, av] = bmemag(newt2) ;

%A = log10(bv/av)
la = 0;
m0 = maepi(1,6);

m = min(newt2.Magnitude);
dt = 1;

t0 = ( max(newt2.Date) - mati)*365;

c

la = [];ti = [];
for t = c:dt:t0
    la = [la (10^(A + bv*(m0-m)) * (t + c)^(-p))*dt ];
    ti = [ti mati+t/365];
end

figure_w_normalized_uicontrolunits(cum)

l = newt2.Date >= mati + c/365;
tmpn = newt2(l,:);
nu = (1:length(tmpn(:,3))+1); nu(length(tmpn(:,3))+1) = length(tmpn(:,3));

try delete(plc); catch ME, error_handler(ME,@do_nothing);end
try delete(plc2); catch ME, error_handler(ME,@do_nothing);end

hold on
plc = plot([tmpn(:,3) ; teb],nu,'k');

plc2 = plot(ti,cumsum(la),'r');




