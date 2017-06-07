report_this_filefun(mfilename('fullpath'));

load tmp3.dat
t = tmp3;

yr = floor(t(:,1)/10000);
mo = floor((t(:,1)-yr*10000)/100);
da = floor((t(:,1)-yr*10000-mo*100));

hr = floor(t(:,2)/100);
minu = floor((t(:,2)-hr*100));
lat = t(:,4) + t(:,5)*10/6/100;
lon = -t(:,6) - t(:,7)*10/6/100;

mag = t(:,9) ;
de= t(:,8) ;
a  = [lon lat yr mo da mag de hr minu t(:,16:19) ];
