function [bval, b_std, aval, mags, nevts] = calc_bwithmag(magnitudes, binInterval, nMinNumberEvents)
    % Calculate b-value depending on cut-off magnitude
    % [bval, b_std, aval, mags, nevts]  = calc_bwithmag(magnitudes, binInterval, nMinNumberevents)
    %
    % Incoming variables:
    % magnitudes        : Earthquake catalog magnitudes
    % binInterval           : Binning interval
    % nMinNumberevents  : Minimum number of events
    %
    % Outgoing variables:
    % bval : b-values ascending with magnitude
    % b_std : Standard deviation of b (Shi & Bolt, 1982) ascending with magnitude
    % aval: a-values ascending with magnitude
    % mags : Ascending magnitudes
    % nevts : Number of events above magnitude cut-off
    %
    % Author: J. Woessner modified by C Reyes
    
    % Check input
    
    % Set fix values
    fMinMag = min(magnitudes);
    fMaxMag = max(magnitudes);
    
    binCenters = fMinMag:binInterval:fMaxMag;
    
    % mBvalue = nan(numel(binCenters),5);
    mags =binCenters(:);
    
    
    for x=1:numel(binCenters)
        % Select magnitude range
        mCat = magnitudes(magnitudes >= binCenters(x) - 0.05);
        
        % Determine size of background catalog
        nevts(x,1) = length(mCat);
        
        % Check for minimum number of events
        if length(mCat) >= nMinNumberEvents
            [ bval(x,1), b_std(x,1), aval(x,1)] =  calc_bmemag(mCat, binInterval);
            % mBvalue(x,1:3) = [fBValue fStdDev fAValue];
        end
    end
end