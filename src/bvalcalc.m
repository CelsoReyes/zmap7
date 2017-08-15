function [bv, magco, std_backg, av, me, mer , me2, rt] =  bvalcalc(b)
    global  backcat n les teb t0b
    
    report_this_filefun(mfilename('fullpath'));
    
    ZG.newcat = b;
    maxmag = max(ZG.newcat.Magnitude);
    dm1 = 0.1;
    mima = min(ZG.newcat.Magnitude);
    if mima > 0 ; mima = 0 ; end
    
    % number of mag units
    nmagu = (maxmag*10)+1;
    
    bval = zeros(1,nmagu);
    bvalsum = zeros(1,nmagu);
    bvalsum3 = zeros(1,nmagu);
    
    [bval,xt2] = hist(ZG.newcat.Magnitude,(mima:dm1:maxmag));
    bvalsum = cumsum(bval);                        % N for M <=
    bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
    xt3 = (maxmag:-dm1:mima);
    
    %backg_be = log10(bvalsum);
    backg_ab = log10(bvalsum3);
    difb = [0 diff(bvalsum3) ];
    %
    i = find(difb == max(difb));
    i = max(i);
    %i = length(xt3)-10*min(ZG.newcat.Magnitude);
    i2 = round(i/3);
    i = i ;
    magco = max(xt3(i));
    
    par2 = 0.1 * max(bvalsum3);
    par3 = 0.12 * max(bvalsum3);
    M1b = [];
    M1b = [xt3(i) bvalsum3(i)];
    
    M2b = [];
    M2b =  [xt3(i2) bvalsum3(i2)];
    
    l = b.Magnitude >= M1b(1) & b.Magnitude <= M2b(1);
    so = log10(bval(10*M1b(1)+2)) - log10(bval(10*M2b(1)));
    me= so/( M2b(1)-0.2- M1b(1));
    mer = dm1;
    
    
    ll = xt3 >= M1b(1) & xt3 <= M2b(1);
    x = xt3(ll);
    y = backg_ab(ll);
    [p,s] = polyfit2(x,y,1);                   % fit a line to background
    f = polyval(p,x);
    f = 10.^f;
    rt = (teb - t0b)/(10.^(polyval(p,7.0)));
    r = corrcoef(x,y);
    r = r(1,2);
    std_backg = std(y - polyval(p,x));      % standard deviation of fit
    
    n = length(x);
    l = b.Magnitude >= M1b(1) & b.Magnitude <= M2b(1);
    les = (mean(b(l,6)) - M1b(1))/dm1;
    
    
    av=p(1,2);
    p=-p(1,1);
    bv=fix(100*p)/100;
    std_backg=fix(100*std_backg)/100;
    tt2=num2str(std_backg);
    tt1=num2str(p);
end
