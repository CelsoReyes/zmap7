function [fBValue, fStdDev, fAValue, fMeanMag] =  calc_bvalue(mCatalog, fBinning)
% function [fBValue, fStdDev, fAValue, fMeanMag] =  calc_bvalue(mCatalog, fBinning)
% ---------------------------------------------------------------------------------
% Calculates the b-value based on the maximum likelihood estimation,
% the standard deviation of the b-value,
% the mean magnitude, and thea-value of an earthquake catalog
%
% Input parameters:
%   mCatalog        Earthquake catalog
%   fBinning        Binning of the earthquake magnitudes (default 0.1)
%
% Output parameters:
%   fBValue         b-value
%   fStdDev         Standard deviation of b-value
%   fAValue        a-value
%   fMeanMag        Mean magnitude
%
% Danijel Schorlemmer
% October 31, 2005

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end


% Set the default value if not passed to the function
if ~exist('fBinning')
  fBinning = 0.1;
end

% Check input
[nY,nX] = size(mCatalog);

if (~isempty(mCatalog) & nX == 1)
    vMag = mCatalog;
elseif (~isempty(mCatalog)  &&  nX > 1)
    vMag = mCatalog(:,6);
else
    disp('No magnitude data available!');
    return
end

% Calculate the minimum and mean magnitude, length of catalog
nLen = length(vMag);
fMinMag = min(vMag);
fMeanMag = mean(vMag);
% Calculate the b-value (maximum likelihood)
fBValue = (1/(fMeanMag-(fMinMag-(fBinning/2))))*log10(exp(1));
% Calculate the standard deviation
fStdDev = (sum((vMag-fMeanMag).^2))/(nLen*(nLen-1));
fStdDev = 2.30 * sqrt(fStdDev) * fBValue^2;
% Calculate thea-value
fAValue = log10(nLen) + fBValue * fMinMag;

