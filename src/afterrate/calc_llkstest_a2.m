function [H,P,KSSTAT,fRMS] = calc_llkstest_a2(time_as,fT1,pval1, pval2, cval1, cval2, kval1, kval2, nMod)
    % calc_llkstest_a2 Calculate KS-Test as goodness-of fit test and RMS of the fit in the learning period
    %
    % [H,P,KSSTAT,fRMS] = calc_llkstest_a2(time_as,fT1,pval1, pval2, cval1, cval2, kval1, kval2, nMod)
    %
    % Input variables:
    % time_as      : Times elapsed between mainshock and each aftershock (duration or days)
    % fT1          : Time elapsed to between mainshock and biggest aftershock (duration or days)
    % pval1, pval2 : p-values of the two periods
    % cval1, cval2 : c-values of the two periods
    % kval1, kval2 : k-values of the two periods
    % nMod         : Fitting model of for Omori parameters
    %
    % Outgoing variables:
    % H       : Reject nullhypothesis (1) or not (0)
    % P       : P-value of the KS-Test
    % KSSTAT  : KS-Test satistic  => See kstest2 for more explanations on the test
    % fRMS    : RMS of the fit
    %
    % see also kstest2
    %
    % J.Woessner, S. Wiemer
    % updated: 13.08.03

    % check input values
    
    if isduration(time_as)
        time_as = days(time_as);
    else
        assert(isnumeric(time_as),'time_as should either be a duration or the number of days')
    end
    if isduration(fT1)
        fT1 = days(fT1);
    else
        assert(isnumeric(fT1),'biggest aftershock should be either a duration or number of days since mainshock');
    end
    
    % Calculate cumulative number for the model
    
    nAftershocks = length(time_as);
    cumnrf = (1:nAftershocks)';
    switch nMod % switch based on the Fitting Model for Omori Parameters
        case 1
            if pval1 ~= 1
                cumnr_modelf = kval1 ./ (pval1-1) .* ...
                    (cval1.^(1-pval1) - (time_as+cval1).^(1-pval1));
            else
                cumnr_modelf =  kval1 .* log(time_as ./ cval1 + 1);
            end
        otherwise
            if pval1 ~= 1
                % calculate values for aftershocks occurring before biggest aftershock
                mask = time_as <= fT1;
                ev = time_as(mask);
                cumnr_modelf(mask) = kval1./(pval1-1) .* ...
                    ( cval1.^(1-pval1) - (ev+cval1) .^ (1-pval1) );
                
                % calculate values for aftershocks occurring after biggest aftershock
                mask = ~mask; % events AFTER fT1
                ev = time_as(mask);
                
                if pval2 ~=1
                    cumnr_modelf(mask) = kval1 ./ (pval1-1) ...
                        .* (cval1.^(1-pval1) - (ev+cval1).^(1-pval1)) ...
                        + kval2/(pval2-1)  .* (cval2.^(1-pval2)-(ev-fT1+cval2).^(1-pval2) );
                else
                    cumnr_modelf(mask) = kval1 .* log(ev/cval1+1) + kval2.*log((ev-fT1)./cval2 + 1);
                end
            else 
                % take the simple route, since pval1 is 1.
                mask = time_as <= fT1;
                ev = time_as(mask);
                
                % calculate values for aftershocks occurring before biggest aftershock
                cumnr_modelf(mask) = kval1 .* log(ev ./ cval1 + 1);
                
                % calculate values for aftershcks occurring after biggest aftershock
                mask = ~mask; % events AFTER fT1
                ev = time_as(mask);
                
                cumnr_modelf(mask) = kval1 .* log(ev./cval1+1) + kval2.*log((ev-fT1)./cval2 + 1);
                
            end
            
    end % End of switch for nMod
    
    time_as=sort(time_as);
    cumnr_modelf=sort(cumnr_modelf);

    % Calculate KSTEST2 as a measure of the goodness of fit
    [H,P,KSSTAT] = kstest2(cumnr_modelf,cumnrf);

    % Calculate RMS
    i=(1:nAftershocks)';
    fRMS = (sum((i-cumnr_modelf).^2)/length(i))^0.5;
