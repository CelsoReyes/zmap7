function [fProbability, fBic] = calc_loglikelihood_nochange(mCat1, mCat2)
% function [fProbability, fBic] = calc_loglikelihood_nochange(mCat1, mCat2);
% ----------------------------------------------------------------------------------------------
% Calculate log-likelihood estimation of NO CHANGE between the two periods
%
% Incoming variable
% mCat1 : EQ catalog period 1 (Catalog to be modified)
% mCat2 : EQ catalog period 2 (Observed catalog)
%
% Outgoing variable
% fProbability : log-likelihood probabilty
% fBic         : Bayesian Information Criterion value
%
% Author: J. Woessner, woessner@seismo.ifg,.ethz.ch
% last update: 26.11.02

% Determine exact time period
fPeriod1 = max(mCat1(:,3)) - min(mCat1(:,3));
fPeriod2 = max(mCat2(:,3)) - min(mCat2(:,3));


% Initialize values
fMinMag = min([min(mCat1(:,6)) min(mCat2(:,6))]);
fMaxMag = max([max(mCat1(:,6)) max(mCat2(:,6))]);

[vPredFMD,vBin1] = hist(mCat1(:,6),0:0.1:fMaxMag);
[vObsFMD,vBin2] = hist(mCat2(:,6),0:0.1:fMaxMag);
% Time normalization and round due to Poisson distribution calculation in calc_log10poisspdf
vPredFMD = ceil(vPredFMD./fPeriod1);
vObsFMD = ceil(vObsFMD./fPeriod2);
% Calculate the likelihoods for both models
vProb_ = calc_log10poisspdf(vObsFMD', vPredFMD');
% Sum the probabilities
fProbability = (-1) * sum(vProb_);

%% Bayesian Information Criterion (BIC)
nDegFree = 0; % degree of freedom
n_samples = length(mCat1(:,6));
fBic = 2*fProbability + 2*log(n_samples)*nDegFree;
