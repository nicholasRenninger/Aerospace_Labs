%%% Driver script for ASEN 2002 Lab 3 Data analysis.
%%% Author: Nicholas Renninger
%%% Last Modified: 11/13/16

clear 
clc
close all

%% Read input files, sort the data into proper data structures for analysis

[boundry_test_matrices, velocity_test_matrices] = ASEN_2002_Lab_3_readInput;


%% Find velocity profile of test chamber as a function of voltage

% pull the two velocity test matrices out of the cell array for analysis
pitot_velocity_matrix = velocity_test_matrices{1};
venturi_velocity_matrix = velocity_test_matrices{2};

isAuxMeasurement = false; % velocity measurements not done w/ aux gauge

% should average points to get most accurate representation of Velocity vs.
% voltage
shouldAverage = true; 

% find air velocity as measured by pitot-static probe, and the voltage
% control model
[pitot_air_velocity, pitot_velocity_matrix, pitot_best_fit_velocity, pitot_coefs] = Velo_Calc_Pitot_Static(pitot_velocity_matrix, isAuxMeasurement, shouldAverage);

% find air velocity as measured by venturi tube configuration, and the
% voltage control model
[venturi_air_velocity, venturi_velocity_matrix, venturi_best_fit_velocity, venturi_coefs] = Velo_Calc_Venturi_Tube(venturi_velocity_matrix, shouldAverage);

velocity_test_matrices{1} = pitot_velocity_matrix;
velocity_test_matrices{2} = venturi_velocity_matrix;


%% Find Height of Boundry Layer as a function of distance from beginning of Test-Section

%%% Takes the Boundry Layer data, and returns the height of the test,
%%% laminar and turbulent boundry layers as functions of x. 
[Boundry_Layer_heights, port_locations, x, x_cr_lam_index, x_turb_cr_index, x_cr_ht] = boundry_calc(boundry_test_matrices);


%% Compare Manometer and Transducer Data

[VoltVec_mano, P_Diff_Vec_mano, VeloVec_mano, VoltVec_trans, VelMatrix_trans, VeloVec_trans] = VelocityVoltageForManometer();


%% Uncertainty Analysis

isManometerComparison = true; % find uncertainty for manometer/transducer comparison
[sigmaV_comparision] = Sigma_V(velocity_test_matrices, isManometerComparison,...
                                 pitot_air_velocity, venturi_air_velocity, ...
                                 P_Diff_Vec_mano, VelMatrix_trans);
                             
isManometerComparison = false; % find uncertainty for transducers, not for manometer
[sigmaV] = Sigma_V(velocity_test_matrices, isManometerComparison,...
                                 pitot_air_velocity, venturi_air_velocity, ...
                                 P_Diff_Vec_mano, VelMatrix_trans);
                             

%% Plot Results

make_plots(Boundry_Layer_heights, pitot_air_velocity, ...
            venturi_air_velocity, x, x_cr_lam_index, x_cr_ht,...
            port_locations, pitot_best_fit_velocity, ...
            venturi_best_fit_velocity, pitot_coefs, ...
            venturi_coefs, sigmaV_comparision, sigmaV, ...
            VoltVec_mano, VeloVec_mano, VoltVec_trans, ...
            VeloVec_trans, velocity_test_matrices);
