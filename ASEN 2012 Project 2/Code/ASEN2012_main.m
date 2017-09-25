%%% Main Script, runs ODE45 Simulations of Rocket Trajectory

%%% purpose: this code is is the driver script, and it runs all of the
%%%          simulations necessary to find the parametrs that allow the
%%%          rocket to reach 85m, and the range at 85m depends on the
%%%          launch angle, the initial vol/mass of water, the drag
%%%          coefficient, and the inital air pressure in the rocket.
%%%
%%% inputs: does not have any required inputs, but does call
%%%         ASEN_Project_2_Input to get the necessary data it needs to run.
%%%          
%%%
%%% outputs: has no defined outputs, but will plot the results of its
%%%          sensitivity analysis, the 85m trajectory, and the verification
%%%          case in separate windows.
%%%          
%%%
%%% assumptions: This driver script really makes no assumptions, as it does
%%%              not do any of the actual scientific calculation.
%%%              
%%%
%%% author's ID: 0dc91b091fd8
%%% date created: 11/25/2016
%%% date modified: 12/1/2016


clear all %#ok<CLALL>
clc
close all

NUM_SENSITIVITY_ITERATIONS = 5;
NUM_SENSITIVITY_VARS = 4;

%%% return maximum and minimum allowed value for each global variable
% [ P_init, m_water, C_drag,     theta ]
% [ (Pa), (kg), (unit-less), (radians) ]
P_atm = 82943.93; % [Pa]
max_global_vals = [600000 + P_atm, 1.4, 0.5, 50 * (pi / 180)];
min_global_vals = [400000 + P_atm, 0.2, 0.3, 30 * (pi / 180)];

% plotting setup

sens_names = {'P_{0, air}', 'M_{water}', 'C_{drag}', 'theta'};
sens_names_form = {sprintf('{\\fontname{times} \\it%s}', sens_names{1}), ...
                   sprintf('{\\fontname{times} \\it%s}', sens_names{2}), ...
                   sprintf('{\\fontname{times} \\it%s}', sens_names{3}), ...
                   sprintf('{\\fontname{times} \\it\\%s}', sens_names{4})};
sensitvity_units = {'(Pa)', '(kg)', '', '(deg)'}; % convert to degress and 
                                                  % for display


%% Creating Vectors of Varied Parameters

% initialize testing matrix
sens_var_vec = cell(1, NUM_SENSITIVITY_VARS);

for i = 1:NUM_SENSITIVITY_VARS
    
    % create linearly spaced vectors with 1 variable varied from its min to
    % its max with all of the rest of the variables constant at their
    % current values
    var_index = i;

    current_var_max = max_global_vals(var_index);
    current_var_min = min_global_vals(var_index);

    % Create Basic Test Matrix, a NUM_SENSITIVITY_VARS x
    % NUM_SENSITIVITY_ITERATIONS matrix that contains the values of the
    % sensitivity parameters that are to be varied. For each sensitivity
    % variable, one test matrix will have NUM_SENSITIVITY_ITERATIONS values
    % ranging from the minimum to the maximum global varibale value to do
    % sensitivity analysis on.
    
    % use the parameters that allow for 85m to vary the parameters around
    var_mat = [461949 + P_atm, 1.0, 0.3, 33.5 * (pi / 180)]; 
    
    temp_mat = repmat(var_mat, [NUM_SENSITIVITY_ITERATIONS, 1]);
    sens_var_vec{var_index} = temp_mat;
    
    % creating vector that varies from min and max param value, with
    % NUM_SENSITIVITY_ITERATIONS steps
    param_var_vec = linspace(current_var_min, current_var_max,...
                             NUM_SENSITIVITY_ITERATIONS);
    
    % Create Varying Paramter column in current Parameter matrix
    sens_var_vec{var_index}(:, var_index) = param_var_vec;
    
    % Make Legend String                                           
    for j = 1:NUM_SENSITIVITY_ITERATIONS
        
        % convert radians back to degrees for readability 
        if i == 4 % looking at theta [rad]
            curr_sens_val = sens_var_vec{var_index}(j, var_index)*(180/pi);
        else
            curr_sens_val = sens_var_vec{var_index}(j, var_index);
        end
        
        LEGEND_STRING{i}{j} = sprintf('%s = %0.3f %s',...
                                      sens_names_form{i}, ...
                                      curr_sens_val, ...
                                      sensitvity_units{i}); %#ok<SAGROW>
    
    end
                                                
end


%% Sensitivity Analysis

% set which parameters to use in ODE45 based on whether you are doing
% sensitivity analysis, finding 85m params, or running a verification case
run_sens_analysis = true;
find_85m_range = false;
run_verification_case = false;

% set global bools that control parameter data flow
setGlobalBools(run_sens_analysis, find_85m_range, run_verification_case);

