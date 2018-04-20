function [mValueGrid, vcsGridNames] = pt_calcinput(mLearningCatalog, mObservedCatalog, mPolygon, rOptions)
% function [result] = pt_calcinput(mLearningCatalog, mObservedCatalog, mPolygon, rOptions)
% ----------------------------------------------------------------------------------------
% Calculation of b-values for the probabilistic forecast test.
%
% Input parameters:
%   mLearningCatalog    Catalog of the first period
%   mObservedCatalog    Catalog of the second period
%   mPolygon            Set of grid nodes of the volume for b-value computation (defined by ex_selectgrid)
%   rOptions            Record with settings for b-value computation (see pt_start)
%
% Output parameters:
%   mValueGrid          Matrix of calculated b-values
%   vcsGridNames        Strings describing the values in mValueGrid
%
% Danijel Schorlemmer
% Oktober 14, 2002

report_this_filefun();

nNumberNodes = length(mPolygon(:,1));

% Init result matrix
if rOptions.bCalcBothPeriods
  mValueGrid = zeros(nNumberNodes, 7);
else
  mValueGrid = zeros(nNumberNodes, 3);
end

if rOptions.nCalcMode == 0   % Spatial b-values
  for nNode_ = 1:nNumberNodes
    % Create node catalog for the first catalog
    mNodeCatalog_ = mLearningCatalog(rOptions.caLearningNodeIndices{nNode_}, :);
    [fBValueLearning, fStdDevLearning, fMcLearning] = calc_BandMc(mNodeCatalog_, rOptions.nMinimumNumber, rOptions.nCalculateMC);
    if rOptions.bCalcBothPeriods
      % Create node catalog for the second catalog
      mNodeCatalog_ = mObservedCatalog(rOptions.caObservedNodeIndices{nNode_}, :);
      [fBValueObserved, fStdDevObserved, fMcObserved] = calc_BandMc(mNodeCatalog_, rOptions.nMinimumNumber, rOptions.nCalculateMC);
      % Calculate the difference
      if (~isnan(fBValueLearning)) & (~isnan(fBValueObserved))
        fDeltaBValue = fBValueObserved - fBValueLearning;
      else
        fDeltaBValue = nan;
      end
    end
    % Store the results
    if rOptions.bCalcBothPeriods
      mValueGrid(nNode_,:) = [fBValueLearning fStdDevLearning fMcLearning fBValueObserved fStdDevObserved fMcObserved fDeltaBValue];
    else
      mValueGrid(nNode_,:) = [fBValueLearning fStdDevLearning fMcLearning];
    end
  end % of for
else  % Mean b-value
  [fBValueLearning, fStdDevLearning, fMcLearning] = calc_BandMc(mLearningCatalog, rOptions.nMinimumNumber, rOptions.nCalculateMC);
  if rOptions.bCalcBothPeriods
    [fBValueObserved, fStdDevObserved, fMcObserved] = calc_BandMc(mObservedCatalog, rOptions.nMinimumNumber, rOptions.nCalculateMC);
    if (~isnan(fBValueLearning)) & (~isnan(fBValueObserved))
      fDeltaBValue = fBValueObserved - fBValueLearning;
    else
      fDeltaBValue = nan;
    end
  end
  for nNode_ = 1:nNumberNodes
    if rOptions.bCalcBothPeriods
      mValueGrid(nNode_,:) = [fBValueLearning fStdDevLearning fMcLearning fBValueObserved fStdDevObserved fMcObserved fDeltaBValue];
    else
      mValueGrid(nNode_,:) = [fBValueLearning fStdDevLearning fMcLearning];
    end
  end % of for
end % of if params.nCalcMode
% Create the description-strings for the output-window
if rOptions.bCalcBothPeriods
  vcsGridNames = cellstr(char('b-value of learning period', 'Std. dev. of learning period b-value', ...
    'Magnitude of completeness of learning period', 'b-value of observation period', 'Std. dev. of observation period b-value', ...
    'Magnitude of completeness of observation period', 'b-value difference'));
else
  vcsGridNames = cellstr(char('b-value of learning period', 'Std. dev. of learning period b-value', ...
    'Magnitude of completeness of learning period'));
end
