%%% ASEN 2003 Lab 2 Main
%%%
%%% Author: Nicholas Renninger
%%% Created: 2/2/2017
%%% Last Modified: 2/17/2017


%% Housekeeping

clear variables
close all
clc


%% Define Constants

% define how many video pixels make up one inch
PIXEL_TO_IN_SETUP_1 = 15.826;
PIXEL_TO_IN_SETUP_2 = 16.510;

% define the possible error in the determination of the ball's height in
% method 1 analysis
BALL_RAD_SETUP_1 = 35.048924 / 2; % [pixels]

% define the possible error in the measurement of the time between bounces
% as the time between frames given the frame rate of the camera - 240 fps.
TIME_ERROR = (2 / 240); % [s]

% Define the height at which the ball was dropped for the trials
H_INIT_DAY_1 = 43.75; % [in]
H_INIT_DAY_2 = 34; % [in]

% Define the uncertainty in the initial height of the ball for Day 1 Data
H_INIT_ERROR_DAY_1 = 4; % [in]
H_INIT_ERROR_DAY_2 = 1; % [in]


% Define the uncertainty in the time till the ball stops - initial time
% measurement uncertainty + final time measurement uncertainty
init_time_error = (2 / 240); % [s]
final_time_error_day_1 = (240 / 240); % [s]
final_time_error_day_2 = (5 / 240); % [s]

STOP_TIME_ERROR_DAY_1 = init_time_error + final_time_error_day_1; % [s]
STOP_TIME_ERROR_DAY_2 = init_time_error + final_time_error_day_2; % [s]


% plot constants
FONTSIZE = 28;
LINEWIDTH = 3.5;
set(0, 'defaulttextinterpreter', 'latex');
dim = [.2 .5 .3 .3];
mean_vec = ones(1, 100);
trials = linspace(0, 11, 100);



%% Read in all of the trials data

% read in data in trial 1 folder
trial_num = 1;
trial_1_data = read_data_files(PIXEL_TO_IN_SETUP_1, trial_num);

% read in data in trial 2 - golf ball folder
trial_num = 2;
trial_2_data = read_data_files(PIXEL_TO_IN_SETUP_1, trial_num);

% read in data in trial 3 - new method folder
trial_num = 3;
trial_3_data = read_data_files(PIXEL_TO_IN_SETUP_1, trial_num);


% define number of trials for Day 1 and Day 2
num_trials_day_1 = length(trial_1_data);
num_trials_day_2 = length(trial_2_data);

%% Calc. e & uncertainty for each method, improved method, and new ball

%%% For Day 1 Data
for i = 1:length(trial_1_data)
    
    h_vec = trial_1_data{i}.y;
    t_vec = trial_1_data{i}.time;
    
    
    %%% Day 1 data, method 1
    [e_curr, sigma_e_curr] = calc_e_method_1(h_vec, t_vec, ...
                                   BALL_RAD_SETUP_1, BALL_RAD_SETUP_1);
    
    e_vec.one.values(i) = e_curr; 
    e_vec.one.error(i) = sigma_e_curr;
    
    
    %%% Day 1 data, method 2
    [e_curr, sigma_e_curr] = calc_e_method_2(h_vec, t_vec, TIME_ERROR);
    
    e_vec.two.values(i) = e_curr; 
    e_vec.two.error(i) = sigma_e_curr;
    
    
    %%% Day 1 data, method 3
    [e_curr, sigma_e_curr] = calc_e_method_3(t_vec, H_INIT_DAY_1, ...
                                             STOP_TIME_ERROR_DAY_1, ...
                                             H_INIT_ERROR_DAY_1);
    
    e_vec.three.values(i) = e_curr; 
    e_vec.three.error(i) = sigma_e_curr;
    
end


