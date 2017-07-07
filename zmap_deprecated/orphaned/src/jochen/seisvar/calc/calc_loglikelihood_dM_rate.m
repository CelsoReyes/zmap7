function [fMshift, fFac, fProbability, fBic, mProblikelihood] = calc_loglikelihood_dM_rate(mCat1, mCat2)
% function [fMshift, fFac, fProbability, fBic, mProblikelihood] = calc_loglikelihood_dM_rate(mCat1, mCat2);
% ----------------------------------------------------------------------------------------
% Calculate log-likelihood estimation for a combination of a magnitude shift dM and a rate
% factor change
%
% Incoming variable
% mCat1 : EQ catalog period 1 (observed catalog to be manipulated)
% mCat2 : EQ catalog period 2 (observation catalog)
%
% Outgoing variable
% fProbability : log-likelihood probabilty
% fMshift      : Magnitude shift for lowest  max. likelihood score
% fFac         : Rate factor for lowest max. likelihood score
% fBic         : Bayesian Information Criterion value
% mProblikelihood : Resulting matrix of parameter combinations: Shift, Rate factor and
%                   likelihood score
% Author: J. Woessner, woessner@seismo.ifg,.ethz.ch
% last update: 28.10.02

% Initialize
vfProbability = [];
vMshift = [];
vFac = [];
vdM_Fac = [];
mProblikelihood = [];

% Determine exact time period
fPeriod1 = max(mCat1(:,3)) - min(mCat1(:,3));
fPeriod2 = max(mCat2(:,3)) - min(mCat2(:,3));

% Create model catalog
mCat1Mod = mCat1;


for fMshift = -0.5:0.1:0.5
    % fMshift
    % Apply shift
    mCat1Mod(:,6) = mCat1Mod(:,6)+fMshift;
    % Determine magnitude bounds
    fMinMag = min([min(mCat1Mod(:,6)) min(mCat2(:,6))]);
    fMaxMag = max([max(mCat1Mod(:,6)) max(mCat2(:,6))]);
    % FMD to be modeled
    [vObsFMD,vBin2] = hist(mCat2(:,6),0:0.1:fMaxMag);
    vObsFMD = ceil(vObsFMD./fPeriod2);
    % FMD to manipulate
    [vPredFMD,vBin1] = hist(mCat1Mod(:,6),0:0.1:fMaxMag);
    % Time normalization and round due to Poisson distribution calculation in calc_log10poisspdf
    vPredOrgFMD = vPredFMD./fPeriod1;
    for fFac=0.1:0.1:3.5
        vPredFMD = ceil(vPredOrgFMD*fFac);
        % Calculate the likelihoods for both models
        vProb_ = calc_log10poisspdf(vObsFMD',vPredFMD');
        % Sum the probabilities
        fProbability = (-1) * sum(vProb_);
        vfProbability = [vfProbability; fProbability];
        vFac = [vFac; fFac];
       % [vFac vfProbability]
       % [vObsFMD', vPredFMD']
    end
    %%% Find the minimum loglikelihodd score: if the minimum score is obtained several times, calculate MEAN
    %%% of the magnitude shift
    vFacloglikeli = [vfProbability vFac];
    vSel = (vFacloglikeli == min(vFacloglikeli(:,1)));
    vFacloglikeli = vFacloglikeli(vSel,:);
    if length(vFacloglikeli(:,1)) > 1
        fProbability = min(vFacloglikeli(:,1));
        fFac = mean(vFacloglikeli(:,2));
    elseif length(vFacloglikeli(:,1)) == 0
        fProbability = nan;
        fFac = nan;
    else
        fProbability = vFacloglikeli(:,1);
        fFac = vFacloglikeli(:,2);
    end
    % Vector of lowest max. likelihood score for simple magntidue shift and a rate factor
    vdM_Fac = [vdM_Fac; fMshift fFac fProbability];
    vMshift = repmat(fMshift, length(vfProbability),1);
    mProblikelihood = [mProblikelihood; vMshift vFac vfProbability];
    % Reset temporary containers and catalog to original
    vfProbability = [];
    vFac = [];
    vFacloglikeli = [];
    vPredFMD = [];
    vPredOrg = [];
    mCat1Mod = mCat1;
end

%%% Find the minimum loglikelihood score: if the minimum score is obtained several times, calculate MEAN
%%% of the magnitude shift and rate factor application
vSel2 = (vdM_Fac == min(vdM_Fac(:,3)));
vdM_Fac = vdM_Fac(vSel2(:,3),:);
if length(vdM_Fac(:,1)) > 1
    fProbability = min(vdM_Fac(:,3));
    fMshift = min(vdM_Fac(:,1));
    fFac = min(vdM_Fac(:,2));
elseif length(vdM_Fac(:,1)) == 0
    fProbability = nan;
    fMshift = nan;
    fFac = nan;
else
    fProbability = vdM_Fac(1,3);
    fMshift = vdM_Fac(1,1);
    fFac = vdM_Fac(1,2);
end

%% Bayesian Information Criterion (BIC)
nDegFree = 2; % Magnitude shift is the degree of freedom
n_samples = length(mCat1(:,6));
fBic = 2*fProbability + 2*log(n_samples)*nDegFree;
