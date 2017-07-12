function [params] = st_calc(params)
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

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Prepare the data
% ----------------

% Separate first catalog
vSel_ = ((params.mCatalog.Date >= params.fStartFirstPeriod) & (params.mCatalog.Date <= params.fEndFirstPeriod));
params.mFirstCatalog = params.mCatalog.subset(vSel_);

% Separate second catalog
vSel_ = ((params.mCatalog.Date >= params.fStartSecondPeriod) & (params.mCatalog.Date <= params.fEndSecondPeriod));
params.mSecondCatalog = params.mCatalog.subset(vSel_);

% Create indices of first catalog
params.rOptions.caFirstNodeIndices = ex_CreateIndexCatalog(params.mFirstCatalog, params.mPolygon, params.bMap, ...
  params.rOptions.nGriddingMode, params.rOptions.nNumberEvents, params.rOptions.fRadius, ...
  params.rOptions.fSizeRectX, params.rOptions.fSizeRectY);
% Create indices of second catalog
params.rOptions.caSecondNodeIndices = ex_CreateIndexCatalog(params.mSecondCatalog, params.mPolygon, params.bMap, ...
  params.rOptions.nGriddingMode, params.rOptions.nNumberEvents, params.rOptions.fRadius, ...
  params.rOptions.fSizeRectX, params.rOptions.fSizeRectY);

% Perform the calculation
% -----------------------

nNumberNodes_ = length(params.mPolygon(:,1));

mValueGrid_ = [];

