function [fProbability_] = calc_LogLikelihoodAValue(fAValue, mCatalog, fBValue)
% function [fProbability] = calc_LogLikelihoodAValue(fAValue, mCatalog, fBValue)
% ------------------------------------------------------------------------------
% Helper function for calc_AValueFixedB.m
%   Computes the negative log-likelihood of a given a- and b-value for a given catalog
%
% Input parameters:
%   fAValue         Predetermineda-value
%   mCatalog        Earthquake catalog
%   fBValue         Predetermined b-value;
%
% Output parameters:
%   fProbability    Negative log-likelihood of the given a- and b-value for the given catalog
%
% Danijel Schorlemmer
% July 1, 2002

global fProbability

% Determine the limits of calculation
fMinMag_ = min(mCatalog.Magnitude);
fMaxMag_ = max(mCatalog.Magnitude);

vCnt_ = (fMinMag_:0.1:fMaxMag_+0.1)'; % Add one more magnitude bin for later use of diff()
% Compute the cumulative FMD
vNumber_ = 10.^(fAValue - (fBValue * vCnt_));
% Determine the number of events in each magnitude bin
mPredictionFMD_ = -diff(vNumber_);
% Create the FMD for the period of observation
vObservedFMD_ = histogram(mCatalog.Magnitude, fMinMag_:0.1:fMaxMag_);
% Calculate the likelihoods for both of the models
vProb_ = calc_log10poisspdf(vObservedFMD_', mPredictionFMD_(:,1));
% Return the values (multiply by -1 to return the lowest value for the highest probability
fProbability_ = (-1) * sum(vProb_);
fProbability = fProbability_;
