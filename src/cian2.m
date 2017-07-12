% will display cum # curve for one anomaly group
report_this_filefun(mfilename('fullpath'));

def = {'1'};
ni2 = inputdlg('Please Input  Anomalie Number ?','Input',1,def);
l = ni2{1};
n = str2double(l);

try
do = ['ZG.newt2 = anB' num2str(n) ';' ];
eval(do)
do = ['ZG.newcat = anB' num2str(n) ';' ];
eval(do)
timeplot(ZG.newt2)
update(mainmap())
axes(h1)
plot(ZG.newt2.Longitude, ZG.newt2.Latitude,'*k','era','normal')
%
