function [fP] = callback_GetPercentile(fPercentile, vDistribution, fValue)


fP = abs(prctile(vDistribution, fPercentile) - fValue);

