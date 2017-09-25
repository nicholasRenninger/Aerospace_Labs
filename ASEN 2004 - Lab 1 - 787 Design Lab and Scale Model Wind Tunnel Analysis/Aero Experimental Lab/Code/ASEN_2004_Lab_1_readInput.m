function [velocity_test_matrix] = ASEN_2004_Lab_1_readInput()

    %%% function [velocity_test_matrix] = ASEN_2004_Lab_1_readInput()
    %%%
    %%% Inputs: nothing, but needs the directory structure from the .m
    %%% files to be set like this:
    %%%
    %%% ..\Data\All_Group_Data\VelocityVoltage\S_01x\
    %%% ..\Data\All_Group_Data\BoundryLayer\S_01x\
    %%%
    %%% In these folders, the data must be saved as a .csv, and organized
    %%% such that each folder contains only data from the correct section.
    %%% The data files must be organized alphabetically, and the data taken
    %%% must be taken in such a way that it follows the ASEN 2004 Lab 1
    %%% test matrix.
    %%%
    %%% Outputs: cell array containing filtered expiremental data for each
    %%% model. Each cell array contains two structures containing the data
    %%% and variance for the two test velocities. There are seven columns
    %%% for each velocity tested, per model. They columns are ordered as
    %%% follows:
    %%%
    %%% 1: Atmospheric Density [kg/m^3]
    %%% 2: Airspeed [m/s]
    %%% 3: Pitot Dynamic Pressure [N/m^2] -or- [Pa]
    %%% 4: Angle of Attack (AoA) [degrees]
    %%% 5: Sting Normal [N]
    %%% 6: Sting Axial Force [N]
    %%% 7: Sting Pitching Moment [Nm]
    %%% 
    %%%
    %%% Author: Nicholas Renninger
    %%% Last Modified: 2/18/17
    %%% ASEN 2004 Lab #1

    %%% Reads all data files from set directory structure, sorts them, and
    %%% amalgamates totalized data matricies containing all test data ready
    %%% for analysis.

    %% Command Window I/O
    disp('Reading in data files...')
    
    %% Set File I/O constants
    
    % Set relevant columns of data to extract from data files
    dataCols = [3:5, 23:26];
    
    % sort data by AoA (3rd column)
    AOA_col = 4;
    
    
    %% set path of velocity data files

    % section 011
    path_Velocity{1} = '../Data/Test Data/S_011/';
    vel_folder_path{1} = cat(2, path_Velocity{1}, '*.csv');

    % section 012
    path_Velocity{2} = '../Data/Test Data/S_012/';
    vel_folder_path{2} = cat(2, path_Velocity{2}, '*.csv');

    % section 013
    path_Velocity{3} = '../Data/Test Data/S_013/';
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
    index_clean = 1;
    index_dirty = 1;
    index_787 = 1;

    % initialize all cell arrays
    [data_clean, data_dirty, ...
     data_787, error_clean, ...
     error_dirty, error_787] = deal(cell(1, 2));
    
    % initialize regex expression
    cleanExpression = 'clean(\w*)';
    dirtyExpression = 'loaded(\w*)';
    seven87Expression = '787(\W*)';

    % read in velocity data from data files into cell arrays corresponding
    % to the type of measurements taken by the pressure transducer. Each
    % Cell entry contains the contents of an entire group's data.
    for j = 1:length(dir_test)

        for k = 1:length(dir_test{j})

            current_directory = dir_test{j};
            filename = cat(2, path_Velocity{j}, current_directory(k, 1).name);
            current_spreadsheet = load(filename);
            
            % average data for each AoA measured
            % 500 measurements per 
            [current_spreadsheet,...
             curr_STD] = average_data_points(current_spreadsheet, 20);
            
            [num_data_points, ~] = size(current_spreadsheet);
            
            % separating data into zero and 25 m/s data, and their errors
            current_zero_data = current_spreadsheet(1:num_data_points/2,...
                                                    dataCols);
            current_zero_error_data = curr_STD(1:num_data_points/2,...
                                                    dataCols);
               
                                                
            current_25_data = current_spreadsheet(num_data_points/2 + 1:...
                                                  num_data_points, ...
                                                  dataCols);
            current_25_error_data = curr_STD(num_data_points/2 + 1:...
                                                  num_data_points, ...
                                                  dataCols); 
            

            % determine which model is being tested: the F-16 clean, F-16
            % Dirty, or the 787 model by matching a regex with the filename
            
            if ~isempty( regexpi(filename, cleanExpression) ) % clean 
                
                % 0 m/s goes in 1st col, 25 m/s goes in 2nd col
                data_clean{index_clean, 1} = current_zero_data;
                data_clean{index_clean, 2} = current_25_data;
                
                error_clean{index_clean, 1} = current_zero_error_data;
                error_clean{index_clean, 2} = current_25_error_data;
                
                index_clean = index_clean + 1;
                %disp('clean')
                
            elseif ~isempty( regexpi(filename, dirtyExpression) ) % dirty
                
                % 0 m/s goes in 1st col, 25 m/s goes in 2nd col
                data_dirty{index_dirty, 1} = current_zero_data;
                data_dirty{index_dirty, 2} = current_25_data;
                
                error_dirty{index_dirty, 1} = current_zero_error_data;
                error_dirty{index_dirty, 2} = current_25_error_data;
                
                index_dirty = index_dirty + 1;
                %disp('dirty')
                
            elseif ~isempty( regexpi(filename, seven87Expression) ) % 787
            
                % 0 m/s goes in 1st col, 25 m/s goes in 2nd col
                data_787{index_787, 1} = current_zero_data;
                data_787{index_787, 2} = current_25_data;
                
                error_787{index_787, 1} = current_zero_error_data;
                error_787{index_787, 2} = current_25_error_data;
                
                index_787 = index_787 + 1;
                %disp('787')
                
            end
            
        end

    end


    %%% sort rows based on voltage to build array of test data vs. increasing
    %%% Voltages


    %%% build up test matrix of velocity data %%%
    
    % initialize matrix with first sets of test data and error
    clean_test_matrix.zero.data = data_clean{1, 1}; 
    clean_test_matrix.twentyFive.data = data_clean{1, 2};
    
    clean_test_matrix.zero.error = error_clean{1, 1};
    clean_test_matrix.twentyFive.error = error_clean{1, 1};
    
    dirty_test_matrix.zero.data = data_dirty{1, 1};
    dirty_test_matrix.twentyFive.data = data_dirty{1, 2};
    
    dirty_test_matrix.zero.error = error_dirty{1, 1};
    dirty_test_matrix.twentyFive.error = error_dirty{1, 2};
    
    seven87_test_matrix.zero.data = data_787{1, 1};
    seven87_test_matrix.twentyFive.data = data_787{1, 2};
    
    seven87_test_matrix.zero.error = error_787{1, 1};
    seven87_test_matrix.twentyFive.error = error_787{1, 2};
    

    % build up rest of data
    for k = 2:length(data_clean)

        clean_test_matrix.zero.data = cat(1, clean_test_matrix.zero.data, ...
                                     data_clean{k, 1});
        clean_test_matrix.twentyFive.data = cat(1, ...
                                           clean_test_matrix.twentyFive.data,...
                                           data_clean{k, 2});
                                       
        clean_test_matrix.zero.error = cat(1, ...
                                          clean_test_matrix.zero.error, ...
                                          error_clean{k, 1});
        clean_test_matrix.twentyFive.error = cat(1, ...
                                    clean_test_matrix.twentyFive.error, ...
                                    error_clean{k, 2});
                                 

    end
    
    % build up rest of data
    for k = 2:length(data_dirty)

        dirty_test_matrix.zero.data = cat(1, dirty_test_matrix.zero.data, ...
                                     data_dirty{k, 1});
        dirty_test_matrix.twentyFive.data = cat(1, ...
                                           dirty_test_matrix.twentyFive.data,...
                                           data_dirty{k, 2});
                                       
        dirty_test_matrix.zero.error = cat(1, ...
                                          dirty_test_matrix.zero.error, ...
                                          error_dirty{k, 1});
        dirty_test_matrix.twentyFive.error = cat(1, ...
                                    dirty_test_matrix.twentyFive.error, ...
                                    error_dirty{k, 2});

    end
    
    % build up rest of data
    for k = 2:length(data_787)

        seven87_test_matrix.zero.data = cat(1, seven87_test_matrix.zero.data, ...
                                     data_787{k, 1});
        seven87_test_matrix.twentyFive.data = cat(1, ...
                                         seven87_test_matrix.twentyFive.data,...
                                           data_787{k, 2});
                                       
                                       
        seven87_test_matrix.zero.error = cat(1, ...
                                          seven87_test_matrix.zero.error, ...
                                          error_787{k, 1});
        seven87_test_matrix.twentyFive.error = cat(1, ...
                                    seven87_test_matrix.twentyFive.error, ...
                                    error_787{k, 2});                                  

    end

    
    [clean_test_matrix.zero.data, idx] = sortrows(clean_test_matrix.zero.data, AOA_col);
    clean_test_matrix.zero.error = clean_test_matrix.zero.error(idx, :);
    
    [clean_test_matrix.twentyFive.data, idx] = sortrows(clean_test_matrix.twentyFive.data, AOA_col);
    clean_test_matrix.twentyFive.error = clean_test_matrix.twentyFive.error(idx, :);

    
    [dirty_test_matrix.zero.data, idx] = sortrows(dirty_test_matrix.zero.data, AOA_col);
    dirty_test_matrix.zero.error = dirty_test_matrix.zero.error(idx, :);

    [dirty_test_matrix.twentyFive.data, idx] = sortrows(dirty_test_matrix.twentyFive.data, AOA_col);
    dirty_test_matrix.twentyFive.error = dirty_test_matrix.twentyFive.error(idx, :);
                                        
    [seven87_test_matrix.zero.data, idx] = sortrows(seven87_test_matrix.zero.data, AOA_col);
    seven87_test_matrix.zero.error = seven87_test_matrix.zero.error(idx, :);
    
    [seven87_test_matrix.twentyFive.data, idx] = sortrows(seven87_test_matrix.twentyFive.data, AOA_col);
    seven87_test_matrix.twentyFive.error = seven87_test_matrix.twentyFive.error(idx, :);
    
    
    % filter out duplicate data points
    [clean_test_matrix.zero.data, ...
     clean_test_matrix.zero.error] = filterAndAverage(clean_test_matrix.zero.data, ...
                                                      clean_test_matrix.zero.error, ...
                                                      AOA_col);
    [clean_test_matrix.twentyFive.data, ...
     clean_test_matrix.twentyFive.error] = filterAndAverage(clean_test_matrix.twentyFive.data, ...
                                                      clean_test_matrix.twentyFive.error, ...
                                                      AOA_col);
     
                                                  
                                                  
    [dirty_test_matrix.zero.data, ...
     dirty_test_matrix.zero.error] = filterAndAverage(dirty_test_matrix.zero.data, ...
                                                      dirty_test_matrix.zero.error, ...
                                                      AOA_col);
    [dirty_test_matrix.twentyFive.data, ...
     dirty_test_matrix.twentyFive.error] = filterAndAverage(dirty_test_matrix.twentyFive.data, ...
                                                      dirty_test_matrix.twentyFive.error, ...
                                                      AOA_col);
                    
                                                  
    [seven87_test_matrix.zero.data, ...
     seven87_test_matrix.zero.error] = filterAndAverage(seven87_test_matrix.zero.data, ...
                                                      seven87_test_matrix.zero.error, ...
                                                      AOA_col);
    [seven87_test_matrix.twentyFive.data, ...
     seven87_test_matrix.twentyFive.error] = filterAndAverage(seven87_test_matrix.twentyFive.data, ...
                                                      seven87_test_matrix.twentyFive.error, ...
                                                      AOA_col);

    
    velocity_test_matrix = {clean_test_matrix,...
                            dirty_test_matrix, ...
                            seven87_test_matrix};
    %% Command Window I/O
    disp('Successfully read in data.')
    
end
