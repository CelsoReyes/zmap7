function [fDeltaProbability, fProbabilityN, fProbabilityH, mPredictionFMD, vObservedFMD, vMagnitudeBins, vProbH, vProbN] ...
  = pt_poissonian(mLearningCatalog, fLearningTime, mObservedCatalog, fObservedTime, nMinimumNumber, fBValueH, fBValueN, ...
  fMcH, fMcN, fMinMag, fMaxMag);
% function [fDeltaProbability, fProbabilityN, fProbabilityH, mPredictionFMD, vObservedFMD, vMagnitudeBins, vProbH, vProbN]
%   = pt_poissonian(mLearningCatalog, fLearningTime, mObservedCatalog, fObservedTime, nMinimumNumber, fBValueH, fBValueN,
%                   fMcH, fMcN, fMinMag, fMaxMag);
% ------------------------------------------------------------------------------------------------
% Calculation of likelihoods for two models based on a- and b-values
%
% Input parameters:
%   mLearningCatalog    Earthquake catalog of the learning period
%   fLearningTime       Length of learning period (can be different than the exact length of mLearningCatalog)
%   mObservedCatalog    Earthquake catalog of the observed period
%   fObservedTime       Length of observed period (can be different than the exact length of mObservedCatalog)
%   nMinimumNumber      Minimum number of earthquakes in the catalog for calculating the output values
%   fBValueH            b-value for test hypothesis
%   fBValueN            b-value for null hypothesis
%   fMcH                Magnitude of completeness for the test hypothesis
%   fMcN                Magnitude of completeness for the null hypothesis
%   fMinMag             Minimum magnitude for testing
%   fMaxMag             Maximum magnitude for testing
%
% Output parameters:
%   fDeltaProbability   Difference of the log-likelihood between both of the models
%   fProbabilityN       Log-likelihood of the null hypothesis
%   fProbabilityH       Log-likelihood of the test hypothesis
%   mPredictionFMD      Forecasted FMD of both models (mPredictionFMD(:,1) test hypothesis, (:,2) null hypothesis)
%   vObservedFMD        Vector with observations corresponding to mPredictionFMD
%   vMAgnitudeBins      Vector containing the tested magnitude bins
%   vProbH              log-likelihoods per magnitude bin of the test hypothesis
%   vProbN              log-likelihoods per magnitude bin of the null hypothesis
%
% Danijel Schorlemmer
% April 30, 2003

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Index description
% xxxxN : Variable with a value for the null hypothesis model
% xxxxH : Variable with a value for the hypothesis model

if ((length(mLearningCatalog(:,1)) < nMinimumNumber) | (isnan(fBValueH)) | (isnan(fBValueN)))
  fDeltaProbability = nan;
  fProbabilityH = nan;
  fProbabilityN = nan;
  mPredictionFMD = [];
  vObservedFMD = [];
  vMagnitudeBins = [];
  vProbH = [];
  vProbN =[];
else
  % Select the higher magnitude of completeness
  fMc = max([fMcH fMcN]);
  % Cut the first catalog at magnitude of completeness
  vSel = mLearningCatalog(:,6) >= fMc;
  mCalcACatalog = mLearningCatalog(vSel,:);
  if length(mCalcACatalog(:,1)) >= nMinimumNumber
    % Compute the maximum likelihood a-values for both models
    fAValueH = calc_MaxLikelihoodA(mCalcACatalog, fBValueH);
    fAValueN = calc_MaxLikelihoodA(mCalcACatalog, fBValueN);
    % Create the predicted FMD
    vCnt = (fMinMag:0.1:fMaxMag+0.1)'; % Add one more magnitude bin for later use of diff()
    vNumberH = 10.^(fAValueH - (fBValueH * vCnt))/fLearningTime * fObservedTime;
    vNumberN = 10.^(fAValueN - (fBValueN * vCnt))/fLearningTime * fObservedTime;
    mNumbers = [vNumberH vNumberN];
    % Determine the number of events in each magnitude bin
    mPredictionFMD = -diff(mNumbers);
    % Cut the second catalog at the minimum magnitude for testing
    vSel = mObservedCatalog(:,6) >= fMinMag;
    mCalcCatalog = mObservedCatalog(vSel,:);
    % Create the FMD for the period of observation
    vObservedFMD = histogram(mCalcCatalog(:,6), fMinMag:0.1:fMaxMag);
    % Calculate the likelihoods for both of the models
    vProbH = calc_logpoisspdf(vObservedFMD', mPredictionFMD(:,1));
    vProbN = calc_logpoisspdf(vObservedFMD', mPredictionFMD(:,2));
    % Return the values
    fProbabilityH = sum(vProbH);
    fProbabilityN = sum(vProbN);
    fDeltaProbability = fProbabilityN - fProbabilityH;
    vObservedFMD = vObservedFMD';   % Simply for returning the vector in the same way as vPredictionFMD
    vMagnitudeBins = (fMinMag:0.1:fMaxMag)';
  else
    fDeltaProbability = nan;
    fProbabilityH = nan;
    fProbabilityN = nan;
    mPredictionFMD = [];
    vObservedFMD = [];
    vMagnitudeBins = [];
    vProbH = [];
    vProbN =[];
  end
end
