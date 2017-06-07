function [mBvalue] = calc_bwithmag(mCatalog, fBinning, nMinNumberevents)
% function [mBvalue] = calc_bwithmag(mCatalog, fBinning, nMinNumberevents)
% ------------------------------------------------------------------------
% Calculate b-value depending on cut-off magnitude
%
% Incoming variables:
% mCatalog : Earthquake catalog
% fBinnig  : Binning interval
% nMinNumberevents : Minimum number of events
%
% Outgoing variables:
% mBvalue(:,1) : b-values ascending with magnitude
% mBvalue(:,2) : Standard deviation of b (Shi & Bolt, 1982) ascending with magnitude
% mBvalue(:,3) : a-values ascending with magnitude
% mBvalue(:,4) : Ascending magnitudes
% mBvalue(:,5) : Number of events above magnitude cut-off
%
% Author: J. Woessner

% Check input
if nargin == 0, error('No catalog input'); end
if nargin == 1, fBinning = 0.1; nMinNumberEvents = 50; disp('Default Bin size: 0.1, Minimum number of events: 50');end
if nargin == 2, nMinNumberEvents = 50; disp('Default Minimum number of events: 50');end
if nargin > 3, error('Too many arguments!'); end


% Initialze
mBvalue = [];

% Set fix values
fMinMag = min(mCatalog(:,6));
fMaxMag = max(mCatalog(:,6));

for fMag=fMinMag:fBinning:fMaxMag
    % Select magnitude range
    vSel = mCatalog(:,6) >= fMag-0.05;
    mCat = mCatalog(vSel,:);
    % Determine size of background catalog
    [nRow, nCol] = size(mCat);
    % Check for minimum number of events
    if length(mCat(:,1)) >= nMinNumberevents
        try
            [fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemag(mCat, fBinning);
            mBvalue = [mBvalue; fBValue fStdDev fAValue fMag nRow];
        catch
            mBvalue = [mBvalue; NaN NaN NaN fMag nRow];
        end
    else
        mBvalue = [mBvalue; NaN NaN NaN fMag nRow];
    end % END of IF
end % END of FOR fMag
