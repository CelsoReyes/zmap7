function [fSignificanceLevel] = kj_calcsig(fTestValue, vDistribution, nPrecision)
% function [fSignificanceLevel] = kj_calcsig(fTestValue, vDistribution, nPrecision)
% ---------------------------------------------------------------------------------
% Calculates the level of significance of fTestValue as the percentiles in a distribution
%
% Input parameters:
%   fTestValue            Value to be tested
%   vDistribution         Value distribution
%   nPrecision            Exponent of precision (1:10^nPrecision) of the calculation of the significance level
%                           Exponent of 10 : 2 -> 0-100, 3 -> 0-1000 (0.0-100), 4 -> 0-10000 (0.00-100)
%                         2: Significance level 1:1:100
%                         3: Significance level 0.1:0.1:100
%                         4: Significance level 0.01:0.01:100
%                         etc.
%
% Output parameter:
%   fSignificanceLevel    Level of significance
%
% Danijel Schorlemmer
% November 8, 2001

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Don't calculate significance for testvalues == nan
if isnan(fTestValue)
  fSignificanceLevel = nan;
  return;
end

% Validation of parameters
if nPrecision < 2
  nPrecision = 2;
end

% nProecision must be a positive integer (>2)
if nPrecision ~= round(nPrecision)
  nPrecision = round(nPrecision);
end

% Prepare the prctile container
fPercent = zeros(1, 10^nPrecision);
% Calculate the prctiles
for nCnt = 1:10^nPrecision
  fPercent(nCnt) = prctile(vDistribution, nCnt/(10^(nPrecision - 2)));
end
nCnt = 1;
% Compare the mean with the prctiles
while (fTestValue > fPercent(nCnt)) & (nCnt < 10^nPrecision)
  nCnt = nCnt + 1;
end
% Decrement the prctile (conservative)
nCnt = nCnt - 1;
% Calculate the significance level
fSignificanceLevel = 100 - nCnt/(10^(nPrecision - 2));


