function averaged_data = average_data_points(current_data, numDataPointsPerMeasurement)
    
    % average data for each voltage measured
    % 500 measurements per velocity
    AoA_indices = linspace(1, length(current_data) + 1,...
                                  length(current_data)/numDataPointsPerMeasurement + 1);

    for k = 1:length(AoA_indices) - 1 % for every voltage measured, average all 500 values together

       current_V_index_range = AoA_indices(k):AoA_indices(k + 1) - 1;
       averaged_data(k, :) = mean(current_data(current_V_index_range, :), 1);

    end
    
end