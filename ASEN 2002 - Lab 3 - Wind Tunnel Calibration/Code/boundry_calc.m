%%% Takes the Boundry Layer data, and returns the height of the test,
%%% laminar and turbulent boundry layers as functions of x. Also finds the
%%% position and height of the transistion point between laminar and
%%% turbulent flow.
%%%
%%% Nicholas Renninger
%%% Last Updated: 11/13/16
%%%


function [Boundry_Layer_heights, port_locations, x, x_cr_lam_index, x_turb_cr_index, x_cr_ht] = boundry_calc(boundry_test_matrices) 


    %% finding height of boundry layer in expiremental data
    for i = 1:length(boundry_test_matrices)

        % find air velocity in boundry layer dont average
        isAuxMeasurement = true;
        [boundry_velocity{i}, ~, ~, ~] = Velo_Calc_Pitot_Static(boundry_test_matrices{i}, isAuxMeasurement, false);

        
        % find free stream velocity from pitot static probe, dont average
        isAuxMeasurement = false;
        [free_stream_velocity{i}, ~, ~, ~] = Velo_Calc_Pitot_Static(boundry_test_matrices{i}, isAuxMeasurement, false);
    
        
        
        % use best fit line for interpolating the fairly sparse V_infinity vs.
        % ELD probe height. Only fit the data points in the 
        indicies_in_boundry_layer = find(boundry_test_matrices{i}(:, 5) < 100); % find where ELD height is not in center (less than ~150)
        x = boundry_test_matrices{i}(indicies_in_boundry_layer, 5);
        y = boundry_velocity{i}(indicies_in_boundry_layer);

        % create new, higher resolution vector of height data in the boundry
        % layer
        best_fit_height_vec = linspace(0, 10, 1000);
        velocity_best_fit{i} = polyval( polyfit(x, y, 2), best_fit_height_vec ); % use second degreee to fit data

        % find where the velocity in the boundry layer is at least 95% of the
        % free-stream velocity
        index_BL_height = find(velocity_best_fit{i} > 0.95 .* mean(free_stream_velocity{i}), 1, 'first');

        % finding height of boundry layer in mm
        boundry_layer_height(i) = best_fit_height_vec(index_BL_height);

    end

    
    %% Building Array of x positions for each static port in m
    port_locations = [0.379222, 0.404114, 0.429006, 0.453898, 0.47879];

    
    %% defining constants for calculating laminar and turbulent boundry layers

    % create vector of x positions from 0 to length of test section, 24" or
    % 0.6096 meters
    x = linspace(0, 0.6096, 1000);

    % gas constant for air, in joules/(kg*K)
    R_Air = 286.9;

    % atmospheric pressure in Pa
    P_atm = mean(boundry_test_matrices{1}(:, 1));

    % atmospherice temperature in K
    T_atm = mean(boundry_test_matrices{1}(:, 2));

    % absolute viscosity coefficient in kg/(m*s)
    mu = 1.7894e-5;

    % V_inf of the air in test conditions in m/s
    V_inf = mean(free_stream_velocity{1});

    %%% finding desnity of air using IGE %%%
    rho_atm = P_atm / (R_Air * T_atm);

    % Reynolds Number (dimensionless)
    Re_x = (rho_atm .* V_inf .* x) ./ mu;

    % Reynolds Number for critical point (dimensionless). Estimated value
    % for Re @ critical x value from pg. 248 of Anderson text.
    Re_xCr = 3.75e5; 
    
    
    %% Laminar Boundry Layer Height

    % Laminar Boundry layer heiht, eqn. 4.91 from anderson text in mm
    laminar_boundry_layer_height = (5.2 .* x) ./ sqrt(Re_x) * 1000;

    
    %% Turbulent Boundry Layer Height over all x

    % Turbulent Boundry layer heiht, eqn. 4.99 from anderson text in mm
    turbulent_boundry_layer_height = (0.37 .* x) ./ (Re_x .^ 0.2) * 1000;

    %% Transisition point - X_critical in m and the corresponding height in mm
    x_cr_lam = ( mu * Re_xCr ) / (rho_atm * V_inf);
    x_cr_lam_indeces = x_cr_lam < (x + 0.001) & x_cr_lam > (x - 0.001);
    x_cr_ht = mean( laminar_boundry_layer_height(x_cr_lam_indeces) );
    x_cr_lam_index = ceil(mean(find(x_cr_lam_indeces)));
    
    %% Turbulent Boundary Layer Critical Height - X_critical in m and the corresponding height in mm
    x_turb_cr_indeces = turbulent_boundry_layer_height < (x_cr_ht + 0.05) & ....
                     turbulent_boundry_layer_height > (x_cr_ht - 0.05);
    x_turb_cr_index = ceil(mean(find(x_turb_cr_indeces)));
    %x_cr_turb = mean( x(x_turb_cr_indeces) );
   
    %% Turbulent Boundry Layer Height with new x, starting from critical point
    
    x_turb = x(x_turb_cr_index:1000-x_cr_lam_index + x_turb_cr_index);
    
    % Reynolds Number (dimensionless)
    Re_x_turb = (rho_atm .* V_inf .* x_turb) ./ mu;
    
    % Turbulent Boundry layer heiht, eqn. 4.99 from anderson text in mm
    turbulent_boundry_layer_height = (0.37 .* x_turb) ./ (Re_x_turb .^ 0.2) * 1000;
    
    
    %% Package up all Boundry Layer data
    Boundry_Layer_heights = {boundry_layer_height, laminar_boundry_layer_height,...
                             turbulent_boundry_layer_height};

                         
end