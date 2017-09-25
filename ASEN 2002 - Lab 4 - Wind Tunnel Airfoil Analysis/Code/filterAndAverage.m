function filtered_matrix = filterAndAverage(input_mat)

    %%% Filter out and average any duplicate data points

    avg_index = 1;
    new_airspeed_index = 1;

    % pull AoA out of matrix
    AoA = input_mat(:, end);
    
    for i = 1:length(input_mat)
        
        current_AoA = AoA(i);
        
        if i ~= 1
            if current_AoA == AoA(i - 1)
                
                similar_mat(avg_index, :) = input_mat(i, :);
                avg_index = avg_index + 1;
                
            else % new AoA
                
                [r, ~] = size (similar_mat);
                
                if r == 1
                    new_matrix(new_airspeed_index, :) = similar_mat;
                else
                    new_matrix(new_airspeed_index, :) = mean(similar_mat);
                end
                
                new_airspeed_index = new_airspeed_index + 1;
                avg_index = 1;
                similar_mat = [];
                similar_mat(avg_index, :) = input_mat(i, :);
                avg_index = avg_index + 1;
            end
            
        elseif i == 1 % first iteration
            
            similar_mat(avg_index, :) = input_mat(i, :);
            avg_index = avg_index + 1;
            
        end
        
    end
    
    if new_matrix(avg_index - 1, end) ~= current_AoA % if have not added last AoA into matrix
        new_matrix(new_airspeed_index, :) = mean(similar_mat, 1);
    end

    filtered_matrix = new_matrix;
    
end
