function [fFac, fProbability, fBic, mProblikelihood] = calc_loglikelihood_rate(mCat1, mCat2)
% function [fFac, fProbability, fBic, mProblikelihood] = calc_loglikelihood_rate(mCat1, mCat2);
% ---------------------------------------------------------------------------------------------
% Calculate log-likelihood estimation of rate factor fFac between to periods
%
% Incoming variable
% mCat1 : EQ catalog period 1 (catalog to be manipulated with rate factor)
% mCat2 : EQ catalog period 2 (observed catalog)
%
% Outgoing variable
% fProbability : log-likelihood probabilty
% fFac         : Rate factor with lowest max. likelihood score
% fBic         : Bayesian Information Criterion value
% mProblikelihood : Solution matrix: rate factor, likelihood score
%
% Author: J. Woessner, woessner@seismo.ifg,.ethz.ch
% last update: 28.10.02

% Initialize
mProblikelihood = [];
vfProbability = [];
vFac = [];

% Determine exact time period
fPeriod1 = max(mCat1(:,3)) - min(mCat1(:,3));
fPeriod2 = max(mCat2(:,3)) - min(mCat2(:,3));

%Initialize values
fMinMag = min([min(mCat1(:,6)) min(mCat2(:,6))]);
fMaxMag = max([max(mCat1(:,6)) max(mCat2(:,6))]);

% Magnitude distribution first catalog and normalize
% Time normalization and round due to Poisson distribution calculation in calc_log10poisspdf
[vPredOrgFMD,vBin1] = hist(mCat1(:,6),0:0.1:fMaxMag);
vPredOrgFMD = vPredOrgFMD./fPeriod1;
% Magnitude distribution second catalog and normalize
% Time normalization and round due to Poisson distribution calculation in calc_log10poisspdf
[vObsFMD,vBin2] = hist(mCat2(:,6),0:0.1:fMaxMag);
vObsFMD = ceil(vObsFMD./fPeriod2);
for fFac = 0.1:0.1:3.5
    % Apply rate factor
    vPredFMD = ceil(vPredOrgFMD*fFac);
    % Calculate the likelihoods for both models
    vProb_ = calc_log10poisspdf(vObsFMD', vPredFMD');
    %[vObsFMD' vPredFMD' vProb_];
    % Sum the probabilities
    fProbability = (-1) * sum(vProb_);
    vfProbability = [vfProbability; fProbability];
    vFac = [vFac; fFac];
    vProb_ = [];
end
%%% Find the minimum loglikelihood score: if the minimum score is obtained several times, calculate MEAN
%%% of the magnitude shift
vFacloglikeli = [vfProbability vFac];
vSel = (vFacloglikeli == min(vFacloglikeli(:,1)));
vFacloglikeli = vFacloglikeli(vSel,:);
if length(vFacloglikeli(:,1)) > 1
    fProbability = min(vFacloglikeli(:,1));
    fFac = mean(vFacloglikeli(:,2));
else
    fProbability = vFacloglikeli(:,1);
    fFac = vFacloglikeli(:,2);
end

mProblikelihood = [vFac vfProbability];
%% Bayesian Information Criterion (BIC)
nDegFree = 1; % Magnitude shift is the degree of freedom
n_samples = length(mCat1(:,6));
fBic = 2*fProbability + 2*log(n_samples)*nDegFree;
