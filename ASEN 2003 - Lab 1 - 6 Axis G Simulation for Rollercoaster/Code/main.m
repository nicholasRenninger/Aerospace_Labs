% This is the driver script that calls all of the functions nessecary to
% design and build a rollercoaster track. Has the folowing dependencies: 
%              
%                    Arrow.m and Derivative.m 
%                  (for test code. find these on FEX)
%
% Author: Nicholas Renninger
% Date Modified: 2/2/17


%% Housekeeping

clear variables
close all
clc

% initializations
h_init = 125; % [m]
g = 9.81; % [m/s^2]
NUM_STEPS = 50;
total_time = 0; % [s]
track_length = 0; % [m]
segment_lengths = zeros(1, 8);
segment_idx = 1;
speed = @(h) sqrt(2 * g * (h_init - h)); % [m/s]

% Plot setup
figure_title = sprintf('Path of Roller Coaster in Cartesian Space');
xlabel_string = sprintf('$y$ Coordinate (m)');
ylabel_string = sprintf('$x$ Coordinate (m)');
zlabel_string = sprintf('Height (m)');
LINEWIDTH = 3;
FONTSIZE = 28;

% initialize plot handles
path_plot = figure('Name', 'Path of Coaster');
scrz = get(groot,'ScreenSize');
set(path_plot, 'Position', scrz)
set(groot, 'defaultLegendInterpreter', 'latex');

gPlot = figure('Name', 'G-Force');
vPlot = figure('Name', 'Speed');


%% Create transition to helix segment

%%% 1st transistion Element - 0 G


% define constants
rollAngle = @(t) (0) * (pi / 180) ; % [rad]
t_start = 0; % [s]
t_end = 10; % [s]
pos_in = [15, 60, h_init]; % [m]

%%% create segment
[R1_t, N_t, T_t, T_out, arc_length] = transition1(t_start, pos_in, ...
                                                path_plot, t_end, ...
                                                LINEWIDTH);

% Define ending location of track segment
R1_t_end = [R1_t{1}(t_end), R1_t{2}(t_end), R1_t{3}(t_end)];
                                        
%%% calculate G's as a function of s
Domain = [t_start, t_end];
[g_and_s_mat, segment_time] = theOriginalGs(Domain, NUM_STEPS, R1_t, ... 
                                         T_t, N_t, false, rollAngle);
                                     
% update track lengt
track_length = track_length + arc_length;
segment_lengths(segment_idx) = g_and_s_mat(end, 1);
segment_idx = segment_idx + 1;
                          
%%% Update G's matrix and total time

% add on change in time to total
total_time = total_time + segment_time;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% create 2nd trasnition element %%%

%%% define constants
rollAngle = @(t) ((-70 / 1.5852) * (t - pi/2)) * (pi / 180) ; % [rad]
t_start = pi/2; % [s]
t_end = 3.156; % [s]
pos_in = R1_t_end; % [m]
 
[R1_t, N_t, T_t, T1_out, arc_length] = transition1andHalf(t_start,....
                                                          pos_in,...
                                                          path_plot, ...
                                                          t_end, ...
                                                          LINEWIDTH);
% update track length
track_length = track_length + arc_length;
segment_lengths(segment_idx) = arc_length;
segment_idx = segment_idx + 1;

% Define ending location of track segment
R1_t_end = [R1_t{1}(t_end), R1_t{2}(t_end), R1_t{3}(t_end)];
                                        
%%% calculate G's as a function of s
Domain = [t_start, t_end];
[g_temp_mat, segment_time] = theOriginalGs(Domain, NUM_STEPS, R1_t, ... 
                                         T_t, N_t, false, rollAngle);
                          
%%% Update G's matrix and total time

% add on change in time to total
total_time = total_time + segment_time;

% add on prev arcLen
g_temp_mat(:, 1) = g_temp_mat(:, 1) + g_and_s_mat(end, 1);
g_and_s_mat = cat(1, g_and_s_mat, g_temp_mat);



%% Create 2nd segment - helix

%%% define constants
helix_max_radius = 20; % [m]
helix_num_loops = 2;
helix_height = 20; % [m]
helix_bank_angle = @(t) -70 * (pi / 180); % [rad]
t_start = 0; % [s]
pos_in = R1_t_end; % [m]

%%% create helix
[arc_length, R2_t, T2_out,...
 N_t, t_end, T_t] = Helix(helix_max_radius, helix_num_loops, ...
                     helix_height, t_start, pos_in, path_plot, LINEWIDTH);

% Define ending location of track segment
R2_t_end = [R2_t{1}(t_end), R2_t{2}(t_end), R2_t{3}(t_end)];

% update track length
track_length = track_length + arc_length;
segment_lengths(segment_idx) = arc_length;
segment_idx = segment_idx + 1;
                                        
