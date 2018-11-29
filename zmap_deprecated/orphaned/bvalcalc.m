function [b_value, magco, std_backg, a_value, me,  rt] = bvalcalc(mycat)
    % bvalcalc calculates b-values and more from a catalog
    %  [bv, magco, std_backg, av, me, ~, rt] = bvalcalc(catalog)
    
    report_this_filefun();
    
    [mima, maxmag] = bounds(mycat.Magnitude);
    dm1 = 0.1;
    if mima > 0
        mima = 0 ; 
    end
    
    mag_bins = mima:dm1:maxmag;
    [bval,~] = hist(mycat.Magnitude, mag_bins);
    % bvalsum = cumsum(bval);                        % N for M <=
    bvalsum3 = cumsum(bval(end:-1:1));    % N for M >= (counted backwards)
    magsteps_desc = mag_bins(end:-1:1);
    
    backg_ab = log10(bvalsum3);
    difb = [0 diff(bvalsum3) ];
    %
    i = find(difb == max(difb),1,'last');
    
    i2 = round(i/3);
    magco = max(magsteps_desc(i));

    M1b = [magsteps_desc(i) bvalsum3(i)];
    M2b = [magsteps_desc(i2) bvalsum3(i2)];
    
    so = log10(bval(10*M1b(1)+2)) - log10(bval(10*M2b(1)));
    me= so/( M2b(1)-0.2- M1b(1));
    
    
    ll = magsteps_desc >= M1b(1) & magsteps_desc <= M2b(1);
    x = magsteps_desc(ll);
    y = backg_ab(ll);
    p = polyfit(x,y,1);                   % fit a line to background
    
    rt = mycat.DateSpan() / (10.^(polyval(p,7.0)));
    
    std_backg = std(y - polyval(p,x));      % standard deviation of fit
    
    l = mycat.Magnitude >= M1b(1) & mycat.Magnitude <= M2b(1);
    
    a_value     = p(2);
    b_value     = fix( 100* (-p(1)))/100;
    std_backg   = fix( 100* std_backg)/100;
end
