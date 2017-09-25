%% ASEN 2003: Dynamics & Systems - Spring 2017
% Project: Rolling Wheel Lab (#4)
% Project Members:  Joseph Grengs
%                   Kian Tanner
%                   Nicholas Renniger
% Project Due Date: Thursday, March 16, 2017 @ 4:00p
% MATLAB Code Created on: 03/02/2017
% MATLAB Code last updated on: 03/14/2017

clear
close all
clc

%% Project Scope:
% This project is designed to analyze a rolling wheel down a ramp under two
% different scenarios.  The first is a uniform cylinder and the second is a
% cylinder with an extra mass added to one side of the cylinder.  This code
% will analyze the data collected from a LABVIEW (.vi) and compare it to a
% analytical model.


%% Inputs/Outputs:
% Inputs: Data files collected from LABVIEW (vi) and measured constants
% Outputs: Measured and modeled angular velocity vs. time plots
%          Residual data plots
%          Statistical information from data

%% Run Program:

%%% Set constants %%%
Mc = 11.7;                          % Mass of cylinder (kg)
Mta = 0.7;                          % Mass of trailing apparatus (kg)
Mem = 3.4;                          % Mass of extra mass (kg)
Rc = 0.235;                         % Radius of cylinder (m)
k = 0.203;                          % Radius of gyration (m)
Ic = Mc * k^2;                      % MOI of cylinder (kg*m^2)
Beta = 5.5 * (pi/180);              % Angle of ramp (radians)
Rtem = 0.178;                       % Radius to extra mass (m)
Rem = 0.019;                        % Radius of extra mass (m)
g = 9.81;                           % Gravitational acceleration (m/s^2)
NUM_PLOT_PTS = 250;                 % number of pts to plot w/ model
shouldSaveFigures = true;           % decide wheter or not to save plots

constants = [Mc Mta Mem Rc k Ic Beta Rtem Rem g ...
             NUM_PLOT_PTS shouldSaveFigures];

load_and_Analyze_Data(constants);   % Import data and begin analysis


