function [fMshift, fProbability, fBic, mProblikelihood, fAICc] = calc_loglikelihood_dM(mCat1, mCat2)
% function [fMshift, fProbability, fBic, mProblikelihood] = calc_loglikelihood_dM(mCat1, mCat2);
% ----------------------------------------------------------------------------------------------
% Calculate log-likelihood estimation of magnitude shift dM between to periods
%
% Incoming variable
% mCat1 : EQ catalog period 1 (Catalog to be modified)
% mCat2 : EQ catalog period 2 (Observed catalog)
%
% Outgoing variable
% fProbability : log-likelihood probabilty
% fMshift      : Magnitude shift with the lowest  max. lieklihood score
% fBic         : Bayesian Information Criterion value
% mProblikelihood : Solution matrix shift and likelihood score
%
% Author: J. Woessner, woessner@seismo.ifg,.ethz.ch
% last update: 28.10.02

% Initialize
mProblikelihood = [];
vfProbability = [];
vMshift = [];

% Determine exact time period
fPeriod1 = max(mCat1(:,3)) - min(mCat1(:,3));
fPeriod2 = max(mCat2(:,3)) - min(mCat2(:,3));

mCat1Mod = mCat1;

for fMshift = -0.5:0.1:0.5
    % Apply shift
    mCat1Mod(:,6) = mCat1Mod(:,6)+fMshift;
    % Initialize values
    fMinMag = min([min(mCat1Mod(:,6)) min(mCat2(:,6))]);
    fMaxMag = max([max(mCat1Mod(:,6)) max(mCat2(:,6))]);

    [vPredFMD,vBin1] = hist(mCat1Mod(:,6),0:0.1:fMaxMag);
    [vObsFMD,vBin2] = hist(mCat2(:,6),0:0.1:fMaxMag);
    % Time normalization and round due to Poisson distribution calculation in calc_log10poisspdf
    vPredFMD = ceil(vPredFMD./fPeriod1);
    vObsFMD = ceil(vObsFMD./fPeriod2);
    % Calculate the likelihoods for both models
    vProb_ = calc_log10poisspdf(vObsFMD',vPredFMD');
    % Sum the probabilities
    fProbability = (-1) * sum(vProb_);
    vfProbability = [vfProbability; fProbability];
    vMshift = [vMshift; fMshift];
    mCat1Mod = mCat1;
end

%%% Find the minimum loglikelihodd score: if the minimum score is obtained several times, calculate MEAN
%%% of the magnitude shift
vdMloglikeli = [vfProbability vMshift];
vSel = (vdMloglikeli == min(vdMloglikeli(:,1)));
vdMloglikeli = vdMloglikeli(vSel,:);
if length(vdMloglikeli(:,1)) > 1
    fProbability = min(vdMloglikeli(:,1));
    fMshift = mean(vdMloglikeli(:,2));
else
    fProbability = vdMloglikeli(:,1);
    fMshift = vdMloglikeli(:,2);
end
% Solution matrix
mProblikelihood = [vMshift vfProbability];

nDegFree = 1; % Magnitude shift is the degree of freedom
n_samples = length(mCat1(:,6))+length(mCat2(:,6));
%% Bayesian Information Criterion (BIC)
fBic = 2*fProbability + 2*log(n_samples)*nDegFree;
%% Corrected Akaike Information Criterion (AICc)
fAICc = -2*(-fProbability)+2*nDegFree+2*nDegFree*(nDegFree+1)/(n_samples-nDegFree-1);