%%% calculate G's as a function of s
Domain = [t_start, t_end];
[g_temp_mat, segment_time] = theOriginalGs(Domain, NUM_STEPS, R2_t, ...
                                          T_t, N_t, false, helix_bank_angle);
                          
%%% Update G's matrix and total time

% add on change in time to total
total_time = total_time + segment_time;

% add on prev arcLen
g_temp_mat(:, 1) = g_temp_mat(:, 1) + g_and_s_mat(end, 1);
g_and_s_mat = cat(1, g_and_s_mat, g_temp_mat);
 


%% next track segment - parabolic hill

%%% define constants
rollAngle = @(t) (-(2/3) * t - 70) * (pi / 180) ; % [rad]
t_start = 0; % [s]
t_end = 30; % [s]
pos_in = R2_t_end; % [m]
T_in = T2_out;

%%% create segment
[R3_t, N_t, T_t, T3_out, arc_length] = para_hill(t_start, pos_in, T_in,...
                                                path_plot, t_end, ...
                                                LINEWIDTH);
% update track length
track_length = track_length + arc_length;
segment_lengths(segment_idx) = arc_length;
segment_idx = segment_idx + 1;

% Define ending location of track segment
R3_t_end = [R3_t{1}(t_end), R3_t{2}(t_end), R3_t{3}(t_end)];
                                        
%%% calculate G's as a function of s
Domain = [t_start, t_end];
[g_temp_mat, segment_time] = theOriginalGs(Domain, NUM_STEPS, R3_t, ... 
                                         T_t, N_t, false, rollAngle);
                          
%%% Update G's matrix and total time

% add on change in time to total
total_time = total_time + segment_time;

% add on prev arcLen
g_temp_mat(:, 1) = g_temp_mat(:, 1) + g_and_s_mat(end, 1);
g_and_s_mat = cat(1, g_and_s_mat, g_temp_mat);



%% Create 3rd track segment - loop

%%% define constants
rollAngle = @(t) -90 * (pi / 180) ; % [rad]
t_start = acos(-T3_out(1)); % [s]
t_end = t_start + 2 * pi; % [s]
pos_in = R3_t_end; % [m]
r = 33; % [m]

%%% create segment
[R4_t, N_t, T_t, T4_out, arc_length] = loop(t_start, r, pos_in, ...
                                            path_plot, t_end, LINEWIDTH);
% update track length
track_length = track_length + arc_length;
segment_lengths(segment_idx) = arc_length;
segment_idx = segment_idx + 1;

% Define ending location of track segment
R4_t_end = [R4_t{1}(t_end), R4_t{2}(t_end), R4_t{3}(t_end)];
                                        
%%% calculate G's as a function of s
Domain = [t_start, t_end];
[g_temp_mat, segment_time] = theOriginalGs(Domain, NUM_STEPS, R4_t, ...
                                           T_t, N_t, false, rollAngle);
                          
%%% Update G's matrix and total time

% add on change in time to total
total_time = total_time + segment_time;

% add on prev arcLen
g_temp_mat(:, 1) = g_temp_mat(:, 1) + g_and_s_mat(end, 1); 
g_and_s_mat = cat(1, g_and_s_mat, g_temp_mat);



%% transition from loop Section

%%% define constants
rollAngle = @(t) (45) * (pi / 180) ; % [rad]
t_start = 0; % [s]
t_end = abs(R4_t_end(3) / T4_out(3)) - 26.827; % [s]
pos_in = R4_t_end; % [m]
T_in = T4_out;
 
[R5_t, N_t, T_t, T5_out, arc_length] = transition2(t_start, pos_in, ...
                                                   path_plot, t_end, ...
                                                   T_in, LINEWIDTH);
% update track length
track_length = track_length + arc_length;
segment_lengths(segment_idx) = arc_length;
segment_idx = segment_idx + 1;

% Define ending location of track segment
R5_t_end = [R5_t{1}(t_end), R5_t{2}(t_end), R5_t{3}(t_end)];
                                        
%%% calculate G's as a function of s
Domain = [t_start, t_end];
[g_temp_mat, segment_time] = theOriginalGs(Domain, NUM_STEPS, R5_t, ... 
                                         T_t, N_t, true, rollAngle);

%%% Update G's matrix and total time

% add on change in time to total
total_time = total_time + segment_time;

% add on prev arcLen
g_temp_mat(:, 1) = g_temp_mat(:, 1) + g_and_s_mat(end, 1);
g_and_s_mat = cat(1, g_and_s_mat, g_temp_mat);



%% transition into braking section

%%% define constants
rollAngle = @(t) (-90) * (pi / 180) ; % [rad]
t_start = acos(-T5_out(1)); % [s]
t_end = pi; % [s]
pos_in = R5_t_end; % [m]
 
