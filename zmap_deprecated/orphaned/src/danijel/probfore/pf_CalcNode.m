function [rResult] = pf_CalcNode(mCatalog, fSplitTime, bLearningPeriod, fLearningPeriod, bForecastPeriod, fForecastPeriod, nCalculateMC, fMcOverall, bMinMagMc, fMinMag, fMaxMag, nTestMethod, nMinimumNumber, fBValueOverall, fStdDevOverall)
% function [rResult] = pf_CalcNode(mCatalog, fSplitTime, bLearningPeriod, fLearningPeriod, bForecastPeriod,
%                                  fForecastPeriod, nCalculateMC, fMcOverall, bMinMagMc, fMinMag, fMaxMag,
%                                  nTestMethod, nMinimumNumber, fBValueOverall, fStdDevOverall)
% ---------------------------------------------------------------------------------------------------------
% Calculates the probabilistic forecast test for a single grid node.
%
% Input parameters:
%   mCatalog                      Catalog of node
%   fSplitTime                    Time at which the catalog will be split
%   bLearningPeriod               Fix duration of the learning period (1 = fix, 0 = use catalog from start)
%   fLearningPeriod               Duration of the learning period
%   bObservationPeriod            Fix duration of the observation period (1 = fix, 0 = use catalog till end)
%   fObservationPeriod            Duration of the observation period
%   nCalculateMC                  Method to calculate magnitude of completeness (see also: help calc_Mc)
%   fMcOverall                    Magnitude of completeness of the overall catalog
%   bMinMagMc                     Use magnitude of completeness as lower limit of magnitude range for testing (=1)
%                                 Use fMinMag as lower limit (=0)
%   fMinMag                       Lower limit of magnitude range for testing
%   fMaxMag                       Upper limit of magnitude range for testing
%   nTestMethod                   Method to test both models (see also: help pf_poissonian)
%   nMinimumNumber                Minimum number of earthquakes per node for determining a b-value
%   fBValueOverall                b-value of the overall catalog
%   fStdDevOverall                overall mean standard deviation of the overall catalog
%
% Output parameters:
%   rResult.fProbDiff             Log-probability difference
%   rResult.fProbK                Log-probability of the null hypothesis
%   rResult.fProbO                Log-probability of the spatially varying b-value hypothesis
%   rResult.fWeightK              Weighting of b-value (bayesian approach) of the null hypothesis
%   rResult.fWeightO              Weighting of b-value (bayesian approach) of the spatially varying b-value hypothesis
%   rResult.fBValueO              b-value of the spatially varying b-value hypothesis
%   rResult.fMc                   Magnitude of completeness
%   rResult.nEventsLearning       Number of events in learning period
%   rResult.nEventsObserved       Number of events in observation period
%   rResult.fLearningPeriodUsed   Length of learning period
%   rResult.fObservedPeriodUsed   Length of observation period
%
% Danijel Schorlemmer
% Mai 7, 2002

% Create the learning and observed catalogs
[mLearningCatalog_, mObservationCatalog_, vDummy_, vDummy_, rResult.fLearningPeriodUsed, rResult.fObservationPeriodUsed] ...
  = ex_SplitCatalog(mCatalog, fSplitTime, bLearningPeriod, fLearningPeriod, bForecastPeriod, fForecastPeriod);

% Determine the local magnitude of completeness
rResult.fMc = calc_Mc(mLearningCatalog_, nCalculateMC);
if isnan(rResult.fMc)
  rResult.fMc = fMcOverall;
elseif isempty(rResult.fMc)
  rResult.fMc = fMcOverall;
end

% Define magnitude range for testing
if bMinMagMc
  fMinMag_ = rResult.fMc;
else
  fMinMag_ = fMinMag;
end

% Cut the catalog at magnitude of completeness
vSel_ = mLearningCatalog_(:,6) >= rResult.fMc;
mLearningCatalog_ = mLearningCatalog_(vSel_,:);

% Do the probabilistic forecast test
[rResult.fProbDiff, rResult.fProbK, rResult.fProbO, rResult.fWeightK, rResult.fWeightO, rResult.fBValueO] = pf_poissonian(mLearningCatalog_, rResult.fLearningPeriodUsed, ...
  mObservationCatalog_, rResult.fObservationPeriodUsed, nTestMethod, nMinimumNumber, rResult.fMc, ...
  fBValueOverall, fStdDevOverall, fMinMag_, fMaxMag);

% Number of events per period
rResult.nEventsLearning = length(mLearningCatalog_(:,6));
rResult.nEventsObserved = length(mObservationCatalog_(:,6));

