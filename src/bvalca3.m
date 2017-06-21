function [bv, magco, std_backg, av, me, mer , me2, pr] =  bvalca3(b,inb1,inb2)
    global  backcat fontsz n les teb t0b no1 bo1 xt3 bvalsum3

    %report_this_filefun(mfilename('fullpath'));

    newcat = b;
    dm1 = 0.1;
    pr = NaN; me2 = NaN; mer = NaN; av = NaN; me = NaN; std_backg = NaN; magco = NaN; bv = NaN;
    maxmag = max(newcat.Magnitude);
    mima = min(newcat.Magnitude);
    if mima > 0 ; mima = 0 ; end

    try % if an error occures, set values to NaN

        % number of mag units
        nmagu = (maxmag*10)+1;

        bval = zeros(1,nmagu);
        bvalsum = zeros(1,nmagu);
        bvalsum3 = zeros(1,nmagu);

        [bval,xt2] = hist(newcat.Magnitude,(mima:dm1:maxmag));
        bvalsum = cumsum(bval);                        % N for M <=
        bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
        xt3 = (maxmag:-dm1:mima);

        backg_ab = log10(bvalsum3);
        difb = [0 diff(bvalsum3) ];
        %
        i = find(difb == max(difb));
        i = max(i);
        i2 = find(bval == max(bval));
        magco = max(xt2(i2));
        % if no automatic etimate of Mcomp
        if inb1 == 2
            i = length(xt3)-10*min(newcat.Magnitude);
            if i > length(xt3); i = length(xt3)-1 ; end
        end

        i2 = 1;

        par2 = 0.1 * max(bvalsum3);
        par3 = 0.12 * max(bvalsum3);
        M1b = [];
        M1b = [xt3(i) bvalsum3(i)];

        M2b = [];
        M2b =  [xt3(i2) bvalsum3(i2)];

        ll = xt3 >= M1b(1) & xt3 <= M2b(1);
        x = xt3(ll);
        y = backg_ab(ll);
        %[p,s] = polyfit2(x,y,1);                   % fit a line to background
        [aw bw,  ew] = wls(x',y');
        p = [bw aw];
        f = polyval(p,x);
        f = 10.^f;
        rt = (teb - t0b)/(10.^(polyval(p,6.0)));
        r = corrcoef(x,y);
        r = r(1,2);
        %std_backg = std(y - polyval(p,x));      % standard deviation of fit
        std_backg = ew;

        l = b(:,6) >= M1b(1) & b(:,6) <= M2b(1);
        les = (mean(b(l,6)) - M1b(1))/dm1;

        av=p(1,2);
        p=-p(1,1);
        bv=fix(100*p)/100;
        std_backg=fix(100*std_backg)/100;

        % calculate probability
        b2 = p; n2 =  M1b(2);
        n = no1+n2;
        da = -2*n*log(n) + 2*no1*log(no1+n2*bo1/b2) + 2*n2*log(no1*b2/bo1+n2) -2;
        pr = (1  -  exp(-da/2-2))*100;
        % if bo1 > b2 ; pr = -pr; end

    catch
        disp('Error while evaluating bvalca3 - set to NaN');
        bv= NaN;  magco= NaN;  std_backg = NaN ;  av = NaN; me = NaN;  mer = NaN ; me2 = NaN ; pr= NaN ;


    end  % try




