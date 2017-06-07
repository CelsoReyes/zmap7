function [fFac, fProbability, fAICc, mProblikelihood, bH] = calc_loglikelihood_rate2(mCat1, mCat2)
% function [fFac, fProbability, fAICc, mProblikelihood] = calc_loglikelihood_rate2(mCat1, mCat2);
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
% fAICc         : Corrected Akaike Information Criterion
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
fMinMag = floor(min([min(mCat1(:,6)) min(mCat2(:,6))]));
fMaxMag = ceil(max([max(mCat1(:,6)) max(mCat2(:,6))]));

% Magnitude distribution first catalog and normalize
% Time normalization and round due to Poisson distribution calculation in calc_log10poisspdf
%[fProbMin, fMc,vX, fNmax, mDataPred] = calc_McCdf2(mCat1, 0.1);
[mResult, fMls, fMc, fMu, fSigma, mDataPred, vPredBest, fBvalue, fAvalue] = calc_McCdfnormal(mCat1, 0.1);
if ~isempty(mDataPred)
    vPredOrgFMD = mDataPred(:,1)'./fPeriod1;
    vMags = mDataPred(:,2)';
    % Magnitude distribution second catalog and normalize
    % Time normalization and round due to Poisson distribution calculation in calc_log10poisspdf
    [vObsFMD,vBin2] = hist(mCat2(:,6),min(vMags):0.1:max(vMags));
    vObsFMD = ceil(vObsFMD./fPeriod2);
    if length(vObsFMD') ~= length(vPredOrgFMD)
        disp('warning')
    end
    % % Cut above Mc
    % vSelMc = (vMags >= fMc);
    % vPredOrgFMD = vPredOrgFMD(:,vSelMc);
    % vObsFMD = vObsFMD(:,vSelMc);
    for fFac = 0.5:0.1:3
        % Apply rate factor
        vPredFMD = vPredOrgFMD*fFac;
        %     figure_w_normalized_uicontrolunits(30)
        %     plot(vBin2, vObsFMD,'bo')
        %     hold on
        %     plot(vMags, vPredOrgFMD,'go')
        %     plot(vMags,vPredFMD,'r*')
        %     hold off
        %     pause
        % Calculate the likelihoods for both models
        vProb_ = calc_log10poisspdf2(vObsFMD', vPredFMD');
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
    nDegFree = 1; % Magnitude shift is the degree of freedom
    n_samples = length(mCat2(:,6))+length(mCat1(:,6));
    %% Corrected Akaike Information Criterion (AICc)
    fAICc = -2*(-fProbability)+2*nDegFree+2*nDegFree*(nDegFree+1)/(n_samples-nDegFree-1);

    % Perform KStest
    vMag1 =[];
    mDataPred(:,1) = ceil(mDataPred(:,1).*fFac./fPeriod1);
    vSel = (mDataPred(:,2) ~= 0); % Remove bins with zero frequency of zero events
    mData2 = mDataPred(vSel,:);
    for nCnt=1:length(mData2(:,1))
        fM = repmat(mData2(nCnt,2),mData2(nCnt,1),1);
        vMag1 = [vMag1; fM];
    end
    [bH,fPval,fKsstat] = kstest2(roundn(mCat2(:,6),-1),roundn(vMag1,-1),0.05,0);
else
    fFac = nan;
    fProbability = nan;
    fAICc = nan;
    mProblikelihood = [];
    bH = nan;
end
