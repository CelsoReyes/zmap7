function [fMshift, fStretch,fProbability, fBic, mProblikelihood] = calc_loglikelihood_Trans(mCat1, mCat2)
% function [fMshift, fStretch,fProbability, fBic, mProblikelihood] = calc_loglikelihood_Trans(mCat1, mCat2);
% ----------------------------------------------------------------------------------------------------------
% Calculate log-likelihood estimation of a magnitude transformation of stretch and shift. Returns best
% fitting values and solution matrix.
%
% Incoming variable
% mCat1 : EQ catalog period 1 (observed catalog to be manipulated)
% mCat2 : EQ catalog period 2 (observation catalog)
%
% Outgoing variable
% fProbability : log-likelihood probabilty
% fMshift      : Combined magnitude shift for the lowest  max. likelihood score
% fStretch     : Magnitude stretch for lowest max. likelihood score
% fBic         :  Bayesion Information Criterion value
% mProblikelihood : Resulting matrix of parameter combinations: Shift, Stretch and
%                   likelihood score
%
% Author: J. Woessner, woessner@seismo.ifg,.ethz.ch
% last update: 28.10.02

% Containers
vfProbability = [];
vMshift = [];
vShiftStretch = [];
mProblikelihood = [];

% Determine exact time period
fPeriod1 = max(mCat1(:,3)) - min(mCat1(:,3));
fPeriod2 = max(mCat2(:,3)) - min(mCat2(:,3));

mCat1Mod = mCat1;
for fStretch = 0.5:0.1:1.5
        % fStretch
    for fMshift = -0.5:0.1:0.5
        %         fMshift
        mCat1Mod(:,6) = fStretch.*mCat1Mod(:,6)+fMshift;
        % Initialize values
        fMinMag = min([min(mCat1Mod(:,6)) min(mCat2(:,6))]);
        fMaxMag = max([max(mCat1Mod(:,6)) max(mCat2(:,6))]);

        [vPredFMD,vBin1] = hist(mCat1Mod(:,6),0:0.1:fMaxMag);
        [vObsFMD,vBin2] = hist(mCat2(:,6),0:0.1:fMaxMag);
        % Time normalization
        vPredFMD = ceil(vPredFMD./fPeriod1);
        vObsFMD = ceil(vObsFMD./fPeriod2);
        %  Calculate the likelihoods for both of the models
        vProb_ = calc_log10poisspdf(vObsFMD', vPredFMD');
        %[vObsFMD' vPredFMD' vProb_];
        % Sum the probabilities
        fProbability = (-1) * sum(vProb_);
        vfProbability = [vfProbability; fProbability];
        vMshift = [vMshift; fMshift];
        mCat1Mod = mCat1;
    end
    %% Find the minimum loglikelihood score: if the minimum score is obtained several times, calculate MEAN
    %% of the magnitude shift
    vdMloglikeli = [vfProbability vMshift];
    vSel = (vdMloglikeli == min(vdMloglikeli(:,1)));
    vdMloglikeli = vdMloglikeli(vSel,:);
    if length(vdMloglikeli(:,1)) > 1
        fProbability = min(vdMloglikeli(:,1));
        fMshift = mean(vdMloglikeli(:,2));
    elseif length(vdMloglikeli(:,1)) == 0
        fProbability = nan;
        fMshift = nan;
    else
        fProbability = vdMloglikeli(:,1);
        fMshift = vdMloglikeli(:,2);
    end
    vShiftStretch = [vShiftStretch; fStretch fMshift fProbability];
    % Solution matrix
    vStretch = repmat(fStretch, length(vfProbability),1);
    mProblikelihood = [mProblikelihood; vStretch vMshift vfProbability];

    mCat1Mod = mCat1;
    vfProbability = [];
    vMshift = [];
    vdMloglikeli = [];
end
vSel2 = (vShiftStretch == min(vShiftStretch(:,3)));
vShiftStretch = vShiftStretch(vSel2(:,3),:);
if length(vShiftStretch(:,1)) > 1
    fProbability = min(vShiftStretch(:,3));
    fMshift = min(vShiftStretch(:,2));
    fStretch = min(vShiftStretch(:,1));
elseif length(vShiftStretch(:,1)) == 0
    Probability = nan;
    fMshift = nan;
    fStretch = nan;
else
    fProbability = vShiftStretch(1,3);
    fMshift = vShiftStretch(:,2);
    fStretch = vShiftStretch(:,1);
end
% %% Bayesian Information Criterion (BIC)
nDegreeFree = 2 ; % Magnitude shift and stretch are the degrees of freedom
n_samples = length(mCat1(:,6));
fBic = 2*fProbability + 2*log(n_samples)*nDegreeFree;
