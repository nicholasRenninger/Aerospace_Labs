function trial_data = read_data_files(pixel_to_in, trial_num)
    
    %%% trial_data = read_data_files(pixel_to_in, trial_num)
    %%%
    %%% Requires that all of the data be organized into following structure
    %%% for the data to be read in:
    %%%                 
    %%%         '../Data/Trial_xxx/', where xxx = trial number
    %%%
    %%% save data must be in .mat format.
    %%% 
    %%% Inputs:
    %%%        - pixel_to_in: defines how many pixels are in one inch
    %%%
    %%%        - tiral_num: this is the trial number of the folder of data
    %%%        to read in. To read in Data from the '../Data/Trial_1/'
    %%%        folder, use trial_num = 1.
    %%%
    %%% Outputs:
    %%%         - cell array containing data from each set of trials as a
    %%%         separate cell. In each cell are cells with the x, y, and
    %%%         time data in structs from each of the trails for that set.
    %%%
    %%% Author: Nicholas Renninger
    %%% Date Created: 2/2/2017
    %%% Last Modified: 2/14/2017
    %%%
    
    
    % Trial *trial_num*
    path_trial{1} = sprintf('../Data/Trial_%d/', trial_num);
    folder_path{1} = cat(2, path_trial{1}, '*.mat');
    dir_test{1} = dir(folder_path{1});

    trial_data{1} = cell(1, length(dir_test{1}));
    


    for j = 1:length(dir_test)
        
        for k = 1:length(dir_test{j})

            current_directory = dir_test{j};
            filename = cat(2, path_trial{j}, current_directory(k, 1).name);
            current_data = load(filename);
            
            temp.x = current_data.ball_xy_position_data.x_pixel;
            temp.y = current_data.ball_xy_position_data.y_pixel;
            temp.time = current_data.ball_xy_position_data.time_seconds;
            
            % convert from pixels to inches
            % temp.x = temp.x ./ pixel_to_in;
            % temp.y = temp.y ./ pixel_to_in;
            
            if length(temp.y) ~= length(temp.time)
                error('%s', filename); 
            end
            
            if trial_num < 2
                for i = 1:length(temp.y)

                    if temp.y(i) == 0
                        temp.y(i) = [];
                    elseif i > 30
                        break
                    end

                end
                
                temp.y = temp.y - min(temp.y(1:8));
            end

            
            trial_data{k} = temp;

        end

    end




end