function varargout = LiveSimulationPage(varargin)
% LIVESIMULATIONPAGE MATLAB code for LiveSimulationPage.fig
%      LIVESIMULATIONPAGE, by itself, creates a new LIVESIMULATIONPAGE or raises the existing
%      singleton*.
%
%      H = LIVESIMULATIONPAGE returns the handle to a new LIVESIMULATIONPAGE or the handle to
%      the existing singleton*.
%
%      LIVESIMULATIONPAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LIVESIMULATIONPAGE.M with the given input arguments.
%
%      LIVESIMULATIONPAGE('Property','Value',...) creates a new LIVESIMULATIONPAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LiveSimulationPage_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LiveSimulationPage_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LiveSimulationPage

% Last Modified by GUIDE v2.5 31-Mar-2018 18:44:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LiveSimulationPage_OpeningFcn, ...
                   'gui_OutputFcn',  @LiveSimulationPage_OutputFcn, ...
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


% --- Executes just before LiveSimulationPage is made visible.
function LiveSimulationPage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LiveSimulationPage (see VARARGIN)

% Choose default command line output for LiveSimulationPage
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LiveSimulationPage wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LiveSimulationPage_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles.timer = timer('Name','MyTimer',               ...
                       'Period',0.1,                    ... 
                       'StartDelay',0,                 ... 
                       'TasksToExecute',inf,           ... 
                       'ExecutionMode','fixedSpacing', ...
                       'TimerFcn',{@timerCallback,handles.figure1});
handles.arduino = setupSerial(COM);
axes(handles.axes2);
handles.Pos = scatter(NaN, NaN);
title('Gait Characterization');
xlabel('Ankle X Position (m)');
ylabel('Ankle Y Position (m)');

axes(handles.axes3);
handles.Hka = plot(NaN, NaN);
title('Knee Angle');
xlabel('Time (s)');
ylabel('Knee Angle (rad)');

 axes(handles.axes4);
handles.Hkt = plot(NaN, NaN);
title('Knee Torque');
xlabel('Time (s)');
ylabel('Knee Torque (Nm)');

 axes(handles.axes6);
handles.Hha = plot(NaN, NaN);
title('Hip Angle');
xlabel('Time (s)');
ylabel('Hip Angle (rad)');

 axes(handles.axes5);
handles.Hht = plot(NaN, NaN);
title('Hip Torque');
xlabel('Time (s)');
ylabel('Hip Torque (Nm)');

guidata(hObject,handles);
start(handles.timer);
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = [get(handles.Pos,'XData'), get(handles.Pos,'YData'), get(handles.Hka,'XData'), get(handles.Hka,'YData'), get(handles.Hkt,'XData'), get(handles.Hkt,'YData')...
    , get(handles.Hha,'XData'), get(handles.Hha,'YData'), get(handles.Hht,'XData'), get(handles.Hht,'YData')];
p_id = getappdata(0, 'p_id');
d = datetime('now');
d_str = datestr(d, 30);
filename = [p_id,'-', d_str, '.csv'];
save(filename, 'data');


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton2.
function pushbutton2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
