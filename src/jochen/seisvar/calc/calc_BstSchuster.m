function [vPerc, v1Sigma, fStdProb] = calc_BstSchuster(mCatalog,fBinning,nSample)
% [vPerc, v1Sigma, fStdProb] = calc_BstSchuster(mCatalog,fBinning,nSample)
%--------------------------------------------------------------------------
% Bootstrap EQ catalog and determine percentiles and standard deviation
% from probabilty of exceeding R compared to random walkout Rp
%
% Incoming variables:
% mCatalog   : EQ catalog
% fBinning   : Magnitude binning interval
% nSample    : Number of bootstrap samples
%
% Outgoing variables:
% fStdProb : Standard deviation (assuming normal distribution)
% vPerc    : Percentiles at [5 10 90 95] percent levels
% v1Sigma  : [16 84] percentiles, according to standard deviation for normal distribution
%
% J. Woessner: woessner@seismo.ifg.ethz.ch
% last update: 24.03.03

% Check input
if nargin == 0, error('No catalog input'); end
if nargin == 1, fBinning = 0.1, nSample = 200, disp('Default Bin size 0.1, Default 200 bootstrap samples');end
if nargin == 2, nSample = 200, disp('Default 200 bootstrap samples'); end
if nargin > 3, error('Too many arguments!'); end


% Initialize
vProb = []; % Probability of exceeding R of random walkout

% Get hours and minutes
vMinute = mCatalog(:,9);
vHour = mCatalog(:,8);

% Create bootstrap samples using bootstrap matlab toolbox
mMinute_bstsamp = bootrsp(vMinute,nSample);
mHour_bstsamp = bootrsp(vHour,nSample);

% Determine uncertainty by bootstrap
for nSamp=1:nSample
    mCatalog(:,8) = mHour_bstsamp(:,nSamp);
    mCatalog(:,9) = mMinute_bstsamp(:,nSamp);
    [mWalkout, fR95, fProb, PHI, R] = calc_Schusterwalk(mCatalog);
    vProb = [vProb; fProb];
end

% Check for Nan and create output
vSel = isnan(vProb);
vNoNanProb = vProb(~vSel,:);

if (~isempty(vNoNanProb) & length(vNoNanProb) > 1)
    [fStdProb] = calc_StdDev(vNoNanProb);
    vPerc = prctile(vNoNanProb,[5 10 90 95]);
    v1Sigma = prctile(vNoNanProb,[16 84]);
elseif (~isempty(vNoNanProb)  &&  length(vNoNanProb) == 1)
    [fStdProb] = calc_StdDev(vNoNanProb);
    vPerc = prctile(vNoNanProb,[5 10 90 95]);
    v1Sigma = prctile(vNoNanProb,[16 84]);
    vPerc = vPerc';
    v1Sigma = v1Sigma';
else
    [fStdProb] = NaN;
    vPerc = [NaN NaN NaN NaN];
    v1Sigma = [NaN NaN];
end
