function [mBvalue] = calc_bwithmag(mCatalog, fBinning, nMinNumberEvents)
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
    % Author: J. Woessner modified by C Reyes
    
    % Check input
    narginchk(1,3)
    
    if nargin == 1
        fBinning = 0.1;
        nMinNumberEvents = 50;
        disp('Default Bin size: 0.1, Minimum number of events: 50');
    elseif nargin == 2
        nMinNumberEvents = 50;
        disp('Default Minimum number of events: 50');
    end
    
    
    % Set fix values
    fMinMag = min(mCatalog.Magnitude);
    fMaxMag = max(mCatalog.Magnitude);
    
    binCenters = fMinMag:fBinning:fMaxMag;
    
    mBvalue=nan(numel(binCenters),5);
    mBvalue(:,4)=binCenters(:);
    
    
    for x=1:numel(binCenters)
        fMag = binCenters(x);
        
        % Select magnitude range
        vSel = mCatalog.Magnitude >= fMag-0.05;
        mCat = mCatalog.subset(vSel);
        
        % Determine size of background catalog
        mBvalue(x,5)=mCat.Count;
        
        % Check for minimum number of events
        if mCat.Count >= nMinNumberEvents
            [ fBValue, fStdDev, fAValue] =  calc_bmemag(mCat, fBinning);
            mBvalue(x,1:3) = [fBValue fStdDev fAValue];
        end
    end
end