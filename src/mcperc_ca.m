report_this_filefun(mfilename('fullpath'));

% This is a comleteness determinationm test


[bv magco0 stan av me mer me2,  pr] =  bvalca3(newt2,inb1,inb2);

rati = 0.5;
dat = [];
im = magco0 - 0.7;

while rati < 0.95;
    im = im + 0.1;
    l = newt2(:,6) >= im;
    nu = length(newt2(l,6));
    [bv magco stan av me mer me2,  pr] =  bvalca3(newt2(l,:),2,2);
    nc = 10.^(av - bv*(im+0.05)) ;nu   , nc
    rati = nu/nc;
    disp(['Completeness Mc: ' num2str(im) ';  rati = ' num2str(rati) '   ' num2str(nu) ]);

end


disp(['Completeness Mc: ' num2str(im) ]);


