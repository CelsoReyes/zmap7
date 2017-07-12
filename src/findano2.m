% This script file is supposed to find an anomaly
% and estimet the exstend in tame and space
%
% Stefan Wiemer  11/94

report_this_filefun(mfilename('fullpath'));

is3 = [];
ni = 80;

[i,j] = find(re3 > 5.5);
X = reshape(loc(1,:),length(gy),length(gx));
Y = reshape(loc(2,:),length(gy),length(gx));
figure_w_normalized_uicontrolunits(map)
hold on
for k = 1:length(i)
    xa0 = X(i(k),j(k));
    ya0 = Y(i(k),j(k));
    plot(xa0,ya0,'xk')
    l = sqrt(((ZG.a.Longitude-xa0)*cosd(ya0)*111).^2 +   ((ZG.a.Latitude-ya0)*111).^2) ;
    [s,is] = sort(l);
    is3 = [is3 ; is(1:ni)];
end   % for k

is3 = sort(is3);

l = [];
for k = 1:length(is3)-1
    if is3(k) ~= is3(k+1)
        l = [l ; is3(k)];
    end
end

l = sort(l);
ZG.newt2= (a(l,:));
figure_w_normalized_uicontrolunits(map)
hold on
plot(ZG.newt2.Longitude,ZG.newt2.Latitude,'bo');

% estimate length of anomaly
%
i1 = find(ZG.newt2.Longitude == min(ZG.newt2.Longitude));i1 = max(i1);
i2 = find(ZG.newt2.Longitude == max(ZG.newt2.Longitude));i2 = max(i2);
di  = sqrt(((ZG.newt2(i1,1)-ZG.newt2(i2,1))*cosd(ya0)*111).^2 +   ((ZG.newt2(i1,2)-ZG.newt2(i2,2))*111).^2) ;
li = [ZG.newt2(i1,1) ZG.newt2(i1,2) ; ZG.newt2(i2,1) ZG.newt2(i2,2)];
plot(li(:,1),li(:,2))



i1 = find(ZG.newt2.Latitude == min(ZG.newt2.Latitude));
i1 = max(i1);
i2 = find(ZG.newt2.Latitude == max(ZG.newt2.Latitude));
i2 = max(i2)
di2  = sqrt(((ZG.newt2(i1,1)-ZG.newt2(i2,1))*cosd(ya0)*111).^2 +   ((ZG.newt2(i1,2)-ZG.newt2(i2,2))*111).^2) ;

li = [ZG.newt2(i1,1) ZG.newt2(i1,2) ; ZG.newt2(i2,1) ZG.newt2(i2,2)];
plot(li(:,1),li(:,2))

di = max([di; di2])
area = (di/2)^2 *pi



