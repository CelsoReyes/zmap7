function [vMc, mStd_McBoot, fStd_Mc, blo, bhi] = calc_BstMcPercInt(mCatalog,fBinning, alpha)
% [vProbMin, vMcBest, mMag_bstsamp, fStd_Mc, fConfLow, fConfUp] = calc_BstMcPerInt(mCatalog, fBinning)
%---------------------------------------------------------------------------
% Bootstrap EQ catalog and determine Mc confidence due to modelling with
% MLS fitting entire FMD distribution
%
% Incoming variables:
% mCatalog   : EQ catalog
% fBinning   : Magnitude binning interval
%
% Outgoing variables:
% vProbMin     : Vector of maximum likelihood scores
% vMcBest      : Best Mc estimate according to MLS
% mMag_bstsamp : Matrix of bootstrap samples of magnitudes
% fStd_Mc      : Standard deviation (assuming normal distribution
%
% J. Woessner: woessner@seismo.ifg.ethz.ch
% last update: 31.01.03

% Initialize
vMls = [];
vMc = [];
vStd_Mcboot = [];
vMls_boot = [];
vMc_boot = [];
mStd_McBoot = [];

nB = 100; % Bootstrap replicates to calculate confidence intervals

% Get magnitudes
vMags = mCatalog(:,6);

% Create bootstrap samples using bootstrap matlab toolbox
nSample = 50;
mMag_bstsamp = bootrsp(vMags,nSample);
!date
% First step: Estimate standard error of Mc original distribution
% Determine Mc uncertainty
for nSamp=1:nSample
    mCatalog(:,6) = mMag_bstsamp(:,nSamp);
    [mResult, fMls, fMc, fMu, fSigma, mDatPredBest, vPredBest] = calc_McCdfnormal(mCatalog, fBinning);
    vMls = [vMls; fMls];
    vMc =  [vMc; fMc];
end
fStd_Mc = std(vMc);
!date
% Second step: Estimate standard error for each Mc of a bootstrap sample
for i = 1:nB
    i
    mCatalog(:,6) = mMag_bstsamp(:,i);
    mMag_bst = bootrsp(mCatalog(:,6),nSample);
    % Bootstrap using the sample for estimating Mc
    for n= 1:nSample
        mCatalog(:,6) = mMag_bstsamp(:,nSample);
        [mResult, fMls, fMc, fMu, fSigma, mDatPredBest, vPredBest] = calc_McCdfnormal(mCatalog, fBinning);
        vMls_boot = [vMls_boot; fMls];
        vMc_boot =  [vMc_boot; fMc];
    end
    fStd_Mcboot = std(vMc_boot);
    vStd_Mcboot = [vStd_Mcboot; fStd_Mcboot];
    mStd_McBoot = [mStd_McBoot; vStd_Mcboot];
end

% Percentile interval
fExp = nB*alpha/2;
sbval = sort(mStd_Mcboot);
blo = sbval(k);
bhi = sbval(nB-k);
