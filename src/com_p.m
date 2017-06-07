report_this_filefun(mfilename('fullpath'));

b = newt2;
tmin1 =0.00005;

mati = maepi(1,3);
l = b(:,3) > mati + tmin1/365;
[bv magco stan av me mer me2,  pr] =  bvalca3(b(l,:),1,1);
%l = b(:,6) > magco+0.1;
b2 = b;
if inb2 ==  1
    l = b(:,6) >= magco;
    b2 = b(l,:);
end
[av2 bv2 stan2 ] =  bmemag(b2);


save_aspar2;
do = [ ' ! '  hodi '/aspar/myaspar' ];
eval(do)

load aspar3.out
re = aspar3;

