function [fMshift, fFac, fProbability, fAICc, mProblikelihood] = calc_loglikelihood_dM_rate2(mCat1, mCat2)
% function [fMshift, fFac, fProbability, fAICc, mProblikelihood] = calc_loglikelihood_dM_rate2(mCat1, mCat2);
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
% fAICc         : Corrected Akaike Information Criterion
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


for fMshift = -0.3:0.1:0.3
    % fMshift
    % Apply shift
    mCat1Mod(:,6) = mCat1Mod(:,6)+fMshift;
    % Determine magnitude bounds
    fMinMag = min([min(mCat1Mod(:,6)) min(mCat2(:,6))]);
    fMaxMag = max([max(mCat1Mod(:,6)) max(mCat2(:,6))]);
    %% Calculate model for best fiting Mc
    %[fProbMin, fMc,vX, fNmax, mDataPred] = calc_McCdf2(mCat1Mod, 0.1);
    [mResult, fMls, fMc, fMu, fSigma, mDataPred, vPredBest, fBvalue] = calc_McCdfnormal(mCat1Mod, 0.1);
    try % mDataPred can be empty
        vPredOrgFMD = mDataPred(:,1)'./fPeriod1;
        vMags = mDataPred(:,2)';
        [vModFMD,vBin1] = hist(mCat1(:,6),min(vMags):0.1:max(vMags));
        %[vObsFMD,vBin2] = hist(mCat2(:,6),fMinMag:0.1:fMaxMag);
        % FMD to be modeled
        [vObsFMD,vBin2] = hist(mCat2(:,6),min(vMags):0.1:max(vMags));
        vObsFMD = ceil(vObsFMD./fPeriod2);
        % FMD to manipulate
        %[vPredFMD,vBin1] = hist(mCat1Mod(:,6),0:0.1:fMaxMag);
        for fFac=0.2:0.1:3
            vPredFMD = vPredOrgFMD*fFac;
            %         figure_w_normalized_uicontrolunits(30)
            %         plot(vBin2, vObsFMD./fPeriod2,'bo')
            %         hold on
            %         plot(vMags, vModFMD./fPeriod1,'go')
            %         plot(vMags,vPredFMD,'r')
            %         hold off
            % Calculate the likelihoods for both models
            vProb_ = calc_log10poisspdf2(vObsFMD',vPredFMD');
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
            fProbability = NaN;
            fFac = NaN;
        else
            fProbability = vFacloglikeli(:,1);
            fFac = vFacloglikeli(:,2);
        end
        % Vector of lowest max. likelihood score for simple magntidue shift and a rate factor
        vdM_Fac = [vdM_Fac; fMshift fFac fProbability];
        vMshift = repmat(fMshift, length(vfProbability),1);
        mProblikelihood = [mProblikelihood; vMshift vFac vfProbability];
    catch
        vdM_Fac = [vdM_Fac; NaN NaN NaN];
    end % of try-catch block
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
    fProbability = NaN;
    fMshift = NaN;
    fFac = NaN;
else
    fProbability = vdM_Fac(1,3);
    fMshift = vdM_Fac(1,1);
    fFac = vdM_Fac(1,2);
end

nDegFree = 2; % Magnitude shift and rate factor are degrees of freedom
n_samples = length(mCat1(:,6))+length(mCat2(:,6));
%% Corrected Akaike Information Criterion (AICc)
fAICc = -2*(-fProbability)+2*nDegFree+2*nDegFree*(nDegFree+1)/(n_samples-nDegFree-1);
