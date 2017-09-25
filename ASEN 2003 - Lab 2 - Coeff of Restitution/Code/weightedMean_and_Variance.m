function [weightedMean, errorMean] = weightedMean_and_Variance(data, error)

    %%% [weightedMean, errorMean] = weightedMean_and_Variance(data, error)
    %%%
    %%% 
    %%%             
    %%% Inputs:
    %%%        - h_vec: a vector of the height of the ball as a function of
    %%%                 time.
    %%%
    %%%        - t_vec: a vector containing the time at which each of the
    %%%                 points in h_vec was recorded.
    %%%
    %%%        - sigma_h_curr: the uncertainty in the measurement of the
    %%%                        balls height.
    %%%
    %%%        - sigma_h_prev: the uncertainty in the measurement of the
    %%%                        balls height.
    %%%
    %%% Outputs:
    %%%         - e: value of the coefficient of restitution based on
    %%%         method
    %%%              1 formulation, averaged using the weighted mean across
    %%%              the entire trial.
    %%%
    %%%         - sigma_e: uncertainty of the value of e, with the
    %%%                    uncertainty computed during each pair of bounces
    %%%                    and then combined using the uncertainty of the
    %%%                    weighted mean theory.
    %%%
    %%% Author: Nicholas Renninger
    %%% Date Created: 2/12/17
    %%% Last Modified: 2/15/17
    
    %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
    
    % calculate weights based on statistical variance of data (error mat.)
    weights = 1 ./ error.^2;
    
    % check if any of the weights is zero and fix it
    if ~isempty(find(weights == inf, 1))
       
        [r, c] = find(weights == inf);
        
        for i = 1:length(r)
           
            % re make weight based on super small error for zero error
            non_zero_errors = error(error(:, c(i)) ~= 0);
            new_error = min(non_zero_errors(:, 1)) * 1e-3;
            weights(r(i), c(i)) = 1 / new_error^2;
            
        end
    end
    
    
    
    %% calculate sums for the weighted mean of the matrix
    [numPoints, numVars] = size(data);
    
    [sumOfAvgPoints, sumOfWeights] = deal(zeros(1, numVars));
    
    for i = 1:numVars
        for j = 1:numPoints
            
            sumOfAvgPoints(i) = sumOfAvgPoints(i) + ...
                                weights(j, i) .* data(j, i); 
            sumOfWeights(i) = sumOfWeights(i) + weights(j, i);
        end
    end
    
    weightedMean = sumOfAvgPoints ./ sumOfWeights;
    
    
    
    %% calculate the variance of the weighted mean
    
    errorMean = sqrt(1 ./ sumOfWeights);
    
     
end