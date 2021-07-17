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
    if ~isnumeric(magnitudes)
        magnitudes = magnitudes.Magnitude; % treat as catalog
    end
    if isrow(magnitudes)
        magnitudes=magnitudes(:);
    end
    fMaxMagnitude = ceil(100*max(magnitudes,[],'all')/100);
    fMinMagnitude = floor(100*min(magnitudes,[],'all')/100);
    if fMinMagnitude > 0
        fMinMagnitude = 0;
    end
    
    
    
    % Create a histogram over magnitudes
    %[vHist, vMagBins] = hist(mCatalog.Magnitude, (fMinMagnitude:0.1:fMaxMagnitude));
    vMagCenters = fMinMagnitude : 0.1 : fMaxMagnitude;
    vMagEdges = fMinMagnitude-0.05 : 0.1 : fMaxMagnitude+0.05;
    fMc = nan(size(magnitudes,2),1);
    for i = 1: size(magnitudes,2)
        magcol = magnitudes(:,i);
        [vHist, ~] = histc(magcol, vMagEdges, 1); %histc for each column --not possible with histogram
        [~, ii] = max(vHist);
        fMc(i) = vMagCenters(ii(end));
    end
    % Get the points with highest number of events -> maximum curvature
    %maxes = max(vHist);
    %fMc = nan(size(vHist,2),1);
    %for j=1:numel(fMc)
    %    fMc(j) = vMagCenters(find(vHist(:,j) == maxes(j), 1, 'last' ));
    %end
end


    
