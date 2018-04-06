function varargout = pt_options(varargin)
% KJ_GRID Application M-file for kj_grid.fig
%    FIG = KJ_GRID launch kj_grid GUI.
%    KJ_GRID('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 12-Jul-2002 10:20:24

if nargin == 1  % LAUNCH GUI

  fig = openfig(mfilename,'reuse');

  % Use system color scheme for figure:
  set(fig,'Color',get(groot,'defaultUicontrolBackgroundColor'));

  % Generate a structure of handles to pass to callbacks, and store it.
  handles = guihandles(fig);
  guidata(fig, handles);

  % Set figure position
  movegui(fig, 'center');

  if varargin{1} == 1
    set(handles.lblSpacingY, 'String', 'Latitude spacing [deg]:');
    set(handles.txtSpacingY, 'String', '0.1');
    set(handles.lblSpacingX, 'String', 'Longitude spacing [deg]:');
    set(handles.txtSpacingX, 'String', '0.1');
  else
    set(handles.lblSpacingY, 'String', 'Depth spacing [km]:');
    set(handles.txtSpacingY, 'String', '1');
    set(handles.lblSpacingX, 'String', 'Horizontal spacing [km]:');
    set(handles.txtSpacingX, 'String', '1');
  end

  % Wait for callbacks to run and window to be dismissed:
  uiwait(fig);

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
function varargout = chkRandomNode_Callback(h, eventdata, handles, varargin)

if get(handles.chkRandomNode, 'Value') == 1
  set(handles.txtNumberCalculationNode, 'Enable', 'on');
else
  set(handles.txtNumberCalculationNode, 'Enable', 'off');
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

[newfile, newpath] = uiputfile('*.mat', 'Choose parameter file');
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
% --------------------

% Hypothesis values
if get(handles.radHNumber, 'Value') == 1
  if ~gui_IsStringPositiveInteger(get(handles.txtHNumber, 'String'), 'Number of events (hypothesis)')
    return;
  end
elseif get(handles.radHRadius, 'Value') == 1
  if ~gui_IsStringPositiveFloat(get(handles.txtHRadius, 'String'), 'Constant radius (hypothesis)')
    return;
  end
elseif get(handles.radHRectangle, 'Value') == 1
  if ~gui_IsStringPositiveFloat(get(handles.txtHSizeRectX, 'String'), 'Rectangle size X (hypothesis)')
    return;
  end
  if ~gui_IsStringPositiveFloat(get(handles.txtHSizeRectY, 'String'), 'Rectangle size Y (hypothesis)')
    return;
  end
end
if ~gui_IsStringPositiveInteger(get(handles.txtHMinimumNumber, 'String'), 'Minimum number of events (hypothesis)')
  return;
end
if ~gui_IsStringPositiveFloat(get(handles.txtHMaximumRadius, 'String'), 'Maximum radius (hypothesis)')
  return;
end

% Null hypothesis values
if get(handles.radNNumber, 'Value') == 1
  if ~gui_IsStringPositiveInteger(get(handles.txtNNumber, 'String'), 'Number of events (null hypothesis)')
    return;
  end
elseif get(handles.radNRadius, 'Value') == 1
  if ~gui_IsStringPositiveFloat(get(handles.txtNRadius, 'String'), 'Constant radius (null hypothesis)')
    return;
  end
elseif get(handles.radNRectangle, 'Value') == 1
  if ~gui_IsStringPositiveFloat(get(handles.txtNSizeRectX, 'String'), 'Rectangle size X (null hypothesis)')
    return;
  end
  if ~gui_IsStringPositiveFloat(get(handles.txtNSizeRectY, 'String'), 'Rectangle size Y (null hypothesis)')
    return;
  end
end
if ~gui_IsStringPositiveInteger(get(handles.txtNMinimumNumber, 'String'), 'Minimum number of events (null hypothesis)')
  return;
end
if ~gui_IsStringPositiveFloat(get(handles.txtNMaximumRadius, 'String'), 'Maximum radius (null hypothesis)')
  return;
end

% Testing values
if get(handles.radTNumber, 'Value') == 1
  if ~gui_IsStringPositiveInteger(get(handles.txtTNumber, 'String'), 'Number of events (testing)')
    return;
  end
elseif get(handles.radTRadius, 'Value') == 1
  if ~gui_IsStringPositiveFloat(get(handles.txtTRadius, 'String'), 'Constant radius (testing)')
    return;
  end
elseif get(handles.radTRectangle, 'Value') == 1
  if ~gui_IsStringPositiveFloat(get(handles.txtTSizeRectX, 'String'), 'Rectangle size X (testing)')
    return;
  end
  if ~gui_IsStringPositiveFloat(get(handles.txtTSizeRectY, 'String'), 'Rectangle size Y (testing)')
    return;
  end
end
if ~gui_IsStringPositiveInteger(get(handles.txtTMinimumNumber, 'String'), 'Minimum number of events (testing)')
  return;
end
if ~gui_IsStringPositiveFloat(get(handles.txtTMaximumRadius, 'String'), 'Maximum radius (testing)')
  return;
end

% Options
if ~gui_IsStringPositiveFloat(get(handles.txtSpacingX, 'String'), 'Spacing X')
  return;
end
if ~gui_IsStringPositiveFloat(get(handles.txtSpacingY, 'String'), 'Spacing Y')
  return;
end
if ~gui_IsStringPositiveFloat(get(handles.txtSplitTime, 'String'), 'Splitting time')
  return;
end
if get(handles.chkForecastPeriod, 'Value') == 1
  if ~gui_IsStringPositiveFloat(get(handles.txtForecastPeriod, 'String'), 'Forecast period')
    return;
  end
end
if get(handles.chkLearningPeriod, 'Value') == 1
  if ~gui_IsStringPositiveFloat(get(handles.txtLearningPeriod, 'String'), 'Learning period')
    return;
  end
end
if get(handles.chkRandomNode, 'Value') == 1
  if ~gui_IsStringPositiveInteger(get(handles.txtNumberCalculationNode, 'String'), 'Number calculations per node')
    return;
  end
end
if get(handles.chkMinMag, 'Value') == 1
  if ~gui_IsStringPositiveFloat(get(handles.txtMinMag, 'String'), 'Minimum magnitude')
    return;
  end
end
if ~gui_IsStringPositiveFloat(get(handles.txtMaxMag, 'String'), 'Maximum magnitude')
  return;
end

% OK, proceed
handles.answer = 1;
guidata(h, handles);
uiresume(handles.figGrid);


% --------------------------------------------------------------------
function varargout = HGridding_Callback(h, eventdata, handles, varargin)

set(handles.radHNumber, 'Value', (varargin{1} == 1));
set(handles.radHRadius, 'Value', (varargin{1} == 2));
set(handles.radHRectangle, 'Value', (varargin{1} == 3));

% --------------------------------------------------------------------
function varargout = radHComputeB_Callback(h, eventdata, handles, varargin)

set(handles.radHSpatialB, 'Value', (varargin{1} == 1));
set(handles.radHOverallB, 'Value', (varargin{1} == 2));

% --------------------------------------------------------------------
function varargout = NGridding_Callback(h, eventdata, handles, varargin)

set(handles.radNNumber, 'Value', (varargin{1} == 1));
set(handles.radNRadius, 'Value', (varargin{1} == 2));
set(handles.radNRectangle, 'Value', (varargin{1} == 3));

% --------------------------------------------------------------------
function varargout = radNComputeB_Callback(h, eventdata, handles, varargin)

set(handles.radNSpatialB, 'Value', (varargin{1} == 1));
set(handles.radNOverallB, 'Value', (varargin{1} == 2));

% --------------------------------------------------------------------
function varargout = TGridding_Callback(h, eventdata, handles, varargin)

set(handles.radTNumber, 'Value', (varargin{1} == 1));
set(handles.radTRadius, 'Value', (varargin{1} == 2));
set(handles.radTRectangle, 'Value', (varargin{1} == 3));


