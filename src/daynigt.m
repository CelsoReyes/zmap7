% plots two cum number plots as a function of day/night

report_this_filefun(mfilename('fullpath'));

l = newt2.Date.Hour >=7 & newt2.Date.Hour <=18;
day = newt2(l,:);

nig = newt2;
nig(l,:) = [];

newt2 = day;
timeplot
ho2 = 'hold'

newt2 = nig;
timeplot

legend('day','night','location','SouthEast')


