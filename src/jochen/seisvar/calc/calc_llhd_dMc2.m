function [fdMc, fProbability, fAICc] = calc_llhd_dMc2(mCat1, mCat2)
% function [fdMc, fProbability, fAICc] = calc_llhd_dMc2(mCat1, mCat2);
% ----------------------------------------------------------------------------------------------
% Calculate log-likelihood estimation of a magnitude of completness change between the two periods
%
% Incoming variable
% mCat1 : EQ catalog period 1 (Catalog to be modified)
% mCat2 : EQ catalog period 2 (Observed catalog)
%
% Outgoing variable
% fdMc         : Change in the magnitude of completeness
% fProbability : log-likelihood probabilty
% fAICc         : Corrected Akaike Information Criterion
%
% Author: J. Woessner, woessner@seismo.ifg,.ethz.ch
% last update: 21.10.03

fBinning = 0.1;
nSample = 100;
nMethod = 6;

% Determine exact time period
fPeriod1 = max(mCat1(:,3)) - min(mCat1(:,3));
fPeriod2 = max(mCat2(:,3)) - min(mCat2(:,3));


% Initialize values
fMinMag = min([min(mCat1(:,6)) min(mCat2(:,6))]);
fMaxMag = max([max(mCat1(:,6)) max(mCat2(:,6))]);

try
%% Calculate model for best fitting Mc, both periods
[mResult1, fMls1, fMc1, fMu1, fSigma1, mDataPredBest1, vPredBest1, fBValue1, fAvalue1] = calc_McCdfnormal(mCat1, fBinning);
[mResult, fMls, fMc2, fMu, fSigma, mDataPredBest, vPredBest, fBValue2, fAvalue2] = calc_McCdfnormal(mCat2, fBinning);

% [fMc1, fStd_Mc1, fBvalue1, fStd_B1, fAvalue1, fStd_A1, vMc1, mBvalue1] = calc_McBboot(mCat1, fBinning, nSample, nMethod)
% [fMc2, fStd_Mc2, fBvalue2, fStd_B2, fAvalue2, fStd_A2, vMc2, mBvalue2] = calc_McBboot(mCat2, fBinning, nSample, nMethod)

% Mc difference
fdMc = fMc2-fMc1;

% Select part of catalog
vSel = mCat1(:,6) >= fMc2-fBinning/2;
mCat1tmp=mCat1(vSel,:);

% Create Model distribution
vMagnitudes = [fMc2:0.1:floor(max(mCat2(:,6)))+0.1];
% Productuvity for fMc2
nNumberEvents = length(mCat1tmp(:,1));
vNumbers = 10.^(log10(nNumberEvents) - fBValue1*(vMagnitudes-fMc2));
%vNumbers = 10.^(fAvalue1- fBValue1*(vMagnitudes-fMc2));
vNumbers = round(vNumbers);
vNCumFMD = round(-diff(vNumbers));
% Calculate synthetic data below Mc
fMinMag = min(mCat2(:,6));
vMagstep = fMinMag:0.1:fMc2-0.1;
vProb = normcdf(vMagstep,fMu1, fSigma1);
vProb = vProb';
vMagstep = vMagstep';

% Calculate number of EQs in bins
fN_Mc = vNCumFMD(1,1);
vN = round(vProb(:,1)*fN_Mc);
%mNonCumModel = [vN vMagstep; vNCumFMD' vBin'];
mNonCumModel = [vN vMagstep; vNCumFMD' vMagnitudes(:,1:end-1)'];

% vMags = mDataPredBest(:,2)';
% FMD to be modeled (second period)
[vObsFMD,vBin2] = hist(mCat2(:,6),roundn(min(mCat2(:,6)),-1):0.1:floor(max(mCat2(:,6))));

% Select bins to calculate loglikelihood
vSel = (mNonCumModel(:,2) < min(vBin2) | mNonCumModel(:,2) > max(vBin2));
vPredFMD = mNonCumModel(~vSel,:);
% Normalize
vObsFMD = ceil(vObsFMD./fPeriod2);
vPredFMD(:,1) = vPredFMD(:,1)./fPeriod1;

if length(vObsFMD') ~= length(vPredFMD(:,1))
    disp('warning')
end
% Calculate the likelihood
vProb_ = calc_log10poisspdf2(vObsFMD', vPredFMD(:,1));
% Sum the probabilities
fProbability = (-1) * sum(vProb_);

nDegFree = 1; % degree of freedom
n_samples = length(mCat2(:,6));
%% Corrected Akaike Information Criterion (AICc)
fAICc = -2*(-fProbability)+2*nDegFree+2*nDegFree*(nDegFree+1)/(n_samples-nDegFree-1);

catch
    fdMc = nan;
    fProbability = nan;
    fAICc = nan;
end
% figure_w_normalized_uicontrolunits(30)
% %plot(mNonCumModel(:,2),mNonCumModel(:,1),'r*',vBin2,vObsFMD,'o')
% histogram(mCat1(:,6),fMinMag:0.1:fMaxMag);
% hold on
% histogram(mCat2(:,6),fMinMag:0.1:fMaxMag)
% h = findobj(gca,'Type','patch');
% set(h,'FaceColor','r','EdgeColor','w')
% plot(vPredFMD(:,2),vPredFMD(:,1),'g*',vBin2,vObsFMD,'o')
