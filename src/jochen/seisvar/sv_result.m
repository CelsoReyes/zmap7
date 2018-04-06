function varargout = sv_result(varargin)

if (nargin == 1) & ~ischar(varargin{1})  % LAUNCH GUI

  fig = openfig(mfilename,'reuse');

  % Generate a structure of handles to pass to callbacks, and store it.
  handles = guihandles(fig);
  % Create the figure-window
  handles.hPlotFigure = figure_w_normalized_uicontrolunits('Name', 'Result plot', 'NumberTitle', 'off');
  handles.hMainAxes = newplot;
  % Store the datasets internally
  handles.vResult = varargin{1}(1);
  handles.vResults = varargin{1};
  % Set up the listbox with descriptions of the stored datasets
  sList = [];
  for nCnt = 1:length(handles.vResults)
    result = handles.vResults(nCnt);
    try
      sList = [sList; cellstr(result.sComment)];
    catch
      sList = [sList; cellstr(num2str(nCnt))];
    end
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
  handles.hSurface = surface(handles.vResult.vX, handles.vResult.vY, zeros(size(handles.mPlotValues)), handles.mPlotValues, 'Parent', handles.hMainAxes);
  axis(handles.hMainAxes, 'image');
  if get(handles.chkInterpolated, 'Value') == 1
    shading(handles.hMainAxes, 'interp');
  else
      set(handles.hSurface,'Edgecolor','none');
  end
  set(handles.hMainAxes, 'box', 'on');
  hold on;

  % Plotting coastline & faults
  if handles.vResult.bMap
    if get(handles.chkCoastlines, 'Value') == 1
      try
        handles.hCoastline = plot(handles.vResult.vCoastline(:,1), handles.vResult.vCoastline(:,2),'LineWidth',1.0,'Color',[0  0  0 ]);
      catch
      end
    end
    if get(handles.chkFaults, 'Value') == 1
      try
        handles.hFaults = plot(handles.vResult.vFaults(:,1), handles.vResult.vFaults(:,2),'k','LineWidth',0.2);
      catch
      end
    end
  end

  if get(handles.chkSeismicity, 'Value') == 1
    if ~isempty(handles.vResult.mCatalog)
      if handles.vResult.bMap
        handles.hEQPlot = plot(handles.vResult.mCatalog.Longitude,handles.vResult.mCatalog.Latitude,'.k','MarkerSize',6,'Marker','.','Color','k','Visible','on');
      else
        handles.hEQPlot = plot(handles.vResult.mCatalog(:,length(handles.vResult.mCatalog.subset(1))),-handles.vResult.mCatalog.Depth,'.k','MarkerSize',6,'Marker','.','Color','k','Visible','on');
      end
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
  case  1, vColormap = autumn(256);
  case  2, vColormap = bone(256);
  case  3, vColormap = colorcube(256);
  case  4, vColormap = cool(256);
  case  5, vColormap = copper(256);
  case  6, vColormap = flag(256);
  case  7, vColormap = gray(256);
  case  8, vColormap = hot(256);
  case  9, vColormap = hsv(256);
  case 10, vColormap = jet(256);
  case 11, vColormap = lines(256);
  case 12, vColormap = pink(256);
  case 13, vColormap = prism(256);
  case 14, vColormap = spring(256);
  case 15, vColormap = summer(256);
  case 16, vColormap = white(256);
  case 17, vColormap = winter(256);
  case 18, vColormap = gui_Colormap_HotCut(256);
  case 19, vColormap = gui_Colormap_HSVCut(256);
  case 20, vColormap = gui_Colormap_RedGrayGreen(256);
  case 21, vColormap = gui_Colormap_RedGrayBlue(256);
  case 22, vColormap = gui_Colormap_BlueYellowRed(256);
  case 23, vColormap = gui_Colormap_Rastafari(256);
  case 24, vColormap = gui_Colormap_4Colors(256);
  case 25, vColormap = gui_Colormap_Skyline(256);
  case 26, vColormap = gui_Colormap_6Colors(256);
  otherwise, vColormap = jet(256);
  end
  % Flip colormap
  if get(handles.chkFlipColormap, 'Value') == 1
    vColormap = flipud(vColormap);
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
function varargout = mnuFileLoad_Callback(h, eventdata, handles, varargin)


