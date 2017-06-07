function varargout = kj_grid(varargin)
% KJ_GRID Application M-file for kj_grid.fig
%    FIG = KJ_GRID launch kj_grid GUI.
%    KJ_GRID('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 13-Nov-2001 09:25:32

if nargin == 1  % LAUNCH GUI

  fig = openfig(mfilename,'reuse');

  % Use system color scheme for figure:
  set(fig,'Color',get(groot,'defaultUicontrolBackgroundColor'));

  % Generate a structure of handles to pass to callbacks, and store it.
  handles = guihandles(fig);
  guidata(fig, handles);

  if varargin{1} == 1
    set(handles.lblSpacingDepth, 'String', 'Latitude spacing [deg]:');
    set(handles.txtSpacingDepth, 'String', '0.1');
    set(handles.lblSpacingHorizontal, 'String', 'Longitude spacing [deg]:');
    set(handles.txtSpacingHorizontal, 'String', '0.1');
  else
    set(handles.lblSpacingDepth, 'String', 'Depth spacing [km]:');
    set(handles.txtSpacingDepth, 'String', '1');
    set(handles.lblSpacingHorizontal, 'String', 'Horizontal spacing [km]:');
    set(handles.txtSpacingHorizontal, 'String', '1');
  end

  if get(handles.chkRandom, 'Value') == 1
    set(handles.txtNumberCalculation, 'Enable', 'on');
    set(handles.chkSignificance, 'Enable', 'on');
    if get(handles.chkSignificance, 'Value') == 1
      set(handles.txtProbability, 'Enable', 'on');
    else
      set(handles.txtProbability, 'Enable', 'off');
    end
  else
    set(handles.txtNumberCalculation, 'Enable', 'off');
    set(handles.chkSignificance, 'Enable', 'off');
    set(handles.txtProbability, 'Enable', 'off');
  end

  if get(handles.chkLearningPeriod, 'Value') == 1
    set(handles.txtLearningPeriod, 'Enable', 'on');
  else
    set(handles.txtLearningPeriod, 'Enable', 'off');
  end

  if get(handles.chkForecastPeriod, 'Value') == 1
    set(handles.txtForecastPeriod, 'Enable', 'on');
  else
    set(handles.txtForecastPeriod, 'Enable', 'off');
  end

  if get(handles.radNumber, 'Value') == 1
    set(handles.txtNumber, 'Enable', 'on');
    set(handles.radRadius, 'Value', [0]);
    set(handles.txtRadius, 'Enable', 'off');
  else
    set(handles.txtNumber, 'Enable', 'off');
    set(handles.radRadius, 'Value', [1]);
    set(handles.txtRadius, 'Enable', 'on');
  end

  if get(handles.chkSaveParameter, 'Value') == 1
    set(handles.btnSaveParameter, 'Enable', 'on');
  else
    set(handles.btnSaveParameter, 'Enable', 'off');
  end

  if get(handles.chkMinMag, 'Value') == 1
    set(handles.txtMinMag, 'Enable', 'off');
  else
    set(handles.txtMinMag, 'Enable', 'on');
  end

  % Wait for callbacks to run and window to be dismissed:
  uiwait(fig);

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
function varargout = radNumber_Callback(h, eventdata, handles, varargin)

if get(handles.radNumber, 'Value') == 1
  set(handles.txtNumber, 'Enable', 'on');
  set(handles.radRadius, 'Value', [0]);
  set(handles.txtRadius, 'Enable', 'off');
else
  set(handles.txtNumber, 'Enable', 'off');
  set(handles.radRadius, 'Value', [1]);
  set(handles.txtRadius, 'Enable', 'on');
end

% --------------------------------------------------------------------
function varargout = radRadius_Callback(h, eventdata, handles, varargin)

if get(handles.radRadius, 'Value') == 1
  set(handles.txtRadius, 'Enable', 'on');
  set(handles.radNumber, 'Value', [0]);
  set(handles.txtNumber, 'Enable', 'off');
else
  set(handles.txtRadius, 'Enable', 'off');
  set(handles.radNumber, 'Value', [1]);
  set(handles.txtNumber, 'Enable', 'on');
end

% --------------------------------------------------------------------
function varargout = chkRandom_Callback(h, eventdata, handles, varargin)

if get(handles.chkRandom, 'Value') == 1
  set(handles.txtNumberCalculation, 'Enable', 'on');
  set(handles.chkSignificance, 'Enable', 'on');
  if get(handles.chkSignificance, 'Value') == 1
    set(handles.txtProbability, 'Enable', 'on');
  else
    set(handles.txtProbability, 'Enable', 'off');
  end
else
  set(handles.txtNumberCalculation, 'Enable', 'off');
  set(handles.chkSignificance, 'Enable', 'off');
  set(handles.txtProbability, 'Enable', 'off');
end

% --------------------------------------------------------------------
function varargout = chkSignificance_Callback(h, eventdata, handles, varargin)

if get(handles.chkSignificance, 'Value') == 1
  set(handles.txtProbability, 'Enable', 'on');
else
  set(handles.txtProbability, 'Enable', 'off');
end

% --------------------------------------------------------------------
function varargout = chkLearningPeriod_Callback(h, eventdata, handles, varargin)

if get(handles.chkLearningPeriod, 'Value') == 1
  set(handles.txtLearningPeriod, 'Enable', 'on');
else
  set(handles.txtLearningPeriod, 'Enable', 'off');
end

% --------------------------------------------------------------------
function varargout = chkForecastPeriod_Callback(h, eventdata, handles, varargin)

if get(handles.chkForecastPeriod, 'Value') == 1
  set(handles.txtForecastPeriod, 'Enable', 'on');
else
  set(handles.txtForecastPeriod, 'Enable', 'off');
end

% --------------------------------------------------------------------
function varargout = chkSaveParameter_Callback(h, eventdata, handles, varargin)

if get(handles.chkSaveParameter, 'Value') == 1
  set(handles.btnSaveParameter, 'Enable', 'on');
else
  set(handles.btnSaveParameter, 'Enable', 'off');
end

% --------------------------------------------------------------------
function varargout = chkMinMag_Callback(h, eventdata, handles, varargin)

if get(handles.chkMinMag, 'Value') == 1
  set(handles.txtMinMag, 'Enable', 'off');
else
  set(handles.txtMinMag, 'Enable', 'on');
end

% --------------------------------------------------------------------
function varargout = btnSaveParameter_Callback(h, eventdata, handles, varargin)

[newfile, newpath] = uiputfile('*.mat','Choose parameter file');
% Cancel pressed?
if isequal(newfile, 0)  ||  isequal(newpath, 0)
  return;
end
% Everything ok?
newfile = [newpath newfile];
if length(newfile) > 1
  set(handles.lblSaveParameter, 'String', newfile);
end

% --------------------------------------------------------------------
function varargout = btnCancel_Callback(h, eventdata, handles, varargin)

handles.answer = 0;
guidata(h, handles);
uiresume(handles.figGrid);

% --------------------------------------------------------------------
function varargout = btnOk_Callback(h, eventdata, handles, varargin)

% Validation of inputs
if get(handles.radNumber, 'Value') == 1
  Tmp = str2double(get(handles.txtNumber, 'String'));
  if (isnan(Tmp) | (Tmp ~= round(Tmp)) | (Tmp <= 0))
    errordlg('Number of events must be a positive integer value');
    return;
  end
end

if get(handles.radRadius, 'Value') == 1
  Tmp = str2double(get(handles.txtRadius, 'String'));
  if (isnan(Tmp) | (Tmp <= 0))
    errordlg('Constant radius must be a positive float value');
    return;
  end
end

Tmp = str2double(get(handles.txtMinimumNumber, 'String'));
if (isnan(Tmp) | (Tmp ~= round(Tmp)) | (Tmp <= 0))
  errordlg('Minimum number of events must be a positive integer value');
  return;
end

Tmp = str2double(get(handles.txtSpacingHorizontal, 'String'));
if (isnan(Tmp) | (Tmp <= 0))
  errordlg('Horizontal spacing must be a positive float value');
  return;
end

Tmp = str2double(get(handles.txtSpacingDepth, 'String'));
if (isnan(Tmp) | (Tmp <= 0))
  errordlg('Depth spacing must be a positive float value');
  return;
end

if get(handles.chkLearningPeriod, 'Value') == 1
  Tmp = str2double(get(handles.txtLearningPeriod, 'String'));
  if (isnan(Tmp) | (Tmp <= 0))
    errordlg('Learning period must be a positive float value');
    return;
  end
end

if get(handles.chkForecastPeriod, 'Value') == 1
  Tmp = str2double(get(handles.txtForecastPeriod, 'String'));
  if (isnan(Tmp) | (Tmp <= 0))
    errordlg('Forecasting period must be a positive float value');
    return;
  end
end

Tmp = str2double(get(handles.txtSplitTime, 'String'));
if (isnan(Tmp) | (Tmp <= 0))
  errordlg('Splitting time must be a positive float value');
  return;
end

if get(handles.chkRandom, 'Value') == 1
  Tmp = str2double(get(handles.txtNumberCalculation, 'String'));
  if (isnan(Tmp) | (Tmp ~= round(Tmp)) | (Tmp <= 0))
    errordlg('Number of calculations must be a positive integer value');
    return;
  end
  if get(handles.chkSignificance, 'Value') == 1
    Tmp = str2double(get(handles.txtProbability, 'String'));
    if (isnan(Tmp))
      errordlg('Probability must be a float value');
      return;
    end
  end
end

if get(handles.chkSaveParameter, 'Value') == 1
  Tmp = get(handles.lblSaveParameter, 'String');
  if isempty(Tmp)
    errordlg('Please select a filename for storing the parameters.');
    return;
  end
end

if get(handles.chkMinMag, 'Value') == 0
  Tmp = str2double(get(handles.txtMinMag, 'String'));
  if (isnan(Tmp) | ((Tmp * 10) ~= round(Tmp * 10)) |(Tmp <= 0))
    errordlg('Minimum magnitude must be a positive float value (precision 0.1)');
    return;
  end
end

Tmp = str2double(get(handles.txtMaxMag, 'String'));
if (isnan(Tmp) | ((Tmp * 10) ~= round(Tmp * 10)) |(Tmp <= 0))
  errordlg('Maximum magnitude must be a positive float value (precision 0.1)');
  return;
end

% OK, proceed
handles.answer = 1;
guidata(h, handles);
uiresume(handles.figGrid);
