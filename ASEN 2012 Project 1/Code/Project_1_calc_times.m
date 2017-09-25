%%% Purpose:
%%%         This function takes the timestamp and mean TC value for
%%%         calorimeter arrays and calculates the indices for when the sample is
%%%         added to the calorimeter, and when the equilibrium regime of
%%%         the system is reached. 
%%%         
%%%         Algorithm for finding when sample is
%%%         added works by analyzing the second derivative of the temp vs
%%%         time data and detecting when slope is rapidly changing,
%%%         indicating the calorimeter is now being rapidly heated by the
%%%         introduction of a sample.
%%%
%%%         Algorithm for finding equilibrium index works as stated in the
%%%         lab procedure, by simply finding when the maximum temp. of the
%%%         equilibrium region occurs.
%%%
%%% Inputs: mean_samples_TC - array of average TC measurement of
%%%                           calorimeter
%%%         timeStamps - array of time stamps for each measurement taken
%%%
%%% Outputs: index_hot_sample_added - index in data arrays for when the
%%%                                   sample is added to the calorimeter
%%%
%%%          index_equilibirum_temp - index in data arrays for when the
%%%                                   sample and the calorimeter first are
%%%                                   in thermal equilibrium
%%%
%%% Assumptions: 
%%%             - equilibrium begins when the maximum temperature is
%%%               achieved
%%%             - no significant thermal gradient is experienced by the
%%%               system until the sample is added. The only way the
%%%               temperature of the calorimeter changes is by the addition
%%%               of the sample
%%%
%%% Author ID:  0dc91b091fd8
%%% Date Created:   10/15/2016
%%% Date Modified:  10/21/2016
 
function [index_hot_sample_added, index_equilibirum_temp] = Project_1_calc_times(timeStamps, mean_samples_TC)
 
    % initializations
    slope = zeros(1, length(mean_samples_TC));
    new_slope = slope;
 
    % build up vec of slopes to find when sample was added
    num = 100; % number of data points in best fit line interval
    hasFoundT_L = false;
    for i = num + 1:length(mean_samples_TC)
        
        % find instantaneous slope using best fit line over num data
        % points
        fit_params = polyfit(timeStamps(i - num:i), mean_samples_TC(i - num:i), 1);
        slope(i - num) = abs(fit_params(1));
 
        % finding "acceleration" of data set to find when slope changes
        if i > num + 1
            new_slope(i - num) = slope(i - num) - slope(i - num - 1);
        end
 
        if i > num + 1 && new_slope(i - num) > 0.25e-4 && ~hasFoundT_L
           index_hot_sample_added = i - 2; % this is the index of when the sample was added to the calorimeter
           hasFoundT_L = true;
        end
        
    end
    
    % find the beginning index of the third region of calorimeter data
    max_T = max(mean_samples_TC(1:1100)); % exclude later data from consideration (noisy) 
    index_equilibirum_temp = find(mean_samples_TC == max_T);
    %plot(timeStamps, mean_samples_TC, index_equilibirum_temp(1), max_T, '+')
end
