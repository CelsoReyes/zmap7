% This function selects events around a seismic
% station that fullfill certain criteria;

report_this_filefun(mfilename('fullpath'));

load /Seis/obelix/stefan/split_data2/ak8897.mat
addpath('/Seis/geodesy/hilary/matlab/edm')


title2 ='What Data are we working on?';
prompt={'Year','month'};

% vlz
vlz = [ -146.3337  61.1322];
ach = [ -155.1608   58.1343];
cola = [-147.8511   64.8738];
% gou
las = 61 + 00.1135*10/6;
los = 149 + 00.4802*10/6;
gou = [ -los las]

% red
las = 60 + 00.2592*10/6;
los = 152 + 00.46308*10/6;
los = -los;
red = [los las]

% aui
las = 59 + 00.2012*10/6;
los = 153 + 00.2566 *10/6;
los = -los;
aui = [los las]

% ive
las = 60 + 00.00972*10/6;
los = 153 + 00.00993 *10/6;
los = -los;
ive = [los las]

% skn
las = 61 + 00.5882*10/6;
los = 151 + 00.3178   *10/6;
los = -los;
skn = [los las]

% crp
las = 61 + 00.1602*10/6;
los = 152 + 00.0933   *10/6;
los = -los;
crp =[los las]

% az = azimuth(las+a(l2,1)*0,los+a(l2,1)*0,a(l2,2),a(l2,1))


los = skn(1);las = skn(2);
l = sqrt(((a(:,1)-los)*cos(pi/180*las)*111).^2 + ((a(:,2)-las)*111).^2) ;
l2 = a(:,6) >=1.8 & 1.2*a(:,7) >= l & l > a(:,7);
s = [floor(a(l2,3)) a(l2,4:5) a(l2,8:9)  ]; s = s';
az = azimuth(las+a(l2,1)*0,los+a(l2,1)*0,a(l2,2),a(l2,1));

s = [floor(a(l2,3:5)) a(l2,8:9) a(l2,6) a(l2,7) l(l2)  az ]; s = s';
fid = fopen(['/Seis/obelix/stefan/AH/9611/skn_all2.txt' ],'w')
fprintf(fid,'%2.0f%2.0f%2.0f%2.0f%2.0f      %3.1f     %6.2f     %6.2f   %6.2f\n',s)
fclose(fid)

los = aui(1);las = aui(2);
l = sqrt(((a(:,1)-los)*cos(pi/180*las)*111).^2 + ((a(:,2)-las)*111).^2) ;
l2 = a(:,6) >=1.4 & a(:,7) >= l;
s = [floor(a(l2,3)) a(l2,4:5) a(l2,8:9)  ]; s = s';
az = azimuth(las+a(l2,1)*0,los+a(l2,1)*0,a(l2,2),a(l2,1));

s = [floor(a(l2,3:5)) a(l2,8:9) a(l2,6) a(l2,7) l(l2)  az ]; s = s';
fid = fopen(['/Seis/obelix/stefan/AH/9611/aui_all2.txt' ],'w')
fprintf(fid,'%2.0f%2.0f%2.0f%2.0f%2.0f      %3.1f     %6.2f     %6.2f   %6.2f\n',s)
fclose(fid)

los = red(1);las = red(2);
l = sqrt(((a(:,1)-los)*cos(pi/180*las)*111).^2 + ((a(:,2)-las)*111).^2) ;
l2 = a(:,6) >=1.4 & a(:,7) >= l;
s = [floor(a(l2,3)) a(l2,4:5) a(l2,8:9)  ]; s = s';
az = azimuth(las+a(l2,1)*0,los+a(l2,1)*0,a(l2,2),a(l2,1));

s = [floor(a(l2,3:5)) a(l2,8:9) a(l2,6) a(l2,7) l(l2)  az ]; s = s';
fid = fopen(['/Seis/obelix/stefan/AH/9611/red_all2.txt' ],'w')
fprintf(fid,'%2.0f%2.0f%2.0f%2.0f%2.0f      %3.1f     %6.2f     %6.2f   %6.2f\n',s)
fclose(fid)
