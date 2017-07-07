report_this_filefun(mfilename('fullpath'));


def = {'6'};
ni2 = inputdlg('Mark events with M > ? ','Input magnitude threshold',1,def);
l = ni2{:};
minmag = str2double(l);

clear maex maix maey maiy
l = a.Magnitude > minmag ;
maepi = a.subset(l);
update(mainmap())

