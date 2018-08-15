function [bv, magco, std_backg, av, pr] =  bvalca3(magnitudes, mc_auto_estimate, overall_b_value)
    % calculates b-values and more from a catalog
    %
    % [bv, magco, std_backg, av, pr] =  BVALCA3(magnitudes, mc_auto_estimate, overall_b_value)
    %
    % INPUT parameters
    % magnitudes     : Magnitude values
    % mc_auto_estimate: use automatic estimate of Mcomp?
    %        McAutoEstimate.auto  DEFAULT
    %        McAutoEstimate.manual
    % overall_b_value: overall b-value (maybe? used in probability calculation)
    %
    % OUTPUT
    %    bv : b-value
    %    magco : magnitude of completion
    %    std_backg: standard deviation of prediction
    %    av : a-value
    %    pr : probability [OF WHAT?]
    
    global les magsteps_desc bvalsum3
    
    %report_this_filefun();
    dm1 = 0.1;
    [pr,  av, std_backg, magco, bv] = deal(nan);
    maxmag = max(magnitudes);
    mima = min( min(magnitudes) , 0);
    if exist('mc_method','var')
        mc_auto_estimate = McAutoEstimate(mc_auto_estimate);
    else
        mc_auto_estimate=McAutoEstimate.auto;
    end
    
    no1=numel(magnitudes); % added by CGR because no1 appears to not be initialized
    
    %try % if an error occurs, set values to NaN
    
    % number of mag units
    % nmagu = (maxmag*10)+1;
    
    [bval,xt2] = hist(magnitudes,(mima:dm1:maxmag));
    % bvalsum = cumsum(bval);                        % N for M <=
    bvalsum3 = cumsum(bval(end:-1:1));    % N for M >= (counted backwards)
    %bvalsum3 = bvalsum3(:);
    
    magsteps_desc = (maxmag:-dm1:mima);
    %magsteps_desc = magsteps_desc(:);
    
    backg_ab = log10(bvalsum3);
    difb = [0 diff(bvalsum3) ];
    %
    i = find(difb == max(difb),1,'last');
    i2 = bval == max(bval);
    magco = max(xt2(i2));
    
    % if no automatic estimate of Mcomp
    if ~mc_auto_estimate
        i = length(magsteps_desc)- round((10*min(magnitudes))); % guessing how to fix this with parens
        if i > length(magsteps_desc)
            i = length(magsteps_desc)-1 ;
        end
    end
    
    M1b = [magsteps_desc(i) bvalsum3(i)];
    M2b = [magsteps_desc(1) bvalsum3(1)];
    
    ll = magsteps_desc >= M1b(1) & magsteps_desc <= M2b(1);
    x = magsteps_desc(ll);
    y = backg_ab(ll);
    %[p,s] = polyfit2(x,y,1);                   % fit a line to background
    [aw, bw, ~, ew] = wls(x',y');
    p = [bw aw];
    
    %% these commented out parts seem unused
    %f = polyval(p,x);
    %f = 10 .^ f;
    %rt = (teb - t0b)/(10.^(polyval(p,6.0)));
    %r = corrcoef(x,y);
    %r = r(1,2);
    
    %std_backg = std(y - polyval(p,x));      % standard deviation of fit
    std_backg = ew;
    
    l = magnitudes >= M1b(1) & magnitudes <= M2b(1);
    les = (mean(magnitudes(l)) - M1b(1))/dm1;
    
    av=p(1,2);
    p=-p(1,1);
    bv=fix(100*p)/100;
    std_backg=fix(100*std_backg)/100;
    
    if nargout >=5
        % calculate probability [OF WHAT?]
        if ~exist('overall_b_value','var')
            warning('provide overall_bvalue, which is needed to calc pr');
            ZG = ZmapGlobal.Data;
            overall_b_value = ZG.overall_b_value;
        elseif isempty(overall_b_value)
            % providing an empty overall_b_value simply uses the default value
            ZG = ZmapGlobal.Data;
            overall_b_value = ZG.overall_b_value;
        end
            
        b2 = p;
        n2 =  M1b(2);
        n = no1+n2;
        da = -2*n*log(n) + 2*no1*log(no1+n2*overall_b_value/b2) + 2*n2*log(no1*b2/overall_b_value+n2) -2;
        pr = (1  -  exp(-da/2-2))*100; % probability
    end
    %catch ME
    %    warning(ME.message)
    %    disp('Error while evaluating bvalca3 - set to NaN');
    %end
end