report_this_filefun(mfilename('fullpath'));

% This is a comleteness determinationm test

%[bv magco0 stan,  av] =  bvalca3(newt2,inb1,inb2);


dat = [];

for i = magco0 - 0.5:0.1:magco0+0.7
    l = newt2(:,6) >= i; nu = length(newt2(l,6));
    [bv magco stan,  av] =  bvalca3(newt2(l,:),2,2);
    nc = 10.^(av - bv*(i+0.05)) ;
    dat = [dat ; i nc nu nu/nc];
end

j =  min(find(dat(:,4) >= 0.95));
Mc = dat(j,1);
magco = Mc;
if isempty(magco) == 1; magco = nan; end
%disp(['Completeness Mc: ' num2str(Mc) ]);


