function [fP] = callback_GetPercentile(fPercentile, vDistribution, fValue)
    % get percentile
    fP = abs(prctile(vDistribution, fPercentile) - fValue);
end
