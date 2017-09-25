function [e, sigma_e] = calc_e_method_3(t_vec, h_init, ...
                                        sigma_t_stop, sigma_h_init)
    
    %%% [e, sigma_e] = calc_e_method_3(t_vec, h_init, sigma_t_stop, ...
    %%%                                sigma_h_init)
    %%%
    %%%
    %%%
    %%% Calculates e (coeff. of restitution) using the method 3 formula:
    %%%                                    
    %%%                                   / 2 * h_init \
    %%%                              sqrt|--------------|
    %%%                  t_(stop) -       \     g      /
    %%%       e =       ---------------------------------
    %%%                                   / 2 * h_init \
    %%%                              sqrt|--------------|
    %%%                  t_(stop) +       \     g      /
    %%%
    %%%
    %%% and its uncertainty based on the general error propagation formula
    %%% and weighted mean and weighted mean uncertainty theory.
    %%%             
    %%% Inputs:
    %%%        - t_vec: a vector containing the time at which each of the
    %%%                 points in h_vec was recorded.
    %%%        
    %%%        - h_init: the initial height in inches that the ball was
    %%%                  dropped from.
    %%%
    %%%        - sigma_t_stop: the uncertainty of the time until the ball
    %%%                        stops bouncing.
    %%%
    %%%        - sigma_h_init: the uncertainty in the initial height that
    %%%                        the ball was released at.
    %%%
    %%%
    %%% Outputs:
    %%%         - e: value of the coefficient of restitution based on
    %%%              method 3 formulation, averaged using the weighted mean
    %%%              across the entire trial.
    %%%
    %%%         - sigma_e: uncertainty of the value of e, with the
    %%%                    uncertainty computed during each pair of bounces
    %%%                    and then combined using the uncertainty of the
    %%%                    weighted mean theory.
    %%%
    %%% Author: Nicholas Renninger
    %%% Date Created: 2/12/17
    %%% Last Modified: 2/15/17
    
    
    %% Method 3
    
    % define gravitational acceleration, at S.L.
    g = 386.4; % [in / s^2]
    
    % Define the method for calculating e for use in uncertainty analysis
    syms t_stop h_o
    e_fcn = @(t_stop, h_o) ( t_stop - sqrt((2*h_o) / g) ) / ...
                           ( t_stop + sqrt((2*h_o) / g) );
    
        
    % compute e
    t_start = t_vec(1);
    t_end = t_vec(end);
    time_stop = t_end - t_start;
    
    e = e_fcn(time_stop, h_init);

    % compute sigma_e
    sigma_e = ErrorProp(e_fcn, [t_stop, h_o], ...
                               [time_stop, h_init], ...
                               [sigma_t_stop, sigma_h_init]);
        
end