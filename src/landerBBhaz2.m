report_this_filefun(mfilename('fullpath'));

% compute the source zones for landers

% define Input parameters
if exist('dy') == 0; dy = 0.15; end
if exist('tmin1') == 0; tmin1 = 0.05; end
if exist('tpre') == 0; tpre = 30; end
if exist('Tobs') == 0; Tobs = 30; end
if exist('prol') == 0; prol = 0.5; end
if exist('org2') == 0; org2 = a; end


def = {num2str(dy),num2str(tmin1),num2str(tpre),num2str(Tobs), num2str(prol)};

tit ='Hazard analysis input parameters';
prompt={ 'Spacing in Latidude steps (dy) in [deg])',...
    'Minimum Time (tmin1) [days]',...
    'Prediction Time (tpre) [days]',...
    'Data period considered (Tobs) [days] ',...
    'Probability level (prol)',...
    };


ni2 = inputdlg(prompt,tit,1,def);

l = ni2{1}; dy= str2double(l);
l = ni2{2}; tmin1= str2double(l);
l = ni2{3}; tpre= str2double(l);
l = ni2{4}; Tobs = str2double(l);
l = ni2{5}; prol= str2double(l);



% make the catalog to be investigated
newt0 = newt2;
dt = 1;

l = org2(:,3) <= maepi(1,3) + Tobs/365;
a = org2(l,:);
subcata; newt2 = a;
timeplot

d = [];

l = a(:,6) > 7;
maepi = a(l,:);

mati = maepi(1,3);
da = []; anz = [];
B = [];
t0 = (max(a(:,3)) - mati)*365;
tlen = t0;
cd /home2/stefan/ZMAP/aspar
fid2 = fopen('sourczones.txt','w');

a0 = a;
l = a(:,1) > -116.6912; % the landers side.
a = a(l,:);

% find the boxes starting at 33:85, stepping in dy

for y = 33.85:dy:34.6
    l = a(:,2) >= y & a(:,2) < y+dy;

    % defined as the 10 amd 90 percentile of the seismicity

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
    timeplot
    % compute the p , a, b, values
    calcp
    % da = [da ; y+dy/2 P];
    B = [B ; b1 y  b2 y];

    anz = [];
    % compute the activity in the prediction period based on p, b, a
    for m2 = 4.25:0.5:7.25
        M2 = maepi(1,6) - m2;
        t0 = tlen;
        pla = 0; pla2 = 0;

        % Integration over time
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
    s = [num2str(-b1,5) ' ' num2str(y) ' ' num2str(-b2,5) ' ' num2str(y)]; s = s';
    fprintf(fid2,'%s\n',s);
    s = [num2str(-b1,5) ' ' num2str(y+dy) ' ' num2str(-b2,5) ' ' num2str(y+dy)]; s = s';
    fprintf(fid2,'%s\n',s);
    fprintf(fid2,'%7.6f    ',anz(:,2));
    fprintf(fid2,'\n');
    fprintf(fid2,'\n');
    fprintf(fid2,'%3.2f  ',anz(:,1));
    fprintf(fid2,'\n');
end


a = a0; % reset the catalog
l = a(:,1) <= -116.6912; % the the BB side.
a = a(l,:);
l = a(:,6) > 6; % find the mmainshock for Big bear
maepi = a(l,:);
mati = a(l,3);
t0 = (max(a(:,3)) - mati)*365;
tlen = t0;

% loop for Big bear
for y = 34.05:dy:34.25
    l = a(:,2) >= y & a(:,2) < y+dy;
    b1 = prctile2(a(l,1),25);
    b2 = prctile2(a(l,1),85);

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
    timeplot
    calcp
    %  da = [da ; y+dy/2 P];
    B = [B ; b1 y  b2 y];

    anz = [];


    for m2 = 4.25:0.5:6.25
        M2 = 6.2 - m2;
        t0 = tlen;
        pla = 0; pla2 = 0;

        for t = t0:dt:t0+tpre
            pla = pla + (10^(A + bv*(M2)) * (t + c)^(-p))  *dt;

            pla2 = pla2 + (10^(A + bv*(M2-0.5)) * (t + c)^(-p))  *dt;
        end

        anz = [anz ;  m2+0.25  (pla-pla2)/tpre];
    end
    % anz(5,2) = 0;

    % write info to file
    s = ['0    1.     -1          zn03']; s = s';
    fprintf(fid2,'%s\n',s);
    s = ['2 1 1']; s = s';
    fprintf(fid2,'%s\n',s);
    s = [num2str(-b1,5) ' ' num2str(y) ' ' num2str(-b2,5) ' ' num2str(y)]; s = s';
    fprintf(fid2,'%s\n',s);
    s = [num2str(-b1,5) ' ' num2str(y+dy) ' ' num2str(-b2,5) ' ' num2str(y+dy)]; s = s';
    fprintf(fid2,'%s\n',s);
    fprintf(fid2,'%7.6f    ',anz(:,2));
    fprintf(fid2,'\n');
    fprintf(fid2,'\n');
    fprintf(fid2,'%3.2f  ',anz(:,1));
    fprintf(fid2,'\n');
end

a = a0;

fclose(fid2) % ended the creatiion of sourcesone.txt

do = [' ! cat head_land.txt | sed -e"s/sub1/' num2str(prol) ' 1 ' num2str(tpre) '/" > head2.txt ' ]; eval(do)
do = [' ! cat head2.txt sourczones.txt tail.txt > /home2/stefan/srisk/myrisk.inp']; eval(do)

cd /home2/stefan/srisk/

do = [ '! /nfs/alaska/home2/stefan/srisk/seis4b.exe  myrisk.inp myrisk.out f2 f3' ]; eval(do)
do = [' !cat myrisk.out | grep -e "LAT   "  -e "' num2str(tpre) ' YE"  > tmp2 ']; eval(do)
try
    condata2
catch ME
    error_handler(ME, @do_nothing);
end

[X2,Y2] = meshgrid((-117.3:0.02:-116.0),(33.5:0.01:35.3));


Z = griddata(-da(:,1),da(:,2),da(:,3),X2,Y2,'linear');
figure

pcolor(X2,Y2,Z); colorbar; shading flat
hold on
shading interp
overlay


return

cd /home2/stefan/ZMAP
obs_pga3

figure
pcolor(rex,rey,re)
shading interp
colorbar
overlay