for nNode_ = 1:nNumberNodes_
  if rem(nNode_,100) == 0
    disp(['Calculating node ' num2str(nNode_) ' of ' num2str(nNumberNodes_)]);
  end
  % save('node.mat', 'nNode_');
  % Create node catalog for the first catalog
  mNodeCatalog_ = params.mFirstCatalog(params.rOptions.caFirstNodeIndices{nNode_}, :);
  % Compute the b-value for first node catalog
  [fBValueFirst_, fStdDevFirst_, fMcFirst_, uDummy1_, N1] = ...
    calc_BandMc(mNodeCatalog_, params.rOptions.nMinimumNumber, params.rOptions.nCalculateMC, params.rOptions.fBinning, ...
      params.rOptions.bConstrainMc, params.rOptions.fMcMin, params.rOptions.fMcMax);
  if isnan(fBValueFirst_)
    fMcWhereBFirst_ = nan;
  else
    fMcWhereBFirst_ = fMcFirst_;
  end
  % Compute thea-value at Mc for first node catalog
  nNumQuakes_ = sum(mNodeCatalog_(:,6) >= fMcFirst_);
  fAnnualRate_ = nNumQuakes_/(params.fEndFirstPeriod - params.fStartFirstPeriod);
  fAValueFirst_ = log10(fAnnualRate_);
  if isnan(fBValueFirst_)
    fAValueWhereBFirst_ = nan;
  else
    fAValueWhereBFirst_ = fAValueFirst_;
  end
  % Bootstrap the error in b-value
  if params.bBootstrapFirst
    [uDummy1_, fBootStdDevMcFirst_, uDummy2_, fBootStdDevBFirst_, uDummy3_, uDummy4_, uDummy5_, mBValuesTmp_] = ...
      calc_McBboot(mNodeCatalog_, params.rOptions.fBinning, params.nNumberBootstrapsFirst, params.rOptions.nCalculateMC, params.rOptions.nMinimumNumber, 0);
    vBValuesFirst_ = mBValuesTmp_(:,2);
  end

  % Create node catalog for the second catalog
  mNodeCatalog_ = params.mSecondCatalog(params.rOptions.caSecondNodeIndices{nNode_}, :);
  % Compute b-value for second node catalog
  [fBValueSecond_, fStdDevSecond_, fMcSecond_, uDummy1_, N2] = ...
    calc_BandMc(mNodeCatalog_, params.rOptions.nMinimumNumber, params.rOptions.nCalculateMC, params.rOptions.fBinning, ...
      params.rOptions.bConstrainMc, params.rOptions.fMcMin, params.rOptions.fMcMax);
  if isnan(fBValueSecond_)
    fMcWhereBSecond_ = nan;
  else
    fMcWhereBSecond_ = fMcSecond_;
  end
  % Compute thea-value at Mc for first node catalog
  nNumQuakes_ = sum(mNodeCatalog_(:,6) >= fMcFirst_);
  fAnnualRate_ = nNumQuakes_/(params.fEndSecondPeriod - params.fStartSecondPeriod);
  fAValueSecond_ = log10(fAnnualRate_);
  if isnan(fBValueSecond_)
    fAValueWhereBSecond_ = nan;
  else
    fAValueWhereBSecond_ = fAValueSecond_;
  end
  % Bootstrap the error in b-value
  if params.bBootstrapSecond
    [uDummy1_, fBootStdDevMcSecond_, uDummy2_, fBootStdDevBSecond_, uDummy3_, uDummy4_, uDummy5_, mBValuesTmp_] = ...
      calc_McBboot(mNodeCatalog_, params.rOptions.fBinning, params.nNumberBootstrapsSecond, params.rOptions.nCalculateMC, params.rOptions.nMinimumNumber, 0);
    vBValuesSecond_ = mBValuesTmp_(:,2);
  end
  % Calculate the difference in b-value
  if (~isnan(fBValueFirst_)) & (~isnan(fBValueSecond_))
    fDeltaBValue_ = fBValueSecond_ - fBValueFirst_;
  else
    fDeltaBValue_ = nan;
  end
  if params.bBootstrapFirst
    fDiffSigma_ = fDeltaBValue_/fBootStdDevBFirst_;
    fAbsDiffSigma_ = abs(fDiffSigma_);
  end
  % Calculate the difference ina-value
  if (~isnan(fAValueWhereBFirst_)) & (~isnan(fAValueWhereBSecond_))
    fDeltaAValue_ = fAValueWhereBSecond_ - fAValueWhereBFirst_;
  else
    fDeltaAValue_ = nan;
  end
  % Calculate Utsu's test
  if (~isnan(fBValueFirst_)) & (~isnan(fBValueSecond_))
    N = N1 + N2;
    dA = -2*N*log(N) + 2*N1*log(N1+(N2*fBValueFirst_/fBValueSecond_)) + 2*N2*log(N2+(N1*fBValueSecond_/fBValueFirst_)) - 2;
    fProbUtsu = exp(-dA/2 - 2);
    fProbRamon = exp(-dA/2 - 1);
    fProbUtsu = log10(fProbUtsu);
    fProbRamon = log10(fProbRamon);
  else
    fProbUtsu = nan;
    fProbRamon = nan;
  end
  % Compute the significance of not being stationary
  if params.bBootstrapFirst
    if (~isnan(fBValueFirst_)) & (~isnan(fBValueSecond_)) & params.bBootstrapFirst & params.bBootstrapSecond
      [fProbability_, fProb12_, fProb21_] = st_probability(fBValueFirst_, vBValuesFirst_, fBValueSecond_, vBValuesSecond_);
    else
      fProbability_ = nan;
      fProb12_ = nan;
      fProb21_ = nan;
    end
  end
  % Store the results
  if (params.bBootstrapFirst & params.bBootstrapSecond)
    mValueGrid_ = [mValueGrid_; fBValueFirst_ fStdDevFirst_ fAValueFirst_ fAValueWhereBFirst_ fMcFirst_ fMcWhereBFirst_ fBootStdDevBFirst_ ...
      fBootStdDevMcFirst_ fBValueSecond_ fStdDevSecond_ fAValueSecond_ fAValueWhereBSecond_ fMcSecond_ fMcWhereBSecond_ fBootStdDevBSecond_ ...
      fBootStdDevMcSecond_ fDeltaBValue_ ...
      fDiffSigma_ fAbsDiffSigma_ fDeltaAValue_ fProbUtsu fProbRamon fProbability_ fProb12_ fProb21_];
  elseif (params.bBootstrapFirst  &&  ~params.bBootstrapSecond)
    mValueGrid_ = [mValueGrid_; fBValueFirst_ fStdDevFirst_ fAValueFirst_ fAValueWhereBFirst_ fMcFirst_ fMcWhereBFirst_ fBootStdDevBFirst_ ...
      fBootStdDevMcFirst_ fBValueSecond_ fStdDevSecond_ fAValueSecond_ fAValueWhereBSecond_ fMcSecond_ fMcWhereBSecond_ fDeltaBValue_ ...
      fDiffSigma_ fAbsDiffSigma_ fDeltaAValue_ fProbUtsu fProbRamon];
  elseif (~params.bBootstrapFirst  &&  params.bBootstrapSecond)
    mValueGrid_ = [mValueGrid_; fBValueFirst_ fStdDevFirst_ fAValueFirst_ fAValueWhereBFirst_ fMcFirst_ fMcWhereBFirst_ ...
      fBValueSecond_ fStdDevSecond_ fAValueSecond_ fAValueWhereBSecond_ fMcSecond_ fMcWhereBSecond_ fBootStdDevBSecond_ ...
      fBootStdDevMcSecond_ fDeltaBValue_ fDeltaAValue_ fProbUtsu fProbRamon];
  else
    mValueGrid_ = [mValueGrid_; fBValueFirst_ fStdDevFirst_ fAValueFirst_ fAValueWhereBFirst_ fMcFirst_ fMcWhereBFirst_ fBValueSecond_ ...
      fStdDevSecond_ fAValueSecond_ fAValueWhereBSecond_ fMcSecond_ fMcWhereBSecond_ fDeltaBValue_ fDeltaAValue_ fProbUtsu fProbRamon];
  end