for i = 1:NUM_SENSITIVITY_VARS
    
    %% new plot for each variable analyzed
    hFig = figure(i);
    set(gca,'FontSize', 28)
    set(hFig, 'Position', [100 100 1600 900])
    hold on
    
    % Print Simulation Status to Command Window
    fprintf('Current Parameter Being Varied: %s\n', sens_names{i})
    
    for j = 1:NUM_SENSITIVITY_ITERATIONS
    
        %%% Determine value of global variable, and which variable will be
        %%% modified for the current solution iteration
        global_conditions = sens_var_vec{i}(j, :);
        setGlobals(global_conditions);

        %% define initial conditions and flight variables

        % Initialize variables, return initial conditions vector
        [~, init_conds] = ASEN2012_Project_2_Input(run_sens_analysis, ...
                                                   find_85m_range, ...
                                                   run_verification_case);

        % Definging the range of time values to solve the system of ODEs 
        INIT_TIME = 0; % seconds
        FINAL_TIME = 5*((j + 6)/3); % last time of projectile - seconds
        time_interval = [INIT_TIME, FINAL_TIME];


        %% Solve System of ODEs and return numeric results 
        [~, rocketVars] = ode45('ASEN2012_Project_2_dy_dt', ...
                                time_interval, init_conds);

        % Set Trajectory Variables                        
        x = rocketVars(:, 5);
        z = rocketVars(:, 6);

        plot(x, z, 'LineWidth', 2) 
        
        fprintf('Simultion Cycle %d/%d Completed.\n', j,...
                 NUM_SENSITIVITY_ITERATIONS)
                               
    end
    
    %% Plot Settings
    legend(LEGEND_STRING{i}, 'location', 'northwest')
    ylim([0, inf])
    xlim([0, inf])
    xlabel('Horizontal Distance (m)') 
    ylabel('Vertical Distance (m)')
    title('Rocket Trajectory')
    
    hold off
    
    fprintf('\n')
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Find conditions for landing at 85 [m]

% set which parameters to use in ODE45 based on whether you are doing
% sensitivity analysis, finding 85m params, or running a verification case
run_sens_analysis = false;
find_85m_range = true;
run_verification_case = false;

% set global bools that control parameter data flow
setGlobalBools(run_sens_analysis, find_85m_range, run_verification_case);

% Print Simulation Status to Command Window
fprintf('Finding Parameters for 85m Range Target.\n\n')

%% define initial conditions and flight variables

% Initialize variables, return initial conditions vector
[~, init_conds] = ASEN2012_Project_2_Input(run_sens_analysis, ...
                                           find_85m_range, ...
                                           run_verification_case);

% Definging the range of time values to solve the system of ODEs 
INIT_TIME = 0; % seconds
FINAL_TIME = 5; % last time of projectile - seconds
time_interval = [INIT_TIME, FINAL_TIME];


%% Solve System of ODEs and return numeric results over time interval
[~, rocketVars] = ode45('ASEN2012_Project_2_dy_dt', time_interval, ...
                        init_conds);

% Set Trajectory Variables                        
x = rocketVars(:, 5);
z = rocketVars(:, 6);

% Find Range of Rocket
z_0 = 0; % looking for when rocket hits ground
near_x_0 = find(x > 30, 1, 'first');
diff_vec = abs(z(near_x_0:end) - z_0);
[~, idx] = min(diff_vec); % index of closest value
idx = idx + length(z(1:near_x_0 - 1)); % adjusting index

range = x(idx);

%% Plot 85m Solution
hFig = figure(NUM_SENSITIVITY_VARS + 1);
set(hFig, 'Position', [100 100 1600 900])

plot(x, z, 'r','LineWidth', 3)

ylim([0, inf])
xlim([0, inf])
new_legend_string = sprintf('Range of Rocket = %0.3g (m)', range);
legend(new_legend_string, 'location', 'northwest')
xlabel('Horizontal Distance (m)') 
ylabel('Vertical Distance (m)')
title('Rocket Trajectory')         
set(gca,'FontSize', 28)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run and Plot Verification Case

% set which parameters to use in ODE45 based on whether you are doing
% sensitivity analysis, finding 85m params, or running a verification case
run_sens_analysis = false;
find_85m_range = false;
run_verification_case = true;

% set global bools that control parameter data flow
setGlobalBools(run_sens_analysis, find_85m_range, run_verification_case);

% Print Simulation Status to Command Window
fprintf('Running Verification Case.\n')

%% define initial conditions and flight variables

% Initialize variables, return initial conditions vector
[~, init_conds] = ASEN2012_Project_2_Input(run_sens_analysis, ...
                                           find_85m_range, ...
                                           run_verification_case);

% Definging the range of time values to solve the system of ODEs 
INIT_TIME = 0; % seconds
FINAL_TIME = 5; % last time of projectile - seconds
time_interval = [INIT_TIME, FINAL_TIME];


%% Solve System of ODEs and return numeric results over time interval
[~, rocketVars] = ode45('ASEN2012_Project_2_dy_dt', time_interval, ...
                        init_conds);

% Set Trajectory Variables                        
x = rocketVars(:, 5);
z = rocketVars(:, 6);

% Find Range of Rocket
z_0 = 0; % looking for when rocket hits ground
near_x_0 = find(x > 30, 1, 'first');
diff_vec = abs(z(near_x_0:end) - z_0);
[~, idx] = min(diff_vec); % index of closest value
idx = idx + length(z(1:near_x_0 - 1)); % adjusting index

range = x(idx);

%% Plot Verification Case
hFig = figure(NUM_SENSITIVITY_VARS + 2);
set(hFig, 'Position', [100 100 1600 900])

plot(x, z, 'b', 'LineWidth', 3)

ylim([0, inf])
xlim([0, inf])
new_legend_string = sprintf('Range of Rocket = %0.3g (m)', range);
legend(new_legend_string, 'location', 'northwest')
xlabel('Horizontal Distance (m)') 
ylabel('Vertical Distance (m)')
title('Rocket Trajectory - Verification Case')         
set(gca,'FontSize', 28)

