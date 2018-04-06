function varargout = kj_result(varargin)
% KJ_RESULT Application M-file for kj_result.fig
%    FIG = KJ_RESULT launch kj_result GUI.
%    KJ_RESULT('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 29-Oct-2001 12:23:08

if (nargin == 1) & ~ischar(varargin{1})  % LAUNCH GUI

  fig = openfig(mfilename,'reuse');

  % Use system color scheme for figure:
  set(fig,'Color',get(groot,'defaultUicontrolBackgroundColor'));

  % Generate a structure of handles to pass to callbacks, and store it.
  handles = guihandles(fig);
  % Create the figure-window
  handles.hPlotFigure = figure_w_normalized_uicontrolunits('Name', 'Kagan & Jackson Test', 'NumberTitle', 'off');
  handles.hMainAxes = newplot;
  % Store the datasets internally
  handles.vResult = varargin{1}(1);
  handles.vResults = varargin{1};
  % Set up the listbox with descriptions of the stored datasets
  sList = [];
  for nCnt = 1:length(handles.vResults)
    result = handles.vResults(nCnt);
    if result.bNumber
      sLine = ['Number: ' num2str(result.nNumberEvents)];
    else
      sLine = ['Radius: ' num2str(result.fRadius)];
    end
    sLine = [sLine ' GetMc: ' num2str(result.nCalculateMC)];
    sLine = [sLine ' Min #: ' num2str(result.nMinimumNumber)];
    sLine = [sLine ' Grid (Hor/Dep)(Lon/Lat): ' num2str(result.fSpacingHorizontal) '/' num2str(result.fSpacingDepth)];
    try
      sLine = [sLine ' Learn: ' num2str(result.fLearning)];
    catch
    end
    try
      sLine = [sLine ' Split: ' num2str(result.fSplitTime)];
    catch
    end
    try
      sLine = [sLine ' Fore: ' num2str(result.fForecast)];
    catch
    end
    try
      if result.bRandom
        sLine = [sLine ' Sim #:' num2str(result.nCalculation)];
      end
    catch
    end
    try
      sLine = [sLine ' Sig:' num2str(result.vSignificanceLevel)];
      sLine = [sLine ' NSig:' num2str(result.vNormSignificanceLevel)];
    catch
    end
    sList = [sList; cellstr(sLine)];
  end
  set(handles.lstSets, 'String', sList);
  set(handles.lstSets, 'Value', 1);

  guidata(fig, handles);
  % Plot the very first dataset and map
  plotit(handles)

  try
    if length(varargin{1}) > 1
      set(handles.lstMaps, 'String', varargin{1}(1).vcsGridNames);
    else
      set(handles.lstMaps, 'String', varargin{1}.vcsGridNames);
    end
  catch
  end

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
function varargout = btnClose_Callback(h, eventdata, handles, varargin)

% Closes plot-figure and this figure
try
  delete(handles.hPlotFigure);
catch
end
delete(handles.dlgResult);

% --------------------------------------------------------------------
function plotit(handles)

try
  % Get selected dataset
  handles.vResult = handles.vResults(get(handles.lstSets, 'Value'));

  % Create new values for plotting
  nIdx = get(handles.lstMaps, 'Value');
  vTmp = nan(length(handles.vResult.vX) * length(handles.vResult.vY), 1);
  vTmp(handles.vResult.vUsedNodes) = handles.vResult.mValueGrid(:,nIdx);
  handles.mPlotValues = reshape(vTmp, length(handles.vResult.vY), length(handles.vResult.vX));

  % Renew plot
  figure_w_normalized_uicontrolunits(handles.hPlotFigure);
  delete(handles.hMainAxes);
  handles.hMainAxes = newplot;
  set(handles.hPlotFigure, 'renderer', 'zbuffer');

  % Plot data
  surface(handles.vResult.vX, handles.vResult.vY, zeros(size(handles.mPlotValues)), handles.mPlotValues, 'Parent', handles.hMainAxes);
  axis(handles.hMainAxes, 'image');
  if get(handles.chkInterpolated, 'Value') == 1
    shading(handles.hMainAxes, 'interp');
  end
  set(handles.hMainAxes, 'box', 'on');
  hold on;
  if get(handles.chkSeismicity, 'Value') == 1
    if handles.vResult.bMap
      handles.hEQPlot = plot(handles.vResult.mCatalog.Longitude,handles.vResult.mCatalog.Latitude,'.k','MarkerSize',6,'Marker','.','Color','k','Visible','on');
    else
      handles.hEQPlot = plot(handles.vResult.mCatalog(:,length(handles.vResult.mCatalog.subset(1))),-handles.vResult.mCatalog.Depth,'.k','MarkerSize',6,'Marker','.','Color','k','Visible','on');
    end
  end
  % Set information values
  set(handles.lblMin, 'String', num2str(min(min(handles.mPlotValues)), 3));
  set(handles.lblMax, 'String', num2str(max(max(handles.mPlotValues)), 3));
  set(handles.lblMean, 'String', num2str(nanmean(handles.vResult.mValueGrid(:,nIdx)), 3));
  if get(handles.chkKeepColormap, 'Value') == 0
    set(handles.txtMin, 'String', num2str(min(min(handles.mPlotValues)), 3));
    set(handles.txtMax, 'String', num2str(max(max(handles.mPlotValues)), 3));
  end

  % Set limits
  fLimMin = str2double(get(handles.txtMin, 'String'));
  if (isnan(fLimMin) | isinf(fLimMin))
    fLimMin = min(min(handles.mPlotValues));
    if isnan(fLimMin)
      fLimMin = 0;
    elseif isinf(fLimMin) % Set to the lowest non-inf value
      mSelection = ~isinf(handles.mPlotValues);
      mNoInfValues = handles.mPlotValues(mSelection);
      fLimMin = min(mNoInfValues(:));
    end
    set(handles.txtMin, 'String', num2str(fLimMin, 3));
  end
  fLimMax = str2double(get(handles.txtMax, 'String'));
  if (isnan(fLimMax) | isinf(fLimMax))
    fLimMax = max(max(handles.mPlotValues));
    if isnan(fLimMax)
      fLimMax = 1;
    elseif isinf(fLimMax) % Set to the highest non-inf value
      mSelection = ~isinf(handles.mPlotValues);
      mNoInfValues = handles.mPlotValues(mSelection);
      fLimMax = max(mNoInfValues(:));
    end
    set(handles.txtMax, 'String', num2str(fLimMax, 3));
  end
  % If both of the values have the same value, colorbar is causing trouble
  if fLimMax == fLimMin
    fLimMax = fLimMax + 0.001;
  end
  set(handles.hMainAxes, 'CLim', [fLimMin fLimMax]);

  % Create a new colorbar
  nColormap = get(handles.lstColormap, 'Value');
  switch nColormap
  case  1, vColormap = autumn;
  case  2, vColormap = bone;
  case  3, vColormap = colorcube;
  case  4, vColormap = cool;
  case  5, vColormap = copper;
  case  6, vColormap = flag;
  case  7, vColormap = gray;
  case  8, vColormap = hot;
  case  9, vColormap = hsv;
  case 10, vColormap = jet;
  case 11, vColormap = lines;
  case 12, vColormap = pink;
  case 13, vColormap = prism;
  case 14, vColormap = spring;
  case 15, vColormap = summer;
  case 16, vColormap = white;
  case 17, vColormap = winter;
  otherwise, vColormap = jet;
  end
  if get(handles.chkColorscale, 'Value') == 0
    nLimit = str2double(get(handles.txtScaleLimit, 'String'));
    if (isnan(nLimit)) | (nLimit ~= round(nLimit))
      nLimit = 20;
      set(handles.txtScaleLimit, 'String', num2str(nLimit));
    end
    vColormap = ex_dcolor(vColormap, nLimit);
  end
  colormap(handles.hMainAxes, vColormap);
  handles.hColorBar = colorbar('horiz', 'peer', handles.hMainAxes);

  % Save changes
  guidata(handles.dlgResult, handles);
catch
end

% --------------------------------------------------------------------
function varargout = btnSave_Callback(h, eventdata, handles, varargin)

% Save the data
[newfile, newpath] = uiputfile('result.mat','Save calculated Kagan & Jackson Test data');
newfile = [newpath newfile];
if length(newfile) > 1
  vResults = handles.vResults;
  save(newfile);
end

% --------------------------------------------------------------------
function varargout = update_Callback(h, eventdata, handles, varargin)

plotit(handles);

% --------------------------------------------------------------------
function varargout = btnAnalyze_Callback(h, eventdata, handles, varargin)

handles.hAnalyzeFigure = kj_analyze(handles.vResult, handles.dlgResult);
guidata(handles.dlgResult, handles);

% --------------------------------------------------------------------
function varargout = GetAxesHandle(h, eventdata, handles, varargin)

varargout{1} = handles.hMainAxes;
