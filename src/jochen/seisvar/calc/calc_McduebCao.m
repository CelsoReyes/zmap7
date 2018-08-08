function [fMc, fBvalue, fBStd, fAvalue] = calc_McduebCao(magnitudes, varargin)
    % CALC_MCDUEBCAO Calculate Mc using the function b-value vs. cut-off-magnitude
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
    
    
    %column indexes for use with mBvalue
    BVAL = 1; BSTD = 2; AVAL = 3; MAG = 4; %unused is COUNT = 5;
    
    % Calculate b-with magnitude
    [mBvalue] = calc_bwithmag(magnitudes, fBinning, nMinNumberEvents);
    
    % Remove NANs
    mBvalue = mBvalue( ~isnan(mBvalue(:,BVAL)) , : );
    
    % Use Shi & Bolt uncertainty to decide for Mc
    % Criterion: If bi+1 - bi < 0.03, then use bi as b-value and cut-off magnitude as Mc
    deltaB = mBvalue(2:end, BVAL) - mBvalue(1:end-1, BVAL);
    idx = [deltaB <= 0.03; false];
    mMcBA = mBvalue(idx, 1:4);
    
    % Create output
    if ~isempty(mMcBA)
        fMc =       mMcBA(1,MAG);
        fBvalue =   mMcBA(1,BVAL);
        fAvalue =   mMcBA(1,AVAL);
        fBStd =     mMcBA(1,BSTD);
    else
        fMc = nan;
        fBvalue = nan;
        fAvalue = nan;
        fBStd = nan;
    end
end