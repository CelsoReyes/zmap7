function [fMc] = calc_McMaxCurvatureMag(vMagnitudes)
% function [fMc] = calc_McMaxCurvatureMag(vMagnitudes);
% -----------------------------------------------
% Determines the magnitude of completeness at the point of maximum
%   curvature of the frequency magnitude distribution
%
% Input parameter:
%   vMagnitudes        Earthquake catalog
%
% Output parameter:
%   fMc             Magnitude of completeness
%
% Danijel Schorlemmer
% November 7, 2001

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

try
  % Get maximum and minimum magnitudes of the catalog
  fMaxMagnitude = max(vMagnitudes);
  fMinMagnitude = min(vMagnitudes);
  if fMinMagnitude > 0
    fMinMagnitude = 0;
  end

  % Number of magnitudes units
  nNumberMagnitudes = (fMaxMagnitude*10) + 1;

  % Create a histogram over magnitudes
  vHist = zeros(1, nNumberMagnitudes);
  [vHist, vMagBins] = hist(vMagnitudes, (fMinMagnitude:0.1:fMaxMagnitude));

  % Get the points with highest number of events -> maximum curvature
  fMc = vMagBins(max(find(vHist == max(vHist))));
catch
  fMc = nan;
end




