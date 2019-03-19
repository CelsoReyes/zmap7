function [fMc, fBvalue, fBStd, fAvalue] = calc_McduebCao(magnitudes, varargin)
    % Calculate Mc using the function b-value vs. cut-off-magnitude
    %
    % [fMc, fBvalue, fBStd, fAvalue] = calc_McduebCao(magnitudes, fBinning, nMinNumberEvents)
    %----------------------------------------------------------------------------------------------------
    % Calculate Mc using the function b-value vs. cut-off-magnitude
    % Decision criterion for Mc and b is: b_i - b_i-1 <= 0.03 as in reference
    %
    % Reference: Cao A., Gao, S.S., Temporal variation of seismic b-values
    % beneath northeastern Japan island arc, GRL, 29, 9, 2002
    %
    % Incoming variables:
    % magnitudes       : EQ catalog magnitudes
    % fBinning         : Bin size
    % nMinNumberEvents : Minimum number of events
    %
    % Outgoing variables:
    % fMc              : Magnitude of completeness
    % fBStd            : Shi & Bolt standard deviation of b
    % fBvalue          : b-value
    % fAvalue          :a-value
    %
    % Author: J. Woessner
    
    % Check input
    
    p=inputParser();
    p.addRequired('magnitudes');
    p.addOptional('binInterval',0.1);
    p.addOptional('minNumberEvents',50);
    p.parse(magnitudes, varargin{:});
    
    magnitudes = p.Results.magnitudes;
    fBinning = p.Results.binInterval;
    nMinNumberEvents = p.Results.minNumberEvents;
        
    if isrow(magnitudes)
        magnitudes=magnitudes';
    end
    
    %TODO: vectorize properly.
    for j=1:size(magnitudes,2)
        [fMc(j), fBvalue(j), fBStd(j), fAvalue(j)] = do_calculation(j);
    end
    
    function [fMc, fBvalue, fBStd, fAvalue] = do_calculation(idx)
        % Calculate b-with magnitude
        these_mags = magnitudes(~isnan(magnitudes(:,idx)));
        [bv, bstd, aval, mags] = calc_bwithmag(these_mags, fBinning, nMinNumberEvents);
        to_remove = isnan(bv);
        bv(to_remove) = [];
        bstd(to_remove) = [];
        aval(to_remove) = [];
        mags(to_remove) = [];
        % Remove NANs
        
        % Use Shi & Bolt uncertainty to decide for Mc
        % Criterion: If bi+1 - bi < 0.03, then use bi as b-value and cut-off magnitude as Mc
        deltaB = bv(2:end) - bv(1:end-1);
        idx = find([deltaB <= 0.03; false],1);
        if ~isempty(idx)
            fMc = mags(idx);
            fBvalue = bv(idx);
            fAvalue = aval(idx);
            fBStd = bstd(idx);
        else
            fMc = nan;
            fBvalue = nan;
            fAvalue = nan;
            fBStd = nan;
        end
    end
end