function st_start(mCatalog, hFigure, bMap, rContainer)
% function st_start(mCatalog, hFigure, bMap, rContainer)
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
% June 26, 2003

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Launch GUI
hMenuFig = st_options(bMap);

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
    % Get parameter values from the gui
    % ---------------------------------
    % Hypothesis
    if get(handles.radNumber, 'Value') == 1
      rOptions.nGriddingMode = 0;
      rOptions.nNumberEvents = str2double(get(handles.txtNumber, 'String'));
      rOptions.fRadius = 0;
      rOptions.fSizeRectX = 0;
      rOptions.fSizeRectY = 0;
      rOptions.nMinimumNumber = 0;
      rOptions.fMaximumRadius = str2double(get(handles.txtMaximumRadius, 'String'));
    elseif get(handles.radRadius, 'Value') == 1
      rOptions.nGriddingMode = 1;
      rOptions.nNumberEvents = 0;
      rOptions.fRadius = str2double(get(handles.txtRadius, 'String'));
      rOptions.fSizeRectX = 0;
      rOptions.fSizeRectY = 0;
      rOptions.nMinimumNumber = str2double(get(handles.txtMinimumNumber, 'String'));
      rOptions.fMaximumRadius = 0;
    else % rectangle
      rOptions.nGriddingMode = 2;
      rOptions.nNumberEvents = 0;
      rOptions.fRadius = 0;
      rOptions.fSizeRectX = str2double(get(handles.txtSizeRectX, 'String'));
      rOptions.fSizeRectY = str2double(get(handles.txtSizeRectY, 'String'));
      rOptions.nMinimumNumber = str2double(get(handles.txtMinimumNumber, 'String'));
      rOptions.fMaximumRadius = 0;
    end
    rOptions.nCalculateMC = get(handles.cboCalculateMC, 'Value');
    rOptions.bConstrainMc = get(handles.chkConstrainMc, 'Value');
    rOptions.fMcMin = str2double(get(handles.txtMcMin, 'String'));
    rOptions.fMcMax = str2double(get(handles.txtMcMax, 'String'));
    if get(handles.cboBinning, 'Value') == 1
      rOptions.fBinning = 0.1;
    else
      rOptions.fBinning = 0.01;
    end

    params.rOptions = rOptions;

    % Options section
    params.bGridEntireArea = get(handles.chkGridEntireArea, 'Value');
    params.fSpacingX = str2double(get(handles.txtSpacingX, 'String'));
    params.fSpacingY = str2double(get(handles.txtSpacingY, 'String'));
    params.fStartFirstPeriod = str2double(get(handles.txtStartFirstPeriod, 'String'));
    params.fEndFirstPeriod = str2double(get(handles.txtEndFirstPeriod, 'String'));
    params.fStartSecondPeriod = str2double(get(handles.txtStartSecondPeriod, 'String'));
    params.fEndSecondPeriod = str2double(get(handles.txtEndSecondPeriod, 'String'));
    params.bBootstrapFirst = get(handles.chkBootstrapFirst, 'Value');
    params.nNumberBootstrapsFirst = str2double(get(handles.txtNumberBootstrapsFirst, 'String'));
    params.bBootstrapSecond = get(handles.chkBootstrapSecond, 'Value');
    params.nNumberBootstrapsSecond = str2double(get(handles.txtNumberBootstrapsSecond, 'String'));

    bSaveParameter = get(handles.chkSaveParameter, 'Value');
    if bSaveParameter
      sSaveParameter = get(handles.lblSaveParameter, 'String');
    end

    % Remove figure from memory
    delete(hMenuFig);

    % Select grid
    [params.mPolygon, params.vX, params.vY, params.vUsedNodes] = ex_selectgrid(hFigure, params.fSpacingX, params.fSpacingY, params.bGridEntireArea);

    % Validate polygonsize
    if length(params.vX) < 4  ||  length(params.vY) < 4
      errordlg('Selection is too small. Please select a larger polygon.');
      return;
    end

    if bSaveParameter
      % Save paramters
      save(sSaveParameter, 'params');
    else
      % Perform the calculation
      [params] = st_calc(params);

      % Display the results
      gui_result(params);
    end
  else
    delete(hMenuFig);
  end
end
