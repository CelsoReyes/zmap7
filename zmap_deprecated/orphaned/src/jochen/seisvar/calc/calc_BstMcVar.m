function [vMc, vMls, fMc_org, fStd_Mc, fSkew, vPerc, fMedianMc, fMeanMc] = calc_BstMcVar(mCatalog,fBinning,nSample)
% [vMc, vMls, fMc_org, fStd_Mc, fSkew, vPerc, fMedian, fMeanMc] = calc_BstMcVar(mCatalog,fBinning,nSample)
%--------------------------------------------------------------------------
% Bootstrap EQ catalog and determine Mc percentiles by modelling entire FMD
% Acutually the same as calc_BstMc without calculation of standard
% deviation
%
% Vary sample size
%
% Incoming variables:
% mCatalog   : EQ catalog
% fBinning   : Magnitude binning interval
% nSample    : Quantatiy of bootstrap samples
%
% Outgoing variables:
% vMc      : Best Mc estimate according to MLS
% vMls     : Vector of maximum likelihood scores
% fMc_org  : Mc estimate from original data
% fStd_Mc  : Standard deviation (assuming normal distribution)
% fSkew    : Skewness of Mc distribution
% vPerc    : Percentiles at [5 10 90 95] percent levels
% fMedianMc  : Median (50 percentile) of vMc
% fMeanMc  : Mean of Mc
%
% J. Woessner: woessner@seismo.ifg.ethz.ch
% last update: 14.02.03

% Check input
if nargin == 0, error('No catalog input'); end
if nargin == 1, fBinning = 0.1, nSample = 500, disp('Default Bin size 0.1, Default 500 bootstrap samples');end
if nargin == 2, nSample = 500, disp('Default 500 bootstrap samples'); end
if nargin > 3, error('Too many arguments!'); end

% Initialize
vMls = [];
vMc = [];

% Get magnitudes
vMags = mCatalog(:,6);

% Create bootstrap samples using bootstrap matlab toolbox
mMag_bstsamp = bootrsp(vMags,nSample);

% First step: Estimate standard error of Mc original distribution
[mResult, fMls, fMc_org, fMu, fSigma, mDatPredBest, vPredBest] = calc_McCdfnormal(mCatalog, fBinning);
% Determine Mc uncertainty
for nSamp=1:nSample
    mCatalog(:,6) = mMag_bstsamp(:,nSamp);
    [mResult, fMls, fMc, fMu, fSigma, mDatPredBest, vPredBest] = calc_McCdfnormal(mCatalog, fBinning);
    vMls = [vMls; fMls];
    vMc =  [vMc; fMc];
end

% Check for Nan and create output
vSel = isnan(vMc);
vNoNanMc = vMc(~vSel,:);
if ~isempty(vNoNanMc)
    fStd_Mc = std(vNoNanMc);
    vPerc = prctile(vNoNanMc,[5 10 90 95]);
    fSkew = skewness(vNoNanMc);
    fMeanMc = mean(vNoNanMc);
    fMedianMc = median(vNoNanMc);
else
    fStd_Mc = NaN;
    vPerc = [NaN NaN NaN NaN];
    fSkew = NaN;
    fMeanMc = NaN;
    fMedianMc = NaN;
end
