function [mFMDC, mFMD] = calc_FMDMag(mCatalog)
% function [mFMDC, mFMD] = calc_FMD(mCatalog)
% -------------------------------------------
% Calculates the cumulative and non-cumulative frequency magnitude distribution
%   for given magnitudes of an earthquake catalog
%
% Input parameter:
%   vMagnitudes    Either EQ catalog in ZMAP format or vector of magnitudes of an earthquake catalog
%
% Output parameters:
%   mFMDC       cumulative frequency magnitude distribution
%               mFMDC(1,:) = magnitudes (x-axis)
%               mFMDC(2,:) = number of events (y-axis)
%   mFMD        non-cumulative frequency magnitude distribution
%
% J. Woessner; woessner@seismo.ifg.ethz.ch
% last update: 12.07.02

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

[nXSize, nYSize] = size(mCatalog);
if nXSize > 1
  % Use magnitude column from ZMAP data catalog format
  vMagnitudes = mCatalog(:,6);
else
  % Use one column magnitude vector
  vMagnitudes = mCatalog;
end

% Determine the magnitude range
fMaxMagnitude = ceil(10 * max(vMagnitudes)) / 10;
fMinMagnitude = floor(min(vMagnitudes));
if fMinMagnitude > 0
  fMinMagnitude = 0;
end

% Naming convention:
%   xxxxR : Reverse order
%   xxxxC : Cumulative number

% Do the calculation
[vNumberEvents] = hist(vMagnitudes, (fMinMagnitude:0.1:fMaxMagnitude));
vNumberEventsR  = vNumberEvents(length(vNumberEvents):-1:1);
vNumberEventsCR = cumsum(vNumberEvents(length(vNumberEvents):-1:1));

% Create the x-axis values
vXAxis = (fMaxMagnitude:-0.1:fMinMagnitude);

% Merge the x-axis values with the FMDs and return them
mFMD  = [vXAxis; vNumberEventsR];
mFMDC = [vXAxis; vNumberEventsCR];
