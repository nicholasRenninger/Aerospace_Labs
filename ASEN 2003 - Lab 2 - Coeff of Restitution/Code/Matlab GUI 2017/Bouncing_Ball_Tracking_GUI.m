function varargout = Bouncing_Ball_Tracking_GUI(varargin)
% BOUNCING_BALL_TRACKING_GUI MATLAB code for Bouncing_Ball_Tracking_GUI.fig
%      BOUNCING_BALL_TRACKING_GUI, by itself, creates a new BOUNCING_BALL_TRACKING_GUI or raises the existing
%      singleton*.
%
%      H = BOUNCING_BALL_TRACKING_GUI returns the handle to a new BOUNCING_BALL_TRACKING_GUI or the handle to
%      the existing singleton*.
%
%      BOUNCING_BALL_TRACKING_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BOUNCING_BALL_TRACKING_GUI.M with the given input arguments.
%
%      BOUNCING_BALL_TRACKING_GUI('Property','Value',...) creates a new BOUNCING_BALL_TRACKING_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Bouncing_Ball_Tracking_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Bouncing_Ball_Tracking_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Bouncing_Ball_Tracking_GUI

% Last Modified by GUIDE v2.5 01-Feb-2017 17:33:45

% Begin initialization code - DO NOT EDIT
clc 
    
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Bouncing_Ball_Tracking_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Bouncing_Ball_Tracking_GUI_OutputFcn, ...
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


% --- Executes just before Bouncing_Ball_Tracking_GUI is made visible.
function Bouncing_Ball_Tracking_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Bouncing_Ball_Tracking_GUI (see VARARGIN)


% Choose default command line output for Bouncing_Ball_Tracking_GUI
handles.output = hObject;

% Clear the display axes
cla(handles.vid_axes);

% Update handles structure
guidata(hObject, handles);

% Clear the output data variable
evalin('base','clearvars ball_xy_position_data');

% Get a valid filename
[filename, pathname] = uigetfile('*.mov', 'Pick a .mp4 Video File');

global k   
k = input(['Enter the coefficient of rotation, k: \n', ...
           'k = 1 -> rotate video CCW 90 deg \n', ...
           'k = -1 -> rotate video CW 90 deg \n', ...
           'k = 2 -> rotate video CCW 180 deg \n', ...
           'k = -2 -> rotate video CW 180 deg \n']);
       
if isequal(filename,0) || isequal(pathname,0)
    disp('User pressed cancel')
    set(handles.prev_frame,'Enable','off')
    set(handles.next_frame,'Enable','off')
    set(handles.capture_data,'Enable','off')
    set(handles.vid_path,'String','User pressed cancel...')
else
    handles.vidPathStr = fullfile(pathname,filename);
    disp(['User selected: ', handles.vidPathStr])
    disp('Opening file...... Please stand by')
    set(handles.prev_frame,'Enable','off')
    set(handles.next_frame,'Enable','on')
    set(handles.capture_data,'Enable','on')
    set(handles.vid_path,'String',handles.vidPathStr)
    
    % Open the video object and save it to the handles structure
    handles.vidObj = VideoReader(handles.vidPathStr);
    handles.vidWidth = handles.vidObj.Width;
    handles.vidHeight = handles.vidObj.Height;
    handles.vidFrames = read(handles.vidObj);
    handles.curr_time = 0;
    handles.ball_xy_position_data = [];
    % Update handles structure
    guidata(hObject, handles);
    
    % Get the first frame and display it
    plot_Frame(handles,1)
    set(handles.frame_count,'String','1')
    disp('Successfully loaded the file!')
end


% UIWAIT makes Bouncing_Ball_Tracking_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Bouncing_Ball_Tracking_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in next_frame.
function next_frame_Callback(hObject, eventdata, handles)
% hObject    handle to next_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curr_frame = str2double(get(handles.frame_count,'String'));
if curr_frame+1 > handles.vidObj.NumberOfFrames
    % Then we can't increment any further so do nothing
    set(handles.prev_frame,'Enable','off')
else
    curr_frame = curr_frame + 1;
    if curr_frame > 1
        set(handles.prev_frame,'Enable','on')
    end
    % Get the new current frame and display it
    set(handles.frame_count,'String',num2str(curr_frame))
    plot_Frame(handles,curr_frame)
    handles.curr_time = (curr_frame-1)/handles.vidObj.FrameRate;
    guidata(hObject, handles);
    
    if curr_frame+1 > handles.vidObj.NumberOfFrames
        % Then we need to grey out the button
        set(hObject,'Enable','off')
    end    
    
end

% See if a data point was recorded at this frame
if ~isempty(handles.ball_xy_position_data)
ind_of = find(handles.ball_xy_position_data(:,1) == handles.curr_time);
if ~isempty(ind_of)
    axes(handles.vid_axes)
    hold on
    plot(handles.ball_xy_position_data(ind_of,2),handles.ball_xy_position_data(ind_of,3),'g.')
    hold off
end
end


% --- Executes on button press in prev_frame.
function prev_frame_Callback(hObject, eventdata, handles)
% hObject    handle to prev_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curr_frame = str2double(get(handles.frame_count,'String'));
if curr_frame-1 < 1
    % Then we can't decrement any further so do nothing
    set(hObject,'Enable','off')
else
    curr_frame = curr_frame - 1;
    
    % Block the user from clicking too quickly
