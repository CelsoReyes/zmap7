function [fPercentile] = calc_GetPercentile(fValue, vDistribution, bAscending)
% function [fPercentile] = calc_GetPercentile(fValue, vDistribution, bAscending)
% ------------------------------------------------------------------------------
% Calculates which percentile value corresponds to the given value for a particular diustribution
%
% Input parameters:
%   fValue            Value for which the percent-value has to be computed
%   vDistribution     Distribution of values
%   bAscending        Compute the percent-value either ascending (in the distribution) or
%                     descending (Default: ascending)
%
% Output parameters:
%   fPercentile       Percent-value for which its percentile matches with fValue
%
% Danijel Schorlemmer
% July 1, 2003


% Declare missing parameters
if ~exist('bAscending', 'var')
  bAscending = true;
end

% Don't calculate percentile for value == nan
if isnan(fValue)
  fPercentile = nan;
  return;
end

% Calculate the percentile
try
  [fPercentile, ~, bExitFlag_] = fminbnd(@callback_GetPercentile, 0, 100, [], vDistribution, fValue);
  if ~bAscending
    fPercentile = 100 - fPercentile;
  end
catch
  fPercentile = nan;
end
