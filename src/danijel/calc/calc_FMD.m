function [mFMDC, mFMD] = calc_FMD(mCatalog)
% function [mFMDC, mFMD] = calc_FMD(mCatalog)
% -------------------------------------------
% Calculates the cumulative and non-cumulative frequency magnitude distribution
%   for a given earthquake catalog
%
% Input parameter:
%   mCatalog    earthquake catalog
%
% Output parameters:
%   mFMDC       cumulative frequency magnitude distribution
%               mFMDC(1,:) = magnitudes (x-axis)
%               mFMDC(2,:) = number of events (y-axis)
%   mFMD        non-cumulative frequency magnitude distribution
%
% Danijel Schorlemmer
% November 16, 2001

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Determine the magnitude range
fMaxMagnitude = ceil(10 * max(mCatalog(:,6))) / 10;
fMinMagnitude = floor(min(mCatalog(:,6)));
if fMinMagnitude > 0
  fMinMagnitude = 0;
end

% Naming convention:
%   xxxxR : Reverse order
%   xxxxC : Cumulative number

% Do the calculation
[vNumberEvents] = hist(mCatalog(:,6), (fMinMagnitude:0.1:fMaxMagnitude));
vNumberEventsR  = vNumberEvents(length(vNumberEvents):-1:1);
vNumberEventsCR = cumsum(vNumberEvents(length(vNumberEvents):-1:1));

% Create the x-axis values
vXAxis = (fMaxMagnitude:-0.1:fMinMagnitude);

% Merge the x-axis values with the FMDs and return them
mFMD  = [vXAxis; vNumberEventsR];
mFMDC = [vXAxis; vNumberEventsCR];
