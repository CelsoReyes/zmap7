function [aValue] = calc_MaxLikelihoodAPoisson(magnitudes, bValue)
% function [aValue] = calc_MaxLikelihoodAPoisson(magnitudes, bValue)
% ------------------------------------------------------------------
% Calculates the maximum likelihood a-value for a given
%   catalog and given b-value using the poisson probability density.
%   The Catalog has to be complete down to the smalles magnitude: Mc=Mmin
%
% Input parameters:
%   magnitudes    earthquake catalog magnitudes (complete down to minimum magnitude)
%   fBValue     Predetermined b-value
%
% Output parameters:
%   fAValue     Maximum likelihood a-value
%
% Danijel Schorlemmer
% July 17, 2002

% Find minimum of negative log-likelihoods
[aValue, ~, exitFlag] = fminbnd(@callback_LogLikelihoodAPoisson, 0.01, 10, [], magnitudes, bValue);

% If search doesn't converge, extrapolate a-value from magnitude of completeness
if exitFlag ~= 1
  fMinMag_ = min(magnitudes);
  aValue = log10(length(magnitudes)) + (bValue * fMinMag_);
end



function [fProbability] = callback_LogLikelihoodAPoisson(fAValue, magnitudes, fBValue)
  % function [fProbability] = callback_LogLikelihoodAPoisson(fAValue, magnitudes, fBValue)
  % ------------------------------------------------------------------------------------
  %   Computes the negative log-likelihood of a given a- and b-value for a given catalog
  %   using the poisson probability density
  %
  % Input parameters:
  %   fAValue         Predetermineda-value
  %   magnitudes      Earthquake catalog Magnitudes
  %   fBValue         Predetermined b-value;
  %
  % Output parameters:
  %   fProbability    Negative log-likelihood of the given a- and b-value for the given catalog
  %
  % Danijel Schorlemmer
  % July 17, 2002
  
  % Determine the limits of calculation
  fMinMag_ = min(magnitudes);
  fMaxMag_ = max(magnitudes);
  
  vCnt_ = (fMinMag_:0.1:fMaxMag_+0.1)'; % Add one more magnitude bin for later use of diff()
  % Compute the cumulative FMD
  vNumber_ = 10.^(fAValue - (fBValue * vCnt_));
  % Determine the number of events in each magnitude bin
  mPredictionFMD_ = -diff(vNumber_);
  % Create the FMD for the period of observation
  vObservedFMD_ = histogram(magnitudes, fMinMag_:0.1:fMaxMag_);
  % Calculate the likelihoods for both of the models
  vProb_ = calc_log10poisspdf(vObservedFMD_', mPredictionFMD_(:,1));
  % Return the values (multiply by -1 to return the lowest value for the highest probability
  fProbability = (-1) * sum(vProb_);
  