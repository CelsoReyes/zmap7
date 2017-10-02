function [bv, magco, std_backg, av, me, mer , me2, pr] =  bvalca3(bcat,inb1)
    % bvalca3
    % bvalca3(catalog, McompEstimationMethod) maybe
    % used to assign the catalog to ZG.newcat
    %
    global n les xt3 bvalsum3
    
    %report_this_filefun(mfilename('fullpath'));
    ZG = ZmapGlobal.Data;
    dm1 = 0.1;
    [pr, me2, mer, av, me, std_backg, magco, bv] = deal(nan);
    maxmag = max(bcat.Magnitude);
    mima = min( min(bcat.Magnitude) , 0);
    if ~exist('no1','var')
        no1=bcat.Count; % added by CGR because no1 appears to not be initialized
    end
    %try % if an error occures, set values to NaN
        
        % number of mag units
        % nmagu = (maxmag*10)+1;
        
        [bval,xt2] = hist(bcat.Magnitude,(mima:dm1:maxmag));
        % bvalsum = cumsum(bval);                        % N for M <=
        bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
        xt3 = (maxmag:-dm1:mima);
        
        backg_ab = log10(bvalsum3);
        difb = [0 diff(bvalsum3) ];
        %
        i = find(difb == max(difb),1,'last');
        i2 = bval == max(bval);
        magco = max(xt2(i2));

        % if no automatic estimate of Mcomp
        if inb1 == 2
            i = length(xt3)-10*min(bcat.Magnitude);
            if i > length(xt3)
                i = length(xt3)-1 ; 
            end
        end
        
        M1b = [xt3(i) bvalsum3(i)];
        M2b =  [xt3(1) bvalsum3(1)];
        
        ll = xt3 >= M1b(1) & xt3 <= M2b(1);
        x = xt3(ll);
        y = backg_ab(ll);
        %[p,s] = polyfit2(x,y,1);                   % fit a line to background
        [aw, bw, ew] = wls(x',y');
        p = [bw aw];
        
        %% these commented out parts seem unused
        %f = polyval(p,x);
        %f = 10 .^ f;
        %rt = (teb - t0b)/(10.^(polyval(p,6.0)));
        %r = corrcoef(x,y);
        %r = r(1,2);
        
        %std_backg = std(y - polyval(p,x));      % standard deviation of fit
        std_backg = ew;
        
        l = bcat.Magnitude >= M1b(1) & bcat.Magnitude <= M2b(1);
        les = (mean(bcat.Magnitude(l)) - M1b(1))/dm1;
        
        av=p(1,2);
        p=-p(1,1);
        bv=fix(100*p)/100;
        std_backg=fix(100*std_backg)/100;
        
        % calculate probability
        b2 = p; n2 =  M1b(2);
        n = no1+n2;
        da = -2*n*log(n) + 2*no1*log(no1+n2*ZG.bo1/b2) + 2*n2*log(no1*b2/ZG.bo1+n2) -2;
        pr = (1  -  exp(-da/2-2))*100;
    %catch ME
    %    warning(ME.message)
    %    disp('Error while evaluating bvalca3 - set to NaN');
    %end
end