function [fDeltaProbability, fProbabilityK, fProbabilityO, fWeightK, fWeightO, fBValueO, vProbK, vProbO, mPredictionFMD] = kj_poissonian(mLearningCatalog, fLearningTime, mObservedCatalog, fObservedTime, nTestMethod, nMinimumNumber, fMc, fBValueK, fStdDevK, fMinMag, fMaxMag, bFull)
    % Calculate log-likelihoods of Kagan & Jackson forecasting model, our forecasting model, and the difference between these two models.
    %
    % [fDeltaProbability, fProbabilityK, fProbabilityO, fWeightK, fWeightO, fBValueO, vProbK, vProbO]...
    %   = kj_poissonian(mLearningCatalog, fLearningTime, mObservedCatalog, fObservedTime, nTestMethod,
    %                   nMinimumNumber, fMc, fBValueK, fStdDevK, fMinMag, fMaxMag, bFull)
    %
    %
    % Calculation of the log-likelihoods of the Kagan & Jackson forecasting model, our forecasting model,
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
    %   fBValueK            Overall b-value for the Kagan & Jackson forecasting model
    %   fStdDevK            Standard deviation of the overall b-value
    %   fMinMag             Minimum magnitude for testing
    %   fMaxMag             Maximum magnitude for testing
    %   bFull               Method to determine the log-likelihoods
    %                       0: Method without warnings. Every 0 is removed before applying the log(). Results in a shorten
    %                          vector of log-likelihoods. Faster.
    %                       1: Method with warnings. First the log() is applied and then the values of -inf are set to zero.
    %                          Slower, but complete vector of log-likelihoods.
    %
    % Output parameters:
    %   fDeltaProbability   Difference of the log-likelihood between both of the models
    %   fProbabilityK       Log-likelihood of the Kagan & Jackson model
    %   fProbabilityO       Log-likelihood of our model
    %   fWeightK            Weighting factor for the Kagan & Jackson model (using bayesian approach: nTestMethod == 3)
    %   fWeightO            Weighting factor for our model (using bayesian approach: nTestMethod == 3)
    %   fBValueO            B-value used for our model
    %   vProbK              log-likelihoods of the Kagan & Jackson model
    %   vProbO              log-likelihoods of our model
    %   mPredictionFMD      Forecasted FMD of both models (mPredictionFMD(:,1) our model, (:,2) Kagan & Jackson model)
    %
    % Danijel Schorlemmer
    % March 13, 2002
    
    report_this_filefun();
    
    % Index description
    % xxxxK : Variable with a value for the Kagan & Jackson model
    % xxxxO : Variable with a value for our model
    
    try
        % Set the weighting values in case nTestMethod == 1 | nTestMethod == 2 for returning them
        fWeightK = 0;
        fWeightO = 0;
        fBValueO = NaN;
        % If no earthquake occured during the learning period
        % return fixed values (don't even calculate the models)
        if isempty(mLearningCatalog(:,1))
            if nTestMethod == 1
                fDeltaProbability = NaN;
                fProbabilityK = NaN;
                fProbabilityO = NaN;
            else % nTestMethod == 2 | nTestMethod == 3
                fDeltaProbability = 0;
                fProbabilityK = -inf;
                fProbabilityO = -inf;
            end
        else
            if ((nTestMethod == 1) || (nTestMethod == 2))
                if length(mLearningCatalog(:,1)) > nMinimumNumber
                    [fBValueO fStdDevO] = calc_bmemag(mLearningCatalog.Magnitude, 0.1);
                    % Prevent from non calculated nodes
                    if isnan(fBValueO)
                        if nTestMethod == 1
                            fDeltaProbability = NaN;
                            fProbabilityK = NaN;
                            fProbabilityO = NaN;
                            return;
                        else % nTestMethod == 2
                            fBValueO = fBValueK;
                        end
                    end
                else
                    if nTestMethod == 1
                        fDeltaProbability = NaN;
                        fProbabilityK = NaN;
                        fProbabilityO = NaN;
                        return;
                    else % nTestMethod == 2
                        fBValueO = fBValueK;
                    end
                end
            else % nTestMethod == 3
                if length(mLearningCatalog(:,1)) > nMinimumNumber
                    % Get the b-value
                    [fBValueO fStdDevO] = calc_bmemag(mLearningCatalog.Magnitude, 0.1);
                    % Determine the b-value of our model using the bayesian approach
                    fWeightK = fStdDevK / (fStdDevK + fStdDevO);
                    fWeightO = fStdDevO / (fStdDevK + fStdDevO);
                    fBValueO = (fWeightK * fBValueO) + (fWeightO * fBValueK);   % This is the new b-value
                    fStdDevO = fStdDevK * fWeightO;
                else
                    fBValueO = fBValueK;
                end
            end
            % Get the a-value
            fAValueO = log10(length(mLearningCatalog(:,1))) + (fBValueO * fMc);
            fAValueK = log10(length(mLearningCatalog(:,1))) + (fBValueK * fMc);
            % Calculate the number of events for both of the models
            mNumbers = [];
            % Test shouldn't start with magnitudes lower than Mc
            if fMinMag < fMc
                fMinMag = fMc;
            end
            % Create the predicted FMD
            vCnt = (fMinMag:0.1:fMaxMag)';
            vNumberO = 10.^(fAValueO - (fBValueO * vCnt))/fLearningTime * fObservedTime;
            vNumberK = 10.^(fAValueK - (fBValueK * vCnt))/fLearningTime * fObservedTime;
            mNumbers = [vNumberO vNumberK];
            % Determine the number of events in each magnitude bin
            mPredictionFMD = -diff(mNumbers);
            % Keep the length
            mPredictionFMD = [NaN NaN; mPredictionFMD];
            % Create the FMD for the period of observation
            vObservedFMD = histogram(mObservedCatalog(:,6), fMinMag:0.1:fMaxMag);
            % Calculate the likelihoods for both of the models
            vProbO = poisspdf(vObservedFMD', mPredictionFMD(:,1));
            vProbK = poisspdf(vObservedFMD', mPredictionFMD(:,2));
            % Choose whether a full or shortened vector of log-likelihoods should be calculated
            if bFull
                % Calculate the log-likelihood
                vProbK = log(vProbK);
                vProbO = log(vProbO);
                % Replace -inf from vProbX with zeros
                vSel = isinf(vProbK);
                vProbK(vSel) = 0;
                vSel = isinf(vProbO);
                vProbO(vSel) = 0;
            else
                % Remove zeros from vProbX avoiding warning messages during the log-function
                vSel   = (vProbO ~= 0);
                vProbO = vProbO(vSel);
                vSel   = (vProbK ~= 0);
                vProbK = vProbK(vSel);
                % Calculate the log-likelihood
                vProbO = log(vProbO);
                vProbK = log(vProbK);
            end
            % Return the values
            fProbabilityK = sum(vProbK);
            fProbabilityO = sum(vProbO);
            fDeltaProbability = fProbabilityO - fProbabilityK;
        end
    catch
        fDeltaProbability = NaN;
        fProbabilityK = NaN;
        fProbabilityO = NaN;
    end
end