% This is runasp - the ZMAP to aspar interface

report_this_filefun(mfilename('fullpath'));

if isunix ~= 1
    errordlg('ASPAR only implemented  for UNIX version! ');
    return
end


teq = (newt2(:,3) - mati)* 365;
[rpd, tbin] = hist(log10(teq),-1:0.2:3.3);

wei = gradient(10.^tbin);
rpd = rpd./wei;
tbin = 10.^tbin;

figure
loglog(tbin,rpd,'^')

px = ginput(1);

close

tmin1 = px(1)
%tmin2 = tbin(max(find(diff(rpd) >= 0))+2)


save_aspar2;

do = [ ' ! '  hodi '/aspar/myaspar' ];
eval(do)

