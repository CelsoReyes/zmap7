report_this_filefun(mfilename('fullpath'));

% compute the source zones for landers

dy = 0.2;
tmin1 = 0.05;
newt0 = newt2;
tpre = 365;
d = [];

l = a(:,6) > 7;
maepi = a(l,:);

mati = maepi(1,3);
M = 7.3 - 5;
da = []; anz = [];
B = [];
t0 = (max(a(:,3)) - mati)*365;
tlen = t0;
cd /home2/stefan/ZMAP/aspar
fid2 = fopen('sourczones.txt','w');

a0 = a;
l = a(:,1) > -116.6912; % the landers side.
a = a(l,:);


for y = 33.85:dy:34.6
    l = a(:,2) >= y & a(:,2) < y+dy;
    b1 = prctile2(a(l,1),10);
    b2 = prctile2(a(l,1),90);

    newt2 = a(l,:);
    figure_w_normalized_uicontrolunits(map)
    try
        delete(pl)
    catch ME
        error_handler(ME, @do_nothing);
    end

    hold on
    pl = plot(newt2(:,1),newt2(:,2),'xk');drawnow

    calcp
    da = [da ; y+dy/2 P];
    B = [B ; b1 y  b2 y];

    anz = [];
    for m2 = 3.75:0.5:5.75
        M2 = maepi(1,6) - m2;
        t0 = tlen;
        pla = 0; pla2 = 0;

        for t = t0:dt:t0+tpre
            pla = pla + (10^(A + bv*(M2)) * (t + c)^(-p))  *dt;
            pla2 = pla2 + (10^(A + bv*(M2-0.5)) * (t + c)^(-p))  *dt;
        end

        anz = [anz ;  m2+0.25  (pla-pla2)*365/tpre];
    end
    % anz(5,2) = anz(5,2)/10;

    % write info to file
    s = ['0    1.     -1          zn03']; s = s';
    fprintf(fid2,'%s\n',s);
    s = ['2 1 1']; s = s';
    fprintf(fid2,'%s\n',s);
    s = [num2str(-b1,5) ' ' num2str(y) ' ' num2str(-b2,5) ' ' num2str(y)]; s = s';
    fprintf(fid2,'%s\n',s);
    s = [num2str(-b1,5) ' ' num2str(y+0.1) ' ' num2str(-b2,5) ' ' num2str(y+0.1)]; s = s';
    fprintf(fid2,'%s\n',s);
    fprintf(fid2,'%7.6f    ',anz(:,2));
    fprintf(fid2,'\n');
    fprintf(fid2,'\n');
    fprintf(fid2,'%3.2f  ',anz(:,1));
    fprintf(fid2,'\n');
end


a = a0;
l = a(:,1) <= -116.6912; % the the BB side.
a = a(l,:);
l = a(:,6) > 6;
maepi = a(l,:);
mati = a(l,3);
t0 = (max(a(:,3)) - mati)*365;
tlen = t0;



for y = 34.10:dy:34.25
    l = a(:,2) >= y & a(:,2) < y+dy;
    b1 = prctile2(a(l,1),10);
    b2 = prctile2(a(l,1),90);

    newt2 = a(l,:);
    figure_w_normalized_uicontrolunits(map)

    try
        delete(pl)
    catch ME
        error_handler(ME, @do_nothing);
    end

    hold on
    pl = plot(newt2(:,1),newt2(:,2),'xk');
    drawnow

    calcp
    da = [da ; y+dy/2 P];
    B = [B ; b1 y  b2 y];

    anz = [];


    for m2 = 3.75:0.5:5.75
        M2 = 6.4 - m2;
        t0 = tlen;
        pla = 0; pla2 = 0;

        for t = t0:dt:t0+tpre
            pla = pla + (10^(A + bv*(M2)) * (t + c)^(-p))  *dt;

            pla2 = pla2 + (10^(A + bv*(M2-0.5)) * (t + c)^(-p))  *dt;
        end

        anz = [anz ;  m2+0.25  (pla-pla2)*365/tpre];
    end
    % anz(5,2) = 0;

    % write info to file
    s = ['0    1.     -1          zn03']; s = s';
    fprintf(fid2,'%s\n',s);
    s = ['2 1 1']; s = s';
    fprintf(fid2,'%s\n',s);
    s = [num2str(-b1,5) ' ' num2str(y) ' ' num2str(-b2,5) ' ' num2str(y)]; s = s';
    fprintf(fid2,'%s\n',s);
    s = [num2str(-b1,5) ' ' num2str(y+0.1) ' ' num2str(-b2,5) ' ' num2str(y+0.1)]; s = s';
    fprintf(fid2,'%s\n',s);
    fprintf(fid2,'%7.6f    ',anz(:,2));
    fprintf(fid2,'\n');
    fprintf(fid2,'\n');
    fprintf(fid2,'%3.2f  ',anz(:,1));
    fprintf(fid2,'\n');
end

a = a0;

fclose(fid2)

do = [' ! cat head.txt sourczones.txt tail.txt > /home2/stefan/srisk/myrisk.inp']; eval(do)
cd /home2/stefan/srisk/
load hpga
ma = max(hpga)

%do = [' ! /home2/stefan/srisk/myrisk2 ' num2str(max(hpga)/2,1)  '  ' num2str(max(hpga)/10,2) ]; eval(do)
do = [' ! /home2/stefan/srisk/myrisk2 0.03 0.005' ]; eval(do)


cd /home2/stefan/ZMAP

