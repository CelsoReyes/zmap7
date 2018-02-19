function [fMc, fBvalue, fBStd, fAvalue, mBave] = calc_Mcdueb(mCatalog, fBinning, nWindowSize, nMinNumberEvents)
    % [fMc, fBvalue, fBStd, fAvalue, mBave] = calc_Mcdueb(mCatalog, fBinning, nWindowSize, nMinNumberEvents)
    %----------------------------------------------------------------------------------------------------
    % Calculate Mc using the function b-value vs. cut-off-magnitude
    % Decision criterion for b and Mc: b_i-std_Shi(b_i) <= b_ave <= b_i+std_Shi(b_i)
    %
    % Relevant reference: Cao A., Gao, S.S., Temporal variation of seismic b-values
    % beneath northeastern Japan island arc, GRL, 29, 9, 2002
    %
    % Incoming variables:
    % mCatalog         : EQ catalog
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
    if nargin == 0, error('No catalog input'); end
    if nargin == 1, fBinning = 0.1; nWindowSize = 5; nMinNumberEvents = 50; disp('Default Bin size: 0.1, Windowsize = 5, Minimum number of events: 50');end;
    if nargin == 2, nWindowSize = 5; nMinNumberEvents = 50; disp('Default Windowsize = 5, Minimum number of events: 50');end;
    if nargin == 3, nMinNumberEvents = 50; disp('Default Minimum number of events: 50');end;
    if nargin > 4, disp('Too many arguments!'), return; end
    
    
    % Calculate b-with magnitude
    [mBvalue] = calc_bwithmag(mCatalog, fBinning, nMinNumberEvents);
    B_MAG_ASC = 1; % mBvalue(:,1) : b-values ascending with magnitude
    B_STD = 2;  % mBvalue(:,2) : Standard deviation of b (Shi & Bolt, 1982) ascending with magnitude
    A_MAG_ASC = 3;  % mBvalue(:,3) : a-values ascending with magnitude
    MAG_ASC = 4;% mBvalue(:,4) : Ascending magnitudes
    % N_GREATER=5; % mBvalue(:,5) : Number of events above magnitude cut-off
    
    % Remove NANs
    vSel = isnan(mBvalue(:,B_MAG_ASC));
    mBvalue = mBvalue(~vSel,:);
    nItems = size(mBvalue,1);
    
    mBave= nan( nItems-nWindowSize, 5 );
    
    latest_good=0;
    % Use Shi & Bolt uncertainty to decide for Mc
    for nStep = 1:(nItems - nWindowSize)
        thisPart = mBvalue(nStep, B_MAG_ASC:MAG_ASC );
        fBave = mean( mBvalue( nStep:nStep+nWindowSize , B_MAG_ASC));
        
        mBave(nStep,:) = [ fBave , thisPart ];
        % Criterion: If fBave is in in between the error estimate of the b-value of the first cut-off magnitude
        % take it as guess
        % NOTE: it looks like this runs multiple times, with only the last one being returned - CGR
        if (abs (fBave - thisPart(B_MAG_ASC)) <= thisPart(B_STD))
            latest_good = nStep;
        end
    end
    
    if latest_good > 0
        thisPart=mBvalue( latest_good, : );
        fMc = thisPart(MAG_ASC);
        fBvalue = thisPart(B_MAG_ASC);
        fAvalue = thisPart(A_MAG_ASC);
        fBStd = thisPart(B_STD);
    else
        
        fMc = nan;
        fBvalue = nan;
        fAvalue = nan;
        fBStd = nan;
    end
    
end