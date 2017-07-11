% plots two cum number plots as a function of day/night
ZG=ZmapGlobal.Data;
report_this_filefun(mfilename('fullpath'));

l = ZG.newt2.Date.Hour >=7 & ZG.newt2.Date.Hour <=18;
day = ZG.newt2(l,:);

nig = ZG.newt2;
nig(l,:) = [];

newt2 = day;
timeplot
ZG.hold_state2=true

newt2 = nig;
timeplot

legend('day','night','location','SouthEast')


