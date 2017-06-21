report_this_filefun(mfilename('fullpath'));

% compute the source zones for landers

dy = 0.15;dx = 0.15;
tmin1 = 0.05;
mati = maepi(1,3);
M = 7.3 - 5;
da = []; anz = [];
B = [];
mainmap_overview()

cd /home2/stefan/ZMAP/aspar
fid2 = fopen('sourczones2.txt','w');

for xx = -117.07:dx:-116.4
    for yy = 33.8:dy:35
        cu = cu+1;
        p = [xx yy ; xx+dx yy ; xx+dx yy+dy ; xx  yy+dy ; xx yy ];
        v = p;
        pl = plot(p(:,1),p(:,2),'r');
        set(pl,'Linewidth',2)

        x = [p(:,1)];
        y = [p(:,2)];      %  closes polygon

        sum3 = 0.;
        XI = a.Longitude;          % this substitution just to make equation below simple
        YI = a.Latitude;
        l2 = polygon_filter(x,y, XI, YI, 'inside');

        newt2 = a.subset(l2);

        if newt2.Count > 10   % nur wenn mindestens 6 EQ in zone

            timeplot

            set(pl,'color','k')
            figure_w_normalized_uicontrolunits(map); hold on;
            plot(newt2.Longitude,newt2.Latitude,'go')
            disp(['This is source zone # ' num2str(cu) ]);
            tlen = (max(a.Date) - mati)*365;
            calcp
            % da = [da ; y+dy/2 P];
            %B = [B ; b1 y  b2 y];

            anz = [];
            for m2 = 4.25:0.5:6.25
                M2 = maepi(1,6) - m2;
                t0 = 30;
                pla = 0; pla2 = 0;

                for t = tlen:dt:tlen+t0
                    pla = pla + (10^(A + bv*(M2)) * (t + c)^(-p))  *dt;

                    pla2 = pla2 + (10^(A + bv*(M2-0.5)) * (t + c)^(-p))  *dt;
                end

                % this is the rate normlized to one year.
                anz = [anz ;  m2+0.25  (pla-pla2)*365/tlen];
            end

            % write info to file
            % cd /home2/stefan/ZMAP/aspar

            s = ['0    1.     -1          zn03']; s = s';
            fprintf(fid2,'%s\n',s);
            s = [num2str(length(v)/2,1) ' 1 1']; s = s';
            fprintf(fid2,'%s\n',s);

            s = [num2str(-v(1,1),5) ' ' num2str(v(1,2),5) ' ' num2str(-v(2,1),5) ' ' num2str(v(2,2),5)]; s = s';
            fprintf(fid2,'%s\n',s);
            s = [num2str(-v(4,1),5) ' ' num2str(v(4,2),5) ' ' num2str(-v(3,1),5) ' ' num2str(v(3,2),5)]; s = s';
            fprintf(fid2,'%s\n',s);

            fprintf(fid2,'%7.6f    ',anz(:,2));
            fprintf(fid2,'\n');
            fprintf(fid2,'\n');
            fprintf(fid2,'%3.2f  ',anz(:,1));
            fprintf(fid2,'\n');

        end %if length

    end
end


fclose(fid2)

do = [' ! cat head.txt sourczones2.txt tail.txt > /home2/stefan/srisk/myrisk.inp']; eval(do)
cd /home2/stefan/srisk/
load hpga
ma = max(hpga)

%do = [' ! /home2/stefan/srisk/myrisk2 ' num2str(max(hpga)/2,1)  '  ' num2str(max(hpga)/10,2) ]; eval(do)
do = [' ! /home2/stefan/srisk/myrisk2 0.2 0.04 ' ]; eval(do)

return


do = [' ! /home2/stefan/srisk/myrisk2 ' num2str(max(hpga)/2,1)  '  ' num2str(max(hpga)/10,2) ]; eval(do)
% rund the exe file
do = [ '! /nfs/alaska/home2/stefan/srisk/seis4b.exe  myriskswiss.inp ssrisk_CHhpeakacc_patrick_10km.out f2 f3' ]; eval(do)
do = [' !cat ssrisk_CHhpeakacc_patrick_10km.out | grep -e "LAT   "  -e "475 YE"  > tmp2 ']; eval(do)

% condata.m resorts the data to get hpga values
do = ['condata']; err = [' ']; eval(do,err);
save data.xyz da -ascii
cd /nfs/alaska/home2/stefan/srisk/
% call gmt script with two parameters: mean of HPGA and steop witdth (10 steps)
do = [' ! /nfs/alaska/home2/stefan/srisk/getgpa 0.19  0.04 ' ]; eval(do)


cd /home2/stefan/ZMAP

