function [aValue] = calc_AValueFixedB(magnitudes, bValue)
    % function [fAValue] = calc_AValueFixedB(mCatalog, bValue)
    % ---------------------------------------------------------
    % Calculates the maximum likelihood a-value for a given
    %   catalog and given b-value. The Catalog has to be complete
    %   down to the smalles magnitude: Mc=Mmin
    %
    % Input parameters:
    %   mCatalog    earthquake catalog (complete down to minimum magnitude)
    %   bValue     Predetermined b-value
    %
    % Output parameters:
    %   fAValue     Maximum likelihooda-value
    %
    % Danijel Schorlemmer
    % July 1, 2002
    
    % Find minimum of negative log-likelihoods
    [aValue, ~, exitFlag] = fminbnd(@calc_LogLikelihoodAValue, 0.01, 10, [], magnitudes, bValue);
    % exitFlag will be 1 if fminbnd converges
    
    % If search doesn't converge, extrapolate a-value from magnitude of completeness
    if exitFlag ~= 1
        minMag = min(magnitudes);
        aValue = log10(length(magnitudes)) + (bValue * minMag);
    end
    
end

function [fProbability] = calc_LogLikelihoodAValue(fAValue, magnitudes, fBValue)
    % function [fProbability] = calc_LogLikelihoodAValue(fAValue, magnitudes, fBValue)
    % ------------------------------------------------------------------------------
    %   Computes the negative log-likelihood of a given a- and b-value for a given catalog
    %
    % Input parameters:
    %   fAValue         Predetermineda-value
    %   magnitudes      Earthquake catalog magnitudes
    %   fBValue         Predetermined b-value;
    %
    % Output parameters:
    %   fProbability    Negative log-likelihood of the given a- and b-value for the given catalog
    %
    % Danijel Schorlemmer
    % July 1, 2002
    
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
end