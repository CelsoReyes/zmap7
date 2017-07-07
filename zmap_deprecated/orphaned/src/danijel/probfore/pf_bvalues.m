function [result] = pf_bvalues(params)
% function [params] = pf_bvalues(params)
% --------------------------------------
% Calculation of b-values for the probabilistic forecast test.
% Input parameters:
%   params.mCatalog           Earthquake catalog
%   params.mPolygon           Polygon (defined by ex_selectgrid)
%   params.vX                 X-vector (defined by ex_selectgrid)
%   params.vY                 Y-vector (defined by ex_selectgrid)
%   params.vUsedNodes         Used nodes vX * vY defining the mPolygon (defined by ex_selectgrid)
%   params.bMap               Calculate a map (=1) or a cross-section (=0)
%   params.bNumber            Use constant number (=1) or constant radius (=0)
%   params.nNumberEvents      Number of earthquakes if bNumber == 1
%   params.fRadius            Radius of gridnode if bNumber == 0
%   params.nMinimumNumber     Minimum number of earthquakes per node
%   params.fSplitTime         Time at which the catalog will be split
%   params.bLearningPeriod    Fix duration of the learning period (1 = fix, 0 = use catalog from start)
%   params.fLearningPeriod    Duration of the learning period
%   params.bForecastPeriod    Fix duration of the forecasting period (1 = fix, 0 = use catalog till end)
%   params.fForecastPeriod    Duration of the forecasting period
%
% Output parameters:
%   Same as input parameters including
%   result.mValueGrid         Matrix of calculated b-values
%   result.vcsGridNames       Strings describing the values in mValueGrid
%
% Danijel Schorlemmer
% June 4, 2001

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Init result matrix
result = params;
result.mValueGrid = [];

for nNode_ = 1:length(params.mPolygon(:,1))
  % Create node catalog
  mNodeCatalog_ = params.mCatalog(params.caNodeIndices{nNode_}, :);
  % Calculate the b-values
  [fDeltaBValue, fBValueLearning, fBValueObserved, fStdDevLearning, fStdDevObserved] ...
    = pf_calcbvalues(mNodeCatalog_, params.fSplitTime, params.bLearningPeriod, params.fLearningPeriod, ...
    params.bForecastPeriod, params.fForecastPeriod, params.nMinimumNumber, params.nCalculateMC);
  % Store the results
  result.mValueGrid = [result.mValueGrid; fDeltaBValue fBValueLearning fBValueObserved fStdDevLearning fStdDevObserved];
end % for nNode
% Create the description-strings for the output-window
result.vcsGridNames = cellstr(char('b-value difference', 'b-value of learning period', 'b-value of observation period', ...
  'Std. dev. of learning period b-value ', 'Std. dev. of observation period b-value'));