end % of for
% Create the description-strings for the output-window
if (params.bBootstrapFirst & params.bBootstrapSecond)
  params.vcsGridNames = cellstr(char('b-value (1st period)', 'Std.-dev. (Shi/Bolt) of b (1st period)', ...
    'annuala-value @ Mc (1st period)', 'annuala-value @ Mc where b computed (1st period)', 'Mc (1st period)', 'Mc where b computed (1st period)', ...
    'Std.-dev. (Bootstrap) of b (1st period)', 'Std.-dev. (Bootstrap) of Mc (1st period)', 'b-value (2nd period)', 'Std.-dev. (Shi/Bolt) of b (2st period)', ...
    'annuala-value @ Mc (2nd period)', 'annuala-value @ Mc where b computed (2nd period)', 'Mc (2nd period)', 'Mc where b computed (2nd period)', ...
    'Std.-dev. (Bootstrap) of b (2nd period)', 'Std.-dev. (Bootstrap) of Mc (2nd period)', 'b-value difference', ...
    'b-value difference in sigma', 'b-value difference in sigma (absolute value)', 'annuala-value difference', 'Utsu test - Log probability', ...
    'Utsu test - Log Probability (Adjusted by Ramon)', 'Probability of not being stationary', 'Probability Period 1 -> 2', ...
    'Probability Period 2 -> 1'));
elseif (params.bBootstrapFirst  &&  ~params.bBootstrapSecond)
  params.vcsGridNames = cellstr(char('b-value (1st period)', 'Std.-dev. (Shi/Bolt) of b (1st period)', ...
    'annuala-value @ Mc (1st period)', 'annuala-value @ Mc where b computed (1st period)', 'Mc (1st period)', 'Mc where b computed (1st period)', ...
    'Std.-dev. (Bootstrap) of b (1st period)', 'Std.-dev. (Bootstrap) of Mc (1st period)', 'b-value (2nd period)', 'Std.-dev. (Shi/Bolt) of b (2st period)', ...
    'annuala-value @ Mc (2nd period)', 'annuala-value @ Mc where b computed (2nd period)', 'Mc (2nd period)', 'Mc where b computed (2nd period)', ...
    'b-value difference', 'b-value difference in sigma', 'b-value difference in sigma (absolute value)', 'a-value difference', 'Utsu test - Log probability', ...
    'Utsu test - Log Probability (Adjusted by Ramon)'));
elseif (~params.bBootstrapFirst  &&  params.bBootstrapSecond)
  params.vcsGridNames = cellstr(char('b-value (1st period)', 'Std.-dev. (Shi/Bolt) of b (1st period)', ...
    'annuala-value @ Mc (1st period)', 'annuala-value @ Mc where b computed (1st period)', 'Mc (1st period)', 'Mc where b computed (1st period)', ...
    'b-value (2nd period)', 'Std.-dev. (Shi/Bolt) of b (2st period)', 'annuala-value @ Mc (2nd period)', 'annuala-value @ Mc where b computed (2nd period)', ...
    'Mc (2nd period)', 'Mc where b computed (2nd period)', 'Std.-dev. (Bootstrap) of b (2nd period)', 'Std.-dev. (Bootstrap) of Mc (2nd period)', ...
    'b-value difference', 'annuala-value difference', 'Utsu test - Log probability', 'Utsu test - Log Probability (Adjusted by Ramon)'));
else
  params.vcsGridNames = cellstr(char('b-value (1st period)', 'Std.-dev. (Shi/Bolt) of b (1st period)', ...
    'annuala-value @ Mc (1st period)', 'annuala-value @ Mc where b computed (1st period)', 'Mc (1st period)', 'Mc where b computed (1st period)', ...
    'b-value (2nd period)', 'Std.-dev. (Shi/Bolt) of b (2st period)', 'annuala-value @ Mc (2nd period)', 'annuala-value @ Mc where b computed (2nd period)', ...
    'Mc (2nd period)', 'Mc where b computed (2nd period)', 'b-value difference', 'annuala-value difference', ...
    'Utsu test - Log probability', 'Utsu test - Log Probability (Adjusted by Ramon)'));
end
params.mValueGrid = mValueGrid_;
