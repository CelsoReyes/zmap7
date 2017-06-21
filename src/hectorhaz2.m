% compute the source zones for landers

report_this_filefun(mfilename('fullpath'));

% compute the source zones for landers

% define Input parameters
if exist('nb') == 0; nb = 10; end
if exist('tmin1') == 0; tmin1 = 0.05; end
if exist('tpre') == 0; tpre = 30; end
if exist('Tobs') == 0; Tobs = 30; end
if exist('prol') == 0; prol = 0.5; end
if exist('org2') == 0; org2 = a; end


def = {num2str(nb),num2str(tmin1),num2str(tpre),num2str(Tobs), num2str(prol)};

tit ='Hazard analysis input parameters';
prompt={ 'Number of source zones',...
    'Minimum Time (tmin1) [days]',...
    'Prediction Time (tpre) [days]',...
    'Data period considered (Tobs) [days] ',...
    'Probability level (prol)',...
    };


ni2 = inputdlg(prompt,tit,1,def);

l = ni2{1}; nb= str2double(l);
l = ni2{2}; tmin1= str2double(l);
l = ni2{3}; tpre= str2double(l);
l = ni2{4}; Tobs = str2double(l);
l = ni2{5}; prol= str2double(l);

mati = maepi(1,3);
tlen = Tobs;
l = org2(:,3) < mati + Tobs/365;
a = org2(l,:);
da = []; anz = [];
B = [];
dt = 1;
mainmap_overview()

cd /home2/stefan/ZMAP/aspar
fid2 = fopen('sourczones.txt','w');

l1 = [];

for kk = 1:nb-1
    l1 = [l1 prctile2(a.Latitude,kk*100/nb)];
end

bo = [34.35 l1 34.88 ];
for ii = 1:length(bo)-1
    l = a.Latitude >= bo(ii) & a.Latitude < bo(ii+1);
    figure_w_normalized_uicontrolunits(map)
    hold on
    plot(a(l,1),a(l,2),'k+')

    b1 = prctile2(a(l,1),25);
    b2 = prctile2(a(l,1),75);
    plot(b1,bo(ii),'+r','Markersize',12)
    plot(b2,bo(ii),'+r','Markersize',12)
    plot(b1,bo(ii+1),'+r','Markersize',12)
    plot(b2,bo(ii+1),'+r','Markersize',12)
    drawnow

    newt2 = a.subset(l);
    calcp
    B = [B ; b1 bo(ii)  b2 bo(ii)];

    anz = [];
    for m2 = 4.25:0.5:6.25
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
    s = ['0    1.     -1          zn035.00']; s = s';
    fprintf(fid2,'%s\n',s);
    s = ['2 1 1']; s = s';
    fprintf(fid2,'%s\n',s);
    s = [num2str(-b1,5) ' ' num2str(bo(ii)) ' ' num2str(-b2,5) ' ' num2str(bo(ii))]; s = s';
    fprintf(fid2,'%s\n',s);
    s = [num2str(-b1,5) ' ' num2str(bo(ii+1)) ' ' num2str(-b2,5) ' ' num2str(bo(ii+1))]; s = s';
    fprintf(fid2,'%s\n',s);
    fprintf(fid2,'%7.6f    ',anz(:,2));
    fprintf(fid2,'\n');
    fprintf(fid2,'\n');
    fprintf(fid2,'%3.2f  ',anz(:,1));
    fprintf(fid2,'\n');
end

fclose(fid2)

%return
cd /home2/stefan/ZMAP/aspar
do = [' ! cat head5.txt | sed -e"s/sub1/' num2str(prol) ' 1 ' num2str(tpre) '/" > head2.txt ' ]; eval(do)
do = [' ! cat head2.txt sourczones.txt tail.txt > /home2/stefan/srisk/myrisk.inp']; eval(do)
cd /home2/stefan/srisk/

do = [ '! /nfs/alaska/home2/stefan/srisk/seis4b.exe  myrisk.inp myrisk.out f2 f3' ]; eval(do)
do = [' !cat myrisk.out | grep -e "LAT   "  -e "' num2str(tpre) ' YE"  > tmp2 ']; eval(do)
try
    condata2
catch ME
    error_handler(ME, @do_nothing);
end

[X2,Y2] = meshgrid((-116.8:0.02:-115.7),(33.92:0.01:35.3));


Z = griddata(-da(:,1),da(:,2),da(:,3),X2,Y2,'linear');
figure

axes('pos',[0.05 0.1 0.4 0.7])
pcolor(X2,Y2,Z);
set(gca,'TickDir','out');
colorbar; shading flat
hold on
shading interp
overlay
[ca1, ca2] = caxis;

cd /home2/stefan/ZMAP

l = obs(:,3) > mati + tlen/365 &  obs(:,3) <  mati+ tlen/365 + tpre/365;
b = obs(l,:);
l = b(:,6) > 3;
b = b(l,:);

ve = [];dx = 0.02; dy = 0.02

for x = -116.8:dx:-115.7
    for y = 33.92:dy:35.3
        ve =    [ ve ; x y ];
    end
end

le = length(ve);
Y0 = zeros(le,1);


for i = 1:length(b)
    di2 = deg2km((distance(ve(:,2),ve(:,1),repmat(b(i,2),le,1),repmat(b(i,1),le,1))));
    R = di2;
    r = sqrt(R.^2 + 5.57^2);
    M = b(i,6);
    Y = -0.136 + 0.229*(M-6) - 0.778 * log10(r) + 0.161*1 ;
    Y = 10.^Y;
    c = [Y , Y0];
    mapga = max(c');
    Y0 = mapga';
end

mapga = mapga';

l1 = length(-116.8:dx:-115.7);
l2 = length(33.92:dy:35.3);

axes('pos',[0.55 0.1 0.4 0.7])
re = reshape(mapga,l2,l1);
rey = reshape(ve(:,2),l2,l1);
rex = reshape(ve(:,1),l2,l1);
pcolor(rex,rey,re);
set(gca,'YTicklabels',[],'TickDir','out');
caxis([ca1 ca2]);
shading interp

colorbar;
overlay
hold on
