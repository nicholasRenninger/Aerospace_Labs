function [averaged_data, STD_mat] = average_data_points(current_data, ...
                                             numDataPointsPerMeasurement)
    
    % average data for each variable measured
    % numDataPointsPerMeasurement measurement per measurement
    AoA_indices = linspace(1, length(current_data) + 1, ...
                                  length(current_data) / ...
                                  numDataPointsPerMeasurement + 1);

    % for every voltage measured, average numDataPointsPerMeasurement
    % values together
    for k = 1:length(AoA_indices) - 1 

       current_V_index_range = AoA_indices(k):AoA_indices(k + 1) - 1;
       averaged_data(k, :) = mean(current_data(current_V_index_range, :), 1);
       STD_mat(k, :) = std(current_data(current_V_index_range, :));

    end
    
end