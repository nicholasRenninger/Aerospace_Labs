%%% Purpose:
%%%         This function reads in the experimental data from an .xlsx file
%%%         into several arrays and returns them to the driver script for
%%%         processing.
%%%
%%% Inputs: filename - string containing .xlsx file to be read
%%%
%%% Outputs: timeStamps - array containing time stamps for each measurement
%%%          mean_samples_TC - array containing the average of all three TC
%%%                            that took data during the experiment
%%%          TC4 - array containing the TC measurements of the boiling water
%%%                bath
%%%
%%% Assumptions: 
%%%             - the three calorimeter TCs can be averaged together
%%%               initially to produce one continuous curve most
%%%               representative of the overall state of the calorimeter.
%%%
%%% Author ID:  0dc91b091fd8
%%% Date Created:   10/15/2016
%%% Date Modified:  10/21/2016
 
function [timeStamps, mean_samples_TC, TC4] = Project_1_input(filename)
 
    % load .xlsx timestamp & TC data
    xlsxData = xlsread(filename);
 
    % save .xlsx data into arrays containing data from time stamp and each TC
    timeStamps = xlsxData(:, 1);
    TC1 = xlsxData(:, 2);
    TC2 = xlsxData(:, 3);
    TC3 = xlsxData(:, 4);
    TC4 = xlsxData(:, 5);
 
    % average the values from the 3 calorimeter
    mean_samples_TC = (TC1 + TC2 + TC3) / 3;
 
end
