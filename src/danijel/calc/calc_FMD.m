function [mFMDC, mFMD] = calc_FMD(magnitudes)
% calc_FMD Calculates the cumulative and non-cumulative frequency magnitude distribution
% function [mFMDC, mFMD] = calc_FMD(magnitudes)
% -------------------------------------------

%   for a given earthquake catalog
%
% Input parameter:
%   magnitudes    earthquake catalog magnitudes
%
% Output parameters:
%   mFMDC       cumulative frequency magnitude distribution
%               mFMDC(1,:) = magnitudes (x-axis)
%               mFMDC(2,:) = number of events (y-axis)
%   mFMD        non-cumulative frequency magnitude distribution
%
% Danijel Schorlemmer
% November 16, 2001

report_this_filefun();
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
[vNumberEvents] = hist(magnitudes, (fMinMagnitude:0.1:fMaxMagnitude));
vNumberEventsR  = vNumberEvents(end:-1:1);
vNumberEventsCR = cumsum(vNumberEvents(end:-1:1));

% Create the x-axis values
vXAxis = (fMaxMagnitude:-0.1:fMinMagnitude);

% Merge the x-axis values with the FMDs and return them
mFMD  = [vXAxis; vNumberEventsR];
mFMDC = [vXAxis; vNumberEventsCR];
