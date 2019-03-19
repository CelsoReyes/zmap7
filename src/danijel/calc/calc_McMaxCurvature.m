function [fMc] = calc_McMaxCurvature(magnitudes)
    % magnitude of completeness at the point of maximum curvature of the frequency magnitude distribution
    %  [fMc] = calc_McMaxCurvature(magnitudes);
    %
    % Input parameter:
    %   mCatalog        Earthquake catalog magnitudes
    %
    % Output parameter:
    %   fMc             Magnitude of completeness, NaN if not computable COLUMN
    %
    %  assumes magnitude bin size of 0.1
    %
    % works on columns of data
    % Danijel Schorlemmer 2001
    % Modified by CGReyes 2017
    
    % report_this_filefun();
    
    % Get maximum and minimum magnitudes of the catalog
    if isempty(magnitudes)
        fMc = nan;
        return
    end
    fMaxMagnitude = max(magnitudes(:));
    fMinMagnitude = min(magnitudes(:));
    if fMinMagnitude > 0
        fMinMagnitude = 0;
    end
    
    
    
    % Create a histogram over magnitudes
    %[vHist, vMagBins] = hist(mCatalog.Magnitude, (fMinMagnitude:0.1:fMaxMagnitude));
    vMagCenters = fMinMagnitude : 0.1 : fMaxMagnitude;
    vMagEdges = fMinMagnitude-0.05 : 0.1 : fMaxMagnitude+0.05;
    [vHist, ~] = histc(magnitudes, vMagEdges, 1); %histc for each column --not possible with histogram
    
    % Get the points with highest number of events -> maximum curvature
    maxes = max(vHist);
    fMc = nan(size(vHist,2),1);
    for j=1:numel(fMc)
        fMc(j) = vMagCenters(find(vHist(:,j) == maxes(j), 1, 'last' ));
    end
end


    
