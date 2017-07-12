% plots two cum number plots as a function of day/night
ZG=ZmapGlobal.Data;
report_this_filefun(mfilename('fullpath'));

l = ZG.newt2.Date.Hour >=7 & ZG.newt2.Date.Hour <=18;
dayCat = ZG.newt2(l,:);

nightCat = ZG.newt2;
nightCat(l,:) = [];

ZG.newt2 = dayCat;
timeplot(ZG.newt2)
ZG.hold_state2=true;

ZG.newt2 = nightCat;
timeplot(ZG.newt2)

legend('day','night','location','SouthEast')


