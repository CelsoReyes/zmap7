report_this_filefun(mfilename('fullpath'));

s = int2str(test(:,3));
s =reshape(s',6,length(s)/6);
yr = str2double(s(1:2,:)');
mo = str2double(s(3:4,:)');
da = str2double(s(5:6,:)');

a = [test(:,1) test(:,2) yr mo da test(:,7) test(:,8) test(:,5) test(:,6)];
