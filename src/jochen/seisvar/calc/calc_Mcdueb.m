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
    
    
    %column indexes for use with mBvalue
    BVAL = 1; BSTD = 2; AVAL = 3; MAG = 4; %unused is COUNT = 5;
   
    
    % Calculate b-with magnitude
    [mBvalue] = calc_bwithmag(magnitudes, fBinning, nMinNumberEvents);
    
    % Remove NANs
    mBvalue = mBvalue( ~isnan(mBvalue(:,BVAL)) , : );
    
    % Use Shi & Bolt uncertainty to decide for Mc
    bAverages = movmean(mBvalue(:,BVAL) , nWindowSize, 'Endpoints','discard');
    calcRange = 1:length(bAverages);
    mBvalue = mBvalue(calcRange, 1:4);
    
    theseBvals = mBvalue(:, BVAL);
    theseBStds = mBvalue(:, BSTD);
    
    % Criterion: If fBave is in in between the error estimate of the b-value of the first cut-off magnitude
    % take it as guess
    goodSteps = abs(bAverages - theseBvals) <= theseBStds;
    latest_good = find(goodSteps,1,'last');
    if ~isempty(latest_good)
        fMc     = mBvalue( latest_good, MAG);
        fBvalue = mBvalue( latest_good, BVAL);
        fAvalue = mBvalue( latest_good, AVAL);
        fBStd   = mBvalue( latest_good, BSTD);
    else
        fMc     = nan;
        fBvalue = nan;
        fAvalue = nan;
        fBStd   = nan;
    end
end