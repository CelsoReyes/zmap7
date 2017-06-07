function [params] = pf_calc(params)
% function [params] = pf_calc(params)
% -----------------------------------
% Calculation of the probabilistic forecast test.
%
% Input parameters:
%   params.mCatalog           Earthquake catalog
%   params.mPolygon           Polygon (defined by ex_selectgrid)
%   params.vX                 X-vector (defined by ex_selectgrid)
%   params.vY                 Y-vector (defined by ex_selectgrid)
%   params.vUsedNodes         Used nodes vX * vY defining the mPolygon (defined by ex_selectgrid)
%   params.bRandom            Perform random simulation (=1) or real calculation (=0)
%   params.nCalculation       Number of random simulations
%   params.bMap               Calculate a map (=1) or a cross-section (=0)
%   params.bNumber            Use constant number (=1) or constant radius (=0)
%   params.nNumberEvents      Number of earthquakes if bNumber == 1
%   params.fRadius            Radius of gridnode if bNumber == 0
%   params.nMinimumNumber     Minimum number of earthquakes per node for determining a b-value
%   params.fForecastPeriod    Forecasting period in years
%   params.bLearningPeriod    Use different learning period than the rest of the catalog
%   params.fLearningPeriod    Learning period in years
%   params.bSignificance      Calculate significance during random simulation
%                             using params.fRealProbability
%   params.fRealProbability   Probability of calculation with real data
%   params.nCalculateMC       Method to calculate magnitude of completeness (see also: help calc_Mc)
%   params.nTestMethod        Method to calculate the Kagan & Jackson test (see also: help kj_poissonian)
%   params.bMinMagMc          Use magnitude of completeness as lower limit of magnitude range for testing (=1)
%                             Use params.fMinMag as lower limit (=0)
%   params.fMinMag            Lower limit of magnitude range for testing
%   params.fMaxMag            Upper limit of magnitude range for testing
%
% Output parameters:
%   Same as input parameters including
%   params.mValueGrid         Matrix of calculated Kagan & Jackson test values
%   params.vRandomMeans       Vector of means of probability differences per simulation run
%   params.vSignificanceLevel Vector of significance levels per simulation run
%   params.fBValueOverall     Calculated overall b-value
%   params.fStdDevOverall     Calculated standard deviation
%   params.fMcOverall         Calculated magnitude of completeness
%
% Danijel Schorlemmer
% April 24, 2002

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Init variable
% params.mRandomDist = [];

% Create random probability-ratios
% --------------------------------
if (params.bRandomNode) | (params.bRandomArea)
  if params.bForceRandomCalculation
    % Init the matrix of random probability-ratios (node-wise) for all calculations
    mRandomDist_ = [];
  else
    try
      mRandomDist_ = params.mRandomDist;
    catch
      mRandomDist_ = [];
    end
  end
  if isempty(mRandomDist_)
    % Loop over the calculations
    for nCnt_ = 1:params.nNumberCalculationNode
      % Init the vector of probability-ratios for one simulation
      vRandomDist_ = [];
      % Randomize catalog
      mRandomCatalog_ = params.mCatalog;
      mRandomCatalog_(:,6) = params.mCatalog(randperm(length(params.mCatalog)), 6);
      % Loop over the grid
      for nNode_ = 1:length(params.mPolygon(:,1))
        % Create catalog of given gridnode
        mNodeCatalog_ = mRandomCatalog_(params.caNodeIndices{nNode_}, :);
        % Calculate the probability-ratio
        [rCalcNodeResult_] = pf_CalcNode(mNodeCatalog_, params.fSplitTime, params.bLearningPeriod, params.fLearningPeriod, ...
          params.bForecastPeriod, params.fForecastPeriod, params.nCalculateMC, params.fMcOverall, params.bMinMagMc, ...
          params.fMinMag, params.fMaxMag, params.nTestMethod, params.nMinimumNumber, params.fBValueOverall, params.fStdDevOverall);
        % Store it into the vector
        vRandomDist_ = [vRandomDist_; rCalcNodeResult_.fProbDiff];
      end % of for nNode_
      % Store the vector into the matrix
      mRandomDist_ = [mRandomDist_ vRandomDist_];
    end % of for nCnt_
    params.mRandomDist = mRandomDist_;
  end
end % of if (params.bRandomNode) | (params.bRandomArea)

% Perform the real calculation
% ----------------------------
% Init result matrix
mValueGrid_ = [];
% Loop over all grid nodes
for nNode_ = 1:length(params.mPolygon(:,1))
  % Create node catalog
  mNodeCatalog_ = params.mCatalog(params.caNodeIndices{nNode_}, :);
  % Calculate the probability-ratio
  [rCalcNodeResult_] = pf_CalcNode(mNodeCatalog_, params.fSplitTime, params.bLearningPeriod, params.fLearningPeriod, ...
    params.bForecastPeriod, params.fForecastPeriod, params.nCalculateMC, params.fMcOverall, params.bMinMagMc, ...
    params.fMinMag, params.fMaxMag, params.nTestMethod, params.nMinimumNumber, params.fBValueOverall, params.fStdDevOverall);
  % Calculate the significnance of the probability-ratio
  if params.bRandomNode
    fSignificanceLevel_ = kj_calcsig(rCalcNodeResult_.fProbDiff, mRandomDist_(nNode_,:), 2);
    fSignificanceLevel_ = fSignificanceLevel_ - 50;
    fSignificanceLevel_ = fSignificanceLevel_ * (-2); % Flip it (we want to be positive)
    fNormSignificanceLevel_ = kj_CalcNormSig(mRandomDist_(nNode_,:), rCalcNodeResult_.fProbDiff);
    fNormSignificanceLevel_ = fNormSignificanceLevel_ - 50;
    fNormSignificanceLevel_ = fNormSignificanceLevel_ * (-2); % Flip it (we want to be positive)
  else % of if params.bRandomNode
    fSignificanceLevel_ = nan;
    fNormSignificanceLevel_ = nan;
  end % of if params.bRandomNode
  % Store the results
  mValueGrid_= [mValueGrid_; fSignificanceLevel_ fNormSignificanceLevel_ rCalcNodeResult_.fProbDiff ...
      rCalcNodeResult_.fProbK rCalcNodeResult_.fProbO rCalcNodeResult_.nEventsLearning rCalcNodeResult_.nEventsObserved ...
      rCalcNodeResult_.fWeightK rCalcNodeResult_.fWeightO params.fBValueOverall rCalcNodeResult_.fBValueO rCalcNodeResult_.fMc];
