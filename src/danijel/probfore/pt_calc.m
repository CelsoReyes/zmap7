function [params] = pt_calc(params)
% function [params] = pt_calc(params)
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
% July 10, 2002

report_this_filefun();

% Perform the calculation
% -----------------------
% Compute the b-values for both models
[mValueGridH, vcsGridNamesH] = pt_calcinput(params.mLearningCatalog, params.mObservedCatalog, params.mPolygon, params.rOptions(1));
[mValueGridN, vcsGridNamesN] = pt_calcinput(params.mLearningCatalog, params.mObservedCatalog, params.mPolygon, params.rOptions(2));
% Apply test moethod settings
if params.nTestMethod == 2    % Use overall b-value for test hypothesis if it's impossible to compute a b-value
  vSel = isnan(mValueGridH(:,1));
  mValueGridH(vSel,:) = mValueGridN(vSel,:);
end
% Init result matrix
mValueGrid_ = [];
% Loop over all grid nodes
for nNode_ = 1:length(params.mPolygon(:,1))
  % Create node catalogs
  mLearningNodeCatalog_ = params.mLearningCatalog(params.rOptions(3).caLearningNodeIndices{nNode_}, :);
  mObservedNodeCatalog_ = params.mObservedCatalog(params.rOptions(3).caObservedNodeIndices{nNode_}, :);
  % Define magnitude range for testing
  fMinMag_ = max([mValueGridH(nNode_,3) mValueGridN(nNode_,3)]);
  if ~(params.bMinMagMc)
    fMinMag_ = max(params.fMinMag, fMinMag_);
  end
  % Calculate the probability-ratio
  [fDeltaProbability, fProbabilityN, fProbabilityH, vPredictionFMD, vObservedFMD, vMagnitudeBins] = pt_poissonian(mLearningNodeCatalog_, params.fLearningPeriodUsed, ...
    mObservedNodeCatalog_, params.fObservedPeriodUsed, params.rOptions(3).nMinimumNumber, mValueGridH(nNode_,1), mValueGridN(nNode_,1), ...
    mValueGridH(nNode_,3), mValueGridN(nNode_,3), fMinMag_, params.fMaxMag);
  if (((params.bRandomNode) | (params.bSaveRates)) & (~isnan(fProbabilityH)))
    nLen_ = length(vObservedFMD(:,1));
    vXMin_ = ones(nLen_, 1) * params.mPolygon(nNode_,1) - (params.rOptions(3).fSizeRectX/2);
    vXMax_ = ones(nLen_, 1) * params.mPolygon(nNode_,1) + (params.rOptions(3).fSizeRectX/2);
    vYMin_ = ones(nLen_, 1) * params.mPolygon(nNode_,2) - (params.rOptions(3).fSizeRectY/2);
    vYMax_ = ones(nLen_, 1) * params.mPolygon(nNode_,2) + (params.rOptions(3).fSizeRectY/2);
    vZMin_ = zeros(nLen_, 1);
    vZMax_ = zeros(nLen_, 1);
    vWeight_ = ones(nLen_, 1);
    vMagMin_ = vMagnitudeBins - 0.05;
    vMagMax_ = vMagnitudeBins + 0.05;
    vRatesH = [vXMin_ vXMax_ vYMin_ vYMax_ vZMin_ vZMax_ vMagMin_ vMagMax_ vPredictionFMD(:,1) vWeight_ vObservedFMD];
    vRatesN = [vXMin_ vXMax_ vYMin_ vYMax_ vZMin_ vZMax_ vMagMin_ vMagMax_ vPredictionFMD(:,2) vWeight_ vObservedFMD];
    if params.bSaveRates
      params.vRatesH = [params.vRatesH; vRatesH];
      params.vRatesN = [params.vRatesN; vRatesN];
    end
    if params.bRandomNode
      [rRelmTest] = relm_RTest4(vRatesH, vRatesN, params.nNumberCalculationNode, vMagnitudeBins(1), 1, 1, 0);
      fAlpha = rRelmTest.fAlpha;
      fBeta = rRelmTest.fBeta;
    else
      fAlpha = nan;
      fBeta = nan;
    end
  else
    fAlpha = nan;
    fBeta = nan;
  end
  mValueGrid_= [mValueGrid_; fDeltaProbability fProbabilityN fProbabilityH ...
      fAlpha fBeta];
end % for nNode
params.vcsGridNames = cellstr(char('Probability difference', ...
  'Null hypothesis', 'Test hypothesis', 'Alpha', 'Beta'));
% Add the b-values of the hypothesis to the overall value grid
params.mValueGrid = [mValueGrid_ mValueGridH mValueGridN];
params.vcsGridNames = [params.vcsGridNames; vcsGridNamesH; vcsGridNamesN];