%%% For Day 2 Data (improved method 3)
for i = 1:length(trial_2_data)
    
    h_vec = trial_2_data{i}.y;
    t_vec = trial_2_data{i}.time;
    
    %%% Day 2 data, method 3
    [e_curr, sigma_e_curr] = calc_e_method_3(t_vec, H_INIT_DAY_2, ...
                                             STOP_TIME_ERROR_DAY_2, ...
                                             H_INIT_ERROR_DAY_2);
    
    e_vec.four.values(i) = e_curr; 
    e_vec.four.error(i) = sigma_e_curr;
    
end


%%% For Day 2 Data (golf ball - method 3)
for i = 1:length(trial_3_data)
    
    h_vec = trial_3_data{i}.y;
    t_vec = trial_3_data{i}.time;
    
    %%% Day 2 data, method 3
    [e_curr, sigma_e_curr] = calc_e_method_3(t_vec, H_INIT_DAY_2, ...
                                             STOP_TIME_ERROR_DAY_2, ...
                                             H_INIT_ERROR_DAY_2);
    
    e_vec.five.values(i) = e_curr; 
    e_vec.five.error(i) = sigma_e_curr;
    
end


%% Calc. the stats of e vector for each method, improved method, & new ball

% find mean value of e for each data set
mean_e_1 = mean(e_vec.one.values);
mean_e_2 = mean(e_vec.two.values);
mean_e_3 = mean(e_vec.three.values);
mean_e_4 = mean(e_vec.four.values);
mean_e_5 = mean(e_vec.five.values);

% std. dev. for each data set 
std_dev_e_1 = std(e_vec.one.values);
std_dev_e_2 = std(e_vec.two.values);
std_dev_e_3 = std(e_vec.three.values);
std_dev_e_4 = std(e_vec.four.values);
std_dev_e_5 = std(e_vec.five.values);

% find std. dev. of the mean for each data set
std_dev_mean_e_1 = std_dev_e_1 / sqrt(num_trials_day_1);
std_dev_mean_e_2 = std_dev_e_2 / sqrt(num_trials_day_1);
std_dev_mean_e_3 = std_dev_e_3 / sqrt(num_trials_day_1);
std_dev_mean_e_4 = std_dev_e_4 / sqrt(num_trials_day_2);
std_dev_mean_e_5 = std_dev_e_5 / sqrt(num_trials_day_2);


% find median value of e for each data set
median_e_1 = median(e_vec.one.values);
median_e_2 = median(e_vec.two.values);
median_e_3 = median(e_vec.three.values);
median_e_4 = median(e_vec.four.values);
median_e_5 = median(e_vec.five.values);

%% Do sensitivity analysis 

sensitivityAnalysis


%% Plot Method 1

figure_title = sprintf('Method 1 Trials');

legend_string = {'$e$ value for each trial', ...
        sprintf('mean e value across trial: %0.3f', mean_e_1)};
    
textbox_str = {sprintf('std. dev. of e: %0.3f', std_dev_e_1), ...
        sprintf('std. dev. of the mean of e: %0.3f', std_dev_mean_e_1), ...
        sprintf('median e value: %0.3f', median_e_1)};
    

xlabel_string = sprintf('Trial Number');
ylabel_string = sprintf('Value of $e$');
y_limits = [0.75, 1];
x_limits = [1, num_trials_day_1];
LEGEND_LOCATION = 'best';
color = [205;16;118] ./ 255;


method_1_plot = figure('name', 'Method 1');
scrz = get(groot,'ScreenSize');
set(method_1_plot, 'Position', scrz)


p2 = plot(trials, mean_vec .* mean_e_1, ':k',...
          'LineWidth', LINEWIDTH);
hold on
p1 = errorbar(e_vec.one.values, e_vec.one.error, 'o',...
              'LineWidth', LINEWIDTH - 1, 'color', color);

annotation('textbox',dim,'String',textbox_str,'FitBoxToText','on', ...
           'interpreter', 'latex', 'fontsize', ...
           FONTSIZE, 'backgroundcolor', 'w');

