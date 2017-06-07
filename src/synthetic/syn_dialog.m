function varargout = syn_dialog(varargin)
    % SYN_DIALOG Application M-file for syn_dialog.fig
    %    FIG = SYN_DIALOG launch syn_dialog GUI.
    %    SYN_DIALOG('callback_name', ...) invoke the named callback.

    % Last Modified by GUIDE v2.0 18-Sep-2001 15:48:59

    if nargin == 1  % LAUNCH GUI

        fig = openfig(mfilename,'reuse');

        % Use system color scheme for figure:
        set(fig,'Color',get(groot,'defaultUicontrolBackgroundColor'));

        % Generate a structure of handles to pass to callbacks, and store it.
        handles = guihandles(fig);
        guidata(fig, handles);

        % Set figure position
        movegui(fig, 'center');

        % Set values (varargin{1} is an earthquake catalog)
        set(handles.txtNumber, 'String', num2str(length(varargin{1})));     % Number of events
        set(handles.txtMinLat, 'String', num2str(min(varargin{1}(:,2))));   % Latitude
        set(handles.txtMaxLat, 'String', num2str(max(varargin{1}(:,2))));
        set(handles.txtMinLon, 'String', num2str(min(varargin{1}(:,1))));   % Longitude
        set(handles.txtMaxLon, 'String', num2str(max(varargin{1}(:,1))));
        set(handles.txtMinDepth, 'String', num2str(min(varargin{1}(:,7)))); % Depth
        set(handles.txtMaxDepth, 'String', num2str(max(varargin{1}(:,7))));
        set(handles.txtMinTime, 'String', num2str(min(varargin{1}(:,3))));  % Time
        set(handles.txtMaxTime, 'String', num2str(max(varargin{1}(:,3))));

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
function varargout = btnOK_Callback(h, eventdata, handles, varargin)

    % Validation of inputs
    Tmp = str2double(get(handles.txtNumber, 'String'));
    if (isnan(Tmp) | (Tmp ~= round(Tmp)) | (Tmp <= 0))
        errordlg('Number of events must be a positive integer value');
        return;
    end
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
    Tmp = str2double(get(handles.txtMinLat, 'String'));
    if (isnan(Tmp))
        errordlg('Latitude (minimum) must be a float value');
        return;
    end
    Tmp = str2double(get(handles.txtMaxLat, 'String'));
    if (isnan(Tmp))
        errordlg('Latitude (maximum) must be a float value');
        return;
    end
    Tmp = str2double(get(handles.txtMinLon, 'String'));
    if (isnan(Tmp))
        errordlg('Longitude (minimum) must be a float value');
        return;
    end
    Tmp = str2double(get(handles.txtMaxLon, 'String'));
    if (isnan(Tmp))
        errordlg('Longitude (maximum) must be a float value');
        return;
    end
    Tmp = str2double(get(handles.txtMinDepth, 'String'));
    if (isnan(Tmp) | (Tmp < 0))
        errordlg('Depth (minimum) must be a positive float value');
        return;
    end
    Tmp = str2double(get(handles.txtMaxDepth, 'String'));
    if (isnan(Tmp) | (Tmp <= 0))
        errordlg('Depth (maximum) must be a positive float value');
        return;
    end
    Tmp = str2double(get(handles.txtMinTime, 'String'));
    if (isnan(Tmp) | (Tmp <= 0))
        errordlg('Time (minimum) must be a positive float value');
        return;
    end
    Tmp = str2double(get(handles.txtMaxTime, 'String'));
    if (isnan(Tmp) | (Tmp <= 0))
        errordlg('Time (maximum) must be a positive float value');
        return;
    end

    % OK, proceed
    handles.answer = 1;
    guidata(h, handles);
    uiresume(handles.figDialog);
