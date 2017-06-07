function [fProbability] = callback_LogLikelihoodAPoisson(fAValue, mCatalog, fBValue)
% function [fProbability] = callback_LogLikelihoodAPoisson(fAValue, mCatalog, fBValue)
% ------------------------------------------------------------------------------------
% Helper function for calc_MaxLikelihoodAPoisson.m
%   Computes the negative log-likelihood of a given a- and b-value for a given catalog
%   using the poisson probability density
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
% July 17, 2002

% Determine the limits of calculation
fMinMag_ = min(mCatalog(:,6));
fMaxMag_ = max(mCatalog(:,6));

vCnt_ = (fMinMag_:0.1:fMaxMag_+0.1)'; % Add one more magnitude bin for later use of diff()
% Compute the cumulative FMD
vNumber_ = 10.^(fAValue - (fBValue * vCnt_));
% Determine the number of events in each magnitude bin
mPredictionFMD_ = -diff(vNumber_);
% Create the FMD for the period of observation
vObservedFMD_ = histogram(mCatalog(:,6), fMinMag_:0.1:fMaxMag_);
% Calculate the likelihoods for both of the models
vProb_ = calc_log10poisspdf(vObservedFMD_', mPredictionFMD_(:,1));
% Return the values (multiply by -1 to return the lowest value for the highest probability
fProbability = (-1) * sum(vProb_);
