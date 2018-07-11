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
    % mCatalog         : EQ catalog magnitudes
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
    if nargin == 0, error('No catalog input'); end
    if nargin == 1, fBinning = 0.1; nWindowSize = 5; nMinNumberEvents = 50; nSample = 100;
        disp('Default Bin size: 0.1, Windowsize = 5, Minimum number of events: 50, Bootstrap samples = 100');end;
    if nargin == 2, nWindowSize = 5; nMinNumberEvents = 50; nSample = 100;
        disp('Default Windowsize = 5, Minimum number of events: 50, Bootstrap samples = 100');end;
    if nargin == 3, nMinNumberEvents = 50; nSample = 100; disp('Default Bootstrap samples = 100');end;
    if nargin == 4, nSample = 100; disp('Default Minimum number of events: 50, Bootstrap samples = 100');end;
    if nargin > 5 disp('Too many arguments!'), return; end
    
    % Initialize
    fMc = NaN;
    fBvalue = NaN;
    mBvalue = [];
    mBvalue_bst = [];
    mBave = [];
    mMcBA = [];
    
    % Set fix values
    fMinMag = min(magnitudes);
    fMaxMag = max(magnitudes);
    
    % Create bootstrap samples using bootstrap matlab toolbox
    mMag_bstsamp = bootrsp(magnitudes,nSample);
    
    % Calculate b-with magnitude
    for fMag=fMinMag:fBinning:fMaxMag
        for nSamp=1:nSample
            sampmagnitudes = mMag_bstsamp(:,nSamp);
            % Select magnitude range
            vSel = sampmagnitudes >= fMag-0.05;
            mCat = sampmagnitudes.subset(vSel);
            % Check for minimum number of events
            if mCat.Count >= nMinNumberEvents
                try
                    [ fBValue, fStdDev, fAValue] =  calc_bmemag(mCat, fBinning);
                    mBvalue_bst = [mBvalue_bst; fBValue fStdDev fAValue fMag];
                catch
                    mBvalue_bst = [mBvalue_bst; NaN NaN NaN fMag];
                end
            else
                mBvalue_bst = [mBvalue_bst; NaN NaN NaN fMag];
            end
        end
        
        % Check for Nan and create output for [16 84]-percentile
        vSel = isnan(mBvalue_bst(:,1));
        mBvalue_bst_tmp = mBvalue_bst(~vSel,:);
        if (~isempty(isempty(mBvalue_bst_tmp(:,1))) &&  length(mBvalue_bst_tmp(:,1)) > 1)
            vSigma = prctile(mBvalue_bst_tmp(:,1),[16 84]);
        elseif (~isempty(mBvalue_bst_tmp(:,1))  &&  length(mBvalue_bst_tmp(:,1)) == 1)
            vSigma = prctile(mBvalue_bst_tmp(:,1),[16 84]);
            vSigma = vSigma';
        else
            vSigma = [NaN NaN];
        end
        % Calculate 2nd moment
        if ~isempty(mBvalue_bst_tmp(:,1))
            fStdBst = std(mBvalue_bst_tmp(:,1),1,'omitnan');
        else
            fStdBst = NaN;
        end
        
        try
            % mBvalue: b std_bolt(b) a Mc 16-perc 18-perc std(b_2nd moment)
            mBvalue = [mBvalue; nanmean(mBvalue_bst) vSigma fStdBst];
        catch
            mBvalue = [mBvalue; NaN NaN NaN NaN NaN NaN NaN];
        end
        mBvalue_bst =[];
    end % END of FOR fMag
    
    % Use bootstrap percentiles to decide for Mc
    for nStep = 1:(length(mBvalue(:,1))-nWindowSize)
        fBave = mean(mBvalue(nStep:nStep+nWindowSize,1));
        mBave = [mBave; fBave mBvalue(nStep,:)];
        % Criterion: If fBave is in in between the error estimate of the b-value of the first cut-off magnitude
        % take it as guess
        if (fBave >= mBvalue(nStep,5) & fBave <= mBvalue(nStep,6))
            mMcBA = [mMcBA; fBave mBvalue(nStep,:)];
        end
    end
    
    % Create output
    try
        fMc = mMcBA(1,5);
        fBvalue = mMcBA(1,2);
        fAvalue = mMcBA(1,4);
        fBStd = mMcBA(1,8);
        fSigmaLow = mMcBA(1,6);
        fSigmaHi = mMcBA(1,7);
    catch
        fMc = NaN;
        fBvalue = NaN;
        fAvalue = NaN;
        fBStd = NaN;
        fSigmaLow = NaN;
        fSigmaHi = NaN;
    end
end