grid on
set(gca,'FontSize', FONTSIZE)
set(gca, 'defaulttextinterpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')
xlim(x_limits)
ylim(y_limits)
title(figure_title)
xlabel(xlabel_string)
ylabel(ylabel_string)
legend([p1, p2], legend_string, 'location', LEGEND_LOCATION, ...
       'interpreter', 'latex')
   
   
%% Plot Method 2

figure_title = sprintf('Method 2 Trials');

legend_string = {'$e$ value for each trial', ...
        sprintf('mean e value across trial: %0.3f', mean_e_2)};
    
textbox_str = {sprintf('std. dev. of e: %0.3f', std_dev_e_2), ...
        sprintf('std. dev. of the mean of e: %0.3f', std_dev_mean_e_2), ...
        sprintf('median e value: %0.3f', median_e_2)};
    

xlabel_string = sprintf('Trial Number');
ylabel_string = sprintf('Value of $e$');
y_limits = [0.75, 1];
x_limits = [1, num_trials_day_1];
LEGEND_LOCATION = 'best';
color = [238;154;0] ./ 255;


method_2_plot = figure('name', 'Method 2');
scrz = get(groot,'ScreenSize');
set(method_2_plot, 'Position', scrz)


p2 = plot(trials, mean_vec .* mean_e_2, ':k',...
          'LineWidth', LINEWIDTH);
hold on
p1 = errorbar(e_vec.two.values, e_vec.two.error, 'o',...
              'LineWidth', LINEWIDTH - 1, 'color', color);

annotation('textbox',dim,'String',textbox_str,'FitBoxToText','on', ...
           'interpreter', 'latex', 'fontsize', ...
           FONTSIZE, 'backgroundcolor', 'w');

grid on
set(gca,'FontSize', FONTSIZE)
set(gca, 'defaulttextinterpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')
xlim(x_limits)
ylim(y_limits)
title(figure_title)
xlabel(xlabel_string)
ylabel(ylabel_string)
legend([p1, p2], legend_string, 'location', LEGEND_LOCATION, ...
       'interpreter', 'latex')
   
   
%% Plot Method 3

figure_title = sprintf('Method 3 Trials');

legend_string = {'$e$ value for each trial', ...
        sprintf('mean e value across trial: %0.3f', mean_e_3)};
    
textbox_str = {sprintf('std. dev. of e: %0.3f', std_dev_e_3), ...
        sprintf('std. dev. of the mean of e: %0.3f', std_dev_mean_e_3), ...
        sprintf('median e value: %0.3f', median_e_3)};
    

xlabel_string = sprintf('Trial Number');
ylabel_string = sprintf('Value of $e$');
y_limits = [0.75, 1];
x_limits = [1, num_trials_day_1];
LEGEND_LOCATION = 'best';
color = [60,179,113] ./ 255;


method_3_plot = figure('name', 'Method 3');
scrz = get(groot,'ScreenSize');
set(method_3_plot, 'Position', scrz)


p2 = plot(trials, mean_vec .* mean_e_3, ':k',...
          'LineWidth', LINEWIDTH);
hold on
p1 = errorbar(e_vec.three.values, e_vec.three.error, 'o',...
              'LineWidth', LINEWIDTH - 1, 'color', color);

annotation('textbox',dim,'String',textbox_str,'FitBoxToText','on', ...
           'interpreter', 'latex', 'fontsize', ...
           FONTSIZE, 'backgroundcolor', 'w');

grid on
set(gca,'FontSize', FONTSIZE)
set(gca, 'defaulttextinterpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')
xlim(x_limits)
ylim(y_limits)
title(figure_title)
xlabel(xlabel_string)
ylabel(ylabel_string)
legend([p1, p2], legend_string, 'location', LEGEND_LOCATION, ...
       'interpreter', 'latex')
   

%% Plot Improved Method 3