[R6_t, N_t, T_t, T6_out, arc_length] = transition3(t_start,....
                                                          pos_in,...
                                                          path_plot, ...
                                                          t_end, ...
                                                          LINEWIDTH);
% update track length
track_length = track_length + arc_length;
segment_lengths(segment_idx) = arc_length;
segment_idx = segment_idx + 1;

% Define ending location of track segment
R6_t_end = [R6_t{1}(t_end), R6_t{2}(t_end), R6_t{3}(t_end)];
                                        
%%% calculate G's as a function of s
Domain = [t_start, t_end];
[g_temp_mat, segment_time] = theOriginalGs(Domain, NUM_STEPS, R6_t, ... 
                                         T_t, N_t, false, rollAngle);
                          
%%% Update G's matrix and total time

% add on change in time to total
total_time = total_time + segment_time;

% add on prev arcLen
g_temp_mat(:, 1) = g_temp_mat(:, 1) + g_and_s_mat(end, 1);
g_and_s_mat = cat(1, g_and_s_mat, g_temp_mat);


%% Braking section

%%% define constants
rollAngle = @(t) (-90) * (pi / 180) ; % [rad]
t_start = 0; % [s]
t_end = 80; % [s]
pos_in = R6_t_end; % [m]
T_in = T6_out;
 
[R7_t, N_t, T_t, T7_out, arc_length] = Brake(t_start, pos_in, ...
                                             path_plot, t_end, LINEWIDTH);

% Define ending location of track segment
R7_t_end = [R7_t{1}(t_end), R7_t{2}(t_end), R7_t{3}(t_end)];

% update track length
track_length = track_length + arc_length;
segment_lengths(segment_idx) = arc_length;
segment_idx = segment_idx + 1;
                                     

%%% calculate G's as a function of s
Domain = [t_start, t_end];
[g_temp_mat, ~] = theOriginalGs(Domain, NUM_STEPS, R7_t, ... 
                                         T_t, N_t, false, rollAngle);

                                     
%%% Re-calc tangental g's to account for braking
A_T = -15.321; % [m/s^2] based on 80m of track to slow down from 49.5 m/s
G_T_braking = A_T / g; % F_t / mg = G_t = A_t / g
segment_time = 3.23084; % [s] accounting for the decreasing velocity

% update G's matrix
g_temp_mat(:, 2) = g_temp_mat(:, 2) + G_T_braking;


%%% Calculate speed through braking section:

% calculate the change in time for the distance traveled - this is
% done using dV = A_T * dt. Create vector of linearly spaced time intervals
time_vec = linspace(0, segment_time, NUM_STEPS);

% initializations
[new_speed_vec, position_vec] = deal(zeros(1, NUM_STEPS));
initial_speed = speed(0); % [m/s]
initial_position = track_length - arc_length; % [m]
idx = 1;

% define initial velocity & position
new_speed_vec(1) = initial_speed;
position_vec(1) = initial_position;

% define position of cart along track as fcn of time
position = @(t) ( (1/2) * A_T * t.^2 ) + (initial_speed .* t) + ...
                initial_position;

% calc speed at each step 
for i = 1:NUM_STEPS
    
    if i > 1 % skip first step
        
        % calculate arc length along the track at each time
        current_time = time_vec(i);
        position_vec(i) = position(current_time);
        
        % calc dt
        dt = time_vec(i) - time_vec(i - 1);
        
        % calculate dSpeed = A_t dt
        dV = A_T * dt;
        
        % define the new speed after the dt interval
        new_speed_vec(idx) = new_speed_vec(idx - 1) + dV;
       
    end
    
    idx = idx + 1;
    
end


% create braking_V vector
braking_V(:, 1) = position_vec; % position is one elem longer than V
braking_V(:, 2) = new_speed_vec;


%%% Update G's matrix and total time

% add on change in time to total
total_time = total_time + segment_time;
avg_speed = track_length / total_time;

% add on prev arcLen
g_temp_mat(:, 1) = g_temp_mat(:, 1) + g_and_s_mat(end, 1);
g_and_s_mat = cat(1, g_and_s_mat, g_temp_mat);



%% Plot G's % V over track

clc
makeGPlot(g_and_s_mat, segment_lengths, gPlot);
makeVPlot(g_and_s_mat, braking_V, segment_lengths, avg_speed, ...
          NUM_STEPS, vPlot);

% configure path plot 
figure(path_plot)
set(gca, 'FontSize', FONTSIZE)
set(gca, 'defaulttextinterpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')
title(figure_title)
xlabel(xlabel_string)
ylabel(ylabel_string)
zlabel(zlabel_string)

%% Print statistics
fprintf('Total Time Elapsed: %0.3g s\n', total_time);
fprintf('Length of the TrackL %0.3g m\n', track_length);
fprintf('Average Speed: %0.3g m/s\n', avg_speed);


