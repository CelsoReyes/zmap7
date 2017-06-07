function [mMcBdepth] = calc_McBwdepth(mCatalog, fBinning, nEvents, nOverlap, nBootSample,nMinNumberevents )
% function [mMcBdepth] = calc_McBwdepth(mCatalog, fBinning, nEvents, nOverlap, nBootSample,nMinNumberevents)
% ------------------------------------------------------------------------
% Calculate Mc and b_value with depth; Mc is EMR-medianMc determined by bootstrapping
%
% Incoming variables:
% mCatalog : Earthquake catalog
% fBinnig  : Binning interval
% nEvents  : Number of events per window
% nOverlap : Number of events that overlap in windows
% nBootSample : Number of bootstrap samples
% nMinNumberevents : Minimum number of events
%
% Outgoing variables:
% mMcBdepth(:,1) : Depth
% mMcBdepth(:,2) : EMR Median Mc
% mMcBdepth(:,3) : 16-percentile
% mMcBdepth(:,4) : 84-percentile
% mMcBdepth(:,5) : b-value
% mMcBdepth(:,6) : Standard deviation of b (Shi & Bolt, 1982)
% mMcBdepth(:,7) :a-value
%
% Author: J. Woessner
% last update: 04.04.03

% Initialze
mMcBdepth = [];

% Set fix values
fMinMag = min(mCatalog(:,6));
fMaxMag = max(mCatalog(:,6));
fMinDepth = min(mCatalog(:,7));
fMaxDepth = max(mCatalog(:,7));

% Sorting by depth
[vSortDepth,vIndiceSort] = sort(mCatalog(:,7));
mCatDep = mCatalog(vIndiceSort(:,1),:);
for nStep = 1:nEvents/nOverlap:length(mCatDep(:,6))-nEvents
    mCat = mCatDep(nStep:nStep+nEvents,:);
    % Determine Mc by bootstrapping
    [vMc, vMls, fMc_org, fStdMc_org, fSkew, vPerc, fMedianMc, fMeanMc, fStdMc, v1Sigma] = calc_BstMc(mCat,fBinning,nBootSample);
    % Mean depth
    fMeanDepth = (mCatDep(nStep,7)+mCatDep(round(nStep+nEvents),7))/2;
    % B-value determination
    % Select magnitude range to calculate b-value for EMR median Mc
    vSel = mCatDep(:,6) >= fMedianMc-0.05;
    mCat2 = mCatDep(vSel,:);
    % Check for minimum number of events
    if length(mCat(:,1)) > nMinNumberevents
        try
            [fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemag(mCat2, fBinning);
            vBvalue = [fBValue fStdDev fAValue];
        catch
            vBvalue = [NaN NaN NaN];
        end
    else
        vBvalue = [NaN NaN NaN];
    end; % END of IF
    % Result matrix
    mMcBdepth = [mMcBdepth; fMeanDepth fMedianMc v1Sigma vBvalue];
end; % End of FOR nStep
