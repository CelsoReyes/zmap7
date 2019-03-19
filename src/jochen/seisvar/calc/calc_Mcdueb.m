function [fMc, fBvalue, fBStd, fAvalue] = calc_Mcdueb(magnitudes, varargin)
    % Calculate Mc using the function b-value vs. cut-off-magnitude
    % [fMc, fBvalue, fBStd, fAvalue] = calc_Mcdueb(magnitudes, fBinning, nWindowSize, nMinNumberEvents)
    %----------------------------------------------------------------------------------------------------
    
    % Decision criterion for b and Mc: b_i-std_Shi(b_i) <= b_ave <= b_i+std_Shi(b_i)
    %
    % Relevant reference: Cao A., Gao, S.S., Temporal variation of seismic b-values
    % beneath northeastern Japan island arc, GRL, 29, 9, 2002
    %
    % Incoming variables:
    % mCatalog         : EQ catalog magnitudes
    % fBinning         : Bin size
    % nWindowSize      : Window size
    % nMinNumberEvents : Minimum number of events
    %
    % Outgoing variables:
    % fMc              : Magnitude of completeness
    % fBStd            : Shi & Bolt deviation for b
    % fBvalue          : b-value
    % fAvalue          :a-value
    %
    % Author: J. Woessner updated: 04.06.03
    % Modified CGReyes 2018
    
    % Check input
    p=inputParser();
    p.addRequired('magnitudes');
    p.addOptional('binInterval',0.1);
    p.addOptional('windowSize',5);
    p.addOptional('minNumberEvents',50);
    p.parse(magnitudes, varargin{:});
    
    magnitudes =        p.Results.magnitudes;
    fBinning =          p.Results.binInterval;
    nWindowSize =       p.Results.windowSize;
    nMinNumberEvents =  p.Results.minNumberEvents;
    
    
    if isrow(magnitudes)
        magnitudes=magnitudes';
    end
    
    
    %TODO: vectorize properly.
    for j=1:size(magnitudes,2)
        [fMc(j), fBvalue(j), fBStd(j), fAvalue(j)] = do_calculation(j);
    end
    
    function [fMc, fBvalue, fBStd, fAvalue] = do_calculation(idx)
        these_mags = magnitudes(~isnan(magnitudes(:,idx)));
        
        % Calculate b-with magnitude
        
        [bv, bstd, aval, mags] = calc_bwithmag(these_mags, fBinning, nMinNumberEvents);
        
        to_remove = isnan(bv);
        bv(to_remove) = [];
        bstd(to_remove) = [];
        aval(to_remove) = [];
        mags(to_remove) = [];
        
        % Remove NANs
        
        % Use Shi & Bolt uncertainty to decide for Mc
        bAverages = movmean(bv , nWindowSize, 'Endpoints', 'discard');
        calcRange = 1:length(bAverages);
        
        theseBvals = bv(calcRange);
        theseBStds = bstd(calcRange);
        
        % Criterion: If fBave is in in between the error estimate of the b-value of the first cut-off magnitude
        % take it as guess
        goodSteps = abs(bAverages - theseBvals) <= theseBStds;
        latest_good = find(goodSteps,1,'last');
        
        if ~isempty(latest_good)
            fMc     = mags(latest_good);
            fBvalue = bv(latest_good);
            fAvalue = aval(latest_good);
            fBStd   = bstd(latest_good);
        else
            fMc     = nan;
            fBvalue = nan;
            fAvalue = nan;
            fBStd   = nan;
        end
    end
end