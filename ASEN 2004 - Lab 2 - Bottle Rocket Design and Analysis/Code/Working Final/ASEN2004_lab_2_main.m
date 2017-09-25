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
%%% author: Nicholas Renninger
%%% date created: 11/25/2016
%%% date modified: 4/14/2017


clear all %#ok<CLALL>
clc
close all


%% Initial Setup

NUM_SENSITIVITY_ITERATIONS = 200;
NUM_MC_ITERATIONS = 200;
NUM_SENSITIVITY_VARS = 5;

% toggle figure saving:
shouldSaveFigures = true;

% set default model to use
modelInUse = @new_thermo_model; % new thermo model

% set default trajectory save name 
figName = {'trajectory'};

%%% set global height index %%%
height_idx = 3;
setGlobalHeightIDX(height_idx);

%%% set global launch offset from N
launch_offset = 30; % [deg]
setGlobalLaunchDir(launch_offset); 

%%% Set Defualt Global Sens. Vars
% use the parameters for TA baseline to vary the parameters around
%         [ 39 psi (guage), 1 L (0.001 m^3), 0.439, 45 degrees, 1000kg/m^3]
global_sens_conditions = [3.5184e+05, 0.000550, 0.439, deg2rad(45), 1000]; 
setSensGlobals(global_sens_conditions);

%%% Set Default Global Other Variables %%%
global_other_conditions{1} = 0.131; % mass of empty bottle [kg]
global_other_conditions{2} = 291.483; % initial temperature of air [K]
global_other_conditions{3} = 82943.93; % atmospheric pressure [Pa]

% surface & aloft wind in cardinal frame, theta is cw angle from north in
% direction of wind:
% [magnitude of wind (m/s), theta (rad), vertical wind (m/s)]
global_other_conditions{4} = [0, deg2rad(120), 0]; % surface
global_other_conditions{5} = [0, deg2rad(0), 0]; % aloft

setOtherGlobals(global_other_conditions);



%% Run UI
choice = ''; % initialize choice to run first iteration of UI

while strcmp(choice, 'exit') == false

    choice = startDialogue;
    
    switch choice

        case 'Calculate Trajectory'
            %% TA Baseline
            disp('Calculate Trajectory')
            if shouldSaveFigures
                prompt = {'Save Name for the Trajectory Plot'};
                dlg_title = 'Trajectory Figure Name';
                num_lines = 1;
                defaultans = {'trajectory'};
                figName = inputdlg(prompt,dlg_title,num_lines,defaultans);
            end
            calculateTrajectory(modelInUse, shouldSaveFigures, figName{1});
            choice = 'exit'; % exit program after plotting
            
        case 'Sensitivity Analysis'
            %% Sensitivity Analysis
            disp('Running Sensitivity Analysis')
            
            
            SensitivityAnalysis(modelInUse, shouldSaveFigures, ...
                                NUM_SENSITIVITY_ITERATIONS, ...
                                NUM_SENSITIVITY_VARS);
            
            choice = 'exit'; % exit program after plotting
            
        case 'Monte Carlo Simulation'
            %% TA Baseline
            disp('Running Monte Carlo Simulation')
            MonteCarloThatShit(modelInUse, shouldSaveFigures, ...
                               NUM_MC_ITERATIONS)
            choice = 'exit'; % exit program after plotting
    
        case 'Input Flight Conditions'
            %% Input Iinit Conditions
            disp('Inputting Flight Conditions')
            inputParamsDialogue;
            
        case 'Setup'
            %% Setup
            disp('Setup')
            settings = setupDialogue;

            %%% Get settings and set them %%%
            NUM_SENSITIVITY_ITERATIONS = settings.num_sens_iter;
            NUM_MC_ITERATIONS = settings.num_mc_iter;
            shouldSaveFigures = settings.check;
            setModel = settings.ModelToUse;
            
            switch setModel
                case 'Old Thermo Model'
                    modelInUse = @old_thermo_model; 
                case 'New Thermo Model'
                    modelInUse = @new_thermo_model;
                case 'ISP Model'
                    modelInUse = @ISP_model;
                case 'Thrust Interpolation Model'
                    modelInUse = @thrustModel;
            end

    end

end
    
disp('Exited Program.')

