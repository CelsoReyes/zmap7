function [magco, bv, std_backg, av] =  bvalca2(mycat)
    % bvalca2 calculate b-values and more from a catalog
    % [magco, bv, std_backg, av] = bvalca2(catalog)
    % uses weighted least squares
    %
    % see also wls
    
    %report_this_filefun();
    
    dm1 = 0.1;
    maxmag = max(mycat.Magnitude);
    mima = min(mycat.Magnitude);
    if mima > 0 ; mima = 0 ; end
    
    % number of mag units
        
    [bval,~] = hist(mycat.Magnitude,(mima:dm1:maxmag));
    bvalsum3 = cumsum(bval(end:-1:1));    % N for M >= (counted backwards)
    magsteps_desc = (maxmag:-dm1:mima);
    
    backg_ab = log10(bvalsum3);
    difb = [0 diff(bvalsum3) ];
    %
    i = find(difb == max(difb),1,'last');
    i2 = 1;
    magco = max(magsteps_desc(i));
    if nargout==1
        return
    end
    M1b = [magsteps_desc(i) bvalsum3(i)];
    M2b =  [magsteps_desc(i2) bvalsum3(i2)];
    
    ll = magsteps_desc >= M1b(1) & magsteps_desc <= M2b(1);
    x = magsteps_desc(ll);
    y = backg_ab(ll);
    
    [aw, bw, ~, ew] = wls(x',y');
    
    std_backg = ew;
    
    l = mycat.Magnitude >= M1b(1) & mycat.Magnitude <= M2b(1);
    
    av = aw;
    p  = -bw;
    bv = fix(100*p)/100;
    std_backg=fix(100*std_backg)/100;
end

