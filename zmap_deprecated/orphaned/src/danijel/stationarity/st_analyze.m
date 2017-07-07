function varargout = st_analyze(varargin)
% KJ_ANALYZE Application M-file for kj_analyze.fig
%    FIG = KJ_ANALYZE launch kj_analyze GUI.
%    KJ_ANALYZE('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 20-Aug-2003 09:47:18

if (nargin == 2) & ~ischar(varargin{1})  % LAUNCH GUI

  fig = openfig(mfilename);

  % Use system color scheme for figure:
  set(fig,'Color',get(groot,'defaultUicontrolBackgroundColor'));

  % Generate a structure of handles to pass to callbacks, and store it.
  handles = guihandles(fig);
  % Store the data
  handles.params = varargin{1};
  handles.hParentFigure = varargin{2};

  % Do a first plot with default values
  plotit(handles);

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
  [hPlot, fBValue, fAValue, fStdDev, fMc] = plot_FMD(mPlotCatalog, 1, handles.axsFMD, 's', 'k', 1, handles.params.rOptions.nCalculateMC, handles.params.rOptions.fBinning);
  set(hPlot, 'MarkerSize', 10);
  sList = [cellstr('Entire time')];
  sList = [sList; cellstr(['     Mc: ' num2str(fMc)])];
  sList = [sList; cellstr(['b-value: ' num2str(fBValue)])];
  sList = [sList; cellstr(['a-value: ' num2str(fAValue)])];
  sList = [sList; cellstr(['std-dev: ' num2str(fStdDev)])];
  set(handles.lstValues, 'String', sList);
  % Plot the cumulative number
  [vDummy, vIndices] = sort(mPlotCatalog(:,3));
  mSortedCatalog = mPlotCatalog(vIndices(:,1),:) ;
  axes(handles.axsTimePlot)
  plot(mSortedCatalog(:,3),(1:length(mSortedCatalog(:,3))),'k-','era','xor');
else
  % Separate first catalog
  vSel_ = ((mPlotCatalog(:,3) >= handles.params.fStartFirstPeriod) & (mPlotCatalog(:,3) <= handles.params.fEndFirstPeriod));
  mFirst = mPlotCatalog(vSel_,:);

  % Separate second catalog
  vSel_ = ((mPlotCatalog(:,3) >= handles.params.fStartSecondPeriod) & (mPlotCatalog(:,3) <= handles.params.fEndSecondPeriod));
  mSecond = mPlotCatalog(vSel_,:);

  % Plot the frequency magnitude distribution for the first period
  [hPlot, fBValue1, fAValue, fStdDev, fMc] = plot_FMD(mFirst, 1, handles.axsFMD, 's', 'k', 1, handles.params.rOptions.nCalculateMC, handles.params.rOptions.fBinning);
  set(hPlot, 'MarkerSize', 3);
  sList = [cellstr('First period')];
  sList = [sList; cellstr(['     Mc: ' num2str(fMc)])];
  sList = [sList; cellstr(['b-value: ' num2str(fBValue1)])];
  sList = [sList; cellstr(['a-value: ' num2str(fAValue)])];
  sList = [sList; cellstr(['std-dev: ' num2str(fStdDev)])];
  sList = [sList; cellstr('')];
  % Plot the frequency magnitude distribution for the second period
  set(handles.axsFMD, 'NextPlot', 'add');
  [hPlot, fBValue2, fAValue, fStdDev, fMc] = plot_FMD(mSecond, 1, handles.axsFMD, '^', 'r', 1, handles.params.rOptions.nCalculateMC, handles.params.rOptions.fBinning);
  set(hPlot, 'MarkerSize', 3);
  sList = [sList; cellstr('Second period')];
  sList = [sList; cellstr(['     Mc: ' num2str(fMc)])];
  sList = [sList; cellstr(['b-value: ' num2str(fBValue2)])];
  sList = [sList; cellstr(['a-value: ' num2str(fAValue)])];
  sList = [sList; cellstr(['std-dev: ' num2str(fStdDev)])];
  sList = [sList; cellstr('')];
  sList = [sList; cellstr(['Delta-b: ' num2str(fBValue2-fBValue1)])];
  set(handles.lstValues, 'String', sList);

  % Normalize the two subcatalogs in time
  fMinTime = min(mFirst(:,3));
  mFirst(:,3) = mFirst(:,3) - fMinTime;
  fMinTime = min(mSecond(:,3));
  mSecond(:,3) = mSecond(:,3) - fMinTime;
  % Plot the cumulative number for the first period
  [vDummy, vIndices] = sort(mFirst(:,3));
  mSortedCatalog = mFirst(vIndices(:,1),:) ;
  axes(handles.axsTimePlot)
  plot(mSortedCatalog(:,3),(1:length(mSortedCatalog(:,3))),'k-','era','xor');
  % Plot the cumulative number for the second period
  [vDummy, vIndices] = sort(mSecond(:,3));
  mSortedCatalog = mSecond(vIndices(:,1),:) ;
  axes(handles.axsTimePlot)
  set(handles.axsTimePlot, 'NextPlot', 'add');
  plot(mSortedCatalog(:,3),(1:length(mSortedCatalog(:,3))),'r:','era','xor');
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
else
  set(handles.radSplitPeriods, 'Value', 1);
end

% --------------------------------------------------------------------
function varargout = radSplitPeriods_Callback(h, eventdata, handles, varargin)

if get(handles.radSplitPeriods, 'Value') == 1
  set(handles.radEntireTime, 'Value', 0);
else
  set(handles.radEntireTime, 'Value', 1);
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
axes(pf_result('GetAxesHandle', handles.hParentFigure, [], guidata(handles.hParentFigure)));

% Select a point in the plot window with the mouse
[fX, fY] = ginput(1);

pickit(handles, fX, fY);

% --------------------------------------------------------------------
function varargout = btnSelect_Callback(h, eventdata, handles, varargin)

fX = str2double(get(handles.txtXSelect, 'String'));
fY = str2double(get(handles.txtYSelect, 'String'));
pickit(handles, fX, fY);

% --------------------------------------------------------------------
function pickit(handles, fX, fY)

% Prepare the data
% If cross-section calculate the lenght along cross-section
if ~handles.params.bMap
  [nRow, nColumn] = size(handles.params.mCatalog);
  xsecx2 = handles.params.mCatalog(:,nColumn);  % length along x-section
  xsecy2 = handles.params.mCatalog(:,7);        % depth of hypocenters
end

% Calculate distance from center point and sort with distance
if handles.params.bMap
  vDistances = sqrt(((handles.params.mCatalog(:,1)-fX)*cos(pi/180*fY)*111).^2 + ((handles.params.mCatalog(:,2)-fY)*111).^2);
else
  vDistances = sqrt(((xsecx2 - fX)).^2 + ((xsecy2 + fY)).^2);
end

% Create the subcatalog
if handles.params.rOptions.nGriddingMode == 0
  % Use first nNumberEvents events
  [vTmp, vIndices] = sort(vDistances);
  mNodeCatalog = handles.params.mCatalog(vIndices,:);
  mNodeCatalog = mNodeCatalog(1:handles.params.nNumberEvents);
else
  % Use all events within fRadius
  vSelection = (vDistances <= handles.params.rOptions(1).fRadius);
  mNodeCatalog = handles.params.mCatalog(vSelection,:);
end

% Store the subcatalog for later use
handles.mNodeCatalog = mNodeCatalog;
guidata(handles.dlgAnalyze, handles);

% Export the node catalog
gui_export.mNodeCatalog = mNodeCatalog;
gui_export.fX = fX;
gui_export.fY = fY;
assignin('base', 'gui_export', gui_export);

% Replot the frequency magnitude distribution and cumulative number
plotit(handles);

% --------------------------------------------------------------------
function varargout = btnBWithTime_Callback(h, eventdata, handles, varargin)

axes(handles.axsBWithTime);
set(handles.axsBWithTime, 'NextPlot', 'replace');

%mCatalog = handles.mNodeCatalog;

fMcMin = str2double(get(handles.txtMcMin, 'String'));
fMcStep = str2double(get(handles.txtMcStep, 'String'));
fMcMax = str2double(get(handles.txtMcMax, 'String'));

nSteps = (fMcMax - fMcMin)/fMcStep + 1;
mColors = gui_Colormap_RedGrayBlue(nSteps);
nStep = 1;
for nMag = fMcMin:fMcStep:fMcMax
  vSel = handles.mNodeCatalog(:,6) >= nMag-0.0001;
  mCatalog = handles.mNodeCatalog(vSel,:);
% Defaults and inits
BV = [];
BV3 = [];
Nmin = 50;
nNumberEvents = str2double(get(handles.txtNumberEvents, 'String'));
nOverlap = str2double(get(handles.txtOverlap, 'String'));

for nCnt = 1:nNumberEvents/nOverlap:length(mCatalog) - nNumberEvents
    b = mCatalog(nCnt:nCnt + nNumberEvents,:);
    magco = min(b(:,6));
    l = b(:,6) >= magco-0.05;
    if length(b(l,:)) >= Nmin
        [uDummy bv stan,  uDummy] = bmemag(b(l,:));
    else
        bv = nan;
    end
    BV = [BV ; bv min(b(:,3)) ; bv max(b(:,3)) ; inf inf];
    BV3 = [BV3 ; bv mean(b(:,3)) stan ];
end

% Errorbar plot
hErrorbar = errorbar(BV3(:,2),BV3(:,1),BV3(:,3),BV3(:,3),'k');
set(hErrorbar(1), 'Color', [0.5 0.5 0.5], 'Linewidth', 1);
set(hErrorbar(2), 'Linewidth', 2, 'Color', mColors(nStep,:));
%
% % Timebar plot
% hTimebar = plot(BV(:,2),BV(:,1),'color',[0.5 0.5 0.5], 'Linewidth', 1);

% Values plot
%hValues = plot(BV3(:,2),BV3(:,1),'s');
%set(hValues,'LineWidth', 1, 'MarkerSize', 4,...
%    'MarkerFaceColor','w','MarkerEdgeColor','k','Marker','s');

  nStep = nStep + 1;
  set(handles.axsBWithTime, 'NextPlot', 'add');
end
