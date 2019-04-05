function [fMc, fBvalue, fBStd, fAvalue, fSigmaLow, fSigmaHi] = calc_McduebBst(magnitudes, varargin)
    % calc_McduebBst  Calculate Mc using the function b-value vs. cut-off-magnitude: Bootstrap approach
    % [fMc, fBvalue, fBStd, fAvalue, fSigmaLow, fSigmaHi] = calc_McduebBst(mCatalog, fBinning, nWindowSize, nMinNumberEvents, nSample)
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
    % Author: J. Woessner
    % updated: 04.06.03
    
    % Check input
    p=inputParser;
    p.addOptional('fBinning',0.1);
    p.addOptional('nWindowSize',5);
    p.addOptional('nMinNumberEvents',50);
    p.addOptional('nSample',100);
    p.parse(varargin{:});
    
    PCTL_RANGE = [16, 84];
    
    fBinning            = p.Results.fBinning;
    nWindowSize         = p.Results.nWindowSize;
    nMinNumberEvents    = p.Results.nMinNumberEvents;
    nSample             = p.Results.nSample;
    
    
    % Set fix values
    fMinMag = min(magnitudes);
    fMaxMag = max(magnitudes);
    
    % Create bootstrap samples using bootstrap matlab toolbox
    deepdim = 1; % for deepdim = 1:size(magnitudes,2)
    mMag_bstsamp = bootrsp(magnitudes,nSample);
    % Calculate b-with magnitude
    magBins = fMinMag:fBinning:fMaxMag;
    nBins = numel(magBins);
    
    % mBvalue = nan(nBins, 7); % contains [meanb_value, meanb_value_std, meana_value vSigma(1) vSigma(2), fStdBst]
    mean_b_value     = nan(nBins,1);
    mean_b_value_std = nan(nBins,1);
    mean_a_value     = nan(nBins,1);
    mean_mag         = nan(nBins,1);
    sigmas           = nan(nSample,2);
    std_bst          = nan(nBins,1);
    
    for i = 1 : nBins
        fMag = magBins(i);
        mBvalue_bst = nan(nSample, 4); % resets each pass, contains [b_value, b_value_std, a_value, magvalue]
        
        magMask = mMag_bstsamp >= fMag - 0.05;
        
        idxs        = (i-1).* nSample + (1:nSample);
        b_value     = nan(nSample,1);
        b_value_std = nan(nSample,1);
        a_value     = nan(nSample,1);
        
        mBvalue_bst(idxs,4) = fMag; 
        for nSamp=1:nSample
            bvalIsNan = magMask(:, nSamp);
            mCat = mMag_bstsamp(bvalIsNan, nSamp);
            
            % Check for minimum number of events
            
            if numel(mCat) >= nMinNumberEvents
                [ b_value(nSamp), b_value_std(nSamp), a_value(nSamp)] =  calc_bmemag(mCat, fBinning);
            end
        end
        mBvalue_bst(idxs, 1:3) = [b_value, b_value_std, a_value];
        
        % Check for Nan and create output for [16 84]-percentile
        bvalIsNan   = isnan(b_value);
        bval_nonans = b_value(~bvalIsNan);
        
        if ~isempty(bval_nonans)
            vSigma = prctile(bval_nonans, PCTL_RANGE);
            if length(bval_nonans)==1
                vSigma = vSigma';
            end
            fStdBst = std(bval_nonans, 1, 'omitnan'); % Calculate 2nd moment
            
            sigmas(i,:)         = vSigma;
            std_bst(i)          = fStdBst;
        end
        
        mean_b_std_a_mag    = nanmean(mBvalue_bst);
        mean_b_value(i)     = mean_b_std_a_mag(1);
        mean_b_value_std(i) = mean_b_std_a_mag(2);
        mean_a_value(i)     = mean_b_std_a_mag(3);
        mean_mag(i)         = mean_b_std_a_mag(4);
        
        % mBvalue(i,:) = [nanmean(mBvalue_bst), vSigma(1), vSigma(2), fStdBst]; % contains [meanb_value, meanb_value_std, meana_value, meanmag, vSigma(1), vSigma(2), fStdBst]
        
    end % END of FOR fMag
    
    % Use bootstrap percentiles to decide for Mc
    totalSteps = nBins - nWindowSize + 1;
    
    b_avg       = movmean(mean_b_value, nWindowSize, 'Endpoints','discard');
    keeprows    = sigmas(1:totalSteps, 1) <= b_avg & b_avg <= sigmas(1:totalSteps, 2);
    
    % b_avg       = b_avg(keeprows); % apply to b_avg before changing it's size
    
    keeprows(nBins) = false; % OK, because len(keeprows) (aka. totalsteps) is always less than nBins
    fMc         = mean_mag(keeprows);
    fBvalue     = mean_b_value(keeprows);
    fAvalue     = mean_a_value(keeprows);
    fBStd       = mean_b_value_std(keeprows);
    fSigmaLow   = sigmas(keeprows, 1);
    fSigmaHi    = sigmas(keeprows, 2);
        

end
