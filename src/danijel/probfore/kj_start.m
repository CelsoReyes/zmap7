function kj_start(mCatalog, hFigure, bMap, rContainer)
% function kj_start(mCatalog, hFigure, bMap, rContainer)
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
% March 13, 2002

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Launch GUI
hMenuFig = kj_grid(bMap);

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
    params.bNumber = get(handles.radNumber, 'Value');
    params.nNumberEvents = str2double(get(handles.txtNumber, 'String'));
    params.fRadius = str2double(get(handles.txtRadius, 'String'));
    params.bGridEntireArea = get(handles.chkGridEntireArea, 'Value');
    params.fSpacingHorizontal = str2double(get(handles.txtSpacingHorizontal, 'String'));
    params.fSpacingDepth = str2double(get(handles.txtSpacingDepth, 'String'));
    params.nMinimumNumber = str2double(get(handles.txtMinimumNumber, 'String'));
    params.nCalculateMC = get(handles.cboMagnitude, 'Value');
    params.nTestMethod = get(handles.cboTestMethod, 'Value');
    params.bBValue = get(handles.chkBValue, 'Value');
    params.bRandom = get(handles.chkRandom, 'Value');
    if params.bRandom
      params.nCalculation = str2double(get(handles.txtNumberCalculation, 'String'));
      params.bSignificance = get(handles.chkSignificance, 'Value');
      if params.bSignificance
        params.fRealProbability = str2double(get(handles.txtProbability, 'String'));
      else
        params.fRealProbability = 0;
      end
    else
      params.nCalculation = 0;
      params.bSignificance = 0;
      params.fRealProbability = 0;
    end
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
      errordlg('Selection too small. Please select a larger polygon.');
      return
    end

    if bSaveParameter
      % Save paramters
      save(sSaveParameter, 'params');
    else
      % Perform the calculation
      [params] = kj_calc(params);
      if params.bBValue
        [bparams] = kj_bvalues(params);
        params.mValueGrid = [params.mValueGrid bparams.mValueGrid];
        params.vcsGridNames = [params.vcsGridNames; bparams.vcsGridNames];
      end
      kj_result(params);
    end
  else
    delete(hMenuFig);
  end
end
