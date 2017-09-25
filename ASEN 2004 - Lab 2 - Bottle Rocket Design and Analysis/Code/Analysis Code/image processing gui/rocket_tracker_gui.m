function varargout = rocket_tracker_gui(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -- ROCKET_TRACKER_GUI MATLAB code for rocket_tracker_gui.fig ------------
%      ROCKET_TRACKER_GUI is a MATLAB interface that can be used to save
%      the x- and y-positions of a water bottle rocket over the course of a
%      launch. Please reference the 'rocket_tracker_gui Procedure' Word
%      document on the ITLL Courses server for a detailed README.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Edit the above text to modify the response to help rocket_tracker_gui

% Last Modified by GUIDE v2.5 31-Mar-2014 14:20:35

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rocket_tracker_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @rocket_tracker_gui_OutputFcn, ...
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes just before rocket_tracker_gui is made visible.
function rocket_tracker_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rocket_tracker_gui (see VARARGIN)

% Clear im_axes
cla(handles.im_axes);

% Get folder that contains rocket launch images
[filename,pathname] = uigetfile('*.mp4','Please Select the .mp4 Video File to Process');
handles.full_vid_path = fullfile(pathname,filename);
if filename == 0
    error('No .mp4 video file was selected, please try again.')
end
handles.dirname = pwd;
% Update handles structure
guidata(hObject, handles);

axes(handles.im_axes); % Set the current axes

% Create the reader object to grab frames from the video file
handles.vidObj = VideoReader(handles.full_vid_path,'tag','RocketVidObj');

% Attempt to initialize the GUI
try
    % Show first frame
    A = read(handles.vidObj,1); % Frame #1
    imshow(A);
    
    set(handles.framenum,'String',1); % Frame #1
    set(handles.xpos_pix,'String',0); % Default x-position
    set(handles.ypos_pix,'String',0); % Default y-position
    set(handles.foldername,'String',handles.full_vid_path); % Save the folder name
    set(handles.data_pts_name,'String','xy_data_pts.mat'); % Default save-file name
%     set(handles.foldername,'UserData',counter+1); % Increment counter
    
    % Initialize status string
    set(handles.status_string,'String','');
    set(handles.status_string,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
    
    % Make arrows for user-friendliness
    axes(handles.arrow1)
    tempx = [-.33 .33 .33 1 0 -1 -.33];
    tempy = [-1 -1 0 0 1 0 0];
    patch(tempx,tempy,'k')
    
    axes(handles.arrow2)
    tempx = [-.25, -.25, 1, 1, .5, .5, 0, .5, .5, .75, .75, -.25];
    tempy = [-.7, -1, -1, .66, .66, 1, .5, 0, .33, .33, -.7, -.7];
    temp = patch(tempx,tempy,'k');
    set(handles.arrow2,'visible','off');
    set(handles.tip2,'visible','off');
    set(temp,'visible','off')
    
    axes(handles.im_axes)
    
    % Make sure the correct things are enabled/disabled
    set(handles.grab_pos,'Enable','on');
    set(handles.nxtframe,'Enable','off');
    set(handles.skip_button,'Enable','on');
    set(handles.data_pts_name,'Enable','on');
    set(handles.arrow1,'visible','on');
    set(handles.tip1,'visible','on');
    set(get(handles.arrow1,'Children'),'visible','on');
    
    % Update handles structure
    guidata(hObject, handles);
catch err
    disp(err)
    error('An invalid folder was selected. Please select a folder containing images from rocket test flights')
end


% --- Outputs from this function are returned to the command line.
function varargout = rocket_tracker_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = [];


% --- Executes on button press in grab_pos.
function grab_pos_Callback(hObject, eventdata, handles)
% hObject    handle to grab_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xlim = get(handles.im_axes,'XLim'); % x-limits of image (pixels)
ylim = get(handles.im_axes,'YLim'); % y-limits of image (pixels)

% Have user select rocket position within frame
[x,y,button] = ginput(1);
if button == 1 && x > xlim(1) && x < xlim(2) && y > ylim(1) && y < ylim(2) % left mouse click and within valid range
    set(handles.xpos_pix,'String',num2str(x)); % Set x-position field
    set(handles.ypos_pix,'String',num2str(y)); % Set y-position field
    set(handles.nxtframe,'Enable','on'); % Enable next frame button
    % Update status string
    set(handles.status_string,'String',['Successfully grabbed position #' get(handles.framenum,'String') '!!!'])
    set(handles.status_string,'BackgroundColor',[0 1 0]);
    % Show next frame arrow tip
    set(handles.arrow2,'visible','on');
    set(get(handles.arrow2,'Children'),'visible','on');
    set(handles.tip2,'visible','on');
    % Plot point selection
    axes(handles.im_axes)
    hold on
    plot(x,y,'.')
    hold off
elseif button == 1 && (x < xlim(1) || x > xlim(2) || y < ylim(1) || y > ylim(2)) % left mouse click but invalid range
    set(handles.xpos_pix,'String','0'); % Reset x-position field
    set(handles.ypos_pix,'String','0'); % Reset y-position field
    set(handles.nxtframe,'Enable','off'); % Disable next frame button
    % Update status string
    set(handles.status_string,'String','Invalid position selection!!! (out of bounds)')
    set(handles.status_string,'BackgroundColor',[1 0 0]);
    % Hide next frame arrow tip
    set(handles.arrow2,'visible','off');
    set(get(handles.arrow2,'Children'),'visible','off');
    set(handles.tip2,'visible','off');
else % wrong button pressed, etc.
    set(handles.xpos_pix,'String','0'); % Reset x-position field
    set(handles.ypos_pix,'String','0'); % Reset y-position field
    set(handles.nxtframe,'Enable','off'); % Disable next frame button
    % Update status string
    set(handles.status_string,'String','Please make position selection with a left-click')
    set(handles.status_string,'BackgroundColor',[1 0 0]);
    % Hide next frame arrow tip
    set(handles.arrow2,'visible','off');
    set(get(handles.arrow2,'Children'),'visible','off');
    set(handles.tip2,'visible','off');
end


% --- Executes on button press in nxtframe.
function nxtframe_Callback(hObject, eventdata, handles)

% hObject    handle to nxtframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the current frame number
curr_frame = str2double(get(handles.framenum,'String')); % Frame #

% Save the x- and y- position data (in pixels)
xpos = str2double(get(handles.xpos_pix,'String'));
ypos = str2double(get(handles.ypos_pix,'String'));
% If file already exists, concatenate data
if exist([handles.dirname '\' get(handles.data_pts_name,'String')],'file') == 2
    load([handles.dirname '\' get(handles.data_pts_name,'String')]);
    data.x = [data.x; xpos];
    data.y = [data.y; ypos];
    
    save([handles.dirname '\' get(handles.data_pts_name,'String')],'data');
    % Update status string
    set(handles.status_string,'String',['Successfully saved position #' get(handles.framenum,'String') '!!!'])
    set(handles.status_string,'BackgroundColor',[0 1 0]);
else % Otherwise create data file and save first points to it
    data = struct([]);
    data(1).x = xpos;
    data(1).y = ypos;
    
    
    handles.dirname = uigetdir(pwd,['Select a Folder to Save ''' get(handles.data_pts_name,'String') ''' data file']);
    while handles.dirname == 0
        waitfor(errordlg('Please select a valid directory to save the data!'))
        handles.dirname = uigetdir(pwd,['Select a Folder to Save ''' get(handles.data_pts_name,'String') ''' data file']);
    end
    guidata(hObject,handles);
    
    save([handles.dirname '\' get(handles.data_pts_name,'String')],'data');
    % Update status string
    set(handles.status_string,'String',['Successfully created ' get(handles.data_pts_name,'String') ' file and saved position #' get(handles.framenum,'String') '!!!']);
    set(handles.status_string,'BackgroundColor',[0 1 0]);
end

% Make sure we're not at the end of the frames
if curr_frame <= handles.vidObj.NumberOfFrames - 1
%     file_name = D(counter).name; % Get frame file-name
    
    % Show the new frame
    A = read(handles.vidObj,curr_frame+1);
    axes(handles.im_axes);
    imshow(A);
    
    % Disable nxt_frame button and update frame information
    set(hObject,'Enable','off');
    set(handles.framenum,'String',curr_frame+1);
    set(handles.xpos_pix,'String','0');
    set(handles.ypos_pix,'String','0');
    
    % Plot x- and y-position history on frame
    temp = load([handles.dirname '\' get(handles.data_pts_name,'String')]);
    hold on
    plot(temp.data.x,temp.data.y,'r.')
    hold off
else
    % Disable nxt_frame button, grab_pos button, skip_button, and update
    % status string
    set(hObject,'Enable','off');
    set(handles.grab_pos,'Enable','off');
    set(handles.status_string,'String','Reached end of video!');
    set(handles.status_string,'BackgroundColor',[0 1 1]);
    set(handles.skip_button,'Enable','off');
end

% Hide nxt_frame arrow tip
set(handles.arrow2,'visible','off');
set(handles.tip2,'visible','off');
set(get(handles.arrow2,'Children'),'visible','off');

% Disable save-file name field and hide arrow tip
set(handles.data_pts_name,'Enable','off');
set(handles.arrow1,'visible','off');
set(handles.tip1,'visible','off');
set(get(handles.arrow1,'Children'),'visible','off');


function data_pts_name_Callback(hObject, eventdata, handles)
% hObject    handle to data_pts_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of data_pts_name as text
%        str2double(get(hObject,'String')) returns contents of data_pts_name as a double
temp = get(hObject,'String');
% Make sure data_pts_name ends in .mat
if ~strcmp(temp(end-3:end),'.mat')
    set(hObject,'String',[temp '.mat']);
    set(handles.status_string,'String','Warning: Automatically corrected file name to end in ''.mat''');
    set(handles.status_string,'BackgroundColor',[1 69/255 0]);
else
    set(handles.status_string,'String','Successfully changed save-file name')
    set(handles.status_string,'BackgroundColor',[0 1 0]);
end
    

% --- Executes during object creation, after setting all properties.
function data_pts_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_pts_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'BackgroundColor','white');


% --- Executes on button press in skip_button.
function skip_button_Callback(hObject, eventdata, handles)
% hObject    handle to skip_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the current frame number
curr_frame = str2double(get(handles.framenum,'String')); % Frame #

% If file doesn't exist, then make sure it is created.
if exist([handles.dirname '\' get(handles.data_pts_name,'String')],'file') ~= 2
    data = struct([]);
    data(1).x = [];
    data(1).y = [];
    
    handles.dirname = uigetdir(pwd,['Select a Folder to Save ''' get(handles.data_pts_name,'String') ''' data file']);
    while handles.dirname == 0
        waitfor(errordlg('Please select a valid directory to save the data!'))
        handles.dirname = uigetdir(pwd,['Select a Folder to Save ''' get(handles.data_pts_name,'String') ''' data file']);
    end
    guidata(hObject,handles);
    
    save([handles.dirname '\' get(handles.data_pts_name,'String')],'data');
    % Update status string
    set(handles.status_string,'String',['Successfully created ' get(handles.data_pts_name,'String') ' file']);
    set(handles.status_string,'BackgroundColor',[0 1 0]);
    
    % Disable save-file name field and hide arrow tip
    set(handles.data_pts_name,'Enable','off');
    set(handles.arrow1,'visible','off');
    set(handles.tip1,'visible','off');
    set(get(handles.arrow1,'Children'),'visible','off');
    
end


% Make sure we're not at the end of the frames
if curr_frame <= handles.vidObj.NumberOfFrames - 1
%     file_name = D(counter).name; % Get frame file-name
    
    % Show the new frame
    A = read(handles.vidObj,curr_frame+1);
    axes(handles.im_axes);
    imshow(A);
    
    % Plot x- and y-position history
    temp = load([handles.dirname '\' get(handles.data_pts_name,'String')]);
    hold on
    plot(temp.data.x,temp.data.y,'r.')
    hold off
    
    % Disable next frame button and update frame information
    set(handles.nxtframe,'Enable','off');
    set(handles.framenum,'String',curr_frame+1);
    set(handles.xpos_pix,'String','0');
    set(handles.ypos_pix,'String','0');
else
    % Disable everything and update status string
    set(handles.nxtframe,'Enable','off');
    set(handles.grab_pos,'Enable','off');
    set(handles.status_string,'String','Reached end of video!');
    set(handles.status_string,'BackgroundColor',[0 1 1]);
    set(hObject,'Enable','off');
end

% Hide nxt_frame arrow tip
set(handles.arrow2,'visible','off');
set(handles.tip2,'visible','off');
set(get(handles.arrow2,'Children'),'visible','off');

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
