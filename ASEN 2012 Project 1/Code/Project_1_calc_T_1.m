%%% Purpose:    
%%%        This function takes in TC4, the array of measurements of the 
%%%        boiling water and calculates T_1 and its uncertainty. 
%%%        
%%%           By finding the mean of the data before the sample is removed, 
%%%        a more accurate estimation of the temperature of the boiling
%%%        water and the sample can be found by averaging the relatively
%%%        constant boiling water temperatures from t = 0 up until the
%%%        sample is removed.
%%%
%%%         To find the uncertainty in T_1, take the standard deviation of
%%%         the set of data averaged to find T_1. This will give the best
%%%         estimate as to the average deviation of the temp. of the
%%%         boiling water / sample   
%%%
%%%
%%% Inputs: 
%%%         index_hot_sample_added  - index in data arrays for when the
%%%                                   sample is added to the calorimeter
%%%
%%%         TC4 - array containing the temperature profile of the boiling
%%%               water
%%%
%%% Outputs:  T_1 - initial temperature of the sample
%%%           sigma_T_1 - uncertainty in the measurement of T_1
%%%
%%% Assumptions: 
%%%            - The sample and the water are in thermal equilibrium, so 
%%%             the initial temp of the sample is the also the temperature
%%%             of the boiling water.
%%%
%%%             - while water boils, temp. does not change, so therefore a
%%%             linear regression is unnecessary here as the slope is just
%%%             = 0.
%%%             
%%%             - can just use data from t = 0 to time when sample is
%%%             removed to find the temperature of the sample, as the
%%%             sample should be in thermal equilibrium with the boiling
%%%             water at that point.
%%%
%%% Author ID:  0dc91b091fd8
%%% Date Created:   10/15/2016
%%% Date Modified:  10/21/2016
 
 
function [T_1, sigma_T_1] = Project_1_calc_T_1(index_hot_sample_added, TC4)
   
 
    % make vector of water temp from t = 0 to when sample was removed
    boiling_water_temp_vec = TC4(1:index_hot_sample_added);
    
    % T_1 is the average of the boiling water temp from t = 0 up until the
    % sample is removed
    T_1 = mean(boiling_water_temp_vec);
    
    % error in T_1 is just the standard deviation of the water temp
    % measurements.
    sigma_T_1 = std(boiling_water_temp_vec);
    
    
end
