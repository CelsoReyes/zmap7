report_this_filefun(mfilename('fullpath'));

d = datenum(ceil(a(:,3))+1900,a(:,4),a(:,5),a(:,8),a(:,9),a(:,9)*0);
tiplo2 = plot(d,(1:length(d)),'r-.');
datetick('x',2)


