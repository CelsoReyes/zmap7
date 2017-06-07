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
% Author: J. Woessner
% last update: 04.06.03

% Check input
if nargin == 0, error('No catalog input'); end
if nargin == 1, fBinning = 0.1; nWindowSize = 5; nMinNumberEvents = 50; disp('Default Bin size: 0.1, Windowsize = 5, Minimum number of events: 50');end;
if nargin == 2, nWindowSize = 5; nMinNumberEvents = 50; disp('Default Windowsize = 5, Minimum number of events: 50');end;
if nargin == 3, nMinNumberEvents = 50; disp('Default Minimum number of events: 50');end;
if nargin > 4, disp('Too many arguments!'), return; end

% Initialize
fMc = nan;
fBvalue = nan;
mBave = [];
mMcBA = [];

% Calculate b-with magnitude
[mBvalue] = calc_bwithmag(mCatalog, fBinning, nMinNumberEvents);
% Remove NANs
vSel = isnan(mBvalue(:,1));
mBvalue = mBvalue(~vSel,:);

% Use Shi & Bolt uncertainty to decide for Mc
for nStep = 1:(length(mBvalue(:,1))-nWindowSize)
    fBave = mean(mBvalue(nStep:nStep+nWindowSize,1));
    mBave = [mBave; fBave mBvalue(nStep,1) mBvalue(nStep,2) mBvalue(nStep,3) mBvalue(nStep,4)];
    % Criterion: If fBave is in in between the error estimate of the b-value of the first cut-off magnitude
    % take it as guess
    if (fBave >= mBvalue(nStep,1)-mBvalue(nStep,2) & fBave <= mBvalue(nStep,1)+mBvalue(nStep,2))
        mMcBA = [mMcBA; fBave mBvalue(nStep,1) mBvalue(nStep,2) mBvalue(nStep,3) mBvalue(nStep,4)];
    end
end
% Create output
try
    fMc = mMcBA(1,5);
    fBvalue = mMcBA(1,2);
    fAvalue = mMcBA(1,4);
    fBStd = mMcBA(1,3);
catch
    fMc = nan;
    fBvalue = nan;
    fAvalue = nan;
    fBStd = nan;
end
