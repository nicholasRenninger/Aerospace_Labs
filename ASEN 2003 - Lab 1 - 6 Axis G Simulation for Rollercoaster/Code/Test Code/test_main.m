%% Houskeeping %%
clear variables
close all
close hidden
clc

H_INIT = 125; % [m]
g = 9.81; % [m/s^2]
g_vec = [0, 0, -9.81]; % [m/s^2]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1st Segment %%

% define time range for segment
t1_init = 0; % not actually time, just chosen param. name
t1_final = 10;
t1_range = [t1_init, t1_final];


%%% Define function for segment %%%
syms t s
x1_t = 0;
y1_t = t;
z1_t = -t^2 + H_INIT;

% defining start and end position of segment
segment_1_fcn = matlabFunction(x1_t, y1_t, z1_t);
[x1_start, y1_start, z1_start] = segment_1_fcn(t1_init);
[x1_end, y1_end, z1_end] = segment_1_fcn(t1_final);


%%% doing arc length transform %%%
speed = sqrt(2 * g * (H_INIT - z1_t));
arcLength = int(speed, 0, t);
t1_new = solve(arcLength == s, t);


%%% Defining TNB Vectors %%%
r1_vec = [x1_t, y1_t, z1_t];

% T vector
vt = diff(r1_vec, t);
T = vt ./ norm(vt);

% N vector
T_prime = diff(T, t);
N = T_prime ./ norm(T_prime);

% B vector
at = diff(vt, t);
B = cross(vt, at) ./ norm(diff(vt, t));


%%% Subbing in t = f(s) to get T, N, B components of acceleration as
%%% functions of s.

% find component of acceleration in the direction of TNB as fcns of t
A_T_t = dot(at, T);
A_N_t = dot(at, N);
A_B_t = dot(at, B);

% find component of acceleration in the direction of TNB as fcns of s
A_T_s = subs(A_T_t, t, t1_new(2));
A_N_s = subs(A_N_t, t, t1_new(2));
A_B_s = subs(A_B_t, t, t1_new(2));

% defining function for A in the TNB frame as functions of s
A_T_s_fcn = matlabFunction(A_T_s, 'Vars', s);
A_N_s_fcn = matlabFunction(A_N_s, 'Vars', s);
A_B_s_fcn = matlabFunction(A_B_s, 'Vars', s);



%% Arc Length of Track %%
norm_of_deriv = sqrt(diff(x1_t, t)^2 + diff(y1_t, t)^2 + diff(z1_t, t)^2);
track_length = double( int(norm_of_deriv, t,...
                           t1_init, t1_final) );

%%% Plot %%%

% Plotting Track Path
path_plot = figure('Name', 'Track Path');
hold on

x1_t = @(t) 0; % fplot needs all fcns to be sym of fcn handles, 0 is a dbl.
fplot3(x1_t, y1_t, z1_t, t1_range);
figure(path_plot)
scatter3(x1_start, y1_start, z1_start, 'filled')

g_plot = figure('Name', 'G-Force Plot');

% Plotting G-force
hold on
fplot(A_T_s_fcn, [0, track_length])
figure(g_plot)
fplot(A_N_s_fcn, [0, track_length])
figure(g_plot)
fplot(A_B_s_fcn, [0, track_length])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2nd Segment %%

% define time range for segment
t2_init = t1_final; % not actually time, just chosen param. name
t2_final = 20;
t2_range = [t2_init, t2_final];

%%% Define function for segment %%%
syms t
x2_t = cos(t) + x1_end;
y2_t = t + y1_end;
z2_t = -t + z1_end;

% defining start and end position of segment
segment_2_fcn = matlabFunction(x2_t, y2_t, z2_t);
[x2_start, y2_start, z2_start] = segment_2_fcn(t2_init);
[x2_end, y2_end, z2_end] = segment_2_fcn(t2_final);

%%% Plot %%%
fplot3(x2_t, y2_t, z2_t, t2_range)
scatter3(x2_start, y2_start, z2_start, 'filled')