report_this_filefun(mfilename('fullpath'));

d = datenum(ceil(a.Date)+1900,a.Date.Month,a.Date.Day,a.Date.Hour,a.Date.Minute,a.Date.Minute*0);
tiplo2 = plot(d,(1:length(d)),'r-.');
datetick('x',2)


