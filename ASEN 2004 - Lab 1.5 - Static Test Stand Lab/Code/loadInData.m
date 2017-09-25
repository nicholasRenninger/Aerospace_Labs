function data = loadInData
    %%% Author: Nicholas Renninger
    %%%
    %%% Purpose: Creates directory of data, creates array of structs from
    %%% each data file
    %%%
    %%% Inputs:
    %%% none
    %%% 
    %%% Outputs:
    %%% data = cell array of structs, each containing the following data
    %%% for each valid static test performed:
    %%%
    %%% water_mass: the mass of water used [kg]
    %%%
    %%% pressure: the pressure inside of the bottle [Pa]
    %%%
    %%% temp: the temperature [K]
    %%%
    %%% group_num: the group number
    %%%
    %%% time: the time vector for the data [s]
    %%%
    %%% thrust: the thrust vector for the data [N]
    %%%
    %%% ISP: the specific impulse [s]
    %%%
    %%% Date Created: 17 April 2017
    %%%
    %%% Last Editted: 17 April 2017
    
    
    relPathData = '../Data/';
    absPathData = cat(2, relPathData, '*.csv');
    
    test_dir = dir(absPathData);
    
    for i = 1:length(test_dir) - 2
       
        filename = cat(2, relPathData, test_dir(i + 2, 1).name);

        [ data{i}.water_mass, data{i}.pressure, data{i}.temp, ...
          data{i}.group_num,  data{i}.time, data{i}.thrust, data{i}.ISP ] = ...
        somethingNew( filename );
        
        
    end
    
end