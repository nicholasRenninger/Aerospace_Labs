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
syms u s
x1_u = 0;
y1_u = sin(u);
z1_u = cos(u) + H_INIT;

