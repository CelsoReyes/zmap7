function [mFirstCatalog, mSecondCatalog, fFirstPeriodExact, fSecondPeriodExact, fFirstPeriod, fSecondPeriod] = ex_SplitCatalog(mCatalog, fSplitTime, bFirstPeriod, fFirstPeriod, bSecondPeriod, fSecondPeriod)
% function [mFirstCatalog, mSecondCatalog, fFirstPeriodExact, fSecondPeriodExact, fFirstPeriod, fSecondPeriod]
%   = ex_SplitCatalog(mCatalog, fSplitTime, bFirstPeriod, fFirstPeriod, bSecondPeriod, fSecondPeriod)
% ------------------------------------------------------------------------------------------------------------
% Splits an earthquake catalog into two subcatalogs according to given time periods.
%
% <---------------------------- mCatalog ----------------------------->
%
% +-----------------+-------------------+---------------------+-------+
% |                 |                   |                     |       |
% |                 |  fFirstPeriod     |   fSecondPeriod     |       |
% |                 |                   |                     |       |
% +-----------------+-------------------+---------------------+-------+
%                                       |
%                                   fSplitTime
%
% Input parameters:
%   mCatalog              Earthquake catalog
%   fSplitTime            Time at which the catalog will be split
%   bFirstPeriod          Fix duration of the first period (1 = fix, 0 = use catalog from start)
%   fFirstPeriod          Duration of the first period
%   bSecondPeriod         Fix duration of the second period (1 = fix, 0 = use catalog till end)
%   fSecondPeriod         Duration of the second period
%
% Output parameters:
%   mFirstCatalog         Earthquake catalog of the first period
%   mSecondCatalog        Earthquake catalog of the second period
%   fFirstPeriodExact     Exact length (in time) of the first catalog
%   fSecondPeriodExact    Exact length (in time) of the second catalog
%   fFirstPeriod          Lenght of the first period according to input parameter fFirstPeriod
%                         corrected by the maximum length of this period
%   fSecondPeriod         Lenght of the second period according to input parameter fSecondPeriod
%                         corrected by the maximum length of this period
%
% Danijel Schorlemmer
% April 25, 2002

report_this_filefun();

% Create the first catalog
if ~bFirstPeriod
  vSelection = (mCatalog.Date < fSplitTime);
else
  vSelection = ((mCatalog.Date < fSplitTime) & (mCatalog.Date >= (fSplitTime - fFirstPeriod)));
end
mFirstCatalog = mCatalog(vSelection, :);
fFirstPeriodExact = max(mFirstCatalog(:,3)) - min(mFirstCatalog(:,3));

% Create the second catalog
if ~bSecondPeriod
  vSelection = (mCatalog.Date > fSplitTime);
else
  vSelection = ((mCatalog.Date > fSplitTime) & (mCatalog.Date <= (fSplitTime + fSecondPeriod)));
end
mSecondCatalog = mCatalog(vSelection, :);
fSecondPeriodExact = max(mSecondCatalog(:,3)) - min(mSecondCatalog(:,3));

% Adjust the input periods (must not be longer than the catalog contains data)
fMaxFirst = fSplitTime - min(mCatalog.Date);
fMaxSecond = max(mCatalog.Date) - fSplitTime;

if bFirstPeriod
  fFirstPeriod = min(fFirstPeriod, fMaxFirst);
else
  fFirstPeriod = fMaxFirst;
end
if bSecondPeriod
  fSecondPeriod = min(fSecondPeriod, fMaxSecond);
else
  fSecondPeriod = fMaxSecond;
end
