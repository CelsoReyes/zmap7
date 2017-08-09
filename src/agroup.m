% This script finds overlapping alarms in space-time
% and groups them together
%
% Stefan Wiemer    4/95

global abo

report_this_filefun(mfilename('fullpath'));

% Reset the alarms to the all alarms above the current threshold
l = abo2(:,4) >= tre2;
abo = abo2(l,:);
abo(:,5) = abo(:,5)* days(ZG.bin_days) + ZG.a.Date(1);


j = 0;
tmp = abo;
figure_w_normalized_uicontrolunits(map)

while length(abo) > 1
    j = j+1;
    [k,m] = findnei(1);
    po = k;
    for i = 1:length(k)
        [k2,m2]  = findnei(k(i));
        po = [po ; k2];
    end
    po = sort(po);
    po2 = [0;  po(1:length(po)-1)] ;
    l = find(po-po2 > 0) ;
    po3 = po(l) ;
    do = ['an' num2str(j) ' = abo(po3,:);'];
    disp([num2str(j) '  Anomalie groups  found'])
    eval(do)
    pl = plot(abo(po3,1),abo(po3,2),'co');
    set(pl,'MarkerSize',5,'Linewidth',4.0,...
        'Color',[rand rand rand])
    abo(po3,:) =[];
end   % while j
