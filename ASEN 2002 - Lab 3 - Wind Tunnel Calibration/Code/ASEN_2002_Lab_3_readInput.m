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



function [boundry_test_matrices, velocity_test_matrices] = ASEN_2002_Lab_3_readInput()


    %% set path of velocity data files

    % section 011
    path_Velocity{1} = '..\Data\All_Group_Data\VelocityVoltage\S_011\';
    vel_folder_path{1} = cat(2, path_Velocity{1}, '*.csv');

    % section 012
    path_Velocity{2} = '..\Data\All_Group_Data\VelocityVoltage\S_012\';
    vel_folder_path{2} = cat(2, path_Velocity{2}, '*.csv');

    % section 013
    path_Velocity{3} = '..\Data\All_Group_Data\VelocityVoltage\S_013\';
    vel_folder_path{3} = cat(2, path_Velocity{3}, '*.csv');



    %% set path of boundry layer data files

    % section 011
    path_Boundry{1} = '..\Data\All_Group_Data\BoundryLayer\S_011\';
    boundry_folder_path{1} = cat(2, path_Boundry{1}, '*.csv');

    % section 012
    path_Boundry{2} = '..\Data\All_Group_Data\BoundryLayer\S_012\';
    boundry_folder_path{2} = cat(2, path_Boundry{2}, '*.csv');

    % section 013
    path_Boundry{3} = '..\Data\All_Group_Data\BoundryLayer\S_013\';
    boundry_folder_path{3} = cat(2, path_Boundry{3}, '*.csv');



    %% Get Dir. for each set of data

    % section 011
    dir_Velocity{1} = dir(vel_folder_path{1});
    dir_BoundryLayer{1} = dir(boundry_folder_path{1});

    % section 012
    dir_Velocity{2} = dir(vel_folder_path{2});
    dir_BoundryLayer{2} = dir(boundry_folder_path{2});

    % section 013
    dir_Velocity{3} = dir(vel_folder_path{3});
    dir_BoundryLayer{3} = dir(boundry_folder_path{3});



    %% Reading Velocity Data out of Spreadsheets and into Cell Arrays

    % determine number of each type of data file
    num_Velocity_files = length(dir_Velocity{1}) + length(dir_Velocity{2}) + length(dir_Velocity{3});

    % intialize beginning indices of saving processes
    index_port_7 = 1;
    index_venturi = 1;

    % initialize all cell arrays
    velocity_pitot_data = cell(1, 1);
    velocity_venturi_data = cell(1, 1);


    % read in velocity data from data files into cell arrays corresponding
    % to the type of measurements taken by the pressure transducer. Each
    % Cell entry contains the contents of an entire group's data.
    for j = 1:length(dir_Velocity)

        for i = 1:length(dir_Velocity{j})

            current_directory = dir_Velocity{j};
            filename = cat(2, path_Velocity{j}, current_directory(i, 1).name);
            current_spreadsheet = xlsread(filename);

            if mod(i, 2) ~= 0 % if group # is odd, pressure diff is pitot-static

                % pulling relevant data out of velocity spreadsheets. Save
                % into pitot-static velocity cell arrays. Only want P_atm,
                % Temp, pressure difference, and voltage for test.
                current_data = current_spreadsheet(:, [1:3, 7]);
                
                % average data for each voltage measured
                % 20 measurements per voltage
                averaged_data_pitot = average_data_points(current_data, 20);

                velocity_pitot_data{index_port_7} = averaged_data_pitot;
                index_port_7 = index_port_7 + 1;

            else % if group # is even, pressure diff is venturi

                % pulling relevant data out of velocity spreadsheets. Save into 
                % venturi velocity cell arrays. Only want P_atm, Temp,
                % pressure difference, and voltage for test.
                current_data = current_spreadsheet(:, [1:3, 7]);
                
                % average data for each voltage measured
                % 20 measurements per voltage
                averaged_data_venturi = average_data_points(current_data, 20);
                
                velocity_venturi_data{index_venturi} = averaged_data_venturi;
                index_venturi = index_venturi + 1;

            end

        end

    end


    %%% sort rows based on voltage to build array of test data vs. increasing
    %%% Voltages


    %%% build up test matrix of pitot data %%%
    pitot_velocity_test_matrix = velocity_pitot_data{1, 1}; % initialize matrix with first set of test data

    % build up rest of data
    for i = 2:length(velocity_pitot_data)

        pitot_velocity_test_matrix = cat(1, pitot_velocity_test_matrix, ...
                                            velocity_pitot_data{1, i});

    end

    % sort data by voltage (4th column), so that the pressure difference
    % measurements increase with increasing voltage
    pitot_velocity_test_matrix = sortrows(pitot_velocity_test_matrix, 4);


    %%% build up test matrix of venturi data %%%
    venturi_velocity_test_matrix = velocity_venturi_data{1, 1}; % initialize matrix with first set of test data

    % build up rest of data
    for i = 2:length(velocity_venturi_data)

        venturi_velocity_test_matrix = cat(1, venturi_velocity_test_matrix, ...
                                            velocity_venturi_data{1, i});

    end

    % sort data by voltage (4th column), so that the pressure difference
    % measurements increase with increasing voltage
    venturi_velocity_test_matrix = sortrows(venturi_velocity_test_matrix, 4);

   
    % flip and negative pressures to be positive, this just means that the
    % expirementer flipped which pressure tube was reference.
    pitot_velocity_test_matrix = abs(pitot_velocity_test_matrix);
    venturi_velocity_test_matrix = abs(venturi_velocity_test_matrix);
    
    
    % combine velocity data into one cell array containing the two sorted
    % arrays of velocity data for easy packaging.
    velocity_test_matrices = {pitot_velocity_test_matrix, venturi_velocity_test_matrix};     
        
    %% Reading Boundry Data out of Spreadsheets and into Cell Arrays

    % determine number of each type of data file
    num_BoundryLayer_files = length(dir_BoundryLayer{1}) + length(dir_BoundryLayer{2}) + length(dir_BoundryLayer{3});


    % intialize beginning indices of saving processes
    index_port_7 = 1;
    index_port_8 = 1;
    index_port_9 = 1;
    index_port_10 = 1;
    index_port_11 = 1;

    % initialize all cell arrays
    port_7_data = cell(1,1);
    port_8_data = cell(1,1);
    port_9_data = cell(1,1);
    port_10_data = cell(1,1);
    port_11_data = cell(1,1);

    % read in velocity data from data files into cell arrays corresponding
    % to the type of measurements taken by the pressure transducer. Each
    % Cell entry contains the contents of an entire group's data.
    for j = 1:length(dir_BoundryLayer)

        for i = 1:length(dir_BoundryLayer{j})

            current_directory = dir_BoundryLayer{j};
            filename = cat(2, path_Boundry{j}, current_directory(i, 1).name);
            current_spreadsheet = xlsread(filename);

            if i <= 2 % groups 1-2 use port 7

                % pulling relevant data out of velocity spreadsheets. Save into 
                % pitot-static velocity cell arrays. Only want P_atm, Temp,
                % pressure difference, and voltage for test.
                current_data = current_spreadsheet(:, [1:4, 6:7]);
                
                % average data for each voltage measured
                % 20 measurements per voltage
                averaged_data_7 = average_data_points(current_data, 20);
                
                port_7_data{index_port_7} = averaged_data_7;
                index_port_7 = index_port_7 + 1;

            elseif  i > 2 && i <= 4 % groups 3-4 use port 8

                % pulling relevant data out of velocity spreadsheets. Save into 
                % pitot-static velocity cell arrays. Only want P_atm, Temp,
                % pressure difference, and voltage for test.
                current_data = current_spreadsheet(:, [1:4, 6:7]);
                
                % average data for each voltage measured
                % 20 measurements per voltage
                averaged_data_8 = average_data_points(current_data, 20);
                
                port_8_data{index_port_8} = averaged_data_8;
                index_port_8 = index_port_8 + 1;

            elseif i > 4 && i <= 6 % groups 5-6 use port 9

                % pulling relevant data out of velocity spreadsheets. Save into 
                % pitot-static velocity cell arrays. Only want P_atm, Temp,
                % pressure difference, and voltage for test.
                current_data = current_spreadsheet(:, [1:4, 6:7]);
                
                % average data for each voltage measured
                % 20 measurements per voltage
                averaged_data_9 = average_data_points(current_data, 20);
                
                port_9_data{index_port_9} = averaged_data_9;
                index_port_9 = index_port_9 + 1;


            elseif i > 6 && i <= 8 % groups 7-8 use port 10

                % pulling relevant data out of velocity spreadsheets. Save into 
                % pitot-static velocity cell arrays. Only want P_atm, Temp,
                % pressure difference, and voltage for test.
                current_data = current_spreadsheet(:, [1:4, 6:7]);
                
                % average data for each voltage measured
                % 20 measurements per voltage
                averaged_data_10 = average_data_points(current_data, 20);
                
                port_10_data{index_port_10} = averaged_data_10;
                index_port_10 = index_port_10 + 1;

            elseif i > 8 && i <= 10 % groups 9-10 use port 11

                % pulling relevant data out of velocity spreadsheets. Save into 
                % pitot-static velocity cell arrays. Only want P_atm, Temp,
                % pressure difference, and voltage for test.
                current_data = current_spreadsheet(:, [1:4, 6:7]);
                
                % average data for each voltage measured
                % 20 measurements per voltage
                averaged_data_11 = average_data_points(current_data, 20);
                
                port_11_data{index_port_11} = averaged_data_11;
                index_port_11 = index_port_11 + 1;

            end


        end

    end

    % consolodate all data into one cell array.
    port_cell_arrays = {port_7_data, port_8_data, port_9_data, port_10_data, port_11_data};


    %%% sort rows based on ELD position to build array of test data vs. increasing
    %%% ELD probe height


    %%% build up test matrix of boundry data %%%

    numOfPortsToAnalyze = length(port_cell_arrays); % this test was run on ports 7, 8, 9, 10, 11

    % data martix will be multi-dimensional array. each "layer" will
    % contain all test data for a port from all sections.

    % build up rest of data
    for i = 1:numOfPortsToAnalyze

        current_port_data = port_cell_arrays{i}; % ex: i = 2, current_port_data = port_8_data
        boundry_test_matrices{i} = current_port_data{1, 1}; % initialize matrix with first set of test data

        for j = 2:length(current_port_data)

            boundry_test_matrices{i} = cat(1, boundry_test_matrices{i}, ...
                                                  current_port_data{j});

        end


        % sort data by ELD height (6th columnin excel file, 5th col in
        % boundry_test_matrix), so that the pressure difference
        % measurements increase with increasing height of ELD probe
        boundry_test_matrices{i} = sortrows(boundry_test_matrices{i}, 5);


    end
    
    % make sure all ELD positions begin @ zero
    for i = 1:length(boundry_test_matrices)
       
        minHeight = min(boundry_test_matrices{i}(:, 5));
        boundry_test_matrices{i}(:, 5) = boundry_test_matrices{i}(:, 5) - minHeight;
        
    end

end


