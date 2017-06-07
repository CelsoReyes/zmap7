function [mBvalue, mMcvalue] = calc_bwithtime(mCatalog, nSampleSize, nOverlap, nMethod, nBstSample, nMinNumberevents, fBinning)
% [mBvalue, mMcvalue] = calc_bwithtime(mCatalog, nSampleSize, nOverlap, nMethod, nBstSample, nMinNumberevents, fBinning)
% ------------------------------------------------------------------------------------------------
% Calculate b-value with time
% Calculate Mc by boostrapping and use mean Mc
%
% Incoming variables:
% mCatalog    : Earthquake catalog
% nSampleSize : Number of events to calculate single b-value
% nOverlap    : Samplesize/nOverlap determines overlap of moving windows
% nMethod     : Method to determine Mc
% nBstSample  : Number of bootstraps to determine Mc
% nMinNumberevents : Minimum number of events
% fBinning    : Binning interval
%
% Outgoing variables:
% mBvalue(:,1) : b-values with time
% mBvalue(:,2) : Standard deviation of b (Shi & Bolt, 1982) with time
% mBvalue(:,3) : a-values with time
% mBvalue(:,4) : fMc with time (mean Mc)
% mBvalue(:,5) : Average date of used sample
% mBvalue(:,6) : b-value for mean(Mc) + 2nd moment of Mc
% mBvalue(:,7) : Standard deviation of b (Shi & Bolt, 1982) for mean(Mc)+
%                2nd moment of Mc
% mBvalue(:,8) :a-value for mean(Mc) + 2nd moment of Mc
% mBvalue(:,9) : b-value for mean(Mc) - 2nd moment of Mc
% mBvalue(:,10) : Standard deviation of b (Shi & Bolt, 1982) for mean(Mc) - 2nd moment of Mc
% mBvalue(:,11) :a-value for mean(Mc) - 2nd moment of Mc
%
% mMcvalue(:,1) : Average date of used sample
% mMcvalue(:,2) : fMc_median with time (of bootstraps)
% mMcvalue(:,3) : fMc_mean with time (of bootstrap)
% mMcvalue(:,4) : fMc original catalog with time
% mMcvalue(:,5) : 16% percentile of Mc
% mMcvalue(:,6) : 84% percentile of Mc
% mMcvalue(:,7) : 2nd moment of empirical Mc-distribution
% Author: J. Woessner
% last update: 04.06.03

% Check input
if nargin == 0, error('No catalog input'); end
if nargin == 1, nSampleSize=150, nOverlap=10, nMethod=1, nBstSample=100, nMinNumberevents=50; fBinning = 0.1;
    disp('Default Sample size: 150, Overlap: 10, Mc-Method=1, Bootstraps for Mc=100, Bin size: 0.1, Minimum number of events: 50');end
if nargin == 2, nOverlap=10, nMethod=1, nBstSample=100, nMinNumberevents=50; fBinning = 0.1;
    disp('Default Overlap: 10, Mc-Method=1, Bootstraps for Mc=100, Bin size: 0.1, Minimum number of events: 50');end
if nargin == 3, nMethod=1, nBstSample=100, nMinNumberevents=50; fBinning = 0.1;
    disp('Default Mc-Method=1, Bootstraps for Mc=100, Bin size: 0.1, Minimum number of events: 50');end
if nargin == 4, nBstSample=100, nMinNumberevents=50; fBinning = 0.1;
    disp('Default Bootstraps for Mc=100, Bin size: 0.1, Minimum number of events: 50');end
if nargin == 5, nMinNumberevents=50; fBinning = 0.1;
    disp('Default Bin size: 0.1, Minimum number of events: 50');end
if nargin == 6, fBinning = 0.1; disp('Default Minimum number of events: 50');end
if nargin > 7, error('Too many arguments!'); end


% Initialze
mBvalue = [];
mBvalue_std1 = [];
mBvalue_std2 = [];
mMcvalue = [];

% Set fix values
fMinMag = min(mCatalog(:,6));
fMaxMag = max(mCatalog(:,6));

for nSamp = 1:nSampleSize/nOverlap:length(mCatalog(:,1))-nSampleSize
    % Select samples
    mCat = mCatalog(nSamp:nSamp+nSampleSize,:);
    % Mean time of selected events
    fTime = mean(mCat(:,3));

    % Determine Mc
    % [fMc] = calc_Mc(mCat, nMethod);
    [fMedianMc, fMeanMc, fMc_org, v1Sigma, fStd_Mc, vMc] = calc_BstMc(mCat, fBinning, nBstSample, nMethod);
    mMcvalue = [mMcvalue; fMedianMc fMeanMc fMc_org v1Sigma fStd_Mc];

    % Select magnitude range and calculate b-value for mean Mc
    vSel = mCatalog(:,6) >= fMeanMc-fBinning/2;
    mCat = mCatalog(vSel,:);
    % Check for minimum number of events
    if length(mCat(:,1)) >= nMinNumberevents
        try
            [fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemag(mCat, fBinning);
            mBvalue = [mBvalue; fBValue fStdDev fAValue fMeanMc fTime];
        catch
            mBvalue = [mBvalue; NaN NaN NaN fMeanMc fTime];
        end
    else
        mBvalue = [mBvalue; NaN NaN NaN fMeanMc fTime];
    end % END of IF

    % Select magnitude range and calculate b-value for mean Mc + fStd_Mc
    vSel = mCatalog(:,6) >= fMeanMc+fStd_Mc-fBinning/2;
    mCat = mCatalog(vSel,:);
    % Check for minimum number of events
    if length(mCat(:,1)) >= nMinNumberevents
        try
            [fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemag(mCat, fBinning);
            mBvalue_std1 = [mBvalue_std1; fBValue fStdDev fAValue];
        catch
            mBvalue_std1 = [mBvalue_std1; NaN NaN NaN];
        end
    else
        mBvalue_std1 = [mBvalue_std1; NaN NaN NaN];
    end % END of IF

    % Select magnitude range and calculate b-value for mean Mc - fStd_Mc
    vSel = mCatalog(:,6) >= fMeanMc-fStd_Mc-fBinning/2;
    mCat = mCatalog(vSel,:);
    % Check for minimum number of events
    if length(mCat(:,1)) >= nMinNumberevents
        try
            [fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemag(mCat, fBinning);
            mBvalue_std2 = [mBvalue_std2; fBValue fStdDev fAValue];
        catch
            mBvalue_std2 = [mBvalue_std2; NaN NaN NaN];
        end
    else
        mBvalue_std2 = [mBvalue_std2; NaN NaN NaN];
    end % END of IF
end % END of FOR fMag

% Result
mBvalue = [mBvalue mBvalue_std1 mBvalue_std2];
