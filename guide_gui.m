function varargout = guide_gui(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guide_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @guide_gui_OutputFcn, ...
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


% --- Executes just before guide_gui is made visible.
function guide_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for guide_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guide_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guide_gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;



function start_box_Callback(hObject, eventdata, handles)
start = str2double(get(handles.start_box,'String'));
setappdata(0, 'dist1', start);


% --- Executes during object creation, after setting all properties.
function start_box_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function distance_box_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function distance_box_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in resolution_dropdown.
function resolution_dropdown_Callback(hObject, eventdata, handles)
resolution = get(handles.resolution_dropdown,'value');
setappdata(0, 'res', resolution);

% --- Executes during object creation, after setting all properties.
function resolution_dropdown_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function end_box_Callback(hObject, eventdata, handles)
end_dist = str2double(get(handles.end_box,'String'));
setappdata(0, 'dist2', end_dist);


% --- Executes during object creation, after setting all properties.
function end_box_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function display_dist_Callback(hObject, eventdata, handles)
dist_mm = str2double(get(handles.display_dist,'String'));

if( dist_mm < 0.01)
    msgbox('Scanning distance must be greater than 10 um','Error');
else
    totalDist = dist_mm;
    setappdata(0, 'scanDist', totalDist);
end

% --- Executes during object creation, after setting all properties.
function display_dist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function delay_box_Callback(hObject, eventdata, handles)
time_ms = str2double(get(handles.delay_box,'String'));
if( time_ms <0)
    msgbox('Delay value cannot be negative','Error');
else
    setappdata(0, 'delay_ms', time_ms);
    time_s = time_ms * 0.001; % convert time from msec to sec
    setappdata(0, 'delay_secs',time_s);
end



% --- Executes during object creation, after setting all properties.
function delay_box_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function displayDistance_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in reset_button.
function reset_button_Callback(hObject, eventdata, handles)
a = arduino('COM3', 'Uno', 'Libraries', {'Adafruit\MotorShieldV2', ...
    'rotaryEncoder'});
shield = addon(a, 'Adafruit\MotorShieldV2');

% Setting up the stepper motor properties
sm_reverse = stepper(shield, 2,200,'StepType','Single');
sm_reverse.RPM = 32767; % max RPM

move(sm_reverse,-1000);


% --- Executes on selection change in mode_listbox.
function mode_listbox_Callback(hObject, eventdata, handles)
mode = get(handles.mode_listbox,'value');
setappdata(0, 'measurement_mode', mode);

% --- Executes during object creation, after setting all properties.
function mode_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function status_text_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function status_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when tiepieSetup is resized.
function tiepieSetup_SizeChangedFcn(hObject, eventdata, handles)


% --- Executes when selected object is changed in tiepieSetup.
function tiepieSetup_SelectionChangedFcn(hObject, eventdata, handles)






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Performing the scan                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function begin_button_Callback(hObject, eventdata, handles)
fprintf("Starting scan \n");
set(handles.status_text, 'String', 'Starting scan');
drawnow;

% Setup arduino connection
a = arduino('COM3', 'Uno', 'Libraries', {'Adafruit\MotorShieldV2', ...
    'rotaryEncoder'});
writeDigitalPin(a, 'D8', 1);

% Setup the stepper motor properties
shield = addon(a, 'Adafruit\MotorShieldV2');
sm = stepper(shield, 2,200,'StepType','Single');
sm.RPM = 32767; % max speed
set(handles.status_text, 'String', 'Arduino configured');
drawnow;

% Setup the encoder
encoder = rotaryEncoder(a,'D2','D3'); % D2 = EB+, D3 = EA+

% Run calculation for number of steps and loops required
step_and_loopCalc
loop_no = getappdata(0, 'loops');
step_no = getappdata(0, 'steps');

% Setup measurement mode
Mmode = getappdata(0,'measurement_mode');
if Mmode == 1 % block mode
    set(handles.status_text, 'String', 'Configuring TiePie in block mode...');
    drawnow;
    TiePie_blockSetup % Configure scope in block mode
    set(handles.status_text, 'String', 'Block mode configured');
    drawnow;
elseif Mmode == 2
    set(handles.status_text, 'String', 'Configuring TiePie in stream mode...');
    drawnow;
    TiePie_streamSetup % Configure scope in stream mode
    set(handles.status_text, 'String', 'Stream mode configured');
    drawnow;
else
    msgbox('No measurement mode has been selected','Error');
end

if Mmode == 1
    startScp % Start scope for block measurement mode
end

for i = 1:loop_no
    % Move the motor and check that it has moved the correct number of steps  
    resetCount(encoder);       % reset the number of steps to 0
    move(sm,step_no);           % moves the desired resolution
    value = readCount(encoder); % 1 step is value = 20
    steps = round(value/20);    % convert to number of steps
    if (steps == 0)
        msgbox('Motor has not moved or encoder is not counting steps','Error');
    elseif (steps ~= step_no)       % if actual position is not same as calculated
        difference = step_no - steps; % calculates difference
        move(sm, difference);   % motor moves to correct position
    end
    
    % Take measurements using the TiePie
    if Mmode == 1
        set(handles.status_text, 'String', 'Taking measurements in block mode');
        drawnow;
        timerPulse;            % Trigger the 555 timer pulse
    else
        setappdata(0, 'scan_progress', i);
        set(handles.status_text, 'String','Taking measurements in stream mode');
        drawnow;
        TiePie_streamMeasure            % Samples echo pulse
        if (mod(i, 5) == 0)
            TiePie_streamPlot;          % Plot every 5 seconds
        end
    end
end

% Plotting and saving the data
if ((Mmode == 1) && (i == loop_no))
    set(handles.status_text, 'String', 'Taking measurements from TiePie');
    TiePie_blockMeasure; % Takes data from TiePie
    fclose all;
    set(handles.status_text, 'String', 'Plotting data...');
    drawnow;
    Plot
    %TiePie_blockPlot
    set(handles.status_text, 'String', 'Data plotted');
    drawnow;
    fclose all;
    clear scp;
    set(handles.status_text, 'String', 'Scan complete!');
elseif Mmode == 2
    set(handles.status_text, 'String', 'Saving data...');
    drawnow;
    dlmwrite('streamData_sample', sample_data); % save the data take of just the test piece
    dlmwrite('streamData_ssp', filtered_data);  % save the test piece data after SSP
    set(handles.status_text, 'String', 'Data saved as streamData');
    drawnow;
    fclose all;
    clear scp;
    set(handles.status_text, 'String', 'Scan complete!');
end


