%

teq = (newt2(:,3) - mati)* 365;
[rpd, tbin] = hist(log10(teq),-1:0.2:3.3);

wei = gradient(10.^tbin);
rpd = rpd./wei;
tbin = 10.^tbin;

figure
loglog(tbin,rpd,'^')

px = ginput(1);

tmin1 = px(1)
tmin2 = tbin(max(find(diff(rpd) >= 0))+2)

