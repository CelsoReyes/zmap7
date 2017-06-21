%   This subroutine selcts the Ni closest earthquakes
%   around a userdefined point
%

report_this_filefun(mfilename('fullpath'));

new = a;
ni  = input('Please input  number of events ni:')
%ni = 100
axes(h6)
[xa0,ya0]  = ginput(1);

l = sqrt(((a.Longitude-xa0)*cos(pi/180*ya0)*111).^2 + ((a.Latitude-ya0)*111).^2) ;
[s,is] = sort(l);
new = a(is(:,1),:) ;
plos1 = plot(new(1:ni,1),new(1:ni,2),'xw','EraseMode','back');
%plos1 = plot(new(1:ni,1),new(1:ni,2),'xw')

figure_w_normalized_uicontrolunits(2)
clf
h3 = gcf;
newt = new(1:ni,:);
[st,ist] = sort(newt);
newt2 = newt(ist(:,3),:);

newt2(:,9) = newt2.Date + newt2.Date.Month/12 + newt2.Date.Day/365;
[st,ist] = sort(newt2);
newt3 = newt2(ist(:,9),:);

%figure_w_normalized_uicontrolunits(3)
%clf
%plode = plot(newt3(:,9),-newt3(:,8),'o')
%axis([81 92.6 -20 0])
%grid
%xlabel('Time')
%ylabel('Depth in km')

timeplot
