function [fAverageBValue, fAverageStdDev] = calc_RandomBValue(mCatalog, nSampleSize, nNumberRuns)
% function [fAverageBValue, fAverageStdDev] = calc_RandomBValue(mCatalog, nSampleSize, nNumberRuns)
% -------------------------------------------------------------------------------------------------
% Determines an average b-value and standard deviation drawing nNumberRuns random samples
%  of size nSampleSize
%
% Input parameters:
%   mCatalog          Earthquake catalog to be used
%   nSampleSize       Samplesize for b-value and standard deviation calculation
%   nNumberRuns       Number of simulation runs
%
% Output parameters:
%   fAverageBValue    Resulting average b-value
%   fAverageStdDev    Resulting standard deviation
%
% Danijel Schorlemmer
% November 7, 2001

global bDebug
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Initialize containers
vBValue = [];
vStdDev = [];

% Simulation run
for i = 1:nNumberRuns
  % Select nSampleSize earthquakes from the catalog
  vSelection = ceil(rand([nSampleSize 1]) * length(mCatalog.Magnitude));
  % Determine b-value and standard deviation of this sample
  [v1 fBValue fStdDev,  v2] = bmemag(mCatalog.subset(vSelection));
  % Store the values in the containers
  vStdDev = [vStdDev; fStdDev];
  vBValue = [vBValue; fBValue];
end

% Return average values
fAverageBValue = nanmean(vBValue);
fAverageStdDev = nanmean(vStdDev);
