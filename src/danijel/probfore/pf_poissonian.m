function [fDeltaProbability, fProbabilityK, fProbabilityO, fWeightK, fWeightO, fBValueO, vProbK, vProbO, mPredictionFMD] = pf_poissonian(mLearningCatalog, fLearningTime, mObservedCatalog, fObservedTime, nTestMethod, nMinimumNumber, fMc, fBValueK, fStdDevK, fMinMag, fMaxMag)
% function [fDeltaProbability, fProbabilityK, fProbabilityO, fWeightK, fWeightO, fBValueO, vProbK, vProbO]
%   = kj_poissonian(mLearningCatalog, fLearningTime, mObservedCatalog, fObservedTime, nTestMethod,
%                   nMinimumNumber, fMc, fBValueK, fStdDevK, fMinMag, fMaxMag)
% ------------------------------------------------------------------------------------------------
% Calculation of the likelihoods of the constant b-value model, our forecasting model,
%   and the difference between these two models.
%
% Input parameters:
%   mLearningCatalog    Earthquake catalog of the learning period
%   fLearningTime       Length of learning period (can be different than the exact length of mLearningCatalog)
%   mObservedCatalog    Earthquake catalog of the observed period
%   fObservedTime       Length of observed period (can be different than the exact length of mObservedCatalog)
%   nTestMethod         Method to test both models:
%                       1: Calculate test only for nodes with nMinimumNumber of earthquakes
%                       2: Calculate test for all nodes using the overall b-value for nodes with
%                          number of earthquakes < nMinimumNumber
%                       3: Calculate test for all nodes using the bayesian approach to determine the b-value for our model
%   nMinimumNumber      Minimum number of earthquakes in the catalog for calculating the output values
%   fMc                 Magnitude of completeness of the catalog
%   fBValueK            Overall b-value for the constant b-value model
%   fStdDevK            Standard deviation of the overall b-value
%   fMinMag             Minimum magnitude for testing
%   fMaxMag             Maximum magnitude for testing
%
% Output parameters:
%   fDeltaProbability   Difference of the log-likelihood between both of the models
%   fProbabilityK       Log-likelihood of the constant b-value model
%   fProbabilityO       Log-likelihood of our forecasting model
%   fWeightK            Weighting factor for the constant b-value model (using bayesian approach: nTestMethod == 3)
%   fWeightO            Weighting factor for our forecasting model (using bayesian approach: nTestMethod == 3)
%   fBValueO            b-value used for our forecasting model
%   vProbK              log-likelihoods of the constant b-value model
%   vProbO              log-likelihoods of our forecasting model
%   mPredictionFMD      Forecasted FMD of both models (mPredictionFMD(:,1) our forecasting model, (:,2) constant b-value model)
%
% Danijel Schorlemmer
% Mai 7, 2002

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Index description
% xxxxK : Variable with a value for the constant b-value model
% xxxxO : Variable with a value for our forecasting model

try
  % Set the weighting values in case nTestMethod == 1 | nTestMethod == 2 for returning them
  fWeightK = 0;
  fWeightO = 0;
  fBValueO = nan;
  % If no earthquake occured during the learning period
  % return fixed values (don't even calculate the models)
  if length(mLearningCatalog(:,1)) == 0
    if nTestMethod == 1
      fDeltaProbability = nan;
      fProbabilityK = nan;
      fProbabilityO = nan;
    else % nTestMethod == 2 | nTestMethod == 3
      fDeltaProbability = 0;
      fProbabilityK = -inf;
      fProbabilityO = -inf;
    end
  else
    if ((nTestMethod == 1) | (nTestMethod == 2))
      if length(mLearningCatalog(:,1)) > nMinimumNumber
        [fMean fBValueO fStdDevO,  fAValueO] = bmemag(mLearningCatalog);
        % Prevent from non calculated nodes
        if isnan(fBValueO)
          if nTestMethod == 1
            fDeltaProbability = nan;
            fProbabilityK = nan;
            fProbabilityO = nan;
            return;
          else % nTestMethod == 2
            fBValueO = fBValueK;
          end
        end
      else
        if nTestMethod == 1
          fDeltaProbability = nan;
          fProbabilityK = nan;
          fProbabilityO = nan;
          return;
        else % nTestMethod == 2
          fBValueO = fBValueK;
        end
      end
    else % nTestMethod == 3
      if length(mLearningCatalog(:,1)) > nMinimumNumber
        % Get the b-value
        [fMean fBValueO fStdDevO,  fAValueO] =  bmemag(mLearningCatalog);
        % Determine the b-value of our model using the bayesian approach
        fWeightK = fStdDevK / (fStdDevK + fStdDevO);
        fWeightO = fStdDevO / (fStdDevK + fStdDevO);
        fBValueO = (fWeightK * fBValueO) + (fWeightO * fBValueK);   % This is the new b-value
        fStdDevO = fStdDevK * fWeightO;
      else
        fBValueO = fBValueK;
      end
    end
    % Get thea-value
    fAValueO = log10(length(mLearningCatalog(:,1))) + (fBValueO * fMc);
    % Compute the maximum likelihooda-value for the constant b-value model
    vSel = mLearningCatalog(:,6) >= fMc;
    mCalcACatalog = mLearningCatalog(vSel,:);
    [fAValueK] = calc_AValueFixedB(mCalcACatalog, fBValueK);
    % Test shouldn't start with magnitudes lower than Mc
    if fMinMag < fMc
      fMinMag = fMc;
    end
    % Create the predicted FMD
    vCnt = (fMinMag:0.1:fMaxMag+0.1)'; % Add one more magnitude bin for later use of diff()
    vNumberO = 10.^(fAValueO - (fBValueO * vCnt))/fLearningTime * fObservedTime;
    vNumberK = 10.^(fAValueK - (fBValueK * vCnt))/fLearningTime * fObservedTime;
    mNumbers = [vNumberO vNumberK];
    % Determine the number of events in each magnitude bin
    mPredictionFMD = -diff(mNumbers);
    % Create the FMD for the period of observation
    vObservedFMD = histogram(mObservedCatalog(:,6), fMinMag:0.1:fMaxMag);
    % Calculate the likelihoods for both of the models
    vProbO = calc_log10poisspdf(vObservedFMD', mPredictionFMD(:,1));
    vProbK = calc_log10poisspdf(vObservedFMD', mPredictionFMD(:,2));
    % Return the values
    fProbabilityK = sum(vProbK);
    fProbabilityO = sum(vProbO);
    fDeltaProbability = fProbabilityO - fProbabilityK;
  end
catch
  fDeltaProbability = nan;
  fProbabilityK = nan;
  fProbabilityO = nan;
end
