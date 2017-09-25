    %%% lab3.m
    %%%
    %%% This script is the main function of this lab. It defines the
    %%% constants and finds the filenames of the files where the data sets
    %%% desired will be found. It then calls in the analyze.m function
    %%% which will calculate and plot everything.
    %%%
    %%% Authors: Pierre Guillaud, Nicholas Renninger, Luke Tafur
    %%% Date Created: 2/16/17
    %%% Last Modified: 2/28/17

    %% HOUSEKEEPING
    close all
    clearvars
    clc

    %% CONSTANTS
    L = 0.254; % m
    R = 0.077; % m
    D = 0.153; % m

    %% Create Directory of Testing Data
    dir_name = '../Data/Actual Data/';
    dir_data = dir(dir_name);

    %% Data Analysis, Plotting, and Statistics
    for i = 1:length(dir_data)

        % generate the filename of data to be loaded and analyzed
        filename = [dir_name, dir_data(i).name];
        
        if strfind(filename, 'Test') % if data is test data
            
            volt = str2double(dir_data(i).name(7:8));
            analyze(L, R, D, filename, volt);
        end
    end
    