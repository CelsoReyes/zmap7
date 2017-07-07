function varargout = bc_SelectMechanism_Dialog(varargin)
% BC_SELECTMECHANISM Application M-file for bc_SelectMechanism.fig
%    FIG = BC_SELECTMECHANISM launch bc_SelectMechanism GUI.
%    BC_SELECTMECHANISM('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 19-Apr-2002 12:26:10

if nargin == 0  % LAUNCH GUI

  fig = openfig(mfilename,'reuse');

  % Use system color scheme for figure:
  set(fig,'Color',get(groot,'defaultUicontrolBackgroundColor'));

  % Generate a structure of handles to pass to callbacks, and store it.
  handles = guihandles(fig);
  guidata(fig, handles);

  % Set figure position
  movegui(fig, 'center');

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
function varargout = btnOK_Callback(h, eventdata, handles, varargin)

Tmp = str2double(get(handles.txtAngle, 'String'));
if (isnan(Tmp) | (Tmp <= 0))
  errordlg('Angle must be a positive float value');
  return;
end

% OK, proceed
handles.answer = 1;
guidata(h, handles);
uiresume(handles.figSelectMechanism);


% --------------------------------------------------------------------
function varargout = btnCancel_Callback(h, eventdata, handles, varargin)

handles.answer = 0;
guidata(h, handles);
uiresume(handles.figSelectMechanism);
