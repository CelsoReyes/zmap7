function [result] = kj_bvalues(params)
% function [params] = kj_bvalues(params)
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
% April 23, 2001

% Init result matrix
result = params;
result.mValueGrid = [];

for nNode = 1:length(params.mPolygon(:,1))
  x = params.mPolygon(nNode, 1);
  y = params.mPolygon(nNode, 2);

  if ~params.bMap
    [nRow, nColumn] = size(params.mCatalog);
    xsecx2 = params.mCatalog(:,nColumn); % length along x-section
    xsecy2 = params.mCatalog(:,7);  % depth of hypocenters
  end

  % calculate distance from center point and sort wrt distance
  if params.bMap
    vDistances = sqrt(((params.mCatalog(:,1)-x)*cos(pi/180*y)*111).^2 + ((params.mCatalog(:,2)-y)*111).^2);
  else
    vDistances = sqrt(((xsecx2 - x)).^2 + ((xsecy2 + y)).^2);
  end
  [vTmp, vIndices] = sort(vDistances);
  mNodeCatalog = params.mCatalog(vIndices(:,1),:);

  % Select the events for calculation
  if params.bNumber
    % Use first nNumberEvents events
    mNodeCatalog = mNodeCatalog(1:params.nNumberEvents,:);
    nEventsPerNode = vTmp(params.nNumberEvents);
  else
    % Use all events within fRadius
    vDistances = (vDistances <= params.fRadius);
    mNodeCatalog = params.mCatalog(vDistances,:);
    nEventsPerNode = length(mNodeCatalog(:,1));
  end

  % Calculate the b-values
  [fDeltaBValue, fBValueLearning, fBValueObserved] = kj_calcbvalues(mNodeCatalog, params.fSplitTime, params.bLearningPeriod, params.fLearningPeriod, params.bForecastPeriod, params.fForecastPeriod, params.nMinimumNumber, params.nCalculateMC);

  % Store the results
  result.mValueGrid = [result.mValueGrid; fDeltaBValue fBValueLearning fBValueObserved];
end % for nNode
result.vcsGridNames = cellstr(char('b-value difference', 'b-value of learning period', 'b-value of observation period'));

