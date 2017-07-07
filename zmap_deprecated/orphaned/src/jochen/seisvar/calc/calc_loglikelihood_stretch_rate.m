function [fStretch, fFac, fProbability, fBic, mPlotlikelihood] = calc_loglikelihood_stretch_rate(mCat1, mCat2)
% function [fStretch, fFac, fProbability, fBic, mPlotlikelihood] = calc_loglikelihood_stretch_rate(mCat1, mCat2);
% ---------------------------------------------------------------------------------------------------------------
% Calculate log-likelihood estimation for a combination of a magnitude stretch c and a rate factor change
%
% Incoming variable
% mCat1 : EQ catalog period 1 (observed catalog to be manipulated)
% mCat2 : EQ catalog period 2 (observation catalog)
%
% Outgoing variable
% fProbability : log-likelihood probabilty
% fStretch      : Magnitude shift for lowest  max. likelihood score
% fFac         : Rate factor for lowest max. likelihood score
% fBic         : Bayesian Information Criterion value
% mPlotlikelihood : Resulting matrix of parameter combinations: Stretch, Rate factor and
%                   likelihood score
%
% Author: J. Woessner, woessner@seismo.ifg,.ethz.ch
% last update: 28.10.02


% Initialize
vfProbability = [];
vFac = [];
vdS_Fac = [];
mPlotlikelihood = [];

% Determine exact time period
fPeriod1 = max(mCat1(:,3)) - min(mCat1(:,3));
fPeriod2 = max(mCat2(:,3)) - min(mCat2(:,3));

% Create model catalog
mCat1Mod = mCat1;

for fStretch = 0.5:0.1:1.5
    % fStretch
    % Apply stretch
    mCat1Mod(:,6) = mCat1Mod(:,6).*fStretch;
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
        vProb_ = calc_log10poisspdf(vObsFMD', vPredFMD');
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
    vdS_Fac = [vdS_Fac; fStretch fFac fProbability];
    vStretch = repmat(fStretch, length(vfProbability),1);
    mPlotlikelihood = [mPlotlikelihood; vStretch vFac vfProbability];
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
vSel2 = (vdS_Fac == min(vdS_Fac(:,3)));
vdS_Fac = vdS_Fac(vSel2(:,3),:);
if length(vdS_Fac(:,1)) > 1
    fProbability = min(vdS_Fac(:,3));
    fStretch = min(vdS_Fac(:,1));
    fFac = min(vdS_Fac(:,2));
elseif length(vdS_Fac(:,1)) == 0
    fProbability = nan;
    fStretch = nan;
    fFac = nan;
else
    fProbability = vdS_Fac(1,3);
    fStretch = vdS_Fac(1,1);
    fFac = vdS_Fac(1,2);
end

%% Bayesian Information Criterion (BIC)
nDegFree = 2; % Magnitude shift is the degree of freedom
n_samples = length(mCat1(:,6));
fBic = 2*fProbability + 2*log(n_samples)*nDegFree;

