function [filtered_data, filtered_error] = filterAndAverage(input_mat, error_mat, AOA_index)

    %%% Filter out and average any duplicate data points

    avg_index = 1;
    new_airspeed_index = 1;

    % pull AoA out of matrix
    AoA = input_mat(:, AOA_index);
    
    for i = 1:length(input_mat)
        
        if i ~= 1
            
            current_AoA = round(AoA(i));
            prev_AoA = round(AoA(i - 1));
            
            if current_AoA == prev_AoA
                
                similar_mat(avg_index, :) = input_mat(i, :);
                sim_error_mat(avg_index, :) = error_mat(i, :);
                avg_index = avg_index + 1;
                
            else % new AoA
                
                [r, ~] = size(similar_mat);
                
                if r == 1
                    new_data_matrix(new_airspeed_index, :) = similar_mat;
                    new_error_matrix(new_airspeed_index, :) = sim_error_mat;
                else
                    [weightedMean, errorMean] = weightedMean_and_Variance(similar_mat, sim_error_mat);
                    new_data_matrix(new_airspeed_index, :) = weightedMean;
                    new_error_matrix(new_airspeed_index, :) = errorMean;
                end
                
                new_airspeed_index = new_airspeed_index + 1;
                avg_index = 1;
                similar_mat = [];
                sim_error_mat = [];
                similar_mat(avg_index, :) = input_mat(i, :);
                sim_error_mat(avg_index, :) = error_mat(i, :);
                avg_index = avg_index + 1;
            end
            
        elseif i == 1 % first iteration
            
            similar_mat(avg_index, :) = input_mat(i, :);
            sim_error_mat(avg_index, :) = error_mat(i, :);
            avg_index = avg_index + 1;
            
        end
        
    end
    
    if new_data_matrix(avg_index - 1, end) ~= current_AoA % if have not added last AoA into matrix
        [weightedMean, errorMean] = weightedMean_and_Variance(similar_mat, sim_error_mat);
        new_data_matrix(new_airspeed_index, :) = weightedMean;
        new_error_matrix(new_airspeed_index, :) = errorMean;
    end

    filtered_data = new_data_matrix;
    filtered_error = new_error_matrix;
    
end
