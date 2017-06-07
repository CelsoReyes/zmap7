report_this_filefun(mfilename('fullpath'));

di = km2deg(red(:,7));
az = red(:,8);
[la,lo] =reckon(az*0+r(2),az*0+r(1),di,az);
s = [lo la red(:,4) red(:,5) red(:,3)-red(:,2) red(:,6)];
cd /Seis/obelix/stefan/DEM
save redaz.dat s -ascii



