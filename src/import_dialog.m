function varargout = import_dialog(varargin)
    % IMPORT_DIALOG Application M-file for import_dialog.fig
    %    FIG = IMPORT_DIALOG launch import_dialog GUI.
    %    IMPORT_DIALOG('callback_name', ...) invoke the named callback.
    
    % Last Modified by GUIDE v2.0 01-Dec-2001 16:06:16
    
    if nargin == 3  % LAUNCH GUI
        
        fig = openfig(mfilename,'reuse');
        
        % Use system color scheme for figure:
        set(fig,'Color',get(groot,'defaultUicontrolBackgroundColor'));
        
        % Generate a structure of handles to pass to callbacks, and store it.
        handles = guihandles(fig);
        
        set(handles.lstFilter, 'String', varargin{1});
        handles.mFilterFiles = varargin{2};
        handles.sFilterDir = varargin{3};
        
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
        catch ME
            disp(ME.message);
        end
        
    end
    
    % --------------------------------------------------------------------
function varargout = btnImport_Callback(h, eventdata, handles, varargin)
    
    % OK, proceed
    handles.answer = 1;
    guidata(h, handles);
    uiresume(handles.figImport);
    
    % --------------------------------------------------------------------
function varargout = btnCancel_Callback(h, eventdata, handles, varargin)
    
    handles.answer = 0;
    guidata(h, handles);
    uiresume(handles.figImport);
    
    % --------------------------------------------------------------------
function varargout = btnInfo_Callback(h, eventdata, handles, varargin)
    
    % Get index of selection
    nFilter = get(handles.lstFilter, 'Value');
    % Get filename of selected filter
    sName = deblank(handles.mFilterFiles(nFilter,:));
    % Get filename of infofile (HTML)
    sHelpFile = feval(sName, 2);
    % Does the filter provides any info file?
    if ~isempty(sHelpFile)
        % Yes, invoke the webhelp
        sInfo = [handles.sFilterDir sHelpFile];
        web(sInfo);
    else
        % No, sorry
        errordlg('No info available.');
    end
