function [fSigmaDistance, fMu, fSigma] = pt_CalcDeltaSig(values, fTestValue)
% function [fSignificanceLevel, fMu, fSigma] = pt_CalcDeltaSig(values, fTestValue)
% ---------------------------------------------------------------------------------
% Calculates the Delta_sigma measure of significance of fTestValue
%
% Input parameters:
%   values               Value distribution (assumed to be a normal distribution)
%   fTestValue            Value to be tested
%
% Output parameter:
%   fSigmaDistance        Delat_sigma measure
%   fMu                   Mu of distribution
%   fSigma                Sigma of distribution
%
% Danijel Schorlemmer
% April 14, 2003

report_this_filefun();

% Select all non-NaN values of the distribution
vSelection = ~isnan(values);
mNoNanValues = values(vSelection);

% Compute the mean and standard deviation of the non-parameterized distribution
fMu = mean(mNoNanValues);
fSigma = std(mNoNanValues,1,'omitnan');

% Return the Delta_sigma measure of the testvalue (+: test hypothesis wins)
fSigmaDistance = (fMu - fTestValue)/fSigma;
