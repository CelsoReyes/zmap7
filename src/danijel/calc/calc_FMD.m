function [mFMDC, mFMD, vXAxis] = calc_FMD(magnitudes)
    % Cumulative and non-cumulative frequency magnitude distribution
    %
    % [mFMDC, mFMD, vXaxis] = calc_FMD(magnitudes)
    %
    %   for a given set of magnitudes (in columns)
    %
    % Input parameter:
    %   magnitudes    columns of earthquake catalog magnitudes
    %
    % Output parameters:
    %   mFMDC       cumulative frequency magnitude distribution
    %               2nd ROW was the number of events (y-axis) COLUMNS
    %   mFMD        non-cumulative frequency magnitude distribution COLUMNS
    %   vXaxis      magBinCenters (x-axis)  COLUMN
    %
    % Danijel Schorlemmer
    % November 16, 2001
    
    if ~isnumeric(magnitudes)
        error('Input should be magnitudes, not the full catalog');
    end
    % Determine the magnitude range
    fMaxMagnitude = ceil(10 * max(magnitudes)) / 10;
    fMinMagnitude = floor(min(magnitudes));
    if fMinMagnitude > 0
        fMinMagnitude = 0;
    end
    
    % Naming convention:
    %   xxxxR : Reverse order
    %   xxxxC : Cumulative number
    
    % Do the calculation
    vNumberEvents = histc(magnitudes, (fMinMagnitude-0.05 : 0.1 : fMaxMagnitude+0.05), 1);
    
    % massage result because histc is different from histcounts (but allows matrix processing)
    vNumberEvents(end-1,:) = vNumberEvents(end-1,:) + vNumberEvents(end,:); 
    vNumberEvents(end,:)=[];
    vNumberEventsR  = vNumberEvents(end : -1 : 1, :);
    vNumberEventsCR = cumsum(vNumberEvents(end : -1 : 1, :));
    
    % Create the x-axis values
    vXAxis = (fMaxMagnitude : -0.1 : fMinMagnitude)';
    
    % Merge the x-axis values with the FMDs and return them
    mFMD  = vNumberEventsR;
    mFMDC = vNumberEventsCR;
end
