function [e, sigma_e] = calc_e_method_1(h_vec, t_vec, ...
                                        sigma_h_curr, sigma_h_prev)
    
    %%% [e, sigma_e] = calc_e_method_1(h_vec, t_vec, ...
    %%%                                sigma_h_curr, sigma_h_prev)
    %%%
    %%% Calculates e (coeff. of restitution) using the method 1 formula:
    %%%             
    %%%              e = (h_(n) / h_(n-1)) ^ 1/2
    %%%
    %%% and its uncertainty based on the general error propagation formula
    %%% and weighted mean and weighted mean uncertainty theory.
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
    
    %% Method 1
    
    % Define the method for calculating e for use in uncertainty analysis
    syms h_curr h_prev 
    e_fcn = @(h_curr, h_prev) sqrt(h_curr / h_prev);
    
    % isolate good data, i.e. first 5 bounces during the trial
    [height, ~] = findFive(h_vec, t_vec);
    
   
    % calc e  and its uncertainty for each bounce up to ~5 bounces
    for i = 2:length(height)
        
        % compute e
        e_vec(i - 1) = sqrt( height(i) / height(i - 1) );
        
        % compute sigma_e
        sigma_e_vec(i - 1) = ErrorProp(e_fcn, [h_curr h_prev], ...
                                       [height(i) height(i-1)], ...
                                       [sigma_h_curr, sigma_h_prev]);
        
    end
    
    % get avg e val and uncertainty for the trial 
    [e, sigma_e] = weightedMean_and_Variance(e_vec', sigma_e_vec');
   
    
end