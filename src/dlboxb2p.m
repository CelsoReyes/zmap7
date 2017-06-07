function varargout = dlboxb2p(varargin)
    % DLBOXB2P Application M-file for dlboxb2p.fig
    %    FIG = DLBOXB2P launch dlboxb2p GUI.
    %    DLBOXB2P('callback_name', ...) invoke the named callback.

    % Last Modified by GUIDE v2.0 10-May-2001 14:28:27

    if nargin == 0  % LAUNCH GUI

        fig = openfig(mfilename,'reuse');

        % Use system color scheme for figure:
        set(fig,'Color',get(groot,'defaultUicontrolBackgroundColor'));

        % Generate a structure of handles to pass to callbacks, and store it.
        handles = guihandles(fig);
        guidata(fig, handles);

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


    report_this_filefun(mfilename('fullpath'));

    % --------------------------------------------------------------------
function varargout = Uniform_rbtn_Callback(h, eventdata, handles, varargin)
    set(handles.real_rbtn, 'Value', 0);


    % --------------------------------------------------------------------
function varargout = real_rbtn_Callback(h, eventdata, handles, varargin)
    set(handles.Uniform_rbtn, 'Value', 0);


    % --------------------------------------------------------------------
function varargout = OK_btn_Callback(h, eventdata, handles, varargin)
    assignin('base', 'cancquest', 'nop');

    if get(handles.Uniform_rbtn, 'Value')==0
        way='real'; assignin('base', 'way', 'real');
    else % i.e. if isunif==1
        way='unif'; assignin('base', 'way', 'unif');
    end
    close(dlboxb2p);

    % --------------------------------------------------------------------
function varargout = Cancel_btn_Callback(h, eventdata, handles, varargin)
    % Stub for Callback of the uicontrol handles.Cancel_btn.
    close(dlboxb2p);
    assignin('base', 'cancquest', 'yes');
    return

