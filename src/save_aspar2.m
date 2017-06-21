%Saving data into ASPAR type 5 format

report_this_filefun(mfilename('fullpath'));

if exist('tlen') == 0; tlen = 30 ; end
str = [];
[newmatfile] = ['t1.sum'];
[ newpath] = [hodi '/aspar/'];

do = [ ' cd ' newpath ];
eval(do)

% lets addev the mainshock as the fisrt and largest event...

l = newt2.Date > maepi(1,3) & newt2.Date < mati + tlen/365;
newt3 =  newt2(l,1:9);
newt3 = [maepi(1:1:9) ; newt3 ];

lam = (newt3(:,2)-floor(newt3(:,2)))*100*6/10;
lom = (newt3(:,1)-floor(newt3(:,1)))*100*6/10;



s = [floor(newt3(:,3:5))  newt3(:,8:9) floor(newt3(:,2)) lam  floor(abs((newt3(:,1))))  lom  newt3(:,7) newt3(:,6)];
fid = fopen([newpath newmatfile],'w') ;;

fprintf(fid,'%7.3f  %7.3f %7f3\n',[min(newt3(:,6)) tmin1 tlen]);

fprintf(fid,'%5.0f %5.0f %5.0f %5.0f %5.0f %5.0f %7.3f %5.0f %7.3f %7.3f %7.3f\n',s');
fclose(fid);
clear s
return