%     set(handles.prev_frame,'Enable','off')
%     set(handles.next_frame,'Enable','off')
%     set(handles.prev_frame,'String','Please wait...')
%     guidata(hObject, handles);
    drawnow
    
    % Get the new current frame and display it
    set(handles.frame_count,'String',num2str(curr_frame))
    plot_Frame(handles,curr_frame)
    handles.curr_time = (curr_frame-1)/handles.vidObj.FrameRate;
    guidata(hObject, handles);
    
    % Re-enable the buttons
%     set(handles.prev_frame,'Enable','on')
%     set(handles.next_frame,'Enable','on')
%     set(handles.prev_frame,'String','<< Previous Frame')
%     guidata(hObject, handles);
    
    if curr_frame == 1
        set(handles.prev_frame,'Enable','off')
    end
    
end

% See if a data point was recorded at this frame
if ~isempty(handles.ball_xy_position_data)
ind_of = find(handles.ball_xy_position_data(:,1) == handles.curr_time);
if ~isempty(ind_of)
    axes(handles.vid_axes)
    hold on
    plot(handles.ball_xy_position_data(ind_of,2),handles.ball_xy_position_data(ind_of,3),'g.')
    hold off
end
end


function vid_path_Callback(hObject, eventdata, handles)
% hObject    handle to vid_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vid_path as text
%        str2double(get(hObject,'String')) returns contents of vid_path as a double


% --- Executes during object creation, after setting all properties.
function vid_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vid_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Clear the path
set(hObject,'String','')


% --- Executes on button press in capture_data.
function capture_data_Callback(hObject, eventdata, handles)
% hObject    handle to capture_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get user input from clicking and constrain it to the image area
set(gcf,'pointer','circle')
[x,y] = ginput(1);
set(gcf,'pointer','arrow')
% [x,y] = myginput(1,'circle');

% if x < 0
%     x = 0;
% elseif x > handles.vidWidth
%     x = handles.vidWidth;
% end
% if y < 0
%     y = 0;
% elseif y > handles.vidHeight
%     y = handles.vidHeight;
% end

% Clear the axes to just display the current frame
plot_Frame(handles,str2double(get(handles.frame_count,'String')));

% Display the point that was selected
axes(handles.vid_axes)
hold on
plot(x,y,'g.')
hold off

if isempty(handles.ball_xy_position_data)
    handles.ball_xy_position_data = [handles.curr_time x y];
else
    % See what the data currently looks like
    ind_before = find(handles.ball_xy_position_data(:,1) < handles.curr_time,1,'last');
    ind_after = find(handles.ball_xy_position_data(:,1) > handles.curr_time,1,'first');
    ind_of = find(handles.ball_xy_position_data(:,1) == handles.curr_time);
    % If we had already collected data here then just overwrite it
    if ~isempty(ind_of)
        handles.ball_xy_position_data(ind_of,:) = [handles.curr_time,x,y];
    % If there's nothing before this time then add the data to the start
    elseif isempty(ind_before)
        handles.ball_xy_position_data = [handles.curr_time,x,y;...
            handles.ball_xy_position_data];
    % If there's nothing after this time then add the data to the end
    elseif isempty(ind_after)
        handles.ball_xy_position_data = [handles.ball_xy_position_data;...
            handles.curr_time,x,y];
    % Otherwise add the data to the middle where it's supposed to go
    else
        handles.ball_xy_position_data = [handles.ball_xy_position_data(1:ind_before,:);...
            handles.curr_time,x,y;handles.ball_xy_position_data(ind_after:end,:)];
    end
end

% Update the variable in the workspace
data_struct.time_seconds = handles.ball_xy_position_data(:,1);
data_struct.x_pixel = handles.ball_xy_position_data(:,2);
data_struct.y_pixel = handles.vidHeight - handles.ball_xy_position_data(:,3);
assignin('base','ball_xy_position_data',data_struct);
guidata(hObject, handles);

function plot_Frame(handles,frame_num)

global k
cdata = handles.vidFrames(:,:,:,frame_num);
cla(handles.vid_axes,'reset')
axes(handles.vid_axes)
imshow(rot90(cdata, k))

% Put the timestamp in the corner of the video
frameRate = handles.vidObj.FrameRate;
curr_time = (frame_num-1)/frameRate;

str = sprintf('Time: %.2f s',curr_time);
axes(handles.vid_axes)
hold on
text(9,handles.vidHeight-20,str,'BackgroundColor',[1 1 1],'FontName','FixedWidth');
hold off
drawnow


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
slidervalue = get(hObject,'Value');
curr_frame = str2double(get(handles.frame_count,'String'));
if curr_frame+1 > handles.vidObj.NumberOfFrames
    % Then we can't increment any further so do nothing
    set(handles.prev_frame,'Enable','off')
else
    curr_frame = round(handles.vidObj.NumberOfFrames*get(hObject,'Value'));
    if curr_frame > 1
        set(handles.prev_frame,'Enable','on')
    end
    % Get the new current frame and display it
    set(handles.frame_count,'String',num2str(curr_frame))
    plot_Frame(handles,curr_frame)
    handles.curr_time = (curr_frame-1)/handles.vidObj.FrameRate;
    guidata(hObject, handles);
    
    if curr_frame+1 > handles.vidObj.NumberOfFrames
        % Then we need to grey out the button
        set(hObject,'Enable','off')
    end    
    
end

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
