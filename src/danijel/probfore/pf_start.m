function pf_start(mCatalog, hFigure, bMap, rContainer)
% function pf_start(mCatalog, hFigure, bMap, rContainer)
% ------------------------------------------------------
% Starts the probabilistic forecast testing. The function invokes the parameter dialog, calls the
%   calculation function and invokes the dialog for displaying the results
%
% Input parameters:
%   mCatalog      Earthquake catalog to use for the testing
%   hFigure       Handle of figure where the user should select the grid (i.e. the seismicity map)
%   bMap          Map/cross-section switch. If the testing is carried out on a map set bMap = 1,
%                 on a cross-section set bMap = 0
%   rContainer    Just a container (structure proposed) to store any variables that should be available in the
%                 probabilistic forecast testing code
%
% Danijel Schorlemmer
% June 4, 2002

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Launch GUI
hMenuFig = pf_grid(bMap);

% Set up parameter struct and store input parameters
params.mCatalog = mCatalog;
params.bMap = bMap;
params.rContainer = rContainer;

% Analyze Output
if ~ishandle(hMenuFig)
  answer = 0;
else
  handles = guidata(hMenuFig);
  answer = handles.answer;
  % OK pressed
  if answer == 1
    % Get the values from figure
    %params.bNumber = get(handles.radNumber, 'Value');   % deprecated
    if get(handles.radNumber, 'Value') == 1
      params.nGriddingMode = 0;   % Constant number
    elseif get(handles.radRadius, 'Value') == 1
      params.nGriddingMode = 1;   % Constant radius
    else
      params.nGriddingMode = 2;   % Rectangle mode
    end
    params.nNumberEvents = str2double(get(handles.txtNumber, 'String'));
    params.fRadius = str2double(get(handles.txtRadius, 'String'));
    params.bGridEntireArea = get(handles.chkGridEntireArea, 'Value');
    params.fSpacingHorizontal = str2double(get(handles.txtSpacingHorizontal, 'String'));
    params.fSpacingDepth = str2double(get(handles.txtSpacingDepth, 'String'));
    params.fSizeRectHorizontal = str2double(get(handles.txtSizeRectHorizontal, 'String'));
    params.fSizeRectDepth = str2double(get(handles.txtSizeRectDepth, 'String'));
    params.nMinimumNumber = str2double(get(handles.txtMinimumNumber, 'String'));
    params.nCalculateMC = get(handles.cboMagnitude, 'Value');
    params.nTestMethod = get(handles.cboTestMethod, 'Value');
    params.bBValue = get(handles.chkBValue, 'Value');
    params.bRandomNode = get(handles.chkRandomNode, 'Value');
    if params.bRandomNode
      params.nNumberCalculationNode = str2double(get(handles.txtNumberCalculationNode, 'String'));
      params.bRandomArea = get(handles.chkRandomArea, 'Value');
      if params.bRandomArea
        params.nNumberCalculationArea = str2double(get(handles.txtNumberCalculationArea, 'String'));
      else
        params.nNumberCalculationArea = 0;
      end
    else
      params.nNumberCalculationNode = 0;
      params.bRandomArea = 0;
      params.nNumberCalculationArea = 0;
    end
    params.bForceRandomCalculation = 0;

    params.fSplitTime = str2double(get(handles.txtSplitTime, 'String'));
    params.bForecastPeriod = get(handles.chkForecastPeriod, 'Value');
    if params.bForecastPeriod
      params.fForecastPeriod = str2double(get(handles.txtForecastPeriod, 'String'));
    else
      params.fForecastPeriod = 0;
    end
    params.bLearningPeriod = get(handles.chkLearningPeriod, 'Value');
    if params.bLearningPeriod
      params.fLearningPeriod = str2double(get(handles.txtLearningPeriod, 'String'));
    else
      params.fLearningPeriod = 0;
    end
    params.bMinMagMc = get(handles.chkMinMag, 'Value');
    if ~params.bMinMagMc
      params.fMinMag = str2double(get(handles.txtMinMag, 'String'));
    else
      params.fMinMag = 1;
    end
    params.fMaxMag = str2double(get(handles.txtMaxMag, 'String'));

    bSaveParameter = get(handles.chkSaveParameter, 'Value');
    if bSaveParameter
      sSaveParameter = get(handles.lblSaveParameter, 'String');
    end

    % Remove figure from memory
    delete(hMenuFig);

    % Select grid
    [params.mPolygon, params.vX, params.vY, params.vUsedNodes] = ex_selectgrid(hFigure, params.fSpacingHorizontal, params.fSpacingDepth, params.bGridEntireArea);

    % Validate polygonsize
    if length(params.vX) < 4  ||  length(params.vY) < 4
      errordlg('Selection is too small. Please select a larger polygon.');
      return;
    end

    if bSaveParameter
      % Save paramters
      save(sSaveParameter, 'params');
    else
      % General calculations

      % Create Indices to catalog
      [params.caNodeIndices] = ex_CreateIndexCatalog(params.mCatalog, params.mPolygon, params.bMap, params.nGriddingMode, ...
        params.nNumberEvents, params.fRadius, params.fSizeRectHorizontal, params.fSizeRectDepth);

      % Determine the overall magnitude of completeness and overall b-value
      params.fMcOverall = calc_Mc(params.mCatalog, params.nCalculateMC);
      vSel = params.mCatalog(:,6) >= params.fMcOverall;
      [vDummy params.fBValueOverall params.fStdDevOverall vDummy] =  bmemag(params.mCatalog(vSel,:));

      % Determine the overall standard deviation of the b-value for the bayesian approach (if used)
      if params.nTestMethod == 3
        disp(['Calculating overall mean standard deviation']);
        params.fStdDevOverall = kj_CalcOverallStdDev(params);
        disp(['Standard deviation calculated']);
      end

      % Perform the calculation
      [params] = pf_calc(params);
      if params.bBValue
        [bparams] = pf_bvalues(params);
        params.mValueGrid = [params.mValueGrid bparams.mValueGrid];
        params.vcsGridNames = [params.vcsGridNames; bparams.vcsGridNames];
      end
      pf_result(params);
    end
  else
    delete(hMenuFig);
  end
end
