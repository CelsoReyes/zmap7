function [mBvalue] = calc_bwithmag(magnitudes, binInterval, nMinNumberEvents)
    % Calculate b-value depending on cut-off magnitude
    % [mBvalue] = calc_bwithmag(mCatalog, binInterval, nMinNumberevents)
    %
    % Incoming variables:
    % magnitudes        : Earthquake catalog magnitudes
    % binInterval           : Binning interval
    % nMinNumberevents  : Minimum number of events
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
    
    % Set fix values
    fMinMag = min(magnitudes);
    fMaxMag = max(magnitudes);
    
    binCenters = fMinMag:binInterval:fMaxMag;
    
    mBvalue=nan(numel(binCenters),5);
    mBvalue(:,4)=binCenters(:);
    
    
    for x=1:numel(binCenters)
        % Select magnitude range
        mCat = magnitudes(magnitudes >= binCenters(x) - 0.05);
        
        % Determine size of background catalog
        mBvalue(x,5) = length(mCat);
        
        % Check for minimum number of events
        if length(mCat) >= nMinNumberEvents
            [ fBValue, fStdDev, fAValue] =  calc_bmemag(mCat, binInterval);
            mBvalue(x,1:3) = [fBValue fStdDev fAValue];
        end
    end
end