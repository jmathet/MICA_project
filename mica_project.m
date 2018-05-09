function varargout = mica_project(varargin)
% MICA_PROJECT MATLAB code for mica_project.fig
%      MICA_PROJECT, by itself, creates a new MICA_PROJECT or raises the existing
%      singleton*.
%
%      H = MICA_PROJECT returns the handle to a new MICA_PROJECT or the handle to
%      the existing singleton*.
%
%      MICA_PROJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_SIN.M with the given input arguments.
%
%      MICA_PROJECT('Property','Value',...) creates a new MICA_PROJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before load_sin_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to load_sin_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help load_sin

% Last Modified by GUIDE v2.5 24-Apr-2018 10:10:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @mica_project_OpeningFcn, ...
    'gui_OutputFcn',  @mica_project_OutputFcn, ...
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


% --- Executes just before load_sin is made visible.
function mica_project_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to load_sin (see VARARGIN)

% Choose default command line output for load_sin
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
addpath(genpath('.'));
try
    img = imread('src/ecg.png');
    image(img);
catch
    textLabel = sprintf('Error : Startup image not found...');
    set(handles.text_main, 'String', textLabel);
end
% UIWAIT makes load_sin wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = mica_project_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)



% --- Executes on button press in window.
function window_Callback(hObject, eventdata, handles)
% hObject    handle to window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xlim_start = str2double(get(handles.xlim1,'String'));
textLabel = sprintf('Time evolution of the loaded signal');
set(handles.text_main, 'String', textLabel);
handles.th = str2double(get(handles.seuil,'String'));
if isnumeric(handles.th) && (handles.th >= 0)
else
    textLabel = sprintf('Incorrect value of threshold');
    set(handles.text_main, 'String', textLabel);
    handles.th = 200; % default value
end
if isnumeric(xlim_start) && (xlim_start >= 0)
else
    textLabel = sprintf('Incorrect value of xlim start');
    set(handles.text_main, 'String', textLabel);
    xlim_start = 1;
end
xlim_end = str2double(get(handles.xlim2,'String'));
if isnumeric(xlim_end) && (xlim_end > xlim_start)
else
    textLabel = sprintf('Incorrect value of xlim end');
    set(handles.text_main, 'String', textLabel);
    xlim_end = 100;
end
try
    plot(handles.time_axis, handles.data);
    hold on; 
    plot(handles.time_axis, (handles.th)*ones(1,handles.N));
    xlim([xlim_start xlim_end]);
    xlabel('Time (s)');
    ylabel('Magnitude');
    grid on;
    legend('ECG data', 'threshold', 'location', 'best');
    hold off;
catch
    textLabel = sprintf('Error : please, load a signal...');
    set(handles.text_main, 'String', textLabel);
end

function xlim1_Callback(hObject, eventdata, handles)
% hObject    handle to xlim1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xlim1 as text
%        str2double(get(hObject,'String')) returns contents of xlim1 as a double

% --- Executes during object creation, after setting all properties.
function xlim1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xlim1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xlim2_Callback(hObject, eventdata, handles)
% hObject    handle to xlim2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xlim2 as text
%        str2double(get(hObject,'String')) returns contents of xlim2 as a double

% --- Executes during object creation, after setting all properties.
function xlim2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xlim2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white')
end

function segment_indice_Callback(hObject, eventdata, handles)
% hObject    handle to segment_indice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of segment_indice as text
%        str2double(get(hObject,'String')) returns contents of segment_indice as a double


% --- Executes during object creation, after setting all properties.
function segment_indice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to segment_indice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_pqrst.
function plot_pqrst_Callback(hObject, eventdata, handles)
% hObject    handle to plot_pqrst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.th = str2double(get(handles.seuil,'String'));
i_seg = str2double(get(handles.segment_indice,'String'));
if isnumeric(handles.th) && (handles.th >= 0)
else
    textLabel = sprintf('Incorrect value of threshold');
    set(handles.text_main, 'String', textLabel);
    handles.th = 200; % default value
end
try
    % Print BPM
    [bpm, R_locs] = bpm_threshold(handles.data, handles.th, handles.Fs);
    textLabel = sprintf('%f bpm', bpm);
    set(handles.text_main, 'String', textLabel);
    % Figures PQRST
    [segment, P_loc, Q_loc, R_loc, S_loc, T_loc ] = ecg_threshold(handles.data, R_locs, i_seg);
    time_segment = (1:length(segment))/handles.Fs;
    plot(time_segment, segment); grid on;
    hold on;
    plot(time_segment(P_loc),segment(P_loc), '*','Color','red'); text(time_segment(P_loc),segment(P_loc),' P ','Color','red','FontSize',14);
    plot(time_segment(Q_loc),segment(Q_loc), '*','Color','red'); text(time_segment(Q_loc),segment(Q_loc),' Q ','Color','red','FontSize',14);
    plot(time_segment(R_loc),segment(R_loc), '*','Color','red'); text(time_segment(R_loc),segment(R_loc),' R ','Color','red','FontSize',14);
    plot(time_segment(S_loc),segment(S_loc), '*','Color','red'); text(time_segment(S_loc),segment(S_loc),' S ','Color','red','FontSize',14);
    plot(time_segment(T_loc),segment(T_loc), '*','Color','red'); text(time_segment(T_loc),segment(T_loc),' T ','Color','red','FontSize',14);
    hold off;
    xlabel('Time (s)');
    ylabel('Magnitude');
catch
    textLabel = sprintf('Threshold error !');
    set(handles.text_main, 'String', textLabel);
end
guidata(hObject, handles);


function seuil_Callback(hObject, eventdata, handles)
% hObject    handle to seuil (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of seuil as text
%        str2double(get(hObject,'String')) returns contents of seuil as a double


% --- Executes during object creation, after setting all properties.
function seuil_CreateFcn(hObject, eventdata, handles)
% hObject    handle to seuil (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in window_init.
function window_init_Callback(hObject, eventdata, handles)
% hObject    handle to window_init (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    plot(handles.time_axis, handles.data); grid on;
    xlabel('Time (s)');
    ylabel('Magnitude');
    textLabel = sprintf('Time evolution of the loaded signal');
    set(handles.text_main, 'String', textLabel);
catch
    textLabel = sprintf('Error : please, load a signal...');
    set(handles.text_main, 'String', textLabel);
end

% --------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)
% hObject    handle to file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile('*.mat', 'rt');
signal = load(fullfile(path, file));
handles.data = signal.ecg;
handles.Fs = signal.Fs;
handles.N = size(handles.data,2);
handles.time_axis = (1:handles.N)/handles.Fs;
plot(handles.time_axis, handles.data); grid on;
xlabel('Time (s)');
ylabel('Magnitude');
textLabel = sprintf('Time evolution of the loaded signal');
set(handles.text_main, 'String', textLabel);
guidata(hObject, handles);
