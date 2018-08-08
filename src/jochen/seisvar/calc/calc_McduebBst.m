function [fMc, fBvalue, fBStd, fAvalue, fSigmaLow, fSigmaHi, mBave, mBvalue] = calc_McduebBst(magnitudes, fBinning, nWindowSize, nMinNumberEvents, nSample)
% calc_McduebBst  Calculate Mc using the function b-value vs. cut-off-magnitude: Bootstrap approach
    % [fMc, fBvalue, fBStd, fAvalue, fSigmaLow, fSigmaHi, mBave, mBvalue] = calc_McduebBst(mCatalog, fBinning, nWindowSize, nMinNumberEvents, nSample)
    %-------------------------------------------------------------------------------------------------------
    % Calculate Mc using the function b-value vs. cut-off-magnitude: Bootstrap approach
    % Decision criterion for b and Mc: b_i-std_Bst(b_i) <= b_ave <= b_i+std_Bst(b_i)
    
    % Relevant reference: Cao A., Gao, S.S., Temporal variation of seismic b-values
    % beneath northeastern Japan island arc, GRL, 29, 9, 2002
    %
    % Incoming variables:
    % magnitudes         : EQ catalog magnitudes
    % fBinning         : Bin size
    % nWindowSize      : Window size
    % nMinNumberEvents : Minimum number of events
    % nSample          : Number of bootstrap samples
    %
    % Outgoing variables:
    % fMc              : Magnitude of completeness
    % fBvalue          : b-value
    % fBStd            : 2nd moment of b-value-distribution (comparable to standard deviation)
    % fAvalue          :a-value
    % fSigmaLow        : 16-percentile of b-value distribution
    % fSigmaHi         : 84-percentile of b-value distribution
    % mBave            : Result matrix for plotting (average values)
    % mBvalue          : Result matrix for plotting
    % Author: J. Woessner
    % updated: 04.06.03
    
    % Check input
    p=inputParser;
    p.addOptional('fBinning',0.1);
    p.addOptional('nWindowSize',5);
    p.addOptional('nMinNumberEvents',50);
    p.addOptional('nSample',100);
    p.parse(fBinning, nWindowSize, nMinNumberEvents, nSample);
    
    fBinning            = p.Results.fBinning;
    nWindowSize         = p.Results.nWindowSize;
    nMinNumberEvents    = p.Results.nMinNumberEvents;
    nSample             = p.Results.nSample;
    
    
    % Set fix values
    fMinMag = min(magnitudes);
    fMaxMag = max(magnitudes);
    
    % Create bootstrap samples using bootstrap matlab toolbox
    mMag_bstsamp = bootrsp(magnitudes,nSample);
    
    % Calculate b-with magnitude
    magBins = fMinMag:fBinning:fMaxMag; 
    
    mBvalue = nan(numel(magBins), 7);
    
    for i = 1:numel(magBins)
        fMag = magBins(i);
        mBvalue_bst = nan(nSample, 4); % resets each pass
        
        magMask = mMag_bstsamp >= fMag - 0.05;
        
        for nSamp=1:nSample
            idx = (i-1)*nSample + nSamp;
            bvalIsNan = magMask(:,nSamp);
            mCat = mMag_bstsamp(bvalIsNan,nSamp);
            %{
            sampmagnitudes = mMag_bstsamp(:,nSamp);
            % Select magnitude range
            vSel = sampmagnitudes >= fMag-0.05;
            mCat = sampmagnitudes(vSel);
            %}
            % Check for minimum number of events
            
            mBvalue_bst(idx,4) = fMag;
            
            if numel(mCat) >= nMinNumberEvents
                try
                    [ fBValue, fStdDev, fAValue] =  calc_bmemag(mCat, fBinning);
                    mBvalue_bst( idx, 1:3) = [fBValue fStdDev fAValue];
                catch ME
                    warning(ME.message);
                end
            end
        end
        
        % Check for Nan and create output for [16 84]-percentile
        bvalIsNan = isnan(mBvalue_bst(:,1));
        bvalOnly = mBvalue_bst(~bvalIsNan, 1);
        if (~isempty(isempty(bvalOnly)) &&  length(bvalOnly) > 1)
            vSigma = prctile(bvalOnly,[16 84]);
        elseif (~isempty(bvalOnly)  &&  length(bvalOnly) == 1)
            vSigma = prctile(bvalOnly,[16 84]);
            vSigma = vSigma';
        else
            vSigma = [NaN NaN];
        end
        % Calculate 2nd moment
        if ~isempty(bvalOnly)
            fStdBst = std(bvalOnly,1,'omitnan');
        else
            fStdBst = NaN;
        end
        
        % mBvalue: b std_bolt(b) a Mc 16-perc 18-perc std(b_2nd moment)
        try
            mBvalue(i,:) = [nanmean(mBvalue_bst) vSigma fStdBst];
        catch ME
            warning(ME.message)
        end
        
    end % END of FOR fMag
    
    % Use bootstrap percentiles to decide for Mc
    totalSteps = size(mBvalue,1) - nWindowSize;
    mBave = nan(totalSteps, 1 + size(mBvalue,2));
    mMcBA = nan(totalSteps, 1 + size(mBvalue,2)); % maximum likely size
    idx = 0; % because mMcBA doesn't necessarily grow at every step, we track it separately
    for nStep = 1 : totalSteps
        fBave = mean(mBvalue(nStep : nStep+nWindowSize, 1));
        mBave(nStep,:) = [fBave mBvalue(nStep,:)];
        % Criterion: If fBave is in in between the error estimate of the b-value of the first cut-off magnitude
        % take it as guess
        if (fBave >= mBvalue(nStep,5) && fBave <= mBvalue(nStep,6))
            idx = idx + 1;
            mMcBA(idx,:) = [fBave mBvalue(nStep,:)];
        end
    end
    
    mMcBA = mMcBA(1:idx,:); % chop off unused portion
    
    % Create output
    
    if ~isempty(mMcBA)
        fMc         = mMcBA(1,5);
        fBvalue     = mMcBA(1,2);
        fAvalue     = mMcBA(1,4);
        fBStd       = mMcBA(1,8);
        fSigmaLow   = mMcBA(1,6);
        fSigmaHi    = mMcBA(1,7);
    else
        
        fMc         = NaN;
        fBvalue     = NaN;
        fAvalue     = NaN;
        fBStd       = NaN;
        fSigmaLow   = NaN;
        fSigmaHi    = NaN;
    end
end
