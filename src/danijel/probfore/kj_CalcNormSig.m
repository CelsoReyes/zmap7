function [fSignificanceLevel, fMu, fSigma] = kj_CalcNormSig(mValues, fTestValue)
% function [fSignificanceLevel, fMu, fSigma] = kj_CalcNormSig(mValues, fTestValue)
% --------------------------------------------------------------------------------
% Calculates the level of significance of fTestValue assuming the distribution
% to be a normal distribution
%
% Input parameters:
%   mValues               Value distribution (assumed to be a normal distribution)
%   fTestValue            Value to be tested
%
% Output parameter:
%   fSignificanceLevel    Level of significance
%   fMu                   Mu of normal distribution
%   fSigma                Sigma of normal distribution
%
% Danijel Schorlemmer
% March 13, 2002

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Select all non-NaN values of the distribution
vSelection = ~isnan(mValues);
mNoNanValues = mValues(vSelection);

% Fit the values to a normal distribution
[fMu, fSigma] = normfit(mNoNanValues);

% Return the significance level of the testvalue
fSignificanceLevel = 1 - (normcdf(fTestValue, fMu, fSigma));
