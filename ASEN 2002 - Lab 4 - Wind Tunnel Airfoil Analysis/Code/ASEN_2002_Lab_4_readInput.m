%%% Inputs: nothing, but needs the directory structure from the .m files to
%%% be set like this:
%%% ..\Data\All_Group_Data\VelocityVoltage\S_01x\
%%% ..\Data\All_Group_Data\BoundryLayer\S_01x\
%%%
%%% In these folders, the data must be saved as a .csv, and organized such
%%% that each folder contains only data from the correct section. The data
%%% files must be organized alphabetically, and the data taken must be
%%% taken in such a way that it follows the ASEN 2002 Lab 3 test matrix.
%%%
%%% Outputs: boundry_test_matrices - Cell array
%%% entries are ordered in order of increasing port # (i.e.
%%% boundry_test_matrices{1} -> port 7, boundry_test_matrices{2} -> port 8)
%%%     cell array containing the sorted arrays
%%% of data from each static port test, with the data sorted by the hieght
%%% of the ELD probe. This way, a continuum of total pressure vs ELD probe
%%% height is created for each static port. This will allow the height of
%%% the boundry layer to be determined at each static port.
%%%
%%% velocity_test_matrices - 1st entry is pitot-static data, 2nd
%%% entry is static ring data.
%%%     cell array containing the sorted arrays of
%%% data from the static ring measurements and from the pitot-static
%%% system. This gives a profile of the pressure in the test chamber with
%%% increasing voltage as measured by both the pitot-staic probe and the
%%% static ring pressure transducers. 
%%%
%%% Author: Nicholas Renninger
%%% Last Modified: 11/13/16
%%% ASEN 2002 Lab #3

%%% Reads all data files from set directory structure, sorts them, and
%%% amalgamates totalized data matricies containing all test data ready for
%%% analysis.



function [velocity_test_matrix] = ASEN_2002_Lab_4_readInput()


    %% set path of velocity data files

    % section 011
    path_Velocity{1} = '..\Data\Test Data\S_011\';
    vel_folder_path{1} = cat(2, path_Velocity{1}, '*.csv');

    % section 012
    path_Velocity{2} = '..\Data\Test Data\S_012\';
    vel_folder_path{2} = cat(2, path_Velocity{2}, '*.csv');

    % section 013
    path_Velocity{3} = '..\Data\Test Data\S_013\';
    vel_folder_path{3} = cat(2, path_Velocity{3}, '*.csv');


    %% Get Dir. for each set of data

    % section 011
    dir_test{1} = dir(vel_folder_path{1});

    % section 012
    dir_test{2} = dir(vel_folder_path{2});

    % section 013
    dir_test{3} = dir(vel_folder_path{3});

    %% Reading Velocity Data out of Spreadsheets and into Cell Arrays

    % intialize beginning indices of saving processes
    index_10 = 1;
    index_20 = 1;
    index_30 = 1;

    % initialize all cell arrays
    velocity_10_data = cell(1, 1);
    velocity_20_data = cell(1, 1);
    velocity_30_data = cell(1, 1);


    % read in velocity data from data files into cell arrays corresponding
    % to the type of measurements taken by the pressure transducer. Each
    % Cell entry contains the contents of an entire group's data.
    for j = 1:length(dir_test)

        for k = 1:length(dir_test{j})

            current_directory = dir_test{j};
            filename = cat(2, path_Velocity{j}, current_directory(k, 1).name);
            current_spreadsheet = xlsread(filename);
            
            % average data for each voltage measured
            % 500 measurements per 
            current_spreadsheet = average_data_points(current_spreadsheet, 500);
            
            [num_data_points, ~] = size(current_spreadsheet);
            
            for i = 1:num_data_points
                
                if mod(i, 3) == 1 % V = 10 m/s
                    % pulling relevant data out of test spreadsheets. Only want
                    % P_atm, Temp, pressure difference, pressure differntials,
                    % and AoA.
                    current_data = current_spreadsheet(i, [1:5, 7:23]);

                    velocity_10_data{index_10} = current_data;
                    index_10 = index_10 + 1;
                    
                elseif mod(i, 3) == 2 % V = 20 m/s
                    
                    % pulling relevant data out of test spreadsheets. Only want
                    % P_atm, Temp, pressure difference, pressure differntials,
                    % and AoA.
                    current_data = current_spreadsheet(i, [1:5, 7:23]);

                    velocity_20_data{index_20} = current_data;
                    index_20 = index_20 + 1;
                    
                else % V = 30 m/s
                    
                    % pulling relevant data out of test spreadsheets. Only want
                    % P_atm, Temp, pressure difference, pressure differntials,
                    % and AoA.
                    current_data = current_spreadsheet(i, [1:5, 7:23]);

                    velocity_30_data{index_30} = current_data;
                    index_30 = index_30 + 1;
                    
                end
               
            end
        end

    end


    %%% sort rows based on voltage to build array of test data vs. increasing
    %%% Voltages


    %%% build up test matrix of velocity data %%%
    velocity_10_test_matrix = velocity_10_data{1, 1}; % initialize matrix with first set of test data
    velocity_20_test_matrix = velocity_20_data{1, 1}; % initialize matrix with first set of test data
    velocity_30_test_matrix = velocity_30_data{1, 1}; % initialize matrix with first set of test data

    % build up rest of data
    for k = 2:length(velocity_10_data)

        velocity_10_test_matrix = cat(1, velocity_10_test_matrix, ...
                                            velocity_10_data{1, k});

    end
    
    % build up rest of data
    for k = 2:length(velocity_20_data)

        velocity_20_test_matrix = cat(1, velocity_20_test_matrix, ...
                                            velocity_20_data{1, k});

    end
    
    % build up rest of data
    for k = 2:length(velocity_30_data)

        velocity_30_test_matrix = cat(1, velocity_30_test_matrix, ...
                                            velocity_30_data{1, k});

    end

    % sort data by AoA (22nd column), so that the pressure difference
    % measurements increase with increasing voltage
    velocity_10_test_matrix = sortrows(velocity_10_test_matrix, 22);
    velocity_20_test_matrix = sortrows(velocity_20_test_matrix, 22);
    velocity_30_test_matrix = sortrows(velocity_30_test_matrix, 22);
    
    % filter out duplicate data points
    velocity_10_test_matrix = filterAndAverage(velocity_10_test_matrix);
    velocity_20_test_matrix = filterAndAverage(velocity_20_test_matrix);
    velocity_30_test_matrix = filterAndAverage(velocity_30_test_matrix);
    
    velocity_test_matrix = {velocity_10_test_matrix,...
                            velocity_20_test_matrix, ...
                            velocity_30_test_matrix};

end
