report_this_filefun(mfilename('fullpath'));

% compute the source zones for landers

dy = 0.15;
tmin1 = 0.05
mati = maepi(1,3);
%M = 7.1 - 5.;
da = []; anz = [];
B = [];
tpre = 30;
prol = 0.33
dt = 0.1;

cd /home2/stefan/ZMAP/aspar
fid2 = fopen('sourczones.txt','w');

l1 = prctile2(a.Latitude,33)
l1 = prctile2(a.Latitude,66)
for y = 34.34:dy:34.8
   l = a.Latitude >= y & a.Latitude < y+dy;
   b1 = prctile2(a(l,1),25);
   b2 = prctile2(a(l,1),75);

   newt2 = a.subset(l);
   calcp
   B = [B ; b1 y  b2 y];

   anz = [];
   for m2 = 4.75:0.5:7.25
      M2 = maepi(1,6) - m2;
      t0 = (max(a.Date) - mati)*365;
      pla = 0; pla2 = 0;

      for t = t0:dt:t0+tpre
         pla = pla + (10^(A + bv*(M2)) * (t + c)^(-p))  *dt;
         pla2 = pla2 + (10^(A + bv*(M2-0.5)) * (t + c)^(-p))  *dt;
      end

      %fac = length(a(l,1))/a.Count
      anz = [anz ;  m2+0.25  (pla-pla2)/tpre];

  end

   % write info to file
   s = ['0    1.     -1          zn03']; s = s';
   fprintf(fid2,'%s\n',s);
   s = ['2 1 1']; s = s';
   fprintf(fid2,'%s\n',s);
   s = [num2str(-b1,5) ' ' num2str(y) ' ' num2str(-b2,5) ' ' num2str(y)]; s = s';
   fprintf(fid2,'%s\n',s);
   s = [num2str(-b1,5) ' ' num2str(y+0.1) ' ' num2str(-b2,5) ' ' num2str(y+dy)]; s = s';
   fprintf(fid2,'%s\n',s);
   fprintf(fid2,'%7.6f    ',anz(:,2));
   fprintf(fid2,'\n');
   fprintf(fid2,'\n');
   fprintf(fid2,'%3.2f  ',anz(:,1));
   fprintf(fid2,'\n');
end

fclose(fid2)

%return

do = [' ! cat head.txt | sed -e"s/sub1/' num2str(prol) ' 1 ' num2str(tpre) '/" > head2.txt ' ]; eval(do)
do = [' ! cat head2.txt sourczones.txt tail.txt > /home2/stefan/srisk/myrisk.inp']; eval(do)
cd /home2/stefan/srisk/
load hpga
ma = max(hpga)

%do = [' ! /home2/stefan/srisk/myrisk2 ' num2str(max(hpga)/2,1)  '  ' num2str(max(hpga)/10,2) ]; eval(do)
do = [' ! /home2/stefan/srisk/myriskhec 0.05 0.01 ' num2str(tpre) ]; eval(do)


cd /home2/stefan/ZMAP



