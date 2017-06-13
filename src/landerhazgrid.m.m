report_this_filefun(mfilename('fullpath'));

% compute the source zones for landers

dy = 0.2;dx = 0.2;
tmin1 = 0.05;
mati = maepi(1,3);
M = 7.3 - 5;
da = []; anz = [];
B = [];
mainmap_overview()

cd /home2/stefan/ZMAP/aspar
fid2 = fopen('sourczones2.txt','w');

for xx = -117.5:dx:-116
    for yy = 33.5:dy:35
        cu = cu+1;
        p = [xx yy ; xx+dx yy ; xx+dx yy+dy ; xx  yy+dy ; xx yy ];
        v = p;
        pl = plot(p(:,1),p(:,2),'r');
        set(pl,'Linewidth',2)

        x = [p(:,1)];
        y = [p(:,2)];      %  closes polygon

        sum3 = 0.;
        XI = a(:,1);          % this substitution just to make equation below simple
        YI = a(:,2);
        m = length(x)-1;      %  number of coordinates of polygon
        l = 1:length(XI);
        l = (l*0)';
        l2 = l;               %  Algorithm to select points inside a closed
        %  polygon based on Analytic Geometry    R.Z. 4/94
        for i = 1:m

            l= ((y(i)-YI < 0) & (y(i+1)-YI >= 0)) & ...
                (XI-x(i)-(YI-y(i))*(x(i+1)-x(i))/(y(i+1)-y(i)) < 0) | ...
                ((y(i)-YI >= 0) & (y(i+1)-YI < 0)) & ...
                (XI-x(i)-(YI-y(i))*(x(i+1)-x(i))/(y(i+1)-y(i)) < 0);

            if i ~= 1
                l2(l) = 1 - l2(l);
            else
                l2 = l;
            end;         % if i

        end;         %  for

        newt2 = a(l2,:);
        if length(newt2(:,1)) > 6   % nur wenn mindestens 6 EQ in zone

            timeplot

            set(pl,'color','k')
            figure_w_normalized_uicontrolunits(map); hold on;
            plot(newt2(:,1),newt2(:,2),'go')
            disp(['This is source zone # ' num2str(cu) ]);


            l = newt2(:,6) >= 3.75 & newt2(:,6) < 4.25;
            r0 = length(newt2(l,6))/120;
            l = newt2(:,6) >= 4.25 & newt2(:,6) < 4.75;
            r1 = length(newt2(l,6))/250;
            l = newt2(:,6) >= 4.75 & newt2(:,6) < 5.25;
            r2 = length(newt2(l,6))/250;
            l = newt2(:,6) >= 5.25 & newt2(:,6) < 5.75;
            r3 = length(newt2(l,6))/400;
            l = newt2(:,6) >= 5.75 & newt2(:,6) < 6.25;
            r4 = length(newt2(l,6))/700;
            l = newt2(:,6) >= 6.25 & newt2(:,6) < 6.75;
            r5 = length(newt2(l,6))/1000;

            if r4 == 0 r4 = r5; end
            if r3 == 0 r3 = r4; end
            if r2 == 0 r2 = r3; end
            if r1 == 0 r1 = r2; end
            if r0 == 0 r0 = r1; end


            r = [r0 r1 r2 r3 r4 r5 ];
            f = min(find(r(2:6) == 0));
            if isempty(f) == 0
               if f < 6  && f > 1
                    r(f) = r(f-1)*0.35
                end
            end

            % write info to file
            % cd /home2/stefan/ZMAP/aspar

            s = ['0    1.     -1          zn03']; s = s';
            fprintf(fid2,'%s\n',s);
            s = [num2str(length(v)/2,1) ' 1 1']; s = s';
            fprintf(fid2,'%s\n',s);

            s = [num2str(v(1,1),5) ' ' num2str(v(1,2),5) ' ' num2str(v(2,1),5) ' ' num2str(v(2,2),5)]; s = s';
            fprintf(fid2,'%s\n',s);
            s = [num2str(v(4,1),5) ' ' num2str(v(4,2),5) ' ' num2str(v(3,1),5) ' ' num2str(v(3,2),5)]; s = s';
            fprintf(fid2,'%s\n',s);


            anz = [r(1) 4.0 ; r(2) 4.5 ; r(3) 5 ; r(4) 5.5 ; r(5) 6.0 ; r(6) 6.5 ];

            fprintf(fid2,'%7.6f    ',anz(:,1));
            fprintf(fid2,'\n');
            fprintf(fid2,'\n');
            fprintf(fid2,'%3.2f  ',anz(:,2));
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
do = [' ! /home2/stefan/srisk/myrisk2 0.25 0.05 ' ]; eval(do)


cd /home2/stefan/ZMAP

figure
plot(da(:,1),da(:,2));
hold on
plot(da(:,1),da(:,2),'o');


