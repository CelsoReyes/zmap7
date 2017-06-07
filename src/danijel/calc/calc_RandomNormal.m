function [mNumbers] = calc_RandomNormal(fMu, fSigma, nRows, nCols)
% function [mNumbers] = calc_RandomNormal(fMu, fSigma, nRows, nCols)
% ------------------------------------------------------------------
% Generate normal distributed random numbers for given mean and
%   standard deviation
%
% Input paramters:
%   fMu         Mean value of the normal distribution (default = 1)
%   fSigma      Standard deviation of normal distribution (default = 1)
%   nRows       Number of rows of output matrix mNumbers (default = 1)
%   nCols       Number of columns of output matrix mNumbers (default = 1)
%
% Output parameters:
%   mNumbers	  Matrix with random numbers
%
% Danijel Schorlemmer
% May 28, 2004


% Randomize
rand('state',sum(100*clock));

% Check for input parameters
if ~exist('fMu', 'var')
  fMu = 1;
end
if ~exist('fSigma', 'var')
  fSigma = 1;
end
if ~exist('nRows', 'var')
  nRows = 1;
end
if ~exist('nCols', 'var')
  nCols = 1;
end

% Generate normal distributed random numbers
mNumbers = randn(nRows, nCols);

% Multiply by given standard deviation
mNumbers = mNumbers .* fSigma;

% Shift by given mean value
mNumbers = mNumbers + fMu;

