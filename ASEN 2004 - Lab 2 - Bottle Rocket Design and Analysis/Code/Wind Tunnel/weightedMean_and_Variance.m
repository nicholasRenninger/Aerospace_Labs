function [weightedMean, errorMean] = weightedMean_and_Variance(data, error)

    % calculate weights based on statistical variance of data (error mat.)
    weights = 1 ./ error.^2;
    
    % check if any of the weights is zero and fix it
    if ~isempty(find(weights == inf, 1))
       
        [r, c] = find(weights == inf);
        
        for i = 1:length(r)
           
            % re make weight based on super small error for zero error
            non_zero_errors = error(error(:, c(i)) ~= 0, c(i));
            if isempty(non_zero_errors)
                new_error = data(r(i), c(i)) * 1e-3;
                weights(r(i), c(i)) = 1 / new_error^2;
            else
                new_error = min(non_zero_errors(:, 1)) * 1e-3;
                weights(r(i), c(i)) = 1 / new_error^2;
            end
            
        end
    end
    
    %% calculate sums for the weighted mean of the matrix
    [numPoints, numVars] = size(data);
    
    [sumOfAvgPoints, sumOfWeights] = deal(zeros(1, numVars));
    
    for i = 1:numVars
        for j = 1:numPoints
            
            sumOfAvgPoints(i) = sumOfAvgPoints(i) + weights(j, i) .* data(j, i); 
            sumOfWeights(i) = sumOfWeights(i) + weights(j, i);
        end
    end
    
    weightedMean = sumOfAvgPoints ./ sumOfWeights;
    
    
    
    %% calculate the variance of the weighted mean
    
    errorMean = sqrt(1 ./ sumOfWeights);
    
     
end