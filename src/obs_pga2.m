report_this_filefun(mfilename('fullpath'));


l = org2(:,3) > mati + tlen/365 &  org2(:,3) <  mati+ tlen/365 + tpre/365;
b = org2(l,:);


%l = org2(:,3) >93 &  org2(:,3) <  98;
%b = org2(l,:);


cd /home2/stefan/srisk/

load lat
load lon
lon = -lon;

ve = [];dx = 0.02; dy = 0.02

for x = -117:dx:-116
    for y = 33.6:dy:35
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
    Y = -0.136 + 0.229*(M-6) - 0.778 * log10(r) ;
    Y = 10.^Y;
    c = [Y , Y0];
    mapga = max(c');
    Y0 = mapga';
end

mapga = mapga';

cd /home2/stefan/srisk/

eq = [b(:,1) b(:,2) b(:,6)];
save eqs.dat eq -ascii

ve = [ve mapga];
save inpudata.xyz ve -ascii

do = [' ! /home2/stefan/srisk/myriskobs2 ' num2str(max(mapga)/2.6,2)  '  ' num2str(max(mapga)/10,2) ]; eval(do)

% do = [' ! /home2/stefan/srisk/myriskobs 0.04 0.008' ]; eval(do)
