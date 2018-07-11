function varargout = kj_analyze(varargin)
% KJ_ANALYZE Application M-file for kj_analyze.fig
%    FIG = KJ_ANALYZE launch kj_analyze GUI.
%    KJ_ANALYZE('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 25-Oct-2001 09:38:02

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
    fSplit = ((max(handles.params.mCatalog.Date) - min(handles.params.mCatalog.Date)) / 2) + min(handles.params.mCatalog.Date);
  end
  set(handles.txtSplit, 'String', num2str(fSplit, 6));

  % Set the length of the learning period if available
  try
    set(handles.txtFirst, 'String', num2str(handles.params.fLearning));
  catch
    set(handles.txtFirst, 'String', '1');
  end

  % Set the length of the forecasting period if available
  try
    set(handles.txtSecond, 'String', num2str(handles.params.fForecast));
  catch
    set(handles.txtSecond, 'String', '1');
  end

  plotit(handles);

  guidata(fig, handles);

  if nargout > 0
    varargout{1} = fig;
  end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

  try
    [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
  catch ME
    disp(ME.message);
  end

end

% --------------------------------------------------------------------
function plotit(handles)

% Plot the frequency magnitude distribution
if get(handles.radEntireCatalog, 'Value') == 1
  mPlotCatalog = handles.params.mCatalog;
else
  mPlotCatalog = handles.mNodeCatalog;
end

axes(handles.axsFMD);
set(handles.axsFMD, 'NextPlot', 'replace');
set(handles.axsTimePlot, 'NextPlot', 'replace');
if get(handles.radEntireTime, 'Value') == 1
  % Plot the frequency magnitude distribution
  [fBValue, fAValue, fStdDev] = plot_FMD(mPlotCatalog,...
    'Axes',handles.axsFMD, 'CalcMc', handles.params.nCalculateMC, 'MarkerSize', 10);
  set(handles.lblBValue1, 'String', num2str(fBValue, 3));
  set(handles.lblAValue1, 'String', num2str(fAValue, 3));
  set(handles.lblStdValue1, 'String', num2str(fStdDev, 3));
  set(handles.lblBValue2, 'String', '');
  set(handles.lblAValue2, 'String', '');
  set(handles.lblStdValue2, 'String', '');
  % Plot the cumulative number
  [~, vIndices] = sort(mPlotCatalog(:,3));
  mSortedCatalog = mPlotCatalog(vIndices(:,1),:) ;
  axes(handles.axsTimePlot)
  plot(mSortedCatalog(:,3),(1:length(mSortedCatalog(:,3))),'k-');
else
  % Split the catalog
  fFirst = str2double(get(handles.txtFirst, 'String'));
  fSecond = str2double(get(handles.txtSecond, 'String'));
  fSplit = str2double(get(handles.txtSplit, 'String'));
  [mFirst, mSecond] = ex_SplitCatalog(mPlotCatalog, fSplit, 1, fFirst, 1, fSecond);
  % Plot the frequency magnitude distribution for the first period
  [fBValue, fAValue, fStdDev] = plot_FMD(mFirst, 'Axes', handles.axsFMD, ...
      'CalcMethod',handles.params.nCalculateMC, 'MarkerSize', 3);
  set(handles.lblBValue1, 'String', num2str(fBValue, 3));
  set(handles.lblAValue1, 'String', num2str(fAValue, 3));
  set(handles.lblStdValue1, 'String', num2str(fStdDev, 3));
  % Plot the frequency magnitude distribution for the second period
  set(handles.axsFMD, 'NextPlot', 'add');
  [fBValue, fAValue, fStdDev] = plot_FMD(mSecond, 'Axes', handles.axsFMD,...
      'Marker','^', 'Color','r', 'CalcMethod', handles.params.nCalculateMC,'MarkerSize',3);
  set(handles.lblBValue2, 'String', num2str(fBValue, 3));
  set(handles.lblAValue2, 'String', num2str(fAValue, 3));
  set(handles.lblStdValue2, 'String', num2str(fStdDev, 3));

  % Plot the Kagan & Jackson test
  plot_FMD(mSecond, 'ShowCumulative', false, 'Axes', handles.axsTest, 'Marker','o', 'Color', 'b', 'MarkerSize', 4);
  set(handles.axsTest, 'NextPlot', 'add');
  % Calculate Mc
  fMc = calc_Mc(mPlotCatalog, handles.params.nCalculateMC);
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
  [fDeltaProbability, fProbabilityK, fProbabilityO, fWeightK, fWeightO, fBValueO, vProbK, vProbO, mPredictionFMD] ...
    = kj_poissonian(mFirst, handles.params.fLearning, mSecond, handles.params.fForecast, handles.params.nTestMethod, ...
    handles.params.nMinimumNumber, fMc, handles.params.fBValueOverall, handles.params.fStdDevOverall, ...
    fMinMag, handles.params.fMaxMag, 1);
  set(handles.txtProbK, 'String', num2str(fProbabilityK));
  set(handles.txtProbO, 'String', num2str(fProbabilityO));
  set(handles.txtProbDiff, 'String', num2str(fDeltaProbability));
  % Plot the results
  vX = (fMinMag:0.1:handles.params.fMaxMag)';
  semilogy(vX, mPredictionFMD(:,1), 'r');
  semilogy(vX, mPredictionFMD(:,2), 'k');
  set(handles.axsTest, 'NextPlot', 'replace');
  axes(handles.axsLikelihood);
  pl1 = plot(vX,cumsum((vProbK)),'k','LineWidth',2.0);
  set(handles.axsLikelihood, 'NextPlot', 'add');
  pl1 = plot(vX,cumsum((vProbO)),'r','LineWidth',2.0);
  set(handles.axsLikelihood, 'NextPlot', 'replace');
  vXLim = get(handles.axsTest, 'XLim');
  set(handles.axsLikelihood, 'XLim', vXLim);

  % Normalize the two subcatalogs in time
  fMinTime = min(mFirst(:,3));
  mFirst(:,3) = mFirst(:,3) - fMinTime;
  fMinTime = min(mSecond(:,3));
  mSecond(:,3) = mSecond(:,3) - fMinTime;
  % Plot the cumulative number for the first period
  [~, vIndices] = sort(mFirst(:,3));
  mSortedCatalog = mFirst(vIndices(:,1),:) ;
  axes(handles.axsTimePlot)
  plot(mSortedCatalog(:,3),(1:length(mSortedCatalog(:,3))),'k-');
  % Plot the cumulative number for the second period
  [~, vIndices] = sort(mSecond(:,3));
  mSortedCatalog = mSecond(vIndices(:,1),:) ;
  axes(handles.axsTimePlot)
  set(handles.axsTimePlot, 'NextPlot', 'add');
  plot(mSortedCatalog(:,3),(1:length(mSortedCatalog(:,3))),'r:');
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

plotit(handles);

% --------------------------------------------------------------------
function varargout = btnClose_Callback(h, eventdata, handles, varargin)

% Close the dialog
delete(handles.dlgAnalyze);

% --------------------------------------------------------------------
function varargout = btnPick_Callback(h, eventdata, handles, varargin)

% Get the axes handle of the plotwindow
axes(kj_result('GetAxesHandle', handles.hParentFigure, [], guidata(handles.hParentFigure)));

% Select a point in the plot window with the mouse
[fX, fY] = ginput(1);

% Prepare the data
% If cross-section calculate the lenght along cross-section
if ~handles.params.bMap
  [nRow, nColumn] = size(handles.params.mCatalog);
  xsecx2 = handles.params.mCatalog(:,nColumn);  % length along x-section
  xsecy2 = handles.params.mCatalog.Depth;        % depth of hypocenters
end

% Calculate distance from center point and sort with distance
if handles.params.bMap
  vDistances = sqrt(((handles.params.mCatalog.Longitude-fX)*cosd(fY)*111).^2 + ((handles.params.mCatalog.Latitude-fY)*111).^2);
else
  vDistances = sqrt(((xsecx2 - fX)).^2 + ((xsecy2 + fY)).^2);
end

% Create the subcatalog
if handles.params.bNumber
  % Use first nNumberEvents events
  [vTmp, vIndices] = sort(vDistances);
  mNodeCatalog = handles.params.mCatalog.subset(vIndices);
  mNodeCatalog = mNodeCatalog(1:handles.params.nNumberEvents);
else
  % Use all events within fRadius
  vSelection = (vDistances <= handles.params.fRadius);
  mNodeCatalog = handles.params.mCatalog.subset(vSelection);
end

% Store the subcatalog for later use
handles.mNodeCatalog = mNodeCatalog;
guidata(handles.dlgAnalyze, handles);

% Replot the frequency magnitude distribution and cumulative number
plotit(handles);
