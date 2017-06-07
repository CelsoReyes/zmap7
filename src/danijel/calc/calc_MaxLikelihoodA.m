function [fAValue] = calc_MaxLikelihoodA(mCatalog, fBValue)
% function [fAValue] = calc_AValueFixedB(mCatalog, fBValue)
% ---------------------------------------------------------
% Calculates the maximum likelihooda-value for a given
%   catalog and given b-value. The Catalog has to be complete
%   down to the smalles magnitude: Mc=Mmin
%
% Input parameters:
%   mCatalog    earthquake catalog (complete down to minimum magnitude)
%   fBValue     Predetermined b-value
%
% Output parameters:
%   fAValue     Maximum likelihooda-value
%
% Danijel Schorlemmer
% July 17, 2002

% Determine number of earthquakes in catalog
nNumber = length(mCatalog(:,1));
% Determine minimum magnitude
fMc = min(mCatalog(:,6));
% Set up the magnitude range for computing the loglikelihood
vMagnitudes = fMc:0.1:10.1;  % 10 is the maximum magnitude. Add an additional bin for diff
% Compute the unscaled number of expected events for a given b-value
vExpectation = 10.^(-fBValue * vMagnitudes);
vExpectation = -diff(vExpectation);
fSum = sum(vExpectation);
% Get thea-value as the maximum likelihood solution
fAValue = log10(nNumber/fSum);
