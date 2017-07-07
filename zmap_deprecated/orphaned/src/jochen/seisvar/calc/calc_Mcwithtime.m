function [mMcvalue] = calc_Mcwithtime(mCatalog, nSampleSize, nOverlap, nMethod, nBstSample, nMinNumberevents, fBinning)
% [mMcvalue] = calc_Mcwithtime(mCatalog, nSampleSize, nOverlap, nMethod, nBstSample, nMinNumberevents, fBinning)
% ------------------------------------------------------------------------------------------------
% Calculate Mc with time and corresponding uncertainties by boostrapping the catalog
%
% Incoming variables:
% mCatalog    : Earthquake catalog
% nSampleSize : Number of events to calculate single b-value
% nOverlap    : Overlap of moving windows
% nMethod     : Method to determine Mc
% nBstSample  : Number of bootstraps
% nMinNumberevents : Minimum number of events
% fBinning    : Binning interval
%
% Outgoing variables:
% mMcvalue(:,1) : Average date of used sample
% mMcvalue(:,2) : fMc_median with time (of bootstraps)
% mMcvalue(:,3) : fMc_mean with time (of bootstrap)
% mMcvalue(:,4) : fMc original catalog with time
% mMcvalue(:,5) : 16% percentile of Mc
% mMcvalue(:,6) : 84% percentile of Mc
% mMcvalue(:,7) : 2nd moment of empirical Mc-distribution
%
% Author: J. Woessner
% last update: 04.06.03

% Check input
if nargin == 0, error('No catalog input'); end
if nargin == 1, nSampleSize=150, nOverlap=10, nMethod=1, nBstSample = 100, nMinNumberevents=50; fBinning = 0.1;
    disp('Default Sample size: 150, Overlap: 10, Mc-Method=1, nBstSample = 100, Bin size: 0.1, Minimum number of events: 50');end;
if nargin == 2, nOverlap=10, nMethod=1, nBstSample = 100, nMinNumberevents=50; fBinning = 0.1;
    disp('Default Overlap: 10, Mc-Method=1, nBstSample = 100, Bin size: 0.1, Minimum number of events: 50');end;
if nargin == 3, nMethod=1, nBstSample = 100, nMinNumberevents=50; fBinning = 0.1;
    disp('Default Mc-Method=1, nBstSample = 100, Bin size: 0.1, Minimum number of events: 50');end;
if nargin == 4, nBstSample = 100, nMinNumberevents=50; fBinning = 0.1;
    disp('Default nBstSample = 100, Bin size: 0.1, Minimum number of events: 50');end;
if nargin == 5, nMinNumberevents=50; fBinning = 0.1; disp('Default Minimum number of events: 50, Bin size: 0.1');end;
if nargin == 6, fBinning = 0.1; disp('Default Bin size: 0.1');end;
if nargin > 7
    error('Too many arguments!');
end


% Initialze
mMcvalue = [];

% Set fix values
fMinMag = min(mCatalog(:,6));
fMaxMag = max(mCatalog(:,6));

for nSamp = 1:nSampleSize/nOverlap:length(mCatalog(:,1))-nSampleSize
    % Select samples
    mCat = mCatalog(nSamp:nSamp+nSampleSize,:);
    % Mean time of selected events
    fTime = mean(mCat(:,3));

    % Check for minimum number of events
    if length(mCat(:,1)) >= nMinNumberevents
        try
            [fMedianMc, fMeanMc, fMc_org, v1Sigma, fStd_Mc, vMc] = calc_BstMethod(mCat, fBinning, nBstSample, nMethod);
            mMcvalue = [mMcvalue; fTime fMedianMc fMeanMc fMc_org v1Sigma fStd_Mc];
        catch
            mMcvalue = [mMcvalue; fTime NaN NaN NaN NaN NaN NaN];
        end
    else
        mMcvalue = [mMcvalue; fTime NaN NaN NaN NaN NaN NaN ];
    end; % END of IF
end; % END of FOR fMag
