report_this_filefun(mfilename('fullpath'));

s = int2str(test(:,1));
s =reshape(s',6,length(s)/6);
yr = str2double(s(1:2,:)');
mo = str2double(s(3:4,:)');
da = str2double(s(5:6,:)');

hr = floor(test(:,2)/100);
min= test(:,2) - hr*100;

a = [test(:,5) test(:,4) yr mo da test(:,7) test(:,6) hr min];
clear s yr mo da hr min
