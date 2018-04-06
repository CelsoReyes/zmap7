function varargout = st_options(varargin)
% ST_OPTIONS Application M-file for st_options.fig
%    FIG = ST_OPTIONS launch st_options GUI.
%    ST_OPTIONS('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 24-May-2005 15:03:29

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
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch ME
		disp(ME.message);
	end

end


% --------------------------------------------------------------------
function varargout = Gridding_Callback(h, eventdata, handles, varargin)

set(handles.radNumber, 'Value', (varargin{1} == 1));
set(handles.radRadius, 'Value', (varargin{1} == 2));
set(handles.radRectangle, 'Value', (varargin{1} == 3));

% --------------------------------------------------------------------
function varargout = btnCancel_Callback(h, eventdata, handles, varargin)

handles.answer = 0;
guidata(h, handles);
uiresume(handles.figOptions);

% --------------------------------------------------------------------
function varargout = btnOk_Callback(h, eventdata, handles, varargin)

% Validation of inputs
% --------------------

% % Hypothesis values
% if get(handles.radHNumber, 'Value') == 1
%   if ~gui_IsStringPositiveInteger(get(handles.txtHNumber, 'String'), 'Number of events (hypothesis)')
%     return;
%   end
% elseif get(handles.radHRadius, 'Value') == 1
%   if ~gui_IsStringPositiveFloat(get(handles.txtHRadius, 'String'), 'Constant radius (hypothesis)')
%     return;
%   end
% elseif get(handles.radHRectangle, 'Value') == 1
%   if ~gui_IsStringPositiveFloat(get(handles.txtHSizeRectX, 'String'), 'Rectangle size X (hypothesis)')
%     return;
%   end
%   if ~gui_IsStringPositiveFloat(get(handles.txtHSizeRectY, 'String'), 'Rectangle size Y (hypothesis)')
%     return;
%   end
% end
% if ~gui_IsStringPositiveInteger(get(handles.txtHMinimumNumber, 'String'), 'Minimum number of events (hypothesis)')
%   return;
% end
% if ~gui_IsStringPositiveFloat(get(handles.txtHMaximumRadius, 'String'), 'Maximum radius (hypothesis)')
%   return;
% end
%
% % Null hypothesis values
% if get(handles.radNNumber, 'Value') == 1
%   if ~gui_IsStringPositiveInteger(get(handles.txtNNumber, 'String'), 'Number of events (null hypothesis)')
%     return;
%   end
% elseif get(handles.radNRadius, 'Value') == 1
%   if ~gui_IsStringPositiveFloat(get(handles.txtNRadius, 'String'), 'Constant radius (null hypothesis)')
%     return;
%   end
% elseif get(handles.radNRectangle, 'Value') == 1
%   if ~gui_IsStringPositiveFloat(get(handles.txtNSizeRectX, 'String'), 'Rectangle size X (null hypothesis)')
%     return;
%   end
%   if ~gui_IsStringPositiveFloat(get(handles.txtNSizeRectY, 'String'), 'Rectangle size Y (null hypothesis)')
%     return;
%   end
% end
% if ~gui_IsStringPositiveInteger(get(handles.txtNMinimumNumber, 'String'), 'Minimum number of events (null hypothesis)')
%   return;
% end
% if ~gui_IsStringPositiveFloat(get(handles.txtNMaximumRadius, 'String'), 'Maximum radius (null hypothesis)')
%   return;
% end
%
% % Testing values
% if get(handles.radTNumber, 'Value') == 1
%   if ~gui_IsStringPositiveInteger(get(handles.txtTNumber, 'String'), 'Number of events (testing)')
%     return;
%   end
% elseif get(handles.radTRadius, 'Value') == 1
%   if ~gui_IsStringPositiveFloat(get(handles.txtTRadius, 'String'), 'Constant radius (testing)')
%     return;
%   end
% elseif get(handles.radTRectangle, 'Value') == 1
%   if ~gui_IsStringPositiveFloat(get(handles.txtTSizeRectX, 'String'), 'Rectangle size X (testing)')
%     return;
%   end
%   if ~gui_IsStringPositiveFloat(get(handles.txtTSizeRectY, 'String'), 'Rectangle size Y (testing)')
%     return;
%   end
% end
% if ~gui_IsStringPositiveInteger(get(handles.txtTMinimumNumber, 'String'), 'Minimum number of events (testing)')
%   return;
% end
% if ~gui_IsStringPositiveFloat(get(handles.txtTMaximumRadius, 'String'), 'Maximum radius (testing)')
%   return;
% end
%
% % Options
% if ~gui_IsStringPositiveFloat(get(handles.txtSpacingX, 'String'), 'Spacing X')
%   return;
% end
% if ~gui_IsStringPositiveFloat(get(handles.txtSpacingY, 'String'), 'Spacing Y')
%   return;
% end
% if ~gui_IsStringPositiveFloat(get(handles.txtSplitTime, 'String'), 'Splitting time')
%   return;
% end
% if get(handles.chkForecastPeriod, 'Value') == 1
%   if ~gui_IsStringPositiveFloat(get(handles.txtForecastPeriod, 'String'), 'Forecast period')
%     return;
%   end
% end
% if get(handles.chkLearningPeriod, 'Value') == 1
%   if ~gui_IsStringPositiveFloat(get(handles.txtLearningPeriod, 'String'), 'Learning period')
%     return;
%   end
% end
% if get(handles.chkRandomNode, 'Value') == 1
%   if ~gui_IsStringPositiveInteger(get(handles.txtNumberCalculationNode, 'String'), 'Number calculations per node')
%     return;
%   end
% end
% if get(handles.chkMinMag, 'Value') == 1
%   if ~gui_IsStringPositiveFloat(get(handles.txtMinMag, 'String'), 'Minimum magnitude')
%     return;
%   end
% end
% if ~gui_IsStringPositiveFloat(get(handles.txtMaxMag, 'String'), 'Maximum magnitude')
%   return;
% end

% OK, proceed
handles.answer = 1;
guidata(h, handles);
uiresume(handles.figOptions);




% --------------------------------------------------------------------
function varargout = chkBootstrapSecond_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = txtNumberBootstrapsSecond_Callback(h, eventdata, handles, varargin)


% --- Executes on button press in chkSaveParameter.
function chkSaveParameter_Callback(hObject, eventdata, handles)

if get(handles.chkSaveParameter, 'Value') == 1
  set(handles.btnSaveParameter, 'Enable', 'on');
else
  set(handles.btnSaveParameter, 'Enable', 'off');
end



% --- Executes on button press in btnSaveParameter.
function btnSaveParameter_Callback(hObject, eventdata, handles)

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



function lblSaveParameter_Callback(hObject, eventdata, handles)
% hObject    handle to lblSaveParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lblSaveParameter as text
%        str2double(get(hObject,'String')) returns contents of lblSaveParameter as a double


