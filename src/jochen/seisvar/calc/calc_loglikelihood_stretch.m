function [fStretch, fProbability, fBic, mProblikelihood] = calc_loglikelihood_stretch(mCat1, mCat2)
% function [fStretch, fProbability, fBic, mProblikelihood] = calc_loglikelihood_stretch(mCat1, mCat2);
% ----------------------------------------------------------------------
% Calculate log-likelihood estimation of magnitude shift dM between to periods
%
% Incoming variable
% mCat1 : EQ catalog period 1 (Catalog to be modified)
% mCat2 : EQ catalog period 2 (Observed catalog)
%
% Outgoing variable
% fProbability : log-likelihood probabilty
% fStretch     : Stretch with lowest  max. lieklihood score
% fBic         : Bayesian Information Criterion value
% mProblikelihood : Solution matrix stretch and likelihood score
%
% Author: J. Woessner, woessner@seismo.ifg,.ethz.ch
% last update: 28.10.02

% Initialize
mProblikelihood = [];
vfProbability = [];
vStretch = [];

% Determine exact time period
fPeriod1 = max(mCat1(:,3)) - min(mCat1(:,3));
fPeriod2 = max(mCat2(:,3)) - min(mCat2(:,3));

mCat1Mod = mCat1;

for fStretch = 0.5:0.1:1.5
    % Apply shift
    mCat1Mod(:,6) = fStretch.*mCat1Mod(:,6);
    % Initialize values
    fMinMag = min([min(mCat1Mod(:,6)) min(mCat2(:,6))]);
    fMaxMag = max([max(mCat1Mod(:,6)) max(mCat2(:,6))]);

    [vPredFMD,vBin1] = hist(mCat1Mod(:,6),0:0.1:fMaxMag);
    [vObsFMD,vBin2] = hist(mCat2(:,6),0:0.1:fMaxMag);
    % Time normalization and round due to Poisson distribution calculation in calc_log10poisspdf
    vPredFMD = ceil(vPredFMD./fPeriod1);
    vObsFMD = ceil(vObsFMD./fPeriod2);
    % Calculate the likelihoods for both models
    vProb_ = calc_log10poisspdf(vObsFMD', vPredFMD');
    % Sum the probabilities
    fProbability = (-1) * sum(vProb_);
    vfProbability = [vfProbability; fProbability];
    vStretch = [vStretch; fStretch];
    mCat1Mod = mCat1;
end

%%% Find the minimum loglikelihodd score: if the minimum score is obtained several times, calculate MEAN
%%% of the magnitude shift
vdSloglikeli = [vfProbability vStretch];
vSel = (vdSloglikeli == min(vdSloglikeli(:,1)));
vdSloglikeli = vdSloglikeli(vSel,:);
if length(vdSloglikeli(:,1)) > 1
    fProbability = min(vdSloglikeli(:,1));
    fStretch = mean(vdSloglikeli(:,2));
else
    fProbability = vdSloglikeli(:,1);
    fStretch = vdSloglikeli(:,2);
end
% Solution matrix
mProblikelihood = [vStretch vfProbability];

%% Bayesian Information Criterion (BIC)
nDegFree = 1; % Magnitude shift is the degree of freedom
n_samples = length(mCat1(:,6));
fBic = 2*fProbability + 2*log(n_samples)*nDegFree;
