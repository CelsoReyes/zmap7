function varargout = bc_options(varargin)
% BC_OPTIONS Application M-file for bc_options.fig
%    FIG = BC_OPTIONS launch bc_options GUI.
%    BC_OPTIONS('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 12-Mar-2004 18:49:02

if nargin == 1  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');
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
	catch
		disp(lasterr);
	end

end

% --------------------------------------------------------------------
function varargout = Gridding_Callback(h, eventdata, handles, varargin)

set(handles.radNumber, 'Value', (varargin{1} == 1));
set(handles.radRadius, 'Value', (varargin{1} == 2));
set(handles.radRectangle, 'Value', (varargin{1} == 3));

% --------------------------------------------------------------------
function varargout = btnOK_Callback(h, eventdata, handles, varargin)

handles.answer = 1;
guidata(h, handles);
uiresume(handles.figOptions);

% --------------------------------------------------------------------
function varargout = btnCancel_Callback(h, eventdata, handles, varargin)

handles.answer = 0;
guidata(h, handles);
uiresume(handles.figOptions);
