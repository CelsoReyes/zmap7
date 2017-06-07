report_this_filefun(mfilename('fullpath'));

s = t(:,1);
yr = floor(s/10000);
mo = floor((s - yr*10000)/100);
da = floor((s - yr*10000 - mo*100));
s = t(:,2);
hr = floor(s/100);
mi = floor(s - hr*100);
a = [ -t(:,6)-t(:,7)*10/6/100 t(:,4)+t(:,5)*10/6/100 yr mo da t(:,9) t(:,8) hr mi ];
a(:,3) = decyear(a(:,[3:5 8 9]));

load /home/stefan/ZMAP/eq_data/out.dat

a = [a   out];

