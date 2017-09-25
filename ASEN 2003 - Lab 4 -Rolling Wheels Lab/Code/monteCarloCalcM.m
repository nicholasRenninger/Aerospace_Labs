function newM = monteCarloCalcM(M_lims, ...
                                omega_exp, ...
                                theta_exp, ...
                                constants, ...
                                modelUsed) 
                            
    %% ASEN 2003: Dynamics & Systems - Spring 2017
    % Project: Rolling Wheel Lab (#4)
    % Project Members:  Joseph Grengs
    %                   Kian Tanner
    %                   Nicholas Renniger
    %
    %
    % Function takes an interval of M value over which to search, along
    % with the experimental data, and runs a short Monte Carlo simulation
    % to randomly generate M values over the specified M interval, and
    % build up a vector of least-squares differences. These differences are
    % computed by trying a random M over the interval, calculating the
    % model omega with this M, and summing the squared difference between
    % the model and experimental data for the random M. This is done
    % thousands of times, and at the end, the minimum sum of squared
    % difference is chosen as the optimal solution, and the M value
    % corresponding to this minimum squared difference is returned as the
    % emprical constant for this lab.
    %
    % Project Due Date: Thursday, March 16, 2017 @ 4:00p
    % MATLAB Code Created on: 03/02/2017
    % MATLAB Code last updated on: 03/15/2017
    
    %% Setup
    MIN_M = M_lims(1);
    MAX_M = M_lims(2);
    NUM_STEPS = 1e3;
    new_M = MIN_M;
    
    % initialize
    [leastSquaresDiff, M_vec] = deal(zeros(1, NUM_STEPS));
    
    %% Find minimizing M
    
    % calculate least squares difference NUM_STEPS times using randomly
    % generated M value.
    for i = 1:NUM_STEPS
        
        curr_M = new_M;
        omega_model = calcModelOmega(theta_exp, curr_M, ...
                                     constants, modelUsed);
                                 
        leastSquaresDiff(i) = sum((omega_exp - omega_model).^2);
        M_vec(i) = curr_M;
        new_M = rand * MAX_M - MIN_M;
           
    end
    
    % find minimum least squares difference
    [~, minIdx] = min(leastSquaresDiff);
    
    % return M value that minimizes the difference
    newM = M_vec(minIdx);
      
    
end