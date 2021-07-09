function [params] = kj_calc(params)
% function [params] = kj_calc(params)
% -----------------------------------
% Calculation of the Kagan & Jackson forecasting test.
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
% March 13, 2002

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Init result matrix
params.mValueGrid = [];
params.vRandomMeans = [];
params.vSignificanceLevel = [];
params.vNormSignificanceLevel = [];

if params.bRandom
  % Create the catalogs for each node with pointers to the overall catalog
  nNumberNodes = length(params.mPolygon(:,1));
  caNodeIndices = cell(nNumberNodes, 1);

  % If cross-section calculate the lenght along cross-section
  if ~params.bMap
    [nRow, nColumn] = size(params.mCatalog);
    xsecx2 = params.mCatalog(:,nColumn);  % length along x-section
    xsecy2 = params.mCatalog(:,7);        % depth of hypocenters
  end

  % loop over all points of the polygon
  disp(['Creating ' num2str(nNumberNodes) ' subcatalogs']);
  for nNode = 1:nNumberNodes

    x = params.mPolygon(nNode, 1);
    y = params.mPolygon(nNode, 2);

    % Calculate distance from center point and sort with distance
    if params.bMap
      vDistances = sqrt(((params.mCatalog(:,1)-x)*cos(pi/180*y)*111).^2 + ((params.mCatalog(:,2)-y)*111).^2);
    else
      vDistances = sqrt(((xsecx2 - x)).^2 + ((xsecy2 + y)).^2);
    end
    if params.bNumber
      % Use first nNumberEvents events
      [vTmp, vIndices] = sort(vDistances);
      caNodeIndices{nNode} = vIndices(1:params.nNumberEvents);
    else
      % Use all events within fRadius
      caNodeIndices{nNode} = find(vDistances <= params.fRadius);
    end
  end % of for nNode
  disp([num2str(nNumberNodes) ' subcatalogs created']);

  % Init values
  vProbDiff = NaN(length(params.mPolygon(:,1)),1);
  vProbK = NaN(length(params.mPolygon(:,1)),1);
  vProbO = NaN(length(params.mPolygon(:,1)),1);

  % overall b-value and Mc
  [v1 params.fBValueOverall params.fStdDevOverall v2] =  bmemag(params.mCatalog);
  params.fMcOverall = calc_Mc(params.mCatalog, params.nCalculateMC);

  % Determine the overall standard deviation of the b-value for the bayesian approach
  if params.nTestMethod == 3
    disp(['Calculating overall standard deviation']);
    params.fStdDevOverall = kj_CalcOverallStdDev(params);
    disp(['Standard deviation calculated']);
  end

  % Define the maximum length of periods
  fMaxLearning = params.fSplitTime - min(params.mCatalog(:,3));
  fMaxForecast = max(params.mCatalog(:,3)) - params.fSplitTime;

  % Do the loop over all calculations
  for nCnt = 1:params.nCalculation
    % Init some variables
    params.mValueGrid = [];
    % Init values
    vProbDiff = NaN(length(params.mPolygon(:,1)),1);
    vProbK = NaN(length(params.mPolygon(:,1)),1);
    vProbO = NaN(length(params.mPolygon(:,1)),1);

    % Permute magnitudes
    mRandomCatalog = params.mCatalog;
    mRandomCatalog(:,6) = params.mCatalog(randperm(length(params.mCatalog)), 6);

    % loop over all points of the polygon
    for nNode = 1:length(params.mPolygon(:,1))

      % Create node catalog
      mNodeCatalog = mRandomCatalog(caNodeIndices{nNode}, :);

      % Determine the local magnitude of completeness
      fMc = calc_Mc(mNodeCatalog, params.nCalculateMC);
      if isnan(fMc)
        fMc = params.fMcOverall;
      elseif isempty(fMc)
        fMc = params.fMcOverall;
      end

      % Create the learning and observed catalogs
      [mLearningCatalog, mObservedCatalog] = ex_SplitCatalog(mNodeCatalog, params.fSplitTime, ...
        params.bLearningPeriod, params.fLearningPeriod, ...
        params.bForecastPeriod, params.fForecastPeriod);

      % Adjust the periods (must not be longer than the catalog contains data)
      if params.bLearningPeriod
        params.fLearning = min(params.fLearningPeriod, fMaxLearning);
      else
        params.fLearning = fMaxLearning;
      end
      if params.bForecastPeriod
        params.fForecast = min(params.fForecastPeriod, fMaxForecast);
      else
        params.fForecast = fMaxForecast;
      end

      % Define magnitude range for testing
      if params.bMinMagMc
        fMinMag = fMc;
      else
        fMinMag = params.fMinMag;
      end

      % Do the Kagan & Jackson test
      [fProbDiff, fProbK, fProbO] = kj_poissonian(mLearningCatalog, params.fLearning, mObservedCatalog, params.fForecast, params.nTestMethod, ...
        params.nMinimumNumber, fMc, params.fBValueOverall, params.fStdDevOverall, fMinMag, params.fMaxMag, 0);
      if ~isnan(fProbDiff)
        if isnan(vProbDiff(nNode))
          vProbDiff(nNode) = 0;
        end
        vProbDiff(nNode) = vProbDiff(nNode) + (fProbDiff/params.nCalculation);
      end
      if ~isnan(fProbK)
        if isnan(vProbK(nNode))
          vProbK(nNode) = 0;
        end
        vProbK(nNode) = vProbK(nNode) + (fProbK/params.nCalculation);
      end
      if ~isnan(fProbO)
        if isnan(vProbO(nNode))
          vProbO(nNode) = 0;
        end
        vProbO(nNode) = vProbO(nNode) + (fProbO/params.nCalculation);
      end
      params.mValueGrid = [params.mValueGrid; vProbDiff(nNode) vProbK(nNode) vProbO(nNode)];
    end  % for nNode
    params.vRandomMeans = [params.vRandomMeans; mean(params.mValueGrid(:, 1), 'omitnan')];
    disp(['Run #' num2str(nCnt) ' of ' num2str(params.nCalculation) ' calculated']);
  end % of for nCalculation
  if params.bSignificance
    nSignificanceLevel = kj_calcsig(params.fRealProbability, params.vRandomMeans, 4);
    disp(['Level of significance: ' num2str(nSignificanceLevel) '% at run #: ' num2str(nCnt) ' Period: ' num2str(params.fForecastPeriod) ' Radius: ' num2str(params.fRadius)]);
    params.vSignificanceLevel = [params.vSignificanceLevel; nSignificanceLevel];
    nSignificanceLevel = kj_CalcNormSig(params.vRandomMeans, params.fRealProbability);
    disp(['Level of significance: ' num2str(nSignificanceLevel) '% at run #: ' num2str(nCnt) ' Period: ' num2str(params.fForecastPeriod) ' Radius: ' num2str(params.fRadius)]);
    params.vNormSignificanceLevel = [params.vNormSignificanceLevel; nSignificanceLevel];
  end
  params.vcsGridNames = cellstr(char('Random: Probability difference (mean)', 'Random: Kagan & Jackson (mean)', 'Random: Our model (mean)'));
