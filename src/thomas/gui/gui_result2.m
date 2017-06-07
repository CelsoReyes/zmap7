function varargout = gui_result2(varargin)

if (nargin == 1) & ~ischar(varargin{1})  % LAUNCH GUI

  fig = openfig(mfilename,'reuse');

  % Generate a structure of handles to pass to callbacks, and store it.
  handles = guihandles(fig);
%vst next to lines have been moved up
  % Store the datasets internally
  handles.vResult = varargin{1}(1);
  handles.vResults = varargin{1};
  % Create the figure-window
%vst
  if (handles.vResult.bMap < 2)
      handles.hPlotFigure = figure_w_normalized_uicontrolunits('Name', 'Result plot', 'NumberTitle', 'off');
  elseif (handles.vResult.bMap == 2)
      handles.hPlotFigure = figure_w_normalized_uicontrolunits('Name', '3DResult plot', 'NumberTitle', 'off');
  end
  handles.hMainAxes = newplot;
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
  catch
    disp(lasterr);
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
%vst
  if (handles.vResult.bMap < 2) % bMap is 0, or 1: 2D-plot
      vTmp = NaN(length(handles.vResult.vX) * length(handles.vResult.vY), 1);
      vTmp(handles.vResult.vUsedNodes) = handles.vResult.mValueGrid(:,nIdx);
      handles.mPlotValues = reshape(vTmp, length(handles.vResult.vY), length(handles.vResult.vX));
  elseif (handles.vResult.bMap == 2) % bMap =2 : 3D-plot
      % prepare Value that will be illustrated on the 3D surface defined above
      handles.mPlotValues=NaN(length(handles.vResult.vUsedNodes),1);
      handles.mPlotValues(handles.vResult.vUsedNodes)=handles.vResult.mValueGrid(:,nIdx);
