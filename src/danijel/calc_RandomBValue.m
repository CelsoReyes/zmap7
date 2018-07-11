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

report_this_filefun();

% Initialize containers
vBValue = [];
vStdDev = [];

% Simulation run
for i = 1:nNumberRuns
  % Select nSampleSize earthquakes from the catalog
  vSelection = ceil(rand([nSampleSize 1]) * length(mCatalog.Magnitude));
  % Determine b-value and standard deviation of this sample
  [fBValue fStdDev] = calc_bmemag(mCatalog.Magnitude(vSelection), 0.1);
  % Store the values in the containers
  vStdDev = [vStdDev; fStdDev];
  vBValue = [vBValue; fBValue];
end

% Return average values
fAverageBValue = nanmean(vBValue);
fAverageStdDev = nanmean(vStdDev);
