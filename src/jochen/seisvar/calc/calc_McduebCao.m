function [fMc, fBvalue, fBStd, fAvalue] = calc_McduebCao(mCatalog, fBinning, nMinNumberEvents)
% [fMc, fBvalue, fBStd, fAvalue] = calc_McduebCao(mCatalog, fBinning, nMinNumberEvents)
%----------------------------------------------------------------------------------------------------
% Calculate Mc using the function b-value vs. cut-off-magnitude
% Decision criterion for Mc and b is: b_i - b_i-1 <= 0.03 as in reference
%
% Reference: Cao A., Gao, S.S., Temporal variation of seismic b-values
% beneath northeastern Japan island arc, GRL, 29, 9, 2002
%
% Incoming variables:
% mCatalog         : EQ catalog
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
% updated: 04.06.03

% Check input
if nargin == 0, error('No catalog input'); end
if nargin == 1, fBinning = 0.1; nMinNumberEvents = 50; disp('Default Bin size: 0.1, Minimum number of events: 50');end;
if nargin == 2, nMinNumberEvents = 50; disp('Default Minimum number of events: 50');end;
if nargin > 3, disp('Too many arguments!'), return; end

% Initialize
fMc = nan;
fBvalue = nan;
mMcBA = [];

% Calculate b-with magnitude
[mBvalue] = calc_bwithmag(mCatalog, fBinning, nMinNumberEvents);
% Remove NANs
vSel = isnan(mBvalue(:,1));
mBvalue = mBvalue(~vSel,:);

% Use Shi & Bolt uncertainty to decide for Mc
for nStep = 2:(length(mBvalue(:,1)))
    % Criterion: If bi+1 - bi < 0.03, then use bi as b-value and cut-off magnitude as Mc
    if (mBvalue(nStep,1)- mBvalue(nStep-1,1)<= 0.03)
        mMcBA = [mMcBA; mBvalue(nStep,1) mBvalue(nStep,2) mBvalue(nStep,3) mBvalue(nStep,4)];
    end
end
% Create output
try
    fMc = mMcBA(1,4);
    fBvalue = mMcBA(1,1);
    fAvalue = mMcBA(1,3);
    fBStd = mMcBA(1,2);
catch
    fMc = nan;
    fBvalue = nan;
    fAvalue = nan;
    fBStd = nan;
end
