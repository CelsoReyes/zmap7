% This file "maxzlta.m" calcultes  the maximum z value for the LTA
% Function. The parameter step (window) can be defined by the user.
%
report_this_filefun(mfilename('fullpath'));

iwl = iwl3* 365/ZG.bin_days;

[len, ncu] = size(cumuall);       % redefine ncu
len = len -2;
lta = 1:1:ncu-2;
var1 = zeros(1,ncu);
var2 = zeros(1,ncu);
lta = zeros(1,ncu);
maxlta = zeros(1,ncu);
maxlta = maxlta -5;
cu = [cumuall(1:ti-1,:) ; cumuall(ti+iwl+1:len,:)];
mean1 = mean(cu(:,:));
wai = waitbar(0,'Please wait...')
set(wai,'Color',[0.8 0.8 0.8],'NumberTitle','off','Name','Percent done');
for i = 1:ncu
    var1(i) = cov(cu(:,i));
end     % for i

for it = 1:step: len - iwl

    waitbar(it/len)

    mean2 = mean(cumuall(it:it+iwl,:));
    for i = 1:ncu
        var2(i) = cov(cumuall(it:it+iwl,i));
    end     % for i
    lta = (mean1 - mean2)./(sqrt(var1/it+var2/(len-it)));
    maxlta2 = [maxlta ;  lta ];
    maxlta = max(maxlta2);

end    % for it


re3 = reshape(maxlta,length(gy),length(gx));

%save maxz_130.110  maxlta2 gx gy re3

close(wai)

stri = [  'Maximum z  Map of   '  file1];
stri2 = ['iwl = ' num2str(iwl3) 'years'];
in = 'lta';
view_max

