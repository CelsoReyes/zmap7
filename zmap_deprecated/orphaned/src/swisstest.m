report_this_filefun(mfilename('fullpath'));

% This is a completeness determination test

newt2 = newcat;
[bv magco0 stan av ] =  bvalca3(newt2,inb1,inb2);


dat = [];

for i = magco0 - 0.9:0.1:magco0+1.5
    if i == 1.9
        i = 1.9
        nu = newt2.Count;
        ll = newt2.Magnitude > 3.3;
        newt2(ll,6) = newt2(ll,6) - 0.20;

        [mw bv2 stan2,  av] =  bmemag(newt2(:,:))
        synthb_aut
        figure
        plot(xt2,(b3-N)./b3*100,'ok')
        hold on
        plot(xt2,(b3-N)./b3*100,'k')
        grid
        res2 = sum(abs(b3 - N))

        return
    end

    l = newt2.Magnitude >= i - 0.0499; nu = length(newt2(l,6));
    %[bv magco stan,  av] =  bvalca3(newt2(l,:),2,2);
    [mw bv2 stan2,  av] =  bmemag(newt2(l,:));
    synthb_aut
    res0 = res;
    % bv = bv + stan ; synthb_aut; res1 = res;
    % bv = bv - 2*stan ; synthb_aut; res2 = res;

    nc = 10.^(av - bv2*(i+0.05)) ;
    nc1 = 10.^(av - (bv2-stan/2)*(i+0.05)) ;
    nc2 = 10.^(av - (bv2+stan/2)*(i+0.05)) ;

    dat = [dat ; i nc nu nu/nc nu/nc1 nu/nc2 res0  ];
    %disp(['Completeness Mc: ' num2str(i) ';  rati = ' num2str(nu/nc)]);

end

return
[mw bv2 stan2,  av] =  bmemag(newt2(:,:))
i = 1.85
l = newt2.Magnitude > 3.0;
newt2(l,6) = newt2(l,6) - 0.2;

%[mw bv2 stan2,  av] =  bmemag(newt2(:,:))
synthb_aut
plot(xt2,(b3-N)./b3*100,'xr')
hold on
plot(xt2,(b3-N)./b3*100,'r')
grid

newt2 = nn;

