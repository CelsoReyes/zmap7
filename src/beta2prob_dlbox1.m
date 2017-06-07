function varargout = beta2prob_dlbox1(varargin)

report_this_filefun(mfilename('fullpath'));

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



    % --------------------------------------------------------------------
    % Cancel Button
function varargout = pushbutton1_Callback(h, eventdata, handles, varargin)
    assignin('base', 'cancquest', 'yes');
    close(beta2prob_dlbox1);



    % --------------------------------------------------------------------
    % OK Button
function varargout = pushbutton2_Callback(h, eventdata, handles, varargin)
    NuRep=[];
    NuRep = get(handles.edit2, 'String');
    assignin('base', 'NuRep', []);
    assignin('base', 'NuRep', NuRep);
    assignin('base', 'cancquest', 'nop');
    close(beta2prob_dlbox1);

    % --------------------------------------------------------------------
    % Field for entering number of repetitions
function varargout = edit2_Callback(h, eventdata, handles, varargin)
