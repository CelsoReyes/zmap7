function varargout = syn_random_dialog(varargin)
    % SYN_RANDOM_DIALOG Application M-file for syn_random_dialog.fig
    %    FIG = SYN_RANDOM_DIALOG launch syn_random_dialog GUI.
    %    SYN_RANDOM_DIALOG('callback_name', ...) invoke the named callback.

    % Last Modified by GUIDE v2.0 19-Sep-2001 12:38:10

    if nargin == 0  % LAUNCH GUI

        fig = openfig(mfilename,'reuse');
        % Use system color scheme for figure:
        set(fig,'Color',get(groot,'defaultUicontrolBackgroundColor'));

        % Generate a structure of handles to pass to callbacks, and store it.
        handles = guihandles(fig);
        guidata(fig, handles);

        % Set figure position
        movegui(fig, 'center');

        if get(handles.cboMagnitudes, 'Value') == 2
            set(handles.txtBValue, 'Enable', 'on');
            set(handles.txtMC, 'Enable', 'on');
            set(handles.txtInc, 'Enable', 'on');
        else
            set(handles.txtBValue, 'Enable', 'off');
            set(handles.txtMC, 'Enable', 'off');
            set(handles.txtInc, 'Enable', 'off');
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
function varargout = btnCancel_Callback(h, eventdata, handles, varargin)

    handles.answer = 0;
    guidata(h, handles);
    uiresume(handles.figDialog);

    % --------------------------------------------------------------------
function varargout = cboMagnitudes_Callback(h, eventdata, handles, varargin)

    if get(handles.cboMagnitudes, 'Value') == 2
        set(handles.txtBValue, 'Enable', 'on');
        set(handles.txtMC, 'Enable', 'on');
        set(handles.txtInc, 'Enable', 'on');
    else
        set(handles.txtBValue, 'Enable', 'off');
        set(handles.txtMC, 'Enable', 'off');
        set(handles.txtInc, 'Enable', 'off');
    end

    % --------------------------------------------------------------------
function varargout = btnOK_Callback(h, eventdata, handles, varargin)

    % Validation of inputs
    if get(handles.cboMagnitudes, 'Value') == 2
        Tmp = str2double(get(handles.txtBValue, 'String'));
        if (isnan(Tmp) | (Tmp <= 0))
            errordlg('b-value must be a positive float value');
            return;
        end
        Tmp = str2double(get(handles.txtMC, 'String'));
        if (isnan(Tmp) | (Tmp <= 0))
            errordlg('Magnitude of completeness must be a positive float value');
            return;
        end
        Tmp = str2double(get(handles.txtInc, 'String'));
        if (isnan(Tmp) | (Tmp <= 0))
            errordlg('Increment must be a positive float value');
            return;
        end
    end

    % OK, proceed
    handles.answer = 1;
    guidata(h, handles);
    uiresume(handles.figDialog);
