function varargout = circle_select_dlg(varargin)
    % CIRCLE_SELECT_DLG MATLAB code for circle_select_dlg.fig
    %      CIRCLE_SELECT_DLG, by itself, creates a new CIRCLE_SELECT_DLG or raises the existing
    %      singleton*.
    %
    %      H = CIRCLE_SELECT_DLG returns the handle to a new CIRCLE_SELECT_DLG or the handle to
    %      the existing singleton*.
    %
    %      CIRCLE_SELECT_DLG('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in CIRCLE_SELECT_DLG.M with the given input arguments.
    %
    %      CIRCLE_SELECT_DLG('Property','Value',...) creates a new CIRCLE_SELECT_DLG or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before circle_select_dlg_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to circle_select_dlg_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES
    
    % Edit the above text to modify the response to help circle_select_dlg
    
    % Last Modified by GUIDE v2.5 03-Oct-2017 16:47:50
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @circle_select_dlg_OpeningFcn, ...
        'gui_OutputFcn',  @circle_select_dlg_OutputFcn, ...
        'gui_LayoutFcn',  [] , ...
        'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end
    
    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
end

% --- Executes just before circle_select_dlg is made visible.
function circle_select_dlg_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to circle_select_dlg (see VARARGIN)
    
    % Choose default command line output for circle_select_dlg
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
    ZG = ZmapGlobal.Data;
    hObject.UserData=ZG.selection_shape;
    hObject.UserData.Points=[ hObject.UserData.X0, hObject.UserData.Y0];
    handles.x_field.String=num2str(hObject.UserData.X0);
    handles.y_field.String=num2str(hObject.UserData.Y0);
    handles.radius_edit.String=num2str(hObject.UserData.Radius);
    handles.nclosest_edit.String=num2str(hObject.UserData.NEventsToEnclose);
    % set something thanks to radial buttons
    
    % UIWAIT makes circle_select_dlg wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = circle_select_dlg_OutputFcn(hObject, ~, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes on button press in okbutton.
function okbutton_Callback(hObject, ~, handles)
    % hObject    handle to okbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if any(isnan(handles.figure1.UserData.Points))
        ZmapMessageCenter.set_error('Circle: No Center','Circle center is not yet defined. Choose a center, then click "ok".');
        return
    end
    
    ZG = ZmapGlobal.Data;
    handles.figure1.UserData.Type='circle';
    ZG.selection_shape=handles.figure1.UserData;
    close(handles.figure1)
    % set all the values based on this dialog box.
end
% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, ~, handles)
    close(handles.figure1);
end


function x_field_Callback(hObject, ~, handles)
    % hObject    handle to x_field (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of x_field as text
    %        str2double(get(hObject,'String')) returns contents of x_field as a double
    handles.figure1.UserData.Points(1,1) = str2double(hObject.String);
end

% --- Executes during object creation, after setting all properties.
function x_field_CreateFcn(hObject, ~, handles)
    % hObject    handle to x_field (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    sr=ZmapGlobal.Data.selection_shape.X0;
    hObject.String=num2str(sr);%handles.figure1.UserData.X0;
    if isempty(sr)
        hObject.Val=nan;
    else
        hObject.Value=sr;
    end
end


function y_field_Callback(hObject, ~, handles)
    handles.figure1.UserData.Points(1,2) = str2double(hObject.String);
end

% --- Executes during object creation, after setting all properties.
function y_field_CreateFcn(hObject, ~, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    sr=ZmapGlobal.Data.selection_shape.Y0;
    hObject.String=num2str(sr);%handles.figure1.UserData.X0;
    if isempty(sr)
        hObject.Val=nan;
    else
        hObject.Value=sr;
    end
end

% --- Executes on button press in mouse_center_select.
function mouse_center_select_Callback(hObject, ~, handles)
    % choose figure
    mmh = mainmap();
    ax=mmh.mainAxes();
    axes(ax);
    try
        handles.figure1.UserData=handles.figure1.UserData.select_circle(handles.figure1.UserData.Radius);
    catch ME
        errordlg(ME.message);
    end
    %uiwait(gcf)
    handles.x_field.String = handles.figure1.UserData.X0;
    handles.y_field.String = handles.figure1.UserData.Y0;
end

% --- Executes on button press in mouse_center_radius_select.
function mouse_center_radius_select_Callback(hObject, ~, handles)
mmh = mainmap();
    ax=mmh.mainAxes();
    axes(ax);
    try
        handles.figure1.UserData=handles.figure1.UserData.select_circle();
    catch ME
        errordlg(ME.message);
    end
    %uiwait(gcf)
    handles.x_field.String = handles.figure1.UserData.X0;
    handles.y_field.String = handles.figure1.UserData.Y0;
    handles.radius_edit.String = handles.figure1.UserData.Radius;
end


function radius_edit_Callback(hObject, ~, handles)
    hObject.Parent.UserData.Radius = str2double(hObject.String);
end

% --- Executes during object creation, after setting all properties.
function radius_edit_CreateFcn(hObject, ~, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    %hObject.String=hObject.Parent.UserData.Radius;
end


function nclosest_edit_Callback(hObject, ~, handles)
    hObject.String=handles.figure1.UserData.X0;
end

% --- Executes during object creation, after setting all properties.
function nclosest_edit_CreateFcn(hObject, ~, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function rb_closest_Callback(hObject,~,handles)
    %
end
function rb_maxradius_Callback(hObject,~,handles)
    %
end
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, ~, handles)
    disp('found pushbutton 2!');
end


% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
    % hObject    handle to the selected object in uibuttongroup1
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.figure1.UserData.CircleBehavior=hObject.UserData;
end


% --- Executes on button press in show_cumplot.
function show_cumplot_Callback(hObject, eventdata, handles)
% hObject    handle to show_cumplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_cumplot
end

% --- Executes on button press in immediateplot_afterclick.
function immediateplot_afterclick_Callback(hObject, eventdata, handles)
% hObject    handle to immediateplot_afterclick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of immediateplot_afterclick
end
