function [fMshift, fProbability, fAICc, mProblikelihood, bH, bH2] = calc_loglikelihood_dM2(mCat1, mCat2)
% function [fMshift, fProbability, fAICc, mProblikelihood, bH] = calc_loglikelihood_dM2(mCat1, mCat2);
% ----------------------------------------------------------------------------------------------------
% Calculate log-likelihood estimation of magnitude shift dM between to periods; use power-law
% approximation to first time period for comparison
%
% Incoming variable
% mCat1 : EQ catalog period 1
% mCat2 : EQ catalog period 2 (Observed catalog)
%
% Outgoing variable
% fProbability    : log-likelihood probabilty
% fMshift         : Magnitude shift with the lowest  max. lieklihood score
% fAICc           : Corrected Akaike Information Criterion
% mProblikelihood : Solution matrix shift and likelihood score
% bH              : Result of KSTEST2 hypothesis test at 0.05 significance level
% bH2             : Result of KSTEST2 hypothesis test at 0.05 significance level on EMR-model
%
% Author: J. Woessner, woessner@seismo.ifg,.ethz.ch
% last update: 02.02.04

% Initialize
mProblikelihood = [];
vfProbability = [];
vMshift = [];
vMc = [];
fBinning = 0.1;

% Determine exact time period
fPeriod1 = max(mCat1(:,3)) - min(mCat1(:,3));
fPeriod2 = max(mCat2(:,3)) - min(mCat2(:,3));

mCat1Mod = mCat1;

for fMshift = -0.4:0.1:0.4
    % Apply shift
    mCat1Mod(:,6) = mCat1(:,6)+fMshift;
    % Initialize values
    fMinMag = floor(min([min(mCat1Mod(:,6)) min(mCat2(:,6))]));
    fMaxMag = ceil(max([max(mCat1Mod(:,6)) max(mCat2(:,6))]));
    %% Calculate model for best fitting Mc
     try
        [mResult, fMls, fMc, fMu, fSigma, mDataPred, vPredBest, fBvalue] = calc_McCdfnormal(mCat1Mod, fBinning);
        vPredFMD = mDataPred(:,1)'./fPeriod1;
        vMags = mDataPred(:,2)';
        [vModFMD,vBin1] = hist(mCat1Mod(:,6),fMinMag:0.1:fMaxMag);
        [vObsFMD,vBin2] = hist(mCat2(:,6),min(vMags):0.1:max(vMags));
%             figure_w_normalized_uicontrolunits(40)
%             plot(vBin2, vObsFMD./fPeriod2,'bo')
%             hold on
%             plot(vBin1, vModFMD./fPeriod1,'go')
%             plot(vMags,vPredFMD,'r*')
%             hold off
%             drawnow
        % Time normalization and round due to Poisson distribution calculation in calc_log10poisspdf
        vObsFMD = ceil(vObsFMD./fPeriod2);
        % Calculate the likelihoods for both models
        vProb_ = calc_log10poisspdf2(vObsFMD',vPredFMD');
        % Sum the probabilities
        fProbability = (-1) * sum(vProb_);
        vfProbability = [vfProbability; fProbability];
        vMshift = [vMshift; fMshift];
        vMc = [vMc; fMc];
    catch
        vfProbability = [vfProbability; NaN];
        vMshift = [vMshift; NaN];
        vMc = [vMc; NaN];
    end; % of try-catch
end

try
    %%% Find the minimum loglikelihood score: if the minimum score is obtained several times, calculate MEAN
    %%% of the magnitude shift
    vdMloglikeli = [vfProbability vMshift];
    vSel = (vdMloglikeli == nanmin(vdMloglikeli(:,1)));
    vdMloglikeli = vdMloglikeli(vSel,:);
    if length(vdMloglikeli(:,1)) > 1
        fProbability = min(vdMloglikeli(:,1));
        fMshift = roundn(mean(vdMloglikeli(:,2)),-1);
    else
        fProbability = vdMloglikeli(:,1);
        fMshift = vdMloglikeli(:,2);
    end
    % KS-Test
    [bH,fPval,fKsstat] = kstest2(roundn(mCat2(:,6),-1),roundn(mCat1(:,6)+fMshift,-1),0.05,0);
    % Solution matrix
    mProblikelihood = [vMc vMshift vfProbability];
    nDegFree = 1; % Magnitude shift is the degree of freedom
    n_samples = length(mCat1(:,6))+length(mCat2(:,6));
    %% Corrected Akaike Information Criterion (AICc)
    fAICc = -2*(-fProbability)+2*nDegFree+2*nDegFree*(nDegFree+1)/(n_samples-nDegFree-1);

    % KSTest on Model
    vMag1 = [];
    mCat1Mod(:,6) = mCat1(:,6)+fMshift;
    [mResult, fMls, fMc, fMu, fSigma, mDataPred, vPredBest, fBvalue] = calc_McCdfnormal(mCat1Mod, fBinning);
    mPredFMD = mDataPred;
    %mPredFMD(:,1) = ceil(mDataPred(:,1)./fPeriod1);
    vSel = (mPredFMD(:,2) ~= 0); % Remove bins with zero frequency of zero events
    mData2 = mPredFMD(vSel,:);
    for nCnt=1:length(mData2(:,1))
        fM = repmat(mData2(nCnt,2),mData2(nCnt,1),1);
        vMag1 = [vMag1; fM];
    end
    [bH2,fPval2,fKsstat2] = kstest2(roundn(mCat2(:,6),-1),roundn(vMag1,-1),0.05,0);

catch
    mProblikelihood = [NaN NaN NaN];
    fAICc = NaN;
    fMshift = NaN;
    fProbability = NaN;
    bH = NaN;
    bH2 = NaN;
end; % of try-catch
