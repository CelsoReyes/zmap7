function [fMedianMc, fMeanMc, fMc_org, v1Sigma, fStd_Mc, vMc] = calc_BstMethod(mCatalog, fBinning, nSample, nMethod)
% function [fMedianMc, fMeanMc, fMc_org, v1Sigma, fStd_Mc, vMc] = calc_BstMethod(mCatalog, fBinning, nSample, nMethod)
%---------------------------------------------------------------------------------------------------------
% Bootstrap EQ catalog and determine Mc choosing a specific method
%
% Incoming variables:
% mCatalog   : EQ catalog
% fBinning   : Magnitude binning interval
% nSample    : Number of bootstrap samples
% nMethod    : Method to determine the magnitude of completeness
%               1: Maximum curvature
%               2: Fixed Mc = minimum magnitude (Mmin)
%               3: Mc90 (90% probability)
%               4: Mc95 (95% probability)
%               5: Best combination (Mc95 - Mc90 - maximum curvature)
%               6: Mc using EMR-method
%               7: Mc due b using Shi & Bolt uncertainty
%               8: Mc due b using bootstrap uncertainty
%               9: Mc due b Cao-criterion
%
% Outgoing variables:
% fMedianMc  : Median (50 percentile) of vMc using nSample bootstraps
% fMeanMc    : Mean of Mc using nSample bootstraps
% fMc_org    : Mc estimate from original dataset
% v1Sigma    : [16 84] percentiles, according to standard deviation for normal distribution
% fStd_Mc    : Second moment of empirical Mc distribution (assuming normal distribution)
% vMc        : Mc estimates from bootstrap samples (empirical distribution)
%
% J. Woessner: woessner@seismo.ifg.ethz.ch
% last update: 28.05.03

% Check input
if nargin == 0, error('No catalog input'); end
if nargin == 1, fBinning = 0.1, nSample = 500, disp('Default Bin size 0.1, Default 500 bootstrap samples');end
if nargin == 2, nSample = 500, disp('Default 500 bootstrap samples'); end
if nargin == 3, nMethod = 5, disp('Default method: Best combination of Max. curvature and goodness fit'); end
if nargin > 4, error('Too many arguments!'); end

% Initialize
vMc = [];

% Get magnitudes
vMags = mCatalog(:,6);

% Create bootstrap samples using bootstrap matlab toolbox
mMag_bstsamp = bootrsp(vMags,nSample);
% Calculate Mc of original catalog
fMc_org = calc_Mc(mCatalog, nMethod);
% Determine Mc uncertainty
for nSamp=1:nSample
    mCatalog(:,6) = mMag_bstsamp(:,nSamp);
    fMc = calc_Mc(mCatalog, nMethod);
    vMc =  [vMc; fMc];
end

% Check for Nan and create output
vSel = isnan(vMc);
vNoNanMc = vMc(~vSel,:);
if ~isempty(vNoNanMc)
    fStd_Mc = calc_StdDev(vNoNanMc);
    fMeanMc = mean(vNoNanMc);
    fMedianMc = median(vNoNanMc);
else
    fStd_Mc = NaN;
    fMeanMc = NaN;
    fMedianMc = NaN;
end

if (~isempty(vNoNanMc) & length(vNoNanMc) > 1)
    v1Sigma = prctile(vNoNanMc,[16 84]);
elseif (~isempty(vNoNanMc)  &&  length(vNoNanMc) == 1)
    v1Sigma = prctile(vNoNanMc,[16 84]);
    v1Sigma = v1Sigma';
else
    v1Sigma = [NaN NaN];
end
