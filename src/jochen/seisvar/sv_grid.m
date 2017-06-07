function varargout = sv_grid(varargin)
% SV_GRID Application M-file for sv_grid.fig
%    FIG = SV_GRID launch sv_grid GUI.
%    SV_GRID('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 22-Aug-2002 10:30:09

if nargin == 1  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(groot,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it.
	handles = guihandles(fig);
	guidata(fig, handles);

if varargin{1} == 1
    set(handles.lblSpacingDepth, 'String', 'Latitude spacing [deg]:');
    set(handles.txtSpacingDepth, 'String', '0.05');
    set(handles.lblSpacingHorizontal, 'String', 'Longitude spacing [deg]:');
    set(handles.txtSpacingHorizontal, 'String', '0.05');
else
    set(handles.lblSpacingDepth, 'String', 'Depth spacing [km]:');
    set(handles.txtSpacingDepth, 'String', '1');
    set(handles.lblSpacingHorizontal, 'String', 'Horizontal spacing [km]:');
    set(handles.txtSpacingHorizontal, 'String', '1');
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

if get(handles.radSplitTime, 'Value') == 1
    set(handles.txtSplitTime, 'Enable', 'on');
    set(handles.txtTimePeriod, 'Enable', 'on');
else
    set(handles.radSplitTime, 'Value', [1]);
    set(handles.txtSplitTime, 'Enable', 'on');
    set(handles.txtTimePeriod, 'Enable', 'on');
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
	catch
		disp(lasterr);
	end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and
%| sets objects' callback properties to call them through the FEVAL
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.

% --------------------------------------------------------------------
% Radiobutton: Number of events
function varargout = radNumber_Callback(h, eventdata, handles, varargin)

if get(handles.radNumber, 'Value') == 1
  set(handles.txtNumber, 'Enable', 'on');
  set(handles.radRadius, 'Value', [0]);
  set(handles.txtRadius, 'Enable', 'off');
  set(handles.radRectangle, 'Value', [0]);
  set(handles.txtSizeRectHorizontal, 'Enable', 'off');
  set(handles.txtSizeRectDepth, 'Enable', 'off');
else
  set(handles.txtNumber, 'Enable', 'off');
  set(handles.radRadius, 'Value', [1]);
  set(handles.txtRadius, 'Enable', 'on');
  set(handles.radRectangle, 'Value', [0]);
  set(handles.txtSizeRectHorizontal, 'Enable', 'off');
  set(handles.txtSizeRectDepth, 'Enable', 'off');
end

% --------------------------------------------------------------------
% Radiobutton: Constant radius
function varargout = radRadius_Callback(h, eventdata, handles, varargin)

if get(handles.radRadius, 'Value') == 1
  set(handles.txtRadius, 'Enable', 'on');
  set(handles.radNumber, 'Value', [0]);
  set(handles.txtNumber, 'Enable', 'off');
  set(handles.radRectangle, 'Value', [0]);
  set(handles.txtSizeRectHorizontal, 'Enable', 'off');
  set(handles.txtSizeRectDepth, 'Enable', 'off');
else
  set(handles.txtRadius, 'Enable', 'off');
  set(handles.radNumber, 'Value', [1]);
  set(handles.txtNumber, 'Enable', 'on');
  set(handles.radRectangle, 'Value', [0]);
  set(handles.txtSizeRectHorizontal, 'Enable', 'off');
  set(handles.txtSizeRectDepth, 'Enable', 'off');
end

% --------------------------------------------------------------------
% Radiobutton: Rectangle size
function varargout = radRectangle_Callback(h, eventdata, handles, varargin)

if get(handles.radRectangle, 'Value') == 1
  set(handles.txtSizeRectHorizontal, 'Enable', 'on');
  set(handles.txtSizeRectDepth, 'Enable', 'on');
  set(handles.radRadius, 'Value', [0]);
  set(handles.txtRadius, 'Enable', 'off');
  set(handles.radNumber, 'Value', [0]);
  set(handles.txtNumber, 'Enable', 'off');
else
  set(handles.radRadius, 'Value', [0]);
  set(handles.txtRadius, 'Enable', 'off');
  set(handles.radNumber, 'Value', [1]);
  set(handles.txtNumber, 'Enable', 'on');
end

% --------------------------------------------------------------------
% Radiobutton: Split Time
function varargout = radSplitTime_Callback(h, eventdata, handles, varargin)

if get(handles.radSplitTime, 'Value') == 1
   set(handles.txtSplitTime, 'Enable', 'on');
   set(handles.txtTimePeriod, 'Enable', 'on');
else
  set(handles.txtTimePeriod, 'Enable', 'on');
  set(handles.txtSplitTime, 'Enable', 'off');
end

% --------------------------------------------------------------------
function varargout = chkTimePeriod_Callback(h, eventdata, handles, varargin)

if get(handles.chkTimeperiod, 'Value') == 1
  set(handles.txtTimeperiod, 'Enable', 'on');
else
  set(handles.txtTimeperiod, 'Enable', 'off');
end

% --------------------------------------------------------------------
function varargout = chkSaveParameter_Callback(h, eventdata, handles, varargin)

if get(handles.chkSaveParameter, 'Value') == 1
  set(handles.btnSaveParameter, 'Enable', 'on');
else
  set(handles.btnSaveParameter, 'Enable', 'off');
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
function varargout = btnOK_Callback(h, eventdata, handles, varargin)

handles.answer = 1;
guidata(h, handles);
uiresume(handles.figGrid);


% --------------------------------------------------------------------
function varargout = btnCancel_Callback(h, eventdata, handles, varargin)

handles.answer = 0;
guidata(h, handles);
uiresume(handles.figGrid);