% Get the filename of new result file
[bOK, sFilePath] = ex_GetFile('*.mat', 'Select a result file');
if bOK
  % Load the new result records
  vTmpResults = load(sFilePath, 'vResults');
  % Add the new result records
  for nCnt = 1:length(vTmpResults.vResults)
    result=vTmpResults.vResults(nCnt);
    handles.vResults = [handles.vResults; result];
  end
  % Create a new list of result records
  sList = [];
  for nCnt = 1:length(handles.vResults)
    result = handles.vResults(nCnt);
    try
      sList = [sList; cellstr(result.sComment)];
    catch
      sList = [sList; cellstr(num2str(nCnt))];
    end
  end
  set(handles.lstSets, 'String', sList);
  set(handles.lstSets, 'Value', 1);
  % Store the new result records
  guidata(handles.dlgResult, handles);
  % Plot the very first dataset and map
  plotit(handles)
  try
    set(handles.lstMaps, 'String', result.vcsGridNames);
  catch
  end
end

% --------------------------------------------------------------------
function varargout = mnuFileSave_Callback(h, eventdata, handles, varargin)

% Save the data
[newfile, newpath] = uiputfile('result.mat', 'Save resutls');
newfile = [newpath newfile];
if length(newfile) > 1
  vResults = handles.vResults;
  save(newfile);
end

% --------------------------------------------------------------------
function varargout = mnuMcEMR_Callback(h, eventdata, handles, varargin)

aux_McEMR(handles.vResult, handles.dlgResult);

% --------------------------------------------------------------------
function varargout = mnuFMD_Callback(h, eventdata, handles, varargin)

aux_1FMD(handles.vResult, handles.dlgResult);

% --------------------------------------------------------------------
function varargout = mnuSMR_Callback(h, eventdata, handles, varargin)

aux_SeisMoment(handles.vResult, handles.dlgResult);

% --------------------------------------------------------------------
function varargout = mnuSMRCumT_Callback(h, eventdata, handles, varargin)

aux_SmrCumT(handles.vResult, handles.dlgResult);

% --------------------------------------------------------------------
function varargout = update_Callback(h, eventdata, handles, varargin)

plotit(handles);

% Buttons
% --------------------------------------------------------------------
function varargout = btnAnalyze_Callback(h, eventdata, handles, varargin)

sAuxiliaryFunction = get(handles.txtAuxiliaryFunction, 'String');
if ~isempty(sAuxiliaryFunction)
  eval([sAuxiliaryFunction '(handles.vResult, handles.dlgResult)']);
end

% --------------------------------------------------------------------
function varargout = btnPlotCDF_Callback(h, eventdata, handles, varargin)

try
  nIdx = get(handles.lstMaps, 'Value');
  vDistribution = handles.vResult.mValueGrid(:,nIdx);
  plot_CDF(vDistribution);
  assignin('base', 'vDistribution', vDistribution);
catch
end

% --------------------------------------------------------------------
function varargout = btnPlotPDF_Callback(h, eventdata, handles, varargin)

try
  nIdx = get(handles.lstMaps, 'Value');
  vDistribution = handles.vResult.mValueGrid(:,nIdx);
  vSel = ~isnan(vDistribution);
  vDistribution = vDistribution(vSel,:);
  nNumberBins = str2double(get(handles.txtNumberBins, 'String'));
  figure;
  histogram(vDistribution, nNumberBins);
catch
end

%% Getting handles
% --------------------------------------------------------------------
function varargout = GetAxesHandle(h, eventdata, handles, varargin)

varargout{1} = handles.hMainAxes;

% --------------------------------------------------------------------
function varargout = GetColorbarHandle(h, eventdata, handles, varargin)

varargout{1} = handles.hColorBar;

% --------------------------------------------------------------------
function varargout = GetFigureHandle(h, eventdata, handles, varargin)

varargout{1} = handles.hPlotFigure;

% --------------------------------------------------------------------
function varargout = GetSurfaceHandle(h, eventdata, handles, varargin)

varargout{1} = handles.hSurface;

% --------------------------------------------------------------------
function varargout = GetEQPlotHandle(h, eventdata, handles, varargin)

varargout{1} = handles.hEQPlot;


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in lstSets.
function lstSets_Callback(hObject, eventdata, handles)
% hObject    handle to lstSets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lstSets contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstSets


