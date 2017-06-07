function [mResult] = calc_McBwtime(mCatalog, nSampleSize, nOverlap, nMethod, nBstSample, nMinNumberevents, fBinning,fMcCorr,ParMode)
% [mResult] = calc_McBwtime(mCatalog, nSampleSize, nOverlap, nMethod, nBstSample, nMinNumberevents, fBinning)
% ------------------------------------------------------------------------------------------------
% Calculate Mc and b-value with time using Mc mean from bootstrap to calculate b-values
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
% mResult(:,1) : Mean time of sample
% mResult(:,2) : fMc with time (mean Mc)
% mResult(:,3) : Standard deviation of mean Mc from the bootstrap
% mResult(:,4) : b-value (mean b)
% mResult(:,5) : Standard deviation of mean b-value from the bootstrap
% mResult(:,6) :a-value (mean b)
% mResult(:,7) : Standard deviation of meana-value from the bootstrap
%
% Author: J. Woessner
% last update: 22.09.03

% Check input
if nargin == 0, error('No catalog input'); end
if nargin == 1, nSampleSize=150, nOverlap=10, nMethod=1, nBstSample=100, nMinNumberevents=50; fBinning = 0.1; fMcCorr = 0;
    disp('Default Sample size: 150, Overlap: 10, Mc-Method=1, Bootstraps for Mc=100, Bin size: 0.1, Minimum number of events: 50, fMcCorr = 0');end;
if nargin == 2, nOverlap=10, nMethod=1, nBstSample=100, nMinNumberevents=50; fBinning = 0.1; fMcCorr = 0;
    disp('Default Overlap: 10, Mc-Method=1, Bootstraps for Mc=100, Bin size: 0.1, Minimum number of events: 50, fMcCorr = 0');end;
if nargin == 3, nMethod=1, nBstSample=100, nMinNumberevents=50; fBinning = 0.1; fMcCorr = 0;
    disp('Default Mc-Method=1, Bootstraps for Mc=100, Bin size: 0.1, Minimum number of events: 50, fMcCorr = 0');end;
if nargin == 4, nBstSample=100, nMinNumberevents=50; fBinning = 0.1; fMcCorr = 0;
    disp('Default Bootstraps for Mc=100, Bin size: 0.1, Minimum number of events: 50, fMcCorr = 0');end;
if nargin == 5, nMinNumberevents=50; fBinning = 0.1; fMcCorr = 0;
    disp('Default Bin size: 0.1, Minimum number of events: 50, fMcCorr = 0');end;
if nargin == 6, fBinning = 0.1; fMcCorr = 0;
    disp('Default Minimum number of events: 50, fMcCorr = 0');end;
if nargin == 7, fMcCorr = 0;disp('Default fMcCorr = 0');end;
if nargin > 9 disp('Too many arguments!'), return; end
if nargin < 9 ParMode=false; end


% Initialze
mResult = [];

% Set fix values
fMinMag = min(mCatalog(:,6));
fMaxMag = max(mCatalog(:,6));

if ~ParMode
    nCnt = 1;
    hWait = waitbar(0,'Please wait...');
    for nSamp = 1:nSampleSize/nOverlap:length(mCatalog(:,1))-nSampleSize
        fP = nCnt*(nSampleSize/nOverlap)/(length(mCatalog(:,1))-nSampleSize);
        % Select samples
        mCat = mCatalog(nSamp:nSamp+nSampleSize-1,:);
        % Mean time of selected events
        fTime = mean(mCat(:,3));
        [fMc, fStd_Mc, fBvalue, fStd_B, fAvalue, fStd_A, vMc, mBvalue] = calc_McBboot(mCat, fBinning, nBstSample, nMethod,nMinNumberevents,fMcCorr);
        mResult = [mResult; fTime fMc fStd_Mc fBvalue fStd_B fAvalue fStd_A];
        waitbar(nCnt*(nSampleSize/nOverlap)/(length(mCatalog(:,1))-nSampleSize))
        nCnt = nCnt + 1;
    end; % END of FOR fMag
    close(hWait)

elseif ParMode
    PosArray=1:nSampleSize/nOverlap:length(mCatalog(:,1))-nSampleSize;
    numElements=numel(PosArray);

    %parfor nSamp = 1:nSampleSize/nOverlap:length(mCatalog(:,1))-nSampleSize
    parfor i = 1:numElements
        %fP = nCnt*(nSampleSize/nOverlap)/(length(mCatalog(:,1))-nSampleSize);
        % Select samples
        nSamp=PosArray(i);
        mCat = mCatalog(nSamp:nSamp+nSampleSize-1,:);
        % Mean time of selected events
        fTime = mean(mCat(:,3));
        [fMc, fStd_Mc, fBvalue, fStd_B, fAvalue, fStd_A, vMc, mBvalue] = calc_McBboot(mCat, fBinning, nBstSample, nMethod,nMinNumberevents,fMcCorr);
        mResult(i,:) = [fTime fMc fStd_Mc fBvalue fStd_B fAvalue fStd_A];
        %waitbar(nCnt*(nSampleSize/nOverlap)/(length(mCatalog(:,1))-nSampleSize))
        %nCnt = nCnt + 1;
    end; % END of FOR fMag


end
end


