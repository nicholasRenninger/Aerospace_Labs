%%% Purpose:
%%%       This script calls a set of routines used to proccess the excel data 
%%%       in the file defined by the user below as "filename". The code
%%%       calculates the specific heat of the material tested and the
%%%       uncertainty in the specific heat of the material based on the
%%%       quality of the data inputted.
%%%
%%% Inputs:
%%%         - user defines filename to be analyzed by setting "filename" to
%%%         the name of the file to be analyzed.
%%% Outputs:
%%%         - calculates the specific heat of the sample, its uncertainty,
%%%         and generates plots of its temperature profile along with the
%%%         results of the regressions used to analyze this overall
%%%         temperature profile.
%%%
%%% Assumptions: 
%%%             - none made specifically in this main script. see each
%%%               individual routine for the specific assumptions made for
%%%               each routine
%%%
%%% Author ID:  0dc91b091fd8
%%% Date Created:   10/15/2016
%%% Date Modified:  10/21/2016
 
 
%% Calculating Specific Heat of Sample
 
clear 
clc
 
filename = 'data9AM.xlsx';
 
% reading in data from xlsx file
[timeStamps, mean_samples_TC, TC4] = Project_1_input(filename);
 
% finding the time when the sample was added to the calorimeter and the
% time when the sample is in equilibrium with the calorimeter
[index_hot_sample_added, index_equilibirum_temp] = Project_1_calc_times(...
                                                        timeStamps,...
                                                        mean_samples_TC);
 
% finding T_o
[T_o, sigma_T_o] = Project_1_calc_T_o(index_hot_sample_added,...
                                      timeStamps, mean_samples_TC);
 
% finding T_1
[T_1, sigma_T_1] = Project_1_calc_T_1(index_hot_sample_added, TC4);
 
% finding T_2
[T_2, sigma_T_2, T_2_time, search_midpoint_T] = Project_1_calc_T_2(...
                                                index_hot_sample_added,...
                                                index_equilibirum_temp,...
                                                timeStamps, mean_samples_TC);

% calculating specific heat of sample in and its uncertainty
[c_s, sigma_c_s] = Project_1_calc_c_s(T_o, sigma_T_o, T_1,...
                                      sigma_T_1, T_2, sigma_T_2);
                                  
% formatting / creating plots
Project_1_formatPlots(T_o, T_1, T_2, T_2_time, TC4, search_midpoint_T, ...
                      index_hot_sample_added, timeStamps);
 
                  
%% Printing Results
 
fprintf('The specific heat of the sample is: %0.4g (J / g / K)\n', c_s);
fprintf('The uncertainty in the calculation of the specific heat is: %0.1g (J / g / K)\n', sigma_c_s);

