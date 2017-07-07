function [fDeltaBValue, fBValueLearning, fBValueObserved] = kj_calcbvalues(mCatalog, fSplitTime, bLearningPeriod, fLearningPeriod, bObservedPeriod, fObservedPeriod, nMinimumNumber, nCalculateMC)
% function [fDeltaBValue, fBValueLearning, fBValueObserved]
%   = kj_calcbvalues(mCatalog, fSplitTime, bLearningPeriod, fLearningPeriod,
%                    bObservedPeriod, fObservedPeriod, nMinimumNumber, nCalculateMC)
% ----------------------------------------------------------------------------------
% Calculation of the b-values in the learning and observation (forecast) period
%
% Input parameters:
%   mCatalog            Earthquake catalog
%   fSplitTime          Time at which the catalog will be split
%   bLearningPeriod     Fix duration of the learning period (1 = fix, 0 = use catalog from start)
%   fLearningPeriod     Duration of the learning period
%   bObservedPeriod     Fix duration of the observation period (1 = fix, 0 = use catalog till end)
%   fObservedPeriod     Duration of the observation period
%   nMinimumNumber      Minimum number of earthquakes in the catalog for calculating the output values
%   nCalculateMC        Method to determine the magnitude of completeness (see also: help calc_Mc)
%
% Output parameters:
%   fDeltaBValue        Difference of both of the b-values (fBValueObserved - fBValueLearning)
%   fBValueLearning     b-value of the learning period
%   fBValueObserved     b-value of the observation (forecast) period
%
% Danijel Schorlemmer
% April 23, 2002

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Init output variables
fDeltaBValue = nan;
fBValueLearning = nan;
fBValueObserved = nan;

try
  % Create the catalogs for the learning and observation periods
  [mLearningCatalog, mObservedCatalog] = ex_SplitCatalog(mCatalog, fSplitTime, bLearningPeriod, fLearningPeriod, bObservedPeriod, fObservedPeriod);

  % Determine magnitude of completeness
  fMc = calc_Mc(mLearningCatalog, nCalculateMC);

  % Calculate the b-value of the learning period
  vSelection = mLearningCatalog(:,6) >= fMc;
  mLearningCatalog = mLearningCatalog(vSelection,:);
  if length(mLearningCatalog(:,1)) > nMinimumNumber
    [vDummy, fBValueLearning, vDummy, vDummy] =  bmemag(mLearningCatalog);
  end

  % Calculate the b-value of the observation period
  vSelection = mObservedCatalog(:,6) >= fMc;
  mObservedCatalog = mObservedCatalog(vSelection,:);
  if length(mObservedCatalog(:,1)) > nMinimumNumber
    [vDummy, fBValueObserved, vDummy, vDummy] =  bmemag(mObservedCatalog);
  end

  % Calculate the difference
  if (~isnan(fBValueLearning)) && (~isnan(fBValueObserved))
    fDeltaBValue = fBValueObserved - fBValueLearning;
  end
catch
end
