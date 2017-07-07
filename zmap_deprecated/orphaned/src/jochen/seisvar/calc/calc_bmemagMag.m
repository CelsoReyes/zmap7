function [fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemagMag(mCatalog)
% function [fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemagMag(mCatalog)
% --------------------------------------------------------------------------
% Calculates the mean magnitude, the b-value based on the maximum likelihood
% on the maximum likelihood estimation, thea-value and the standard deviation
% of the b-value.
%
% Incoming variable:
% mCatalog: EQ- catalog in ZMAP format
%
% Outgoing:
%   fMeanMag        Mean magnitude
%   fBValue         b-value
%   fStdDev         Standard deviation of b-value
%   fAValue        a-value
%
% J. Woessner: woessner@seismo.ifg.ethz.ch
% last update: 03.09.02

% Originally taken from D. Schorlemmer calc_bmemag.m
% Track changes:
% 01.20.02: Added fBinning variable again

fBinning = 0.1;

[nXSize, nYSize] = size(mCatalog);
if nXSize > 1
  % Use magnitude column from ZMAP data catalog format
  vMagnitude = mCatalog(:,6);
else
  % Use one column magnitude vector
  vMagnitude = mCatalog;
end

try
% Calculate the minimum and mean magnitude, length of catalog
nLen = length(vMagnitude);
fMinMag = min(vMagnitude);
fMeanMag = mean(vMagnitude);
% Calculate the b-value (maximum likelihood)
fBValue = (1/(fMeanMag-(fMinMag-fBinning/2)))*log10(exp(1));
% Calculate the standard deviation
fStdDev = (sum((vMagnitude-fMeanMag).^2))/(nLen*(nLen-1));
fStdDev = 2.30 * sqrt(fStdDev) * fBValue^2;
% Calculate thea-value
fAValue = log10(nLen) + fBValue * fMinMag;
catch
fBValue = nan;
fMeanMag = nan;
fStdDev = nan;
fAValue = nan;
end
