function [H,P,KSSTAT,fRMS] = calc_llkstest_a2(time_as,fT1,pval1, pval2, cval1, cval2, kval1, kval2, nMod)
    % calc_llkstest_a2 Calculate KS-Test as goodness-of fit test and RMS of the fit in the learning period
    %
    % [H,P,KSSTAT,fRMS] = calc_llkstest_a2(time_as,fT1,pval1, pval2, cval1, cval2, kval1, kval2, nMod)
    %
    % Input variables:
    % time_as      : Times of aftershocks in days after mainshock
    % fT1          : Date of biggest aftershock
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
    % J.Woessner, S. Wiemer
    % updated: 13.08.03

    % % Check values
    % if (isnan(pval1) == 0 & isnan(pval2) == 0)

    % Calculate cumulative number for the model
    cumnrf = (1:length(time_as))';
    cumnr_modelf = [];
    if nMod == 1
        for i=1:length(time_as)
            if pval1 ~= 1
                cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_as(i)+cval1)^(1-pval1));
            else
                cm = kval1*log(time_as(i)/cval1+1);
            end
            cumnr_modelf = [cumnr_modelf; cm];
        end % END of FOR on length(time_as)
    else
        for i=1:length(time_as)
            if time_as(i) <= fT1
                if pval1 ~= 1
                    cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_as(i)+cval1)^(1-pval1));
                else
                    cm = kval1*log(time_as(i)/cval1+1);
                end
                cumnr_modelf = [cumnr_modelf; cm];
            else
                if (pval1 ~= 1 & pval2 ~= 1)
                    cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_as(i)+cval1)^(1-pval1))+ kval2/(pval2-1)*(cval2^(1-pval2)-(time_as(i)-fT1+cval2)^(1-pval2));
                else
                    cm = kval1*log(time_as(i)/cval1+1) + kval2*log((time_as(i)-fT1)/cval2+1);
                end
                cumnr_modelf = [cumnr_modelf; cm];
            end %END of IF on fT1
        end % End of FOR length(time_as)
    end % End of if on nMod
    time_as=sort(time_as);
    cumnr_modelf=sort(cumnr_modelf);

    % Calculate KSTEST2 as a measure of the goodness of fit
    [H,P,KSSTAT] = kstest2(cumnr_modelf,cumnrf);

    % Calculate RMS
    i=(1:1:length(time_as))';
    fRMS = (sum((i-cumnr_modelf).^2)/length(i))^0.5;
    % else
    %     disp('no result')
    %     H=nan;
    %     P=nan;
    %     KSSTAT = nan;
    %     fRMS = nan;
    % end % END of isnan check

