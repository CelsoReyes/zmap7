function [vMc, fMc_org, fStd_Mc, fMeanMc, fMedianMc] = calc_BstMcMaxCurvVar(mCatalog,fBinning, nSample)
% function [vMc, fMc_org, fStd_Mc, fMeanMc, fMedianMc] = calc_BstMcMaxCurvVar(mCatalog,fBinning, nSample)
%--------------------------------------------------------------------------------------------------------
% Bootstrap EQ catalog and determine Mc using maximum curvature
%
% Incoming variables:
% mCatalog   : EQ catalog
% fBinning   : Magnitude binning interval
% nSample    : Number of bootstrap samples
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
% First step:
fMc_org = calc_Mc(mCatalog, 1);
% Determine Mc uncertainty
for nSamp=1:nSample
    mCatalog(:,6) = mMag_bstsamp(:,nSamp);
    fMc = calc_Mc(mCatalog, 1);
    vMc =  [vMc; fMc];
end

% Check for Nan and create output
vSel = isnan(vMc);
vNoNanMc = vMc(~vSel,:);
if ~isempty(vNoNanMc)
    fStd_Mc = std(vNoNanMc);
    fMeanMc = mean(vNoNanMc);
    fMedianMc = median(vNoNanMc);
else
    fStd_Mc = nan;
    fMeanMc = nan;
    fMedianMc = nan;
end