figure_title = sprintf('Improved Method 3 Trials');

legend_string = {'$e$ value for each trial', ...
        sprintf('mean e value across trial: %0.3f', mean_e_4)};
    
textbox_str = {sprintf('std. dev. of e: %0.3f', std_dev_e_4), ...
        sprintf('std. dev. of the mean of e: %0.3f', std_dev_mean_e_4), ...
        sprintf('median e value: %0.3f', median_e_4)};
    

xlabel_string = sprintf('Trial Number');
ylabel_string = sprintf('Value of $e$');
y_limits = [0.75, 1];
x_limits = [1, num_trials_day_2];
LEGEND_LOCATION = 'best';
color = [36;24;130] ./ 255;


method_3_imp_plot = figure('name', 'Improved Method 3');
scrz = get(groot,'ScreenSize');
set(method_3_imp_plot, 'Position', scrz)


p2 = plot(trials, mean_vec .* mean_e_4, ':k',...
          'LineWidth', LINEWIDTH);
hold on
p1 = errorbar(e_vec.four.values, e_vec.four.error, 'o',...
              'LineWidth', LINEWIDTH - 1, 'color', color);

annotation('textbox',dim,'String',textbox_str,'FitBoxToText','on', ...
           'interpreter', 'latex', 'fontsize', ...
           FONTSIZE, 'backgroundcolor', 'w');

grid on
set(gca,'FontSize', FONTSIZE)
set(gca, 'defaulttextinterpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')
xlim(x_limits)
ylim(y_limits)
title(figure_title)
xlabel(xlabel_string)
ylabel(ylabel_string)
legend([p1, p2], legend_string, 'location', LEGEND_LOCATION, ...
       'interpreter', 'latex')
   
   

%% Plot Golf Ball - Method 3

figure_title = sprintf('Golf Ball - Method 3 Trials');

legend_string = {'$e$ value for each trial', ...
        sprintf('mean e value across trial: %0.3f', mean_e_5)};
    
textbox_str = {sprintf('std. dev. of e: %0.3f', std_dev_e_5), ...
        sprintf('std. dev. of the mean of e: %0.3f', std_dev_mean_e_5), ...
        sprintf('median e value: %0.3f', median_e_5)};
    

xlabel_string = sprintf('Trial Number');
ylabel_string = sprintf('Value of $e$');
y_limits = [0.75, 1];
x_limits = [1, num_trials_day_2];
LEGEND_LOCATION = 'best';
color = [125;38;205] ./ 255;


golf_ball_plot = figure('name', 'Golf Ball - Method 3');
scrz = get(groot,'ScreenSize');
set(golf_ball_plot, 'Position', scrz)


p2 = plot(trials, mean_vec .* mean_e_5, ':k',...
          'LineWidth', LINEWIDTH);
hold on
p1 = errorbar(e_vec.five.values, e_vec.five.error, 'o',...
              'LineWidth', LINEWIDTH - 1, 'color', color);

annotation('textbox',dim,'String',textbox_str,'FitBoxToText','on', ...
           'interpreter', 'latex', 'fontsize', ...
           FONTSIZE, 'backgroundcolor', 'w');

grid on
set(gca,'FontSize', FONTSIZE)
set(gca, 'defaulttextinterpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')
xlim(x_limits)
ylim(y_limits)
title(figure_title)
xlabel(xlabel_string)
ylabel(ylabel_string)
legend([p1, p2], legend_string, 'location', LEGEND_LOCATION, ...
       'interpreter', 'latex')
   
%{
for i = 1:10
    
   figure
   plot(trial_1_data{i}.time, trial_1_data{i}.y)
    
end

for i = 1:11
    
   figure
   plot(trial_2_data{i}.time, trial_2_data{i}.y)
    
end

for i = 1:11
    
   figure
   plot(trial_3_data{i}.time, trial_3_data{i}.y)
    
end
%}