%Saving data into ASPAR type 5 format

report_this_filefun(mfilename('fullpath'));

str = [];
[newmatfile] = ['t1.sum'];
[ newpath] = [hodi '/aspar/'];

newt3 = [];
do = [ ' cd ' newpath ];
eval(do)

% lets add the mainshock as the fisrt and largest event...
l = newt2.Date > maepi(1,3);
newt3 =  newt2(l,1:9);
newt3 = [maepi(1,1:9) ; newt3 ];
lam = (newt3(:,2)-floor(newt3(:,2)))*100*6/10;
lom = (newt3(:,1)-floor(newt3(:,1)))*100*6/10;

s = [floor(newt3(:,3:5))  newt3(:,8:9) floor(newt3(:,2)) lam floor(abs((newt3(:,1))))  lom  newt3(:,7) newt3(:,6)];

fid = fopen([newpath newmatfile],'w') ;;
fprintf(fid,'%5.0f %5.0f %5.0f %5.0f %5.0f %5.0f %7.3f %5.0f %7.3f %7.3f %7.3f\n',s');
fclose(fid);
clear s
return
