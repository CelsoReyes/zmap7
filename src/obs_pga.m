report_this_filefun(mfilename('fullpath'));


l = org2(:,3) > mati+ 2.5/365 &  org2(:,3) <  mati+ 3/365 + 7/365;
b = org2(l,:);

cd /home2/stefan/srisk/

load lat
load lon
lon = -lon;


le = length(lat);
Y0 = zeros(le,1);


for i = 1:length(b)
    di2 = deg2km((distance(lat,lon,repmat(b(i,2),le,1),repmat(b(i,1),le,1))));
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

save hpga2 mapga -ascii

do = [' ! /home2/stefan/srisk/myriskobs2 ' num2str(max(mapga)/2.4,2)  '  ' num2str(max(mapga)/10,2) ]; eval(do)

% do = [' ! /home2/stefan/srisk/myriskobs 0.04 0.008' ]; eval(do)
