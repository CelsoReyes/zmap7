function [fProbability, fAICc] = calc_loglikelihood_nochange2(mCat1, mCat2)
% function [fProbability, fAICc] = calc_loglikelihood_nochange2(mCat1, mCat2);
% ----------------------------------------------------------------------------------------------
% Calculate log-likelihood estimation of NO CHANGE between the two periods
%
% Incoming variable
% mCat1 : EQ catalog period 1 (Catalog to be modified)
% mCat2 : EQ catalog period 2 (Observed catalog)
%
% Outgoing variable
% fProbability : log-likelihood probabilty
% fAICc         : Corrected Akaike Information Criterion
%
% Author: J. Woessner, woessner@seismo.ifg,.ethz.ch
% last update: 26.11.02

fBinning = 0.1;

% Determine exact time period
fPeriod1 = max(mCat1(:,3)) - min(mCat1(:,3));
fPeriod2 = max(mCat2(:,3)) - min(mCat2(:,3));


% Initialize values
fMinMag = min([min(mCat1(:,6)) min(mCat2(:,6))]);
fMaxMag = max([max(mCat1(:,6)) max(mCat2(:,6))]);

try
    %% Calculate model for best fiting Mc
    [mResult, fMls, fMc, fMu, fSigma, mDatPred, vPredBest, fBvalue] = calc_McCdfnormal(mCat1, fBinning);
    vPredFMD = mDatPred(:,1)'./fPeriod1;
    vMags = mDatPred(:,2)';
    % FMD to be modeled
    [vObsFMD,vBin2] = hist(mCat2(:,6),min(vMags):0.1:max(vMags));
    vObsFMD = ceil(vObsFMD./fPeriod2);
    % Calculate the likelihoods for both models
    vProb_ = calc_log10poisspdf2(vObsFMD', vPredFMD');
    % Sum the probabilities
    fProbability = (-1) * sum(vProb_);

    nDegFree = 0; % degree of freedom
    n_samples = length(mCat2(:,6));
    %% Corrected Akaike Information Criterion (AICc)
    fAICc = -2*(-fProbability)+2*nDegFree+2*nDegFree*(nDegFree+1)/(n_samples-nDegFree-1);
catch
    fAICc = nan;
    fProbability = nan;
end
