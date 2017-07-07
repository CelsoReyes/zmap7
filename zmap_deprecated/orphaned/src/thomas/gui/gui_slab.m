function varargout = gui_slab(varargin)
% GUI_SLAB M-file for gui_slab.fig
%      GUI_SLAB, by itself, creates a new GUI_SLAB or raises the existing
%      singleton*.
%
%      H = GUI_SLAB returns the handle to a new GUI_SLAB or the handle to
%      the existing singleton*.
%
%      GUI_SLAB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_SLAB.M with the given input arguments.
%
%      GUI_SLAB('Property','Value',...) creates a new GUI_SLAB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_slab_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_slab_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help gui_slab

% Last Modified by GUIDE v2.5 16-Mar-2006 16:54:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_slab_OpeningFcn, ...mfilename
                   'gui_OutputFcn',  @gui_slab_OutputFcn, ...
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


% --- Executes just before gui_slab is made visible.
function gui_slab_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_slab (see VARARGIN)

% Choose default command line output for gui_slab
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_slab wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_slab_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% ---------------------------------------------------------------------------
% --- Executes on button press in btnOK.
function btnOK_Callback(hObject, eventdata, handles)
% hObject    handle to btnOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.answer = 1;
guidata(hObject, handles);
uiresume(handles.figure1);
gui_slab_OutputFcn(hObject, eventdata, handles)


% -------------------------------------------------------------------------

% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.answer = 0;
guidata(hObject, handles);
gui_slab_OutputFcn(hObject, eventdata, handles)
uiresume(handles.figure1);


% -------------------------------------------------------------------------

% --- Executes on button press in chkCylSmp.
function chkCylSmp_Callback(hObject, eventdata, handles)
% hObject    handle to chkCylSmp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkCylSmp
get(fObject,'Value')

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2




function vPerc_Callback(hObject, eventdata, handles)
% hObject    handle to vPerc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vPerc as text
%        str2double(get(hObject,'String')) returns contents of vPerc as a double


% --- Executes during object creation, after setting all properties.
function vPerc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vPerc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(groot,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fRadius_Callback(hObject, eventdata, handles)
% hObject    handle to fRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fRadius as text
%        str2double(get(hObject,'String')) returns contents of fRadius as a double


% --- Executes during object creation, after setting all properties.
function fRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(groot,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nMinColEvents_Callback(hObject, eventdata, handles)
% hObject    handle to nMinColEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nMinColEvents as text
%        str2double(get(hObject,'String')) returns contents of nMinColEvents as a double


% --- Executes during object creation, after setting all properties.
function nMinColEvents_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nMinColEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(groot,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2



function fCylSmpN_Callback(hObject, eventdata, handles)
% hObject    handle to fCylSmpN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fCylSmpN as text
%        str2double(get(hObject,'String')) returns contents of fCylSmpN as a double


% --- Executes during object creation, after setting all properties.
function fCylSmpN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fCylSmpN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(groot,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fCylSmpBnd_Callback(hObject, eventdata, handles)
% hObject    handle to fCylSmpBnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fCylSmpBnd as text
%        str2double(get(hObject,'String')) returns contents of fCylSmpBnd as a double


% --- Executes during object creation, after setting all properties.
function fCylSmpBnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fCylSmpBnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(groot,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in chk3DSmp.
function chk3DSmp_Callback(hObject, eventdata, handles)
% hObject    handle to chk3DSmp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk3DSmp



function nDx_Callback(hObject, eventdata, handles)
% hObject    handle to nDx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nDx as text
%        str2double(get(hObject,'String')) returns contents of nDx as a double


% --- Executes during object creation, after setting all properties.
function nDx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nDx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(groot,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function f3DSmpValue_Callback(hObject, eventdata, handles)
% hObject    handle to f3DSmpValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f3DSmpValue as text
%        str2double(get(hObject,'String')) returns contents of f3DSmpValue as a double


% --- Executes during object creation, after setting all properties.
function f3DSmpValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f3DSmpValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(groot,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function f3DSmpBnd_Callback(hObject, eventdata, handles)
% hObject    handle to f3DSmpBnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f3DSmpBnd as text
%        str2double(get(hObject,'String')) returns contents of f3DSmpBnd as a double


% --- Executes during object creation, after setting all properties.
function f3DSmpBnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f3DSmpBnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(groot,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


