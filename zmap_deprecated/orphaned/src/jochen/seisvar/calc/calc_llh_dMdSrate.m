function [fMshift, fStretch, fFac, fProbability, fBic, mProblikelihood] = calc_llh_dMdSrate(mCat1, mCat2)
% function [fMshift, fStretch, fFac, fProbability, fBic, mProblikelihood] = calc_llh_dMdSrate(mCat1, mCat2);
% --------------------------------------------------------------------------------------------------------------------
% Calculate log-likelihood estimation for a combination of a magnitude stretch dS, shift dM and a rate
% factor change
%
% Incoming variable
% mCat1 : EQ catalog period 1 (observed catalog to be manipulated)
% mCat2 : EQ catalog period 2 (observation catalog)
%
% Outgoing variable
% fProbability : log-likelihood probabilty
% fStretch     : Magnitude shift for lowest  max. likelihood score
% fMshift      : Magnitude stretch for lowest  max. likelihood score
% fFac         : Rate factor for lowest max. likelihood score
% fBic         : Bayesian Information Criterion value
% mProblikelihood : Solution matrix (dS, dM, Rate, likelhood score)
%
% Author: J. Woessner, woessner@seismo.ifg,.ethz.ch
% last update: 28.10.02

% Initialize
vfProbability = [];
vFac = [];
vdM_Facloglikeli =[];
vdM_Fac = [];
vdSdM_Fac = [];
mProblikelihood =[];
mProblikelihoodTmp = [];

% Determine exact time period
fPeriod1 = max(mCat1(:,3)) - min(mCat1(:,3));
fPeriod2 = max(mCat2(:,3)) - min(mCat2(:,3));

% Create model catalog
mCat1Mod = mCat1;

for fStretch = 0.5:0.1:1.5
    % fStretch
    for fMshift = -0.5:0.1:0.5
        % Apply shift and stretch
        mCat1Mod(:,6) = mCat1Mod(:,6).*fStretch+fMshift;
        % Determine magnitude bounds
        fMinMag = min([min(mCat1Mod(:,6)) min(mCat2(:,6))]);
        fMaxMag = max([max(mCat1Mod(:,6)) max(mCat2(:,6))]);
        %% Calculate model for best fiting Mc
        [fProbMin, fMc,vX, fNmax, mDataPred] = calc_McCdf2(mCat1Mod, 0.1);
        vPredOrgFMD = mDataPred(:,1)';
        vMags = mDataPred(:,2)';
        [vModFMD,vBin1] = hist(mCat1(:,6),min(vMags):0.1:max(vMags));
        %[vObsFMD,vBin2] = hist(mCat2(:,6),fMinMag:0.1:fMaxMag);
        % FMD to be modeled
        [vObsFMD,vBin2] = hist(mCat2(:,6),min(vMags):0.1:max(vMags));
        vObsFMD = ceil(vObsFMD./fPeriod2);
        for fFac=0.1:0.1:3.5
            vPredFMD = vPredOrgFMD*fFac;
%             figure_w_normalized_uicontrolunits(50)
%             plot(vBin2, vObsFMD,'bo')
%             hold on
%             plot(vMags, vModFMD./fPeriod1,'go')
%             plot(vMags,vPredFMD,'r*')
%             hold off
            % Calculate the likelihoods for both models
            vProb_ = calc_log10poisspdf2(vObsFMD', vPredFMD');
            % Sum the probabilities
            fProbability = (-1) * sum(vProb_);
            vfProbability = [vfProbability; fProbability];
            vFac = [vFac; fFac];
            % [vFac vfProbability]
            % [vObsFMD', vPredFMD']
        end
         % Solution matrix part one
        vMshift = repmat(fMshift, length(vfProbability),1);
        mProblikelihoodTmp = [mProblikelihoodTmp; vMshift vFac vfProbability];
        %%% Find the minimum loglikelihodd score: if the minimum score is obtained several times, calculate MEAN
        %%% value
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
        vdM_Facloglikeli = [vdM_Facloglikeli; fMshift fFac fProbability];
        %% Reset temporary containers and catalog
        vfProbability = [];
        vFac = [];
        vFacloglikeli = [];
        vPredFMD = [];
        vPredOrg = [];
        mCat1Mod = mCat1;
    end
    % Solution matrix part two
    vStretch = repmat(fStretch, length(mProblikelihoodTmp(:,1)),1);
    mProblikelihood = [mProblikelihood; vStretch mProblikelihoodTmp];
    vSel2 = (vdM_Facloglikeli == min(vdM_Facloglikeli(:,3)));
    vdM_Facloglikeli = vdM_Facloglikeli(vSel2(:,3),:);
    if length(vdM_Facloglikeli(:,1)) > 1
        fProbability = min(vdM_Facloglikeli(:,3));
        fFac = mean(vdM_Facloglikeli(:,2));
        fMshift = mean(vdM_Facloglikeli(:,1));
    elseif length(vdM_Facloglikeli(:,1)) == 0
        fProbability = nan;
        fFac = nan;
        fMshift = nan;
    else
        fProbability = vdM_Facloglikeli(:,3);
        fFac = vdM_Facloglikeli(:,2);
        fMshift = vdM_Facloglikeli(:,1);
    end
    % Vector of lowest max. likelihood score for magnitude shift and a rate factor
    vdSdM_Fac = [vdSdM_Fac; fStretch fMshift fFac fProbability];
    % Reset temporary containers and catalog to original
%     vfProbability = [];
%     vFac = [];
%     vFacloglikeli = [];
%     vPredFMD = [];
%     vPredOrg = [];
    vdM_Facloglikeli = [];
    mProblikelihoodTmp = [];
    mCat1Mod = mCat1;
end

%%% Find the minimum loglikelihood score: if the minimum score is obtained several times, calculate MEAN
vSel3 = (vdSdM_Fac == min(vdSdM_Fac(:,4)));
vdSdM_Fac = vdSdM_Fac(vSel3(:,4),:);
if length(vdSdM_Fac(:,4)) > 1
    fMshift = mean(vdSdM_Fac(1,2));
    fStretch = mean(vdSdM_Fac(1,1));
    fFac = mean(vdSdM_Fac(1,3));
    fProbability = vdSdM_Fac(1,4);
elseif length(vdSdM_Fac(:,4)) == 0
    fMshift = nan;
    fStretch = nan;
    fFac = nan;
    fProbability = nan;
else
    fMshift = vdSdM_Fac(1,2);
    fStretch = vdSdM_Fac(1,1);
    fFac = vdSdM_Fac(1,3);
    fProbability = vdSdM_Fac(1,4);
end

%% Bayesian Information Criterion (BIC)
nDegFree = 3; % Magnitude shift is the degree of freedom
n_samples = length(mCat1(:,6));
fBic = 2*fProbability + 2*log(n_samples)*nDegFree;
