%
report_this_filefun(mfilename('fullpath'));

for i = 1:j
    do = ['tmp = an' num2str(i) ';' ];
    eval(do)
    m = [];
    for t = 1:length(tmp(:,1) )
        xa0 = tmp(t,1);ya0 = tmp(t,2);
        l = sqrt(((a(:,1)-xa0)*cos(pi/180*ya0)*111).^2 + ((a(:,2)-ya0)*111).^2) ;
        [s,is] = sort(l);
        m = [m ; is(1:ni,1)];
    end  % for t
    m = sort(m);
    m2 = [0 ; m(1:length(m)-1)];
    l = find(m-m2 > 0);
    do = ['anB' num2str(i) ' = a(m(l),:);' ];
    eval(do)
end   % for i
%