end % for nNode
params.vcsGridNames = cellstr(char('Significance level', 'Significance level (normal distribution)', 'Probability difference', 'Kagan & Jackson', 'Our model', 'Number events in learning period', ...
  'Number events in forecasting period', 'Weighting of the overall b-value', 'Weighting of the node b-value', ...
  'b-value used for Kagan & Jackson model', 'b-value used for our model', 'Magnitude of completeness'));
params.mValueGrid = mValueGrid_;
% params.mRandomDist = mRandomDist_;


% % Perform the random simulation over the area
% % -------------------------------------------
% if params.bRandomArea
%   % Init matrix for significance values (n-times per gridnode)
%   mSignificanceGrid_ = [];
%   % Loop over the calculations
%   for nCnt_ = 1:params.nNumberCalculationArea
%     % Randomize catalog
%     mRandomCatalog_ = params.mCatalog;
%     mRandomCatalog_(:,6) = params.mCatalog(randperm(length(params.mCatalog)), 6);
%     % Init vector for significance values of one calculation over the entire grid
%     vSignificanceGrid_ = [];
%     % Loop over the grid
%     for nNode_ = 1:length(params.mPolygon(:,1))
%       % Create node catalog
%       mNodeCatalog_ = mRandomCatalog_(params.caNodeIndices{nNode_}, :);
%       % Calculate the probability-ratio
%       [rCalcNodeResult_] = pf_CalcNode(mNodeCatalog_, params.fSplitTime, params.bLearningPeriod, params.fLearningPeriod, ...
%         params.bForecastPeriod, params.fForecastPeriod, params.nCalculateMC, params.fMcOverall, params.bMinMagMc, ...
%         params.fMinMag, params.fMaxMag, params.nTestMethod, params.nMinimumNumber, params.fBValueOverall, params.fStdDevOverall);
%       % Calculate the significnance of the probability-ratio
%       fSignificanceLevel_ = kj_calcsig(rCalcNodeResult_.fProbDiff, mRandomDist_(nNode_,:), 2);
%       fSignificanceLevel_ = fSignificanceLevel_ - 50;
%       fSignificanceLevel_ = fSignificanceLevel_ * (-2); % Flip it (we want to be positive)
%       %       fNormSignificanceLevel_ = kj_CalcNormSig(mRandomDist_(nNode_,:), rCalcNodeResult_.fProbDiff);
%       %       fNormSignificanceLevel_ = fNormSignificanceLevel_ - 50;
%       %       fNormSignificanceLevel_ = fNormSignificanceLevel_ * (-2); % Flip it (we want to be positive)
%       % Store it into the vector
%       vSignificanceGrid_ = [vSignificanceGrid_ fSignificanceLevel_];
%     end % of for nNode_
%     % Store the vector into the matrix
%     mSignificanceGrid_ = [mSignificanceGrid_; vSignificanceGrid_];
%   end % of for nCnt_
% params.mSignificanceGrid = mSignificanceGrid_;
%
% % Evaluate overall significance
% % -----------------------------
%
% % Has to be set in the dialog
params.fSignificanceLevel = 95;
% % Compute the number of grid nodes with significant values
vSel_ = mValueGrid_(:,1) > params.fSignificanceLevel;
params.nRealPositive_ = sum(vSel_);
vSel_ = mValueGrid_(:,1) < -params.fSignificanceLevel;
params.nRealNegative_ = sum(vSel_);
% % Display them
disp(['Number positive: ' num2str(params.nRealPositive_)]);
disp(['Number negative: ' num2str(params.nRealNegative_)]);
%
% mRandomPositive_ = [];
% mRandomNegative_ = [];
%
% for nCnt_ = 1:params.nNumberCalculationArea
%  vSel_ = mSignificanceGrid_(nCnt_,:) > params.fSignificanceLevel;
%   %mTempGrid_ = mSignificanceGrid_(nCnt_,vSel_);
%   mRandomPositive_ = [mRandomPositive_; sum(vSel_)];
%
%  vSel_ = mSignificanceGrid_(nCnt_,:) < -params.fSignificanceLevel;
%   %mTempGrid_ = mSignificanceGrid_(nCnt_,vSel_);
%   mRandomNegative_ = [mRandomNegative_; sum(vSel_)];
% end
%
% fPositiveSignificance = kj_calcsig(nRealPositive_, mRandomPositive_, 3);
% fNegativeSignificance = kj_calcsig(nRealNegative_, mRandomNegative_, 3);
%
% disp(['Positive significance: ' num2str(fPositiveSignificance)]);
% disp(['Negative significance: ' num2str(fNegativeSignificance)]);
% end % of if params.bRandomArea
