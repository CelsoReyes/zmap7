report_this_filefun(mfilename('fullpath'));

remin = [];
for m = 4:0.1:7
    m
    re3 =(teb - t0b)./(10.^(avm-m*old));
    l = isnan(re3);
    re3(l) = [];
    remin = [remin ; min(re3) m];
end
figure
plot(remin(:,2),remin(:,1))

