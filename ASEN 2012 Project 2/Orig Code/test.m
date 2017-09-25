%%% Main Script, runs ODE45 Simulations of Rocket Trajectory
%%% purpose: this code is is the driver script, and it runs all of the
%%% simulations necessary to find the parametrs that allow the
%%% rocket to reach 85m, and the range at 85m depends on the
%%% launch angle, the initial vol/mass of water, the drag
%%% coefficient, and the inital air pressure in the rocket.
%%%
%%% inputs: does not have any required inputs, but does call
%%% ASEN_Project_2_Input to get the necessary data it needs to run.
%%%
%%%
%%% outputs: has no defined outputs, but will plot the results of its
%%% sensitivity analysis, the 85m trajectory, and the verification
%%% case in separate windows.
%%%
%%%
%%% assumptions: This driver script really makes no assumptions, as it does
%%% not do any of the actual scientific calculation.
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
% [ P_init, m_water, C_drag, theta ]
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
function dydt = ASEN2012_Project_2_dy_dt(~, y)
%%% Function for use in ODE45, calculates rate of change of launch
%%% angle, the initial vol/mass of water, the drag coefficient, and the
%%% inital air pressure in the rocket as functions of time.
%%% purpose: This function calculates the rate of change of the tracked
%%% variables - launch angle, the initial vol/mass of water,
%%% the drag coefficient, and the inital air pressure in the
%%% rocket - as functions of time. Formats its input and
%%% output for use in ODE45.
%%%
%%%
%%% inputs: takes a vector y that contains all of the tracked variables
%%% that is used to calculate the new rate of change of all of
%%% these same tracked variables.
%%%
%%%
%%% outputs: outputs a vector containing how each tracked variable
%%% changed with each iteration.
%%%
%%%
%%% assumptions: assumes that the system is isentropic, that the gas
%%% can be treated as an Ideal Gas, that water is
%%% incompressible, and assumes steady atmospheric
%%% conditions for the duration of the flight.
%%%
%%%
%%% author's ID: 0dc91b091fd8
%%% date created: 11/25/2016
%%% date modified: 12/1/2016
% sensitivity varibales are set each time sensitivity analysis is ran
[global_vars] = GetGlobals;
% Set the Value of the 4 Globals
P_air_init = global_vars(1);
C_drag = global_vars(3);
% determine wheter doing sensitivity analysis or not
[do_sens_analysis, do_85m_analysis, run_verif_case] = getGlobalBool;
%% resolving y vec. into its constituent variables for readability
Velocity = y(1);
mass_air = y(2);
mass_water = y(3);
theta = y(4);
x_pos = y(5); % only here for debugging
z_pos = y(6); % only here for debugging
V_air = y(7);
%% Initializing Needed Parameters for Trajectory Calculation
[flight_params, ~] = ASEN2012_Project_2_Input(do_sens_analysis, ...
do_85m_analysis, ...
run_verif_case);
g = flight_params(1);
C_discharge = flight_params(2);
V_bottle = flight_params(3);
P_atm = flight_params(4);
gamma = flight_params(5);
rho_water = flight_params(6);
A_throat = flight_params(7);
A_bottle = flight_params(8);
R_air = flight_params(9);
mass_bottle = flight_params(10);
V_air_init = flight_params(11);
Rho_air_atm = flight_params(12);
T_air_init = flight_params(13);
m_air_init = flight_params(14);
%%% Make sure that air volume does not exceed bottle volume
if V_air > V_bottle
V_air = V_bottle;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Determining Flight Regime of Rocket and Related parameters
if V_air < V_bottle % Water Thrust Period of Flight
% Air pressure at Time t
P_air = P_air_init * (V_air_init / V_air) ^ gamma;
% Exhaust Velocity
Vel_exhaust = sqrt((2/rho_water) * (P_air - P_atm));
% Mass flow rate of water out the Throat of the Bottle and of Air
dmWater_dt = -C_discharge * rho_water * A_throat * Vel_exhaust;
dmAir_dt = 0;
% Thrust of Rocket
F = 2 * C_discharge * (P_air - P_atm) * A_throat;
%% Rate of Change of Volume of Air
if V_air < V_bottle
dVair_dt = C_discharge * A_throat * Vel_exhaust;
else
dVair_dt = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else % Air Thrust Period of Flight
% Pressure and Temperature of air in bottle when all of the water
% is expelled.
P_end = P_air_init * (V_air_init / V_bottle) ^ gamma;
T_end = T_air_init * (V_air_init / V_bottle) ^ (gamma - 1);
% Air Pressure at Time t
P_air_mass_eqn = P_end * (mass_air / m_air_init) ^ gamma;
if P_air_mass_eqn > P_atm
% Local Air Denisty & Air Temp
rho_air = mass_air / V_bottle;
T_air = P_air_mass_eqn / (rho_air * R_air);
% Critical Pressure
crit_pressure = P_air_mass_eqn * (2 / (gamma + 1)) ...
^ (gamma / (gamma - 1));
%% Check for Choked Flow (M_exit = 1)
if crit_pressure > P_atm % Choked Flow
T_exit = (2 / (gamma + 1)) * T_air;
rho_exit = crit_pressure / (R_air * T_exit);
Velocity_exit = sqrt(gamma * R_air * T_exit);
P_air_exit = crit_pressure;
elseif crit_pressure <= P_atm % Not Choked
% Exit air Pressure is ambient air pressure
P_air_exit = P_atm;
%%% Solve System of Equations %%%
syms M_exit T_exit rho_exit
press_eqn = ( P_air_mass_eqn / P_atm == ...
(1 + ((gamma - 1) / 2) * M_exit ^ 2) ^ (gamma / (gamma - 1)) );
temp_eqn = ( T_exit / T_air == 1 + ((gamma - 1) / 2) * M_exit ^ 2 );
rho_eqn = ( rho_exit == P_atm / (R_air * T_exit) );
solution = solve(press_eqn, temp_eqn, rho_eqn, M_exit, T_exit, rho_exit);
%%% Find Exit Mach Number %%%
M_exit_indeces_real = find(imag(solution.M_exit) == 0);
M_exit_real = double(solution.M_exit(M_exit_indeces_real));
M_exit_indeces_positive = M_exit_real > 0;
M_exit = M_exit_real(M_exit_indeces_positive);
%%% Find Exit Temperature %%%
T_exit_indeces_real = find(imag(solution.T_exit) == 0);
T_exit_real = double(solution.T_exit(T_exit_indeces_real));
T_exit_no_Duplicates = unique(T_exit_real);
if length(T_exit_no_Duplicates) > 1
error('duplicates homie');
end
T_exit = unique(T_exit_real);
%%% Find Exit Air Density %%%
rho_exit_indeces_real = find(imag(solution.rho_exit) == 0);
rho_exit_real = double(solution.rho_exit(rho_exit_indeces_real));
rho_exit_no_Duplicates = unique(rho_exit_real);
if length(rho_exit_no_Duplicates) > 1
error('duplicates homie');
end
rho_exit = unique(rho_exit_real);
% Find exit Velocity
Velocity_exit = M_exit * sqrt(gamma * R_air * T_exit);
if isempty(Velocity_exit)
error('All imaginary Solutions')
end
end
% Volume of Air no longer is changing, V_air == V_bottle
dVair_dt = 0;
%% Rate of Change Air Mass, Water Mass
dmAir_dt = -C_discharge * rho_exit * A_throat * Velocity_exit;
dmWater_dt = 0;
%% Calculate Thrust
F = -dmAir_dt * Velocity_exit + (P_air_exit - P_atm) * A_throat;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else % Ballistic (No Thrust Period) Phase
F = 0; % no thrust anymore :'(
% no change in amount of water/air in bottle
dmAir_dt = 0;
dmWater_dt = 0;
% Volume of Air no longer is changing, V_air == V_bottle
dVair_dt = 0;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Drag
Drag = (Rho_air_atm / 2) * (Velocity ^ 2) * C_drag * A_bottle;
%% Basic Governing Equations
% Mass of Rocket
if mass_water < 0
mass_water = 0;
end
mass_rocket = mass_bottle + mass_air + mass_water;
dVel_dt = (F - Drag - mass_rocket * g * sin(theta)) / mass_rocket;
if Velocity > 1
dTheta_dt = (1/Velocity) * -g * cos(theta);
else
dTheta_dt = 0;
end
dx_dt = Velocity * cos(theta);
dz_dt = Velocity * sin(theta);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Assign the change in y to the dydt vector for ode45
dydt(1) = dVel_dt;
dydt(2) = dmAir_dt;
dydt(3) = dmWater_dt;
dydt(4) = dTheta_dt;
dydt(5) = dx_dt;
dydt(6) = dz_dt;
dydt(7) = dVair_dt;
dydt = dydt';
end
function [flight_params,...
initial_conditions] = ASEN2012_Project_2_Input(use_globals,...
find_85m_range, ...
do_verification)
%%% Input function where constants for project are set.
%%% purpose: This function exists to pass data to both the main and
%%% dy_dt function. This allows the flight parameters for
%%% solution in ODE45 to be consolodated to one place and
%%% allows for easy switching of which flight parameters are
%%% returned based on what type of simulation you are running.
%%%
%%% inputs: takes three bool inputs, which tell the function whether to
%%% return the specific flight parameters for running the
%%% sensitivity analysis, the 85m range finding, or the
%%% verification case.
%%%
%%%
%%% outputs: returns a formatted vector of flight parameters needed in
%%% each iteration of the dy_dt ODE45 function for the
%%% calculation of the trajectory and a formatted vector of
%%% initial conditions needed in ODE45 to tell it where to
%%% begin solving the ODE.
%%%
%%%
%%% assumptions: assumes that all parameters will be set in SI units,
%%% that water is incompressible, and that the gas in the
%%% rocket is an Ideal Gas for at lest the beginning of
%%% the flight.
%%%
%%%
%%% author's ID: 0dc91b091fd8
%%% date created: 11/25/2016
%%% date modified: 12/1/2016
%% Define Contants
g = 9.81; % [m/s^2]
C_discharge = 0.8; % discharge coefficient [dimensionless]
Rho_air_atm = 0.961; % ambient air density [kg/m^3]
V_bottle = 0.002; % volume of empty 2 litre bottle [m^3]
P_atm = 82943.93; % atmospheric pressure [Pa]
gamma = 1.4; % ratio of specific heats for air [dimensionless]
rho_water = 1000; % density of water [kg/m^3]
D_throat = 0.021; % diameter of throat [m]
D_bottle = 0.105; % diameter of bottle [m]
R_air = 287; % gas constant for air [J/kg/K]
m_bottle = 0.07; % mass of empty bottle [kg]
T_air_init = 300; % initial temperature of air [K]
A_throat = (pi/4) * D_throat ^ 2; % cross-sect area of throat [m^2]
A_bottle = (pi/4) * D_bottle ^ 2; % cross-sect area of bottle [m^2]
%% Define Initial Conditions
if use_globals
% Set Global Variables for Sensitivity Analysis
[global_vars] = GetGlobals;
% Set the Value of the 4 Globals
P_air_init = global_vars(1);
m_water_init = global_vars(2);
C_drag = global_vars(3);
theta_init = global_vars(4);
% re-calculate vol of water based on chosen mass of water
V_water_init = m_water_init / rho_water; % initial vol.
% of water in bottle [m^3]
elseif do_verification % run simulation on verification case
C_drag = 0.5; % drag coefficient [dimensionless]
%%% Initial Absolute Pressure of Air in Bottle [Pa]
P_gauge_air = 344738; % initial gauge pressure of air in bottle[Pa]
P_air_init = P_atm + P_gauge_air;
V_water_init = 0.001; % initial vol. of water in bottle [m^3]
% Initial Mass of Water
m_water_init = rho_water * V_water_init; % [kg]
theta_init = 45 * (pi / 180); % theta [rad]
elseif find_85m_range % use preset values for sensitivity params
C_drag = 0.3; % drag coefficient [dimensionless]
%%% Initial Absolute Pressure of Air in Bottle [Pa]
P_gauge_air = 461949; % initial gauge pressure of air in bottle[Pa]
P_air_init = P_atm + P_gauge_air;
V_water_init = 0.001; % initial vol. of water in bottle [m^3]
% Initial Mass of Water
m_water_init = rho_water * V_water_init; % [kg]
theta_init = 33.7 * (pi / 180); % theta [rad]
end
% upodate global conditions so that dydt uses preset values
global_conditions = [P_air_init, m_water_init, C_drag, theta_init];
setGlobals(global_conditions);
%%% Initial Conditions of Tracked Variables
Vel_init = 0; % initial velocity of the rocket [m/s]
x_init = 0; % initial horizontal position [m]
y_init = 0.1; % initial vertical position [m]
% Initial Mass of Air in Bottle
V_air_init = V_bottle - V_water_init; % [kg]
m_air_init = (P_air_init * V_air_init) / (R_air * T_air_init); % [kg]
%% Formatting Output
flight_params = [g, C_discharge, V_bottle, P_atm, gamma,...
rho_water, A_throat, A_bottle, R_air, m_bottle, ...
V_air_init, Rho_air_atm, ...
T_air_init, m_air_init];
initial_conditions = [Vel_init, m_air_init, m_water_init,...
theta_init, x_init, y_init, V_air_init];
end
function [bool_out_1, bool_out_2, bool_out_3] = getGlobalBool
%%% function that gets the global boolean parameter control values
%%% purpose: function allows the global bool variables: "if you are
%%% running a sensitivity analysis", "if you are trying to
%%% find the 85m range paramters", and "if you are running the
%%% verification case" to be passed to anywhere in any of the
%%% functions or scripts in use. This allows the user to get
%%% the parameters that control which flight params are passed
%%% to the dy_dt function used ODE45.
%%%
%%%
%%% inputs: no reauired inputs.
%%%
%%%
%%% outputs: returns the bool values for the bool
%%% parameters for use in other functions.
%%%
%%%
%%% assumptions: assumes that the global vars have already been set
%%% before asssigning them to anything.
%%%
%%%
%%% author's ID: 0dc91b091fd8
%%% date created: 11/25/2016
%%% date modified: 12/1/2016
global is_doing_sensitiv_analysis find_85m_range do_verification
% return the current setting for which paramters are
% used in ODE45
bool_out_1 = is_doing_sensitiv_analysis;
bool_out_2 = find_85m_range;
bool_out_3 = do_verification;
end
function [global_vars] = GetGlobals
%%% function that gets the global variation parameters
%%% purpose: function allows the global variation parameters: launch
%%% angle, the initial vol/mass of water, the drag
%%% coefficient, and the inital air pressure in the rocket to
%%% be passed to any other function or script without the
%%% other functions knowing about the variables
%%%
%%%
%%% inputs: takes no inputs.
%%%
%%%
%%% outputs: returns a vector of numeric values for the variation
%%% parameters.
%%%
%%%
%%% assumptions: assumes that the global vars have already been set
%%% before asssigning them to anything.
%%%
%%%
%%% author's ID: 0dc91b091fd8
%%% date created: 11/25/2016
%%% date modified: 12/1/2016
% define pair i the initial pressure of air (the limit being the burst
% pressure of the bottle, with some factor of safety), the initial
% volume fraction (or equivalently initial mass) of water, the drag
% coefficient and the launch angle as global variables to run the
% simulation multiple times, all varying these paramters each time
global P_air_init m_water_init C_drag theta_init
% return current global variable values
global_vars = [P_air_init, m_water_init, C_drag, theta_init];
end
function setGlobalBools(bool_in_1, bool_in_2, bool_in_3)
%%% function that sets the global boolean parameter control values
%%% purpose: function allows the global bool variables: "if you are
%%% running a sensitivity analysis", "if you are trying to
%%% find the 85m range paramters", and "if you are running the
%%% verification case" to be set from anywhere in any of the
%%% functions or scripts in use. This allows the user to
%%% change which parameters are passed to the dy_dt function
%%% used ODE45.
%%%
%%%
%%% inputs: takes the bool values for the bool
%%% parameters that you want to assign to their respective
%%% global vars.
%%%
%%%
%%% outputs: no defined outputs, but will set the 3 bool global
%%% variable values for the entire workspace.
%%%
%%%
%%% assumptions: assumes that the input of bool global conditions is
%%% formatted properly so that the right values can be
%%% assigned to the right variables.
%%%
%%%
%%% author's ID: 0dc91b091fd8
%%% date created: 11/25/2016
%%% date modified: 12/1/2016
global is_doing_sensitiv_analysis find_85m_range do_verification
% Set whether running sensitivty analysis, 85m optimization, or are
% running a verification case
is_doing_sensitiv_analysis = bool_in_1;
find_85m_range = bool_in_2;
do_verification = bool_in_3;
end
function setGlobals(global_conditions)
%%% function that sets the global variation parameters
%%% purpose: function allows the global variation parameters: launch
%%% angle, the initial vol/mass of water, the drag
%%% coefficient, and the inital air pressure in the rocket to
%%% be set from anywhere in any of the functions or scripts in
%%% use.
%%%
%%%
%%% inputs: takes a vector of numeric values for the variation
%%% parameters that you want to assign to their respective
%%% global vars.
%%%
%%%
%%% outputs: no defined outputs, but will set the 4 variation global
%%% variable values for the entire workspace.
%%%
%%%
%%% assumptions: assumes that the vector of global conditions is
%%% formatted properly so that the right values can be
%%% assigned to the right variables.
%%%
%%%
%%% author's ID: 0dc91b091fd8
%%% date created: 11/25/2016
%%% date modified: 12/1/2016
% define pair i the initial pressure of air (the limit being the burst
% pressure of the bottle, with some factor of safety), the initial
% volume fraction (or equivalently initial mass) of water, the drag
% coefficient and the launch angle as global variables to run the
% simulation multiple times, all varying these paramters each time
global P_air_init m_water_init C_drag theta_init
% Set the Value of the 4 Globals
P_air_init = global_conditions(1);
m_water_init = global_conditions(2);
C_drag = global_conditions(3);
theta_init = global_conditions(4);
end