else % of if bRandom
  % Determine the overall b-value and magnitude of completeness
  [v1 params.fBValueOverall params.fStdDevOverall v2] =  bmemag(params.mCatalog);
  params.fMcOverall = calc_Mc(params.mCatalog, params.nCalculateMC);

  % Determine the overall standard deviation of the b-value for the bayesian approach (if used)
  if params.nTestMethod == 3
    disp(['Calculating overall standard deviation']);
    params.fStdDevOverall = kj_CalcOverallStdDev(params);
    disp(['Standard deviation calculated']);
  end

  % Define the maximum length of periods
  fMaxLearning = params.fSplitTime - min(params.mCatalog(:,3));
  fMaxForecast = max(params.mCatalog(:,3)) - params.fSplitTime;

  % Loop over all grid nodes
  for nNode = 1:length(params.mPolygon(:,1))
    x = params.mPolygon(nNode, 1);
    y = params.mPolygon(nNode, 2);

    % Calculate distances from center point
    if params.bMap
      vDistances = sqrt(((params.mCatalog(:,1)-x)*cos(pi/180*y)*111).^2 + ((params.mCatalog(:,2)-y)*111).^2);
    else
      [nRow, nColumn] = size(params.mCatalog);
      xsecx2 = params.mCatalog(:,nColumn);                        % Length along cross-section
      xsecy2 = params.mCatalog(:,7);                              % Depth of hypocenters
      vDistances = sqrt(((xsecx2 - x)).^2 + ((xsecy2 + y)).^2);
    end

    % Select the events for calculation
    if params.bNumber
      % Sort with distance
      [vTmp, vIndices] = sort(vDistances);
      mNodeCatalog = params.mCatalog(vIndices(:,1),:);
      % Use first nNumberEvents events
      mNodeCatalog = mNodeCatalog(1:params.nNumberEvents,:);
    else
      % Use all events within fRadius
      vDistances = (vDistances <= params.fRadius);
      mNodeCatalog = params.mCatalog(vDistances,:);
    end

    % Determine the local magnitude of completeness
    fMc = calc_Mc(mNodeCatalog, params.nCalculateMC);
    if isnan(fMc)
      fMc = params.fMcOverall;
    elseif isempty(fMc)
      fMc = params.fMcOverall;
    end

    % Create the learning and observed catalogs
    [mLearningCatalog, mObservedCatalog] = ex_SplitCatalog(mNodeCatalog, params.fSplitTime, ...
      params.bLearningPeriod, params.fLearningPeriod, ...
      params.bForecastPeriod, params.fForecastPeriod);

    % Adjust the periods (must not be longer than the catalog contains data)
    if params.bLearningPeriod
      params.fLearning = min(params.fLearningPeriod, fMaxLearning);
    else
      params.fLearning = fMaxLearning;
    end
    if params.bForecastPeriod
      params.fForecast = min(params.fForecastPeriod, fMaxForecast);
    else
      params.fForecast = fMaxForecast;
    end

    % Define magnitude range for testing
    if params.bMinMagMc
      fMinMag = fMc;
    else
      fMinMag = params.fMinMag;
    end

    % Do the Kagan & Jackson test
    [fProbDiff, fProbK, fProbO, fWeightK, fWeightO, fBValueO] = kj_test(mLearningCatalog, params.fLearning, ...
      mObservedCatalog, params.fForecast, params.nTestMethod, params.nMinimumNumber, fMc, ...
      params.fBValueOverall, params.fStdDevOverall, fMinMag, params.fMaxMag, 0);

    nNumberEventsLearning = length(mLearningCatalog(:,6));
    nNumberEventsObserved = length(mObservedCatalog(:,6));

    % Store the results
    params.mValueGrid = [params.mValueGrid; fProbDiff fProbK fProbO nNumberEventsLearning nNumberEventsObserved fWeightK fWeightO params.fBValueOverall fBValueO];
    params.vcsGridNames = cellstr(char('Probability difference', 'Kagan & Jackson', 'Our model', 'Number events in learning period', ...
      'Number events in forecasting period', 'Weighting of the overall b-value', 'Weighting of the node b-value', ...
      'b-value used for Kagan & Jackson model', 'b-value used for our model'));
  end % for nNode
end
