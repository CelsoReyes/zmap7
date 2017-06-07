function varargout = bz_grid(varargin)
    % BZ_GRID Application M-file for bz_grid.fig
    %    FIG = BZ_GRID launch bz_grid GUI.
    %    BZ_GRID('callback_name', ...) invoke the named callback.

    % Last Modified by GUIDE v2.0 26-Apr-2001 10:27:07

    report_this_filefun(mfilename('fullpath'));

    if nargin == 0  % LAUNCH GUI

        fig = openfig(mfilename,'reuse');

        % Use system color scheme for figure:
        set(fig,'Color',get(groot,'defaultUicontrolBackgroundColor'));

        % Generate a structure of handles to pass to callbacks, and store it.
        handles = guihandles(fig);
        guidata(fig, handles);

        % Init dialog
        if get(handles.chkExcludeEvents, 'Value') == 1
            set(handles.txtExcludeEvents, 'Enable', 'on');
        else
            set(handles.txtExcludeEvents, 'Enable', 'off');
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
function varargout = btnOk_Callback(h, eventdata, handles, varargin)

    % Check Inputs
    Tmp = str2double(get(handles.txtNumberOfEvents, 'String'));
    if (isnan(Tmp) | (Tmp ~= round(Tmp)) | (Tmp <= 0))
        errordlg('Number of Events must be a positive integer value');
        return
    end

    Tmp = str2double(get(handles.txtSpacingLongitude, 'String'));
    if (isnan(Tmp) | (Tmp <= 0))
        errordlg('Spacing in longitude must be a positive float value');
        return
    end

    Tmp = str2double(get(handles.txtSpacingLatitude, 'String'));
    if (isnan(Tmp) | (Tmp <= 0))
        errordlg('Spacing in latitude must be a positive float value');
        return
    end

    if get(handles.chkExcludeEvents, 'Value') == 1
        Tmp = str2double(get(handles.txtExcludeEvents, 'String'));
        if (isnan(Tmp) | (Tmp <= 0))
            errordlg('Exclude events must be a positive float value');
            return
        end
    end

    handles.answer = 1;
    guidata(h, handles);
    uiresume(handles.figGrid);

    % --------------------------------------------------------------------
function varargout = btnCancel_Callback(h, eventdata, handles, varargin)

    handles.answer = 0;
    guidata(h, handles);
    uiresume(handles.figGrid);

    % --------------------------------------------------------------------
function varargout = chkExcludeEvents_Callback(h, eventdata, handles, varargin)

    if get(handles.chkExcludeEvents, 'Value') == 1
        set(handles.txtExcludeEvents, 'Enable', 'on');
    else
        set(handles.txtExcludeEvents, 'Enable', 'off');
    end

