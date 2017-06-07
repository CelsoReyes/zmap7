function varargout = kj_analyze(varargin)
% KJ_ANALYZE Application M-file for kj_analyze.fig
%    FIG = KJ_ANALYZE launch kj_analyze GUI.
%    KJ_ANALYZE('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 28-Aug-2003 13:16:39

if (nargin == 2) & ~ischar(varargin{1})  % LAUNCH GUI

  fig = openfig(mfilename,'reuse');

  % Use system color scheme for figure:
  set(fig,'Color',get(groot,'defaultUicontrolBackgroundColor'));

  % Generate a structure of handles to pass to callbacks, and store it.
  handles = guihandles(fig);
  % Store the data
  handles.params = varargin{1};
  handles.hParentFigure = varargin{2};

  % Set the used splitting time if available
  try
    fSplit = handles.params.fSplitTime;
  catch
    fSplit = ((max(handles.params.mCatalog(:,3)) - min(handles.params.mCatalog(:,3))) / 2) + min(handles.params.mCatalog(:,3));
  end
  set(handles.txtSplit, 'String', num2str(fSplit, 6));

  % Set the length of the learning period if available
  try
    set(handles.txtFirst, 'String', num2str(handles.params.fLearningPeriodUsed));
  catch
    set(handles.txtFirst, 'String', '1');
  end

  % Set the length of the forecasting period if available
  try
    set(handles.txtSecond, 'String', num2str(handles.params.fObservedPeriodUsed));
  catch
    set(handles.txtSecond, 'String', '1');
  end

  plotit(handles, []);

  guidata(fig, handles);

  if nargout > 0
    varargout{1} = fig;
  end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

  try
    [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
  catch
    disp(lasterr);
  end

end

% --------------------------------------------------------------------
function plotit(handles, gui_export)

% Plot the frequency magnitude distribution
if get(handles.radEntireCatalog, 'Value') == 1
  mPlotCatalog = handles.params.mCatalog;
else
  mPlotCatalog = handles.mNodeCatalog;
  mTestCatalog = handles.mNodeTestCatalog;
end

if get(handles.chkExternalPlotting, 'Value') == 1
  figure
  axsFMD = subplot(2, 2, 1);
  axsTimePlot = subplot(2, 2, 3);
  axsLikelihood = subplot(2, 2, 4);
  axsTest = subplot(2, 2, 2);
else
  axsFMD = handles.axsFMD;
  axsTimePlot = handles.axsTimePlot;
  axsLikelihood = handles.axsLikelihood;
  axsTest = handles.axsTest;
end

axes(axsFMD);
set(axsFMD, 'NextPlot', 'replace');
set(axsTimePlot, 'NextPlot', 'replace');
if get(handles.radEntireTime, 'Value') == 1
  % Plot the frequency magnitude distribution
  [hPlotFMD, fBValue, fAValue, fStdDev] = plot_FMD(mPlotCatalog, 1, axsFMD, 's', 'k', 1, handles.params.rOptions(1).nCalculateMC);
  set(hPlotFMD, 'MarkerSize', 10);
  set(handles.lblBValue1, 'String', num2str(fBValue, 3));
  set(handles.lblAValue1, 'String', num2str(fAValue, 3));
  set(handles.lblStdValue1, 'String', num2str(fStdDev, 3));
  set(handles.lblBValue2, 'String', '');
  set(handles.lblAValue2, 'String', '');
  set(handles.lblStdValue2, 'String', '');
  % Plot the cumulative number
  [vDummy, vIndices] = sort(mPlotCatalog(:,3));
  mSortedCatalog = mPlotCatalog(vIndices(:,1),:) ;
  axes(axsTimePlot)
  hPlotTime = plot(mSortedCatalog(:,3),(1:length(mSortedCatalog(:,3))),'k-','era','xor');
else
  % Split the catalog
  fFirst = str2double(get(handles.txtFirst, 'String'));
  fSecond = str2double(get(handles.txtSecond, 'String'));
  fSplit = str2double(get(handles.txtSplit, 'String'));
  [mPlotFirst, mPlotSecond] = ex_SplitCatalog(mPlotCatalog, fSplit, 1, fFirst, 1, fSecond);
  [mTestFirst, mTestSecond] = ex_SplitCatalog(mTestCatalog, fSplit, 1, fFirst, 1, fSecond);
  % Plot the frequency magnitude distribution for the first period
  [hPlotFMD1, fBValueFirst, fAValue, fStdDev] = plot_FMD(mPlotFirst, 1, axsFMD, 's', 'k', 1, handles.params.rOptions(1).nCalculateMC);
  set(hPlotFMD1, 'MarkerSize', 3);
  set(handles.lblBValue1, 'String', num2str(fBValueFirst, 3));
  set(handles.lblAValue1, 'String', num2str(fAValue, 3));
  set(handles.lblStdValue1, 'String', num2str(fStdDev, 3));
  % Plot the frequency magnitude distribution for the second period
  set(axsFMD, 'NextPlot', 'add');
  [hPlotFMD2, fBValueSecond, fAValue, fStdDev] = plot_FMD(mPlotSecond, 1, axsFMD, '^', 'r', 1, handles.params.rOptions(1).nCalculateMC);
  set(hPlotFMD2, 'MarkerSize', 3);
  set(handles.lblBValue2, 'String', num2str(fBValueSecond, 3));
  set(handles.lblAValue2, 'String', num2str(fAValue, 3));
  set(handles.lblStdValue2, 'String', num2str(fStdDev, 3));

  % Plot the forecast test
  [hPlotTest1] = plot_FMD(mTestSecond, 0, axsTest, 'o', 'b', 0, 1);
  set(hPlotTest1, 'MarkerSize', 4);
  set(axsTest, 'NextPlot', 'add');
  % Calculate Mc
  fMc = calc_Mc(mPlotFirst, handles.params.rOptions(1).nCalculateMC);
  if isnan(fMc)
    fMc = handles.params.fMcOverall;
  elseif isempty(fMc)
    fMc = handles.params.fMcOverall;
  end
  % Define magnitude range for testing
  if handles.params.bMinMagMc
    fMinMag = fMc;
  else
    fMinMag = handles.params.fMinMag;
  end

  % Perform the test
  [fDeltaProbability, fProbabilityN, fProbabilityH, mPredictionFMD, vObservedFMD, vMagnitudeBins, vProbH, vProbN] ...
    = pt_poissonian(mTestFirst, fFirst, mTestSecond, fSecond, handles.params.rOptions(3).nMinimumNumber, ...
    fBValueFirst, handles.params.mValueGrid(1,9), 1.1, 1.1, handles.params.fMinMag, handles.params.fMaxMag);

  set(handles.txtProbK, 'String', num2str(fProbabilityN));
  set(handles.txtProbO, 'String', num2str(fProbabilityH));
  set(handles.txtProbDiff, 'String', num2str(fDeltaProbability));
  % Plot the results
  vX = (fMinMag:0.1:handles.params.fMaxMag)';
  hPlotTest2 = semilogy(vX, mPredictionFMD(:,1), 'r');
  hPlotTest3 = semilogy(vX, mPredictionFMD(:,2), 'k');
  set(axsTest, 'NextPlot', 'replace');
  axes(axsLikelihood);
  hPlotLike1 = plot(vX,cumsum((vProbN)),'k','LineWidth',2.0);
  set(axsLikelihood, 'NextPlot', 'add');
  hPlotLike2 = plot(vX,cumsum((vProbH)),'r','LineWidth',2.0);
  set(axsLikelihood, 'NextPlot', 'replace');
  vXLim = get(axsTest, 'XLim');
  set(axsLikelihood, 'XLim', vXLim);

  % Normalize the two subcatalogs in time
  fMinTime = min(mTestFirst(:,3));
  mTestFirst(:,3) = mTestFirst(:,3) - fMinTime;
  fMinTime = min(mTestSecond(:,3));
  mTestSecond(:,3) = mTestSecond(:,3) - fMinTime;
  % Plot the cumulative number for the first period
  [vDummy, vIndices] = sort(mTestFirst(:,3));
  mSortedCatalog = mTestFirst(vIndices(:,1),:) ;
  axes(axsTimePlot)
  hPlotTime1 = plot(mSortedCatalog(:,3),(1:length(mSortedCatalog(:,3))),'k-','era','xor');
  % Plot the cumulative number for the second period
  [vDummy, vIndices] = sort(mTestSecond(:,3));
  mSortedCatalog = mTestSecond(vIndices(:,1),:) ;
  axes(axsTimePlot)
  set(axsTimePlot, 'NextPlot', 'add');
  hPlotTime2 = plot(mSortedCatalog(:,3),(1:length(mSortedCatalog(:,3))),'r:','era','xor');
  if get(handles.chkExternalPlotting, 'Value') == 1
    gui_export.hPlotFMD = hPlotFMD;
    gui_export.hPlotFMD1 = hPlotFMD1;
    gui_export.hPlotFMD2 = hPlotFMD2;
    gui_export.hPlotTime = hPlotTime;
    gui_export.hPlotTime1 = hPlotTime1;
    gui_export.hPlotTime2 = hPlotTime2;
    gui_export.hPlotTest1 = hPlotTest1;
    gui_export.hPlotTest2 = hPlotTest2;
    gui_export.hPlotTest3 = hPlotTest3;
    gui_export.hPlotLike1 = hPlotLike1;
    gui_export.hPlotLike2 = hPlotLike2;
    assignin('base', 'gui_export', gui_export);
  end
end

% --------------------------------------------------------------------
function varargout = radEntireCatalog_Callback(h, eventdata, handles, varargin)

if get(handles.radEntireCatalog, 'Value') == 1
  set(handles.radPickLocations, 'Value', 0);
  set(handles.btnPick, 'Enable', 'off');
else
  set(handles.radPickLocations, 'Value', 1);
  set(handles.btnPick, 'Enable', 'on');
end

% --------------------------------------------------------------------
function varargout = radPickLocations_Callback(h, eventdata, handles, varargin)

if get(handles.radPickLocations, 'Value') == 1
  set(handles.radEntireCatalog, 'Value', 0);
  set(handles.btnPick, 'Enable', 'on');
else
  set(handles.radEntireCatalog, 'Value', 1);
  set(handles.btnPick, 'Enable', 'off');
end

% --------------------------------------------------------------------
function varargout = radEntireTime_Callback(h, eventdata, handles, varargin)

if get(handles.radEntireTime, 'Value') == 1
  set(handles.radSplitPeriods, 'Value', 0);
  set(handles.txtFirst, 'Enable', 'off');
  set(handles.txtSecond, 'Enable', 'off');
  set(handles.txtSplit, 'Enable', 'off');
else
  set(handles.radSplitPeriods, 'Value', 1);
  set(handles.txtFirst, 'Enable', 'on');
  set(handles.txtSecond, 'Enable', 'on');
  set(handles.txtSplit, 'Enable', 'on');
end

% --------------------------------------------------------------------
function varargout = radSplitPeriods_Callback(h, eventdata, handles, varargin)

if get(handles.radSplitPeriods, 'Value') == 1
  set(handles.radEntireTime, 'Value', 0);
  set(handles.txtFirst, 'Enable', 'on');
  set(handles.txtSecond, 'Enable', 'on');
  set(handles.txtSplit, 'Enable', 'on');
else
  set(handles.radEntireTime, 'Value', 1);
  set(handles.txtFirst, 'Enable', 'off');
  set(handles.txtSecond, 'Enable', 'off');
  set(handles.txtSplit, 'Enable', 'off');
end

% --------------------------------------------------------------------
function varargout = btnRePlot_Callback(h, eventdata, handles, varargin)

plotit(handles, []);

% --------------------------------------------------------------------
function varargout = btnClose_Callback(h, eventdata, handles, varargin)

% Close the dialog
delete(handles.dlgAnalyze);

% --------------------------------------------------------------------
function varargout = btnPick_Callback(h, eventdata, handles, varargin)

% Get the axes handle of the plotwindow
axes(pf_result('GetAxesHandle', handles.hParentFigure, [], guidata(handles.hParentFigure)));

% Select a point in the plot window with the mouse
[fX, fY] = ginput(1);
set(handles.txtXSelect, 'String', num2str(fX));
set(handles.txtYSelect, 'String', num2str(fY));

pickit(handles, fX, fY);

% --------------------------------------------------------------------
function varargout = btnSelect_Callback(h, eventdata, handles, varargin)

fX = str2double(get(handles.txtXSelect, 'String'));
fY = str2double(get(handles.txtYSelect, 'String'));
pickit(handles, fX, fY);

% --------------------------------------------------------------------
function pickit(handles, fX, fY)

mNodeCatalog = ex_CreateNodeCatalog(handles.params.mCatalog, [fX fY], handles.params.bMap, handles.params.rOptions(1).nGriddingMode, ...
  handles.params.rOptions(1).nNumberEvents, handles.params.rOptions(1).fRadius, handles.params.rOptions(1).fSizeRectX, handles.params.rOptions(1).fSizeRectY);

mNodeTestCatalog = ex_CreateNodeCatalog(handles.params.mCatalog, [fX fY], handles.params.bMap, handles.params.rOptions(3).nGriddingMode, ...
  handles.params.rOptions(3).nNumberEvents, handles.params.rOptions(3).fRadius, handles.params.rOptions(3).fSizeRectX, handles.params.rOptions(3).fSizeRectY);

% Store the subcatalogs for later use
handles.mNodeCatalog = mNodeCatalog;
handles.mNodeTestCatalog = mNodeTestCatalog;
guidata(handles.dlgAnalyze, handles);

% Export the node catalog
gui_export.mNodeCatalog = mNodeCatalog;
gui_export.mTestCatalog = mNodeTestCatalog;
gui_export.fX = fX;
gui_export.fY = fY;
gui_export.handles = handles;
assignin('base', 'gui_export', gui_export);

% Replot the frequency magnitude distribution and cumulative number
plotit(handles, gui_export);


