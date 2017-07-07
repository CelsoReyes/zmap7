report_this_filefun(mfilename('fullpath'));

%iwl = input('Please input the window lenght iwl:  ')
ncu = length(cumuall(1,:));
lta = 1:1:ncu-2;
var1 = zeros(1,ncu);
var2 = zeros(1,ncu);
lta = zeros(1,ncu);
maxlta = zeros(1,ncu);
maxlta = maxlta -5;
mean1 = mean(cumuall(1:tdiff,:));
for i = 1:ncu
    var1(i) = cov(cumuall(1:tdiff,i));
end     % for i


it
mean2 = mean(cumuall(it:it+iwl,:));
for i = 1:ncu
    %   var1(i) = cov(cumuall(1:tdiff,i));
    var2(i) = cov(cumuall(it:it+iwl,i));
end     % for i
lta = (mean1 - mean2)./(sqrt(var1/it+var2/(tdiff-it)));
maxlta2 = [maxlta ;  lta ];
maxlta = max(maxlta2);



re3 = reshape(maxlta,length(gy),length(gx));

% set values gretaer tresh = nan
%
[len, ncu] = size(cumuall);
s = cumuall(len,:);
r = reshape(s,length(gy),length(gx));
l = r > tresh;
re4 = re3;
re4(l) = zeros(1,length(find(l)))*nan;


ma = [ma max(max(re4))];
mi = [mi min(min(re4))];
