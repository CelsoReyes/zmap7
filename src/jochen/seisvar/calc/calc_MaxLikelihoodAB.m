function [fBValue, fAValue] = calc_MaxLikelihoodAB(mCatalog, mControl)
    % function [fBValue, fAValue] = calc_MaxLikelihoodAB(mCatalog, mControl, bReBin)
    % ------------------------------------------------------------------------------
    % Computes the maximum likelihood a- and b-values for a set of given catalogs.
    %
    % Input parameters:
    %   mCatalog        Catalog containing different periods with varying
    %                   magnitude of completeness
    %   mControl        Controlmatrix containing informations about the single catalogs
    %                   mControl(n,:) contains information about caCatalogs{n}
    %                   Column 1: Starting time of catalog
    %                   Column 2: Magnitude of completeness
    %                   Column 3: Starting magnitude bin
    %                   Column 4: Magnitude bin stepsize (must be 0.1)
    %   bReBin          REMOVED OPTION since it must always be 0 (false)
    
    %
    % Output parameters:
    %   fBValue         Maximum likelihood b-value
    %   fAValue         Maximum likelihood a-value
    %
    % Danijel Schorlemmer
    % July 5, 2002
    
    startTimes = mControl(:,1);
    McValues = mControl(:,2);
    
    % Get the number of different periods in the catalog
    nCats = size(mControl,1);
    
    caCatalogs_ = cell(nCats,1);
    
    % Init vector with ending times for each period
    maxTimes = zeros(nCats, 1);
    
    % Determine ending time of each period, and add to control matrix
    maxTimes(1:nCats-1) = startTimes(2:nCats);
    maxTimes(nCats) = max(mCatalog.Date);
    mControl(:,5) = maxTimes;
    
    % Loop over the control matrix
    for idx = 1:nCats
        % Determine starting time of period
        minTime = startTimes(idx);
        maxTime = maxTimes(idx);
        % Create subcatalog for period
        theseMags = mCatalog.Magnitude((mCatalog.Date >= minTime) & (mCatalog.Date < maxTime));
        
        % Store the subcatalog at magnitude of completeness
        caCatalogs_{idx} = theseMags(theseMags >= McValues(idx));
    end
    % Set the callback starting values
    vStartValues = [1; 1];
    % Find the maximum likelihood solution
    [vValues, ~, ~] = fminsearch(@callback_LogLikelihoodABValue, vStartValues, [], caCatalogs_, mControl);
    % Return values
    fAValue = vValues(1);
    fBValue = vValues(2);
end


function [fProbability] = callback_LogLikelihoodABValue(vValues, caMags, mControl)
    % function [fProbability] = callback_LogLikelihoodABValue(vValues, caCatalogs, mControl)
    % --------------------------------------------------------------------------------------
    % Helper callback-function for calc_MaxLikelihoodAB.m
    %   Computes the negative log-likelihood sum of a given a- and b-value for a
    %   set of given catalogs
    %
    % Input parameters:
    %   vValues         Vector with a- and b-value (vValues(1) =a-value, vValues(2) = b-value)
    %   caMags      Cell array containing magnitudes for each catalog
    %   mControl        Controlmatrix containing informations about the single catalogs
    %                   mControl(n,:) contains information about caCatalogs{n}
    %                   Column 1: Starting time of catalog
    %                   Column 2: Magnitude of completeness
    %                   Column 3: Starting magnitude bin
    %                   Column 4: Magnitude bin stepsize (must be 0.1)
    %                   Column 5: Ending time of catalog
    %
    % Output parameters:
    %   fProbability    Negative log-likelihood of the given a- and b-value for the set of given catalogs
    %
    % Danijel Schorlemmer
    % July 5, 2002
    
    startTimes = mControl(:,1);
    McValues = mControl(:,2);
    magStepSizes = mControl(:,4);
    maxTimes = mControl(:,5);
    
    % Get the number of different periods in the catalog
    nCats = size(mControl,1);
    
    totalDuration = maxTimes(nCats) - startTimes(1);
    
    vProbabilities = zeros(length(caMags),1);
    
    eachDuration = maxTimes - startTimes;
    durationRatios = eachDuration / totalDuration;
    all_fA = vValues(1) + log10(durationRatios);
    % Loop over all catalogs
    for n = 1:length(caMags)
        % Extract catalog from cell array
        mags = caMags{n};
        if isempty(mags)
            return
        end
        
        % Determine maximum magnitude of catalog
        maxMag = max(mags);
        % Set up vector of available magnitude bins
        
        vCnt_ = (McValues(n):magStepSizes(n):(maxMag+magStepSizes(n)))'; % Add one more magnitude bin for later use of diff()
 
        % Compute lengths of periods and ajust the a-value
        fA_ = all_fA(n);
        
        % Compute the cumulative FMD
        vNumber_ = 10.^(fA_ - (vValues(2) * vCnt_));
        
        % Determine the number of events in each magnitude bin
        mPredictionFMD_ = -diff(vNumber_);
        
        % Create the FMD for the period of observation
        vObservedFMD_ = histogram(mags, McValues(n):magStepSizes(n):maxMag);
        
        % Calculate the likelihoods for both of the models
        vProb_ = calc_log10poisspdf(vObservedFMD_', mPredictionFMD_);
        % Return the values (multiply by -1 to return the lowest value for the highest probability
        vProbabilities(n) = sum(vProb_);
        
    end
    % Sum the probabilities for all given catalogs
    fProbability = (-1) * sum(vProbabilities);
end
