function [H,P,KSSTAT,fRMS] = calc_llkstest(time_as, pval, cval, kval)
    % [H,P,KSSTAT,fRMS] = calc_llkstest(time_as, pval, cval, kval);
    % -------------------------------------------------------------------
    % Calculate KS-Test as goodness-of fit test and RMS of the fit in the learning period
    %
    % Input variables:
    % time_as      : Times of aftershocks in days after mainshock
    % pval         : p-value
    % cval         : c-value
    % kval         : k-value
    %
    % Outgoing variables:
    % H       : Reject nullhypothesis (1) or not (0)
    % P       : P-value of the KS-Test
    % KSSTAT  : KS-Test satistic  => See kstest2 for more explanations on the test
    % fRMS    : RMS of the fit
    %
    % J.Woessner, S.Wiemer, S.Neukomm
    % last update: 14.08.03

    % Calculate cumulative number for the model
    cumnrf = (1:length(time_as))';
    cumnr_modelf = [];
    for i=1:length(time_as)
        if pval ~= 1
            cm = kval/(pval-1)*(cval^(1-pval)-(time_as(i)+cval)^(1-pval));
        else
            cm = kval*log(time_as(i)/cval+1);
        end
        cumnr_modelf = [cumnr_modelf; cm];
    end
    time_as=sort(time_as);
    cumnr_modelf=sort(cumnr_modelf);

    % Calculate KSTEST2 as a measure of the goodness of fit
    [H,P,KSSTAT] = kstest2(cumnr_modelf,cumnrf);

    % Calculate RMS
    i=(1:1:length(time_as))';
    fRMS = (sum((i-cumnr_modelf).^2)/length(i))^0.5;