%       handles.mPlotValues(isnan(handles.vResult.vUsedNodes))=nan;
%             handles.mPlotValues(isnan(handles.vResult.mValueGrid(:,1))=nan;
      if (nIdx==1 || nIdx==6)
          vSel=~isnan(handles.vResult.mValueGrid(:,1));
      else
          vSel=~isnan(handles.vResult.mValueGrid(:,1)) & ~(handles.vResult.mValueGrid(:,6)>40);
      end
      vTmp=handles.vResult.mValueGrid(:,nIdx);
      vTmp(~vSel)=nan;
      handles.mPlotValues(handles.vResult.vUsedNodes)=vTmp;
      %       handles.mPlotValues(handles.mPlotValues == 0)=nan;
      handles.mPlotValues=reshape(handles.mPlotValues,length(handles.vResult.vY),length(handles.vResult.vX));
      handles.Result.mZ(isnan(handles.mPlotValues))=nan;
  elseif (handles.vResult.bMap == 3) % bMap = 3 : Cross section in 3D-plot
      if (nIdx==1 || nIdx==6)
          vSel=~isnan(handles.vResult.mValueGrid(:,1));
      else
          vSel=~isnan(handles.vResult.mValueGrid(:,1)) & ~(handles.vResult.mValueGrid(:,6)>20);
      end
      vTmp=handles.vResult.mValueGrid(:,nIdx);
      vTmp(~vSel,:)=nan;
      mPlotValues=reshape(vTmp,size(handles.vResult.mX,1),size(handles.vResult.mX,2));
      hold on; surf(handles.vResult.mX,handles.vResult.mY,-handles.vResult.mZ,mPlotValues);
      shading interp;
  end

  if get(handles.chkOverlayNext,'Value') == 1
      hold on;
  else
      % Renew plot
      figure_w_normalized_uicontrolunits(handles.hPlotFigure);
      handles.hMainAxes = newplot;
      delete(handles.hMainAxes);
      handles.hMainAxes = newplot;
      set(handles.hPlotFigure, 'renderer', 'zbuffer');
  end

  % Plot data
  if (handles.vResult.bMap < 2)  % create 2D-plot
      handles.hSurface = surface(handles.vResult.vX, handles.vResult.vY, zeros(size(handles.mPlotValues)), handles.mPlotValues, 'Parent', handles.hMainAxes);
      axis(handles.hMainAxes, 'image');
      if get(handles.chkInterpolated, 'Value') == 1
          shading(handles.hMainAxes, 'interp');
      end
  elseif (handles.vResult.bMap == 2)  % create 3D-plot
      surf(handles.vResult.mX,handles.vResult.mY,-handles.vResult.mZ,handles.mPlotValues);
      view(3)
      if get(handles.chkInterpolated, 'Value') == 1
          shading(handles.hMainAxes, 'interp');
      end
  end
  set(handles.hMainAxes, 'box', 'on');
  hold on;
%vst
  if (handles.vResult.bMap == 1)
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

  if (handles.vResult.bMap == 2)
      if get(handles.chkCoastlines, 'Value') == 1
          try
              vXLim=get(handles.hMainAxes,'XLim');
              vYLim=get(handles.hMainAxes,'YLim');
              vZLim=get(handles.hMainAxes,'ZLim');
              vIdXLim=(handles.vResult.vCoastline(:,1) < vXLim(2)) & (handles.vResult.vCoastline(:,1) > vXLim(1));
              vIdX=((handles.vResult.vCoastline(:,1) == -Inf) | (handles.vResult.vCoastline(:,1) == Inf) | isnan(handles.vResult.vCoastline(:,1)) | vIdXLim);
              vIdYLim=(handles.vResult.vCoastline(:,2) < vYLim(2)) & (handles.vResult.vCoastline(:,2) > vYLim(1));
              vIdY=((handles.vResult.vCoastline(:,2) == -Inf) | (handles.vResult.vCoastline(:,2) == Inf)  | isnan(handles.vResult.vCoastline(:,2)) | vIdYLim);
              vId=(vIdX & vIdY);
              handles.hCoastline = plot3(handles.vResult.vCoastline(vId,1), handles.vResult.vCoastline(vId,2),...
                  ones(size(handles.vResult.vCoastline(vId),1),1)*max(vZLim),'LineWidth',1.0,'Color',[0  0  0 ]);
          catch
          end
      end
      if get(handles.chkFaults, 'Value') == 1
          try
              vXLim=get(handles.hMainAxes,'XLim');
              vYLim=get(handles.hMainAxes,'YLim');
              vZLim=get(handles.hMainAxes,'ZLim');
              vIdXLim=(handles.vResult.vFaults(:,1) < vXLim(2)) & (handles.vResult.vFaults(:,1) > vXLim(1));
              vIdX=((handles.vResult.vFaults(:,1) == -Inf) | (handles.vResult.vFaults(:,1) == Inf) |  isnan(handles.vResult.vFaults(:,1)) | vIdXLim);
              vIdYLim=(handles.vResult.vFaults(:,2) < vYLim(2)) & (handles.vResult.vFaults(:,2) > vYLim(1));
              vIdY=((handles.vResult.vFaults(:,2) == -Inf) | (handles.vResult.vFaults(:,2) == Inf) |  isnan(handles.vResult.vFaults(:,2)) | vIdYLim);
              vId=(vIdX & vIdY);
              handles.hFaults = plot3(handles.vResult.vFaults(vId,1), handles.vResult.vFaults(vId,2),...
                  ones(size(handles.vResult.vFaults(vId),1),1)*max(vZLim),'r','LineWidth',0.2);
          catch
          end
      end
      if handles.vResult.chkVolcanoes == 1
              try
                  vXLim=get(handles.hMainAxes,'XLim');
                  vYLim=get(handles.hMainAxes,'YLim');
                  vZLim=get(handles.hMainAxes,'ZLim');
                  vIdXLim=(handles.vResult.vVolcanoes(:,1) < vXLim(2)).*(handles.vResult.vVolcanoes(:,1) > vXLim(1));
                  vIdYLim=(handles.vResult.vVolcanoes(:,2) < vYLim(2)).*(handles.vResult.vVolcanoes(:,2) > vYLim(1));
                  vId=(vIdXLim.*vIdYLim == 1);
                  handles.vVolcanoes = plot3(handles.vResult.vVolcanoes(vId,1), handles.vResult.vVolcanoes(vId,2),...
                      ones(size(handles.vResult.vVolcanoes(vId),1),1)*max(vZLim),...
                      'r^',...
                      'MarkerSize',7,...
                      'LineWidth',2);
              catch
              end
          end
  end


  if get(handles.chkSeismicity, 'Value') == 1
%vst
    if ~isempty(handles.vResult.mCatalog)
      if (handles.vResult.bMap == 1)
        handles.hEQPlot = plot(handles.vResult.mCatalog(:,1),handles.vResult.mCatalog(:,2),'.k','MarkerSize',6,'Marker','.','Color','k','Visible','on');
      elseif   (handles.vResult.bMap == 0)
        handles.hEQPlot = plot(handles.vResult.mCatalog(:,length(handles.vResult.mCatalog(1,:))),-handles.vResult.mCatalog(:,7),'.k','MarkerSize',6,'Marker','.','Color','k','Visible','on');
      elseif   (handles.vResult.bMap == 2)
        handles.hEQPlot = plot3(handles.vResult.mCatalog(:,1),handles.vResult.mCatalog(:,2),-handles.vResult.mCatalog(:,7),'.k','MarkerSize',2,'Marker','.','Color','k','Visible','on');
%         hold on; i=80;plot3(handles.vResult.mCatalog(handles.vResult.caNodeIndices2{i},1),handles.vResult.mCatalog(handles.vResult.caNodeIndices2{i},2),-handles.vResult.mCatalog(handles.vResult.caNodeIndices2{i},7),'MarkerSize',2,'Marker','*','Color','k','Visible','on')
%         hold on; i=80;plot3(handles.vResult.mPolygon(i,1),handles.vResult.mPolygon(i,2),-handles.vResult.mPolygon(i,3),'MarkerSize',10,'Marker','d','Color','r','Visible','on')
%         handles.vResult.caNodeIndices2
        view(3);
      end
    end
  end
  % Set information values
  set(handles.lblMin, 'String', num2str(min(min(handles.mPlotValues)), 3));
  set(handles.lblMax, 'String', num2str(max(max(handles.mPlotValues)), 3));
  set(handles.lblMean, 'String', num2str(nanmean(handles.vResult.mValueGrid(:,nIdx)), 3));
  set(handles.lblMedian, 'String', num2str(nanmedian(handles.vResult.mValueGrid(:,nIdx)), 3));
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
      fLimMin = min(min(mNoInfValues));
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
      fLimMax = max(max(mNoInfValues));
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
  case 21, vColormap = gui_Colormap_RedGreen(255); % Centerline is gray -> 255
  case 22, vColormap = gui_Colormap_RedGrayBlue(256);
  case 23, vColormap = gui_Colormap_RedGrayBlueEx(256);
  case 24, vColormap = gui_Colormap_BlueYellowRed(256);
  case 25, vColormap = gui_Colormap_Rastafari(256);
  case 26, vColormap = gui_Colormap_Reggae(256);
  case 27, vColormap = gui_Colormap_4Colors(256);
  case 28, vColormap = gui_Colormap_Skyline(256);
  case 29, vColormap = gui_Colormap_SkylineCut(256);
  otherwise, vColormap = jet(256);
  end
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
  handles.vColormap = vColormap;
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
[newfile, newpath] = uiputfile('result.mat', 'Save calculated probabilistic forecast test data');
newfile = [newpath newfile];
if length(newfile) > 1
  vResults = handles.vResults;
  save(newfile);
end

% --------------------------------------------------------------------
function varargout = update_Callback(h, eventdata, handles, varargin)

T=view;
plotit(handles);
view(T);

% --------------------------------------------------------------------
function varargout = btnAnalyze_Callback(h, eventdata, handles, varargin)

sAuxiliaryFunction = get(handles.txtAuxiliaryFunction, 'String');
if ~isempty(sAuxiliaryFunction)
  eval([sAuxiliaryFunction '(handles.vResult, handles.dlgResult)']);
end

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
function varargout = GetDatasetsHandle(h, eventdata, handles, varargin)

varargout{1} = handles.lstSets;

% --------------------------------------------------------------------
function varargout = GetResults(h, eventdata, handles, varargin)

varargout{1} = handles.vResults;

% --------------------------------------------------------------------
function varargout = GetColormap(h, eventdata, handles, varargin)

varargout{1} = handles.vColormap;

% --------------------------------------------------------------------
function varargout = GetCatalog(h, eventdata, handles, varargin)

varargout{1} = handles.vResult.mCatalog;

% --------------------------------------------------------------------
function varargout = mnuFileExport_Callback(h, eventdata, handles, varargin)

% Save the data
[newfile, newpath] = uiputfile('figure.eps', 'Export figure');
newfile = [newpath newfile];
if length(newfile) > 1
  exportfig(handles.hPlotFigure, newfile, 'Color', 'cmyk');
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


% --- Executes on button press in chkOverlayNext.
function chkOverlayNext_Callback(hObject, eventdata, handles)
% hObject    handle to chkOverlayNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkOverlayNext


