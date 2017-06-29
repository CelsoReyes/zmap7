report_this_filefun(mfilename('fullpath'));

% compute the source zones for landers

dy = 0.15;
tmin1 = 3;
newt0 = newt2;
tpre =  120;

l = storedcat(:,3) <= maepi(1,3) +60/365;
a = storedcat(l,:);
update(mainmap()); newt2 = a;
timeplot

d = [];
prol = 0.90;

l = a.Magnitude > 7;
maepi = a.subset(l);

mati = maepi(1,3);
M = 7.4 - 4;
da = []; anz = [];
B2 = [];
t0 = (max(a.Date) - mati)*365;
tlen = t0;
cd /home2/stefan/ZMAP/aspar
fid2 = fopen('sourczones.txt','w');

dx = 0.33;


for x = 29:dx:31
    l = a.Longitude >= x & a.Longitude < x+dx;
    b1 = prctile2(a(l,2),20);
    b2 = prctile2(a(l,2),80);

    newt2 = a.subset(l);
    mcperc_ca3;
    if isnan(Mc95) == 0
        magco = Mc95;
    elseif isnan(Mc90) == 0
        magco = Mc90;
    else
        [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
    end
    magco
    l = newt2.Magnitude >= magco;
    newt2 = newt2(l,:);

    figure_w_normalized_uicontrolunits(map)
    try
        delete(pl)
    catch ME
        disp(ME.message);
    end

    hold on
    pl = plot(newt2.Longitude,newt2.Latitude,'xk');drawnow
    timeplot

    calcp
    %da = [da ; x+dx/2 P];
    B2 = [B2 ; b1 x  b2 x];

    anz = [];
    for m2 = 4.75:0.5:7.25
        M2 = maepi(1,6) - m2;
        t0 = tlen;
        pla = 0; pla2 = 0;
        dt = 0.5;
        for t = t0:dt:t0+tpre
            pla = pla + (10^(A + bv*(M2)) * (t + c)^(-p))  *dt;
            pla2 = pla2 + (10^(A + bv*(M2-0.5)) * (t + c)^(-p))  *dt;
        end

        anz = [anz ;  m2+0.25  (pla-pla2)/tpre];
    end
    % anz(5,2) = anz(5,2)/10;

    % write info to file
    s = ['0    1.     -1          zn03']; s = s';
    fprintf(fid2,'%s\n',s);
    s = ['2 1 1']; s = s';
    fprintf(fid2,'%s\n',s);
    s = [num2str(x) ' ' num2str(b1,5) ' ' num2str(x) ' ' num2str(b2,5)]; s = s';
    fprintf(fid2,'%s\n',s);
    s = [num2str(x+dx) ' ' num2str(b1,5) ' ' num2str(x+dx) ' ' num2str(b2,5)]; s = s';
    fprintf(fid2,'%s\n',s);
    fprintf(fid2,'%7.6f    ',anz(:,2));
    fprintf(fid2,'\n');
    fprintf(fid2,'\n');
    fprintf(fid2,'%3.2f  ',anz(:,1));
    fprintf(fid2,'\n');
end


%end


fclose(fid2)

do = [' ! cat head_turk.txt | sed -e"s/sub1/' num2str(prol) ' 1 ' num2str(tpre) '/" > head2.txt ' ]; eval(do)
do = [' ! cat head2.txt sourczones.txt tail.txt > /home2/stefan/srisk/myrisk.inp']; eval(do)

cd /home2/stefan/srisk/

do = [ '! /nfs/alaska/home2/stefan/srisk/seis4b.exe  myrisk.inp myrisk.out f2 f3' ]; eval(do)
do = [' !cat myrisk.out | grep -e "LAT   "  -e "' num2str(tpre) ' YE"  > tmp2 ']; eval(do)
do = ['condata2']; err = [' ']; eval(do,err);
save inpudata.xyz da -ascii

eq = [a.Longitude a.Latitude a.Magnitude];
save eqs2.dat eq -ascii

cd /home2/stefan/srisk/

do = [' ! /home2/stefan/srisk/myriskturk 0.05 0.02 ' num2str(tpre) ]; eval(do)

load lat
load lon
load hpga

[X,Y] = meshgrid(min(lon)-0.1:0.08:max(lon)+0.1,min(lat)-0.1:0.08:max(lat)+0.1);

Z = griddata(lon,lat,hpga,X,Y,'linear');
figure

pcolor(X,Y,Z); colorbar; shading flat
hold on
shading interp
overlay

