% will display cum # curve for one anomaly group
report_this_filefun(mfilename('fullpath'));

def = {'1'};
ni2 = inputdlg('Please Input  Anomalie Number ?','Input',1,def);
l = ni2{1};
n = str2double(l);


do = ['newt2 = anB' num2str(n) ';' ];
eval(do)
do = ['newcat = anB' num2str(n) ';' ];
eval(do)
timeplot
subcata
axes(h1)
plot(newt2(:,1),newt2(:,2),'*k','era','normal')
%
