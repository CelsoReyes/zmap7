function [fMshift, fMshiftFit, fAICc] = calc_Magshift(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, nCalculateMC)
% function [fMshift] = calc_Magshift(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, nCalculateMC);
% -------------------------------------------------------------------------------------------------
% Function to calculate simple magnitude shift between two time periods using the
% procedure proposed by Zuniga & Wyss, BSSA, Vol.85, No.6, 1858-1866, 1995
% Mnew = Mold + fMshift
%
% Incoming variables:
% mCatalog     : current earthquake catalog
% bTimePeriod   : Use catalog from beginning to end (0), use time periods (1)
% fSplitTime   : Splittime of catalog
% fTimePeriod  : Time periods
% nCalculateMC : Method to determine Mc (1-5 see help calc_Mc)
%
% Outgoing variable:
% fMshift : magnitude shift
% fMshiftFit : Goodness of fit in percent to modeling second period with simple magnitude shift of
%              first period

% J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 21.08.02

% Track of changes:
% 10.07.02: Original version
% 21.08.02: Solved stability  problem (Error: vFMD(1,1) index exceeds matrix dimension) by adding
%           ~isempty(vFMD) & ~isempty(vFMDSecond) into if statement

fMinMag = min(mCatalog(:,6));
fMaxMag = max(mCatalog(:,6));

[mFirstCatalog, mSecondCatalog, fFirstPeriodExact, fSecondPeriodExact, fFirstPeriod,...
       result.fSecondPeriod] = ex_SplitCatalog(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, bTimePeriod, fTimePeriod);
% Create the frequency magnitude distribution vectors for the two time periods
[vFMD, vNonCFMD] = calc_FMD(mFirstCatalog);
[vFMDSecond, vNonCFMDSecond] = calc_FMD(mSecondCatalog);

% Calculate magnitude of completeness
fMc = calc_Mc(mFirstCatalog, nCalculateMC);
fMcSecond = calc_Mc(mSecondCatalog, nCalculateMC);

if (~isempty(fMc) & ~isempty(fMcSecond) & ~isempty(vFMD) & ~isempty(vFMDSecond))
    % First period
    [nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(mFirstCatalog, vFMD, fMc);
    % Calculate the b-value etc. for M > Mc
    [fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemagMag(mFirstCatalog(vSel,:));
    vPoly = [-1*fBValue fAValue];
    fBFunc = 10.^(polyval(vPoly, vMagnitudes));
    %% Second period
    [nIndexLoSecond, fMagHiSecond, vSelSecond, vMagnitudesSecond] = fMagToFitBValue(mSecondCatalog, vFMDSecond, fMcSecond);
    % Calculate the b-value etc. for M > Mc
    [fMeanMagSecond, fBValueSecond, fStdDevSecond, fAValueSecond] = calc_bmemagMag(mSecondCatalog(vSelSecond,:));
    vPolySecond = [-1*fBValueSecond fAValueSecond];
    fBFuncSecond = 10.^(polyval(vPolySecond, vMagnitudesSecond));
    % Determine magnitude shift
    fMintercept = 1/fBValueSecond*(fAValueSecond-log10(vFMD(2,nIndexLo)));
    fMshift = fMintercept - vFMD(1,nIndexLo);
else
    disp('fMc, fMcSecond or vFMD / vFMDSecond not derivable');
    fMshift=NaN;
end

%%% Goodness of fit determination
mCatModel = mFirstCatalog;
mCatModel(:,6) = mCatModel(:,6)+fMshift;

[vEv_val2 vMags2 vEventsum2 vEvsum_rev2,  vMags_rev2] =calc_cumulsum(mSecondCatalog);
[vEv_valMod vMagsMod vEventsumMod vEvsum_revMod,  vMags_revMod] =calc_cumulsum(mCatModel);

fMshiftFit  = sum(abs(vEventsum2-vEventsumMod))/sum(vEventsum2);
fMshiftFit = 100-fMshiftFit*100;

% % Select bins to calculate loglikelihood
% vSel = (mNonCumModel(:,2) < min(vBin2) | mNonCumModel(:,2) > max(vBin2));
% vPredFMD = mNonCumModel(~vSel,:);
% vPredFMD(:,1) = ceil(vPredFMD(:,1)./fPeriod1);
[vModFMD,vBin1] = hist(mCatModel(:,6),fMinMag:0.1:fMaxMag);
[vObsFMD,vBin2] = hist(mSecondCatalog(:,6),fMinMag:0.1:fMaxMag);
vObsFMD = ceil(vObsFMD./fTimePeriod);
vPredFMD = ceil(vModFMD./fTimePeriod);
% vEv_val2 = ceil(vEv_val2./fTimePeriod);
% vEv_valMod = ceil(vEv_valMod./fTimePeriod);
% Calculate the likelihood
vProb_ = calc_log10poisspdf2(vObsFMD,vPredFMD);
% Sum the probabilities
fProbability = (-1) * sum(vProb_);

nDegFree = 1; % degree of freedom
n_samples = length(mCatalog(:,6));
%% Corrected Akaike Information Criterion (AICc)
fAICc = -2*(-fProbability)+2*nDegFree+2*nDegFree*(nDegFree+1)/(n_samples-nDegFree-1);
