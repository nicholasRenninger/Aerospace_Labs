%%% Authors:  Sotomayor, Renninger
%%% Created:  26 October 2016
%%% Modified: 11/13/16
%%% The purpose of this function is to take in two static pressures,
%%% Temperature, Pressures and, the two cross sectional areas, and return a
%%% velocity.  


function [ air_velocity, venturi_velocity_matrix, best_fit_velocity, coefs ] = Velo_Calc_Venturi_Tube(venturi_velocity_matrix, shouldAverage)

    % ratio of the cross-sectional areas of the settling chamber vs. the test-section
    AREA_RATIO = 9.5;

    % gas constant for air, in joules/(kg*K)
    R_Air = 286.9;

    %% defining cross-sectional areas of wind tunnel

    % A2 is the cross-sectional area of the test-section in m^2
    A2 = 0.092903;

    % A1 is the cross-sectional area of the settling chamber in m^2
    A1 = A2 * AREA_RATIO;

    %%% finding best fit to create voltage to airspeed model
    x = venturi_velocity_matrix(:, 4); % Voltage 

    if shouldAverage % average the data points

        avg_index = 1;
        new_airspeed_index = 1;

        for i = 1:length(venturi_velocity_matrix)

           current_voltage = x(i);

           if i ~= 1
               if current_voltage == x(i - 1)

                    similar_speed(avg_index, :) = venturi_velocity_matrix(i, :);
                    avg_index = avg_index + 1;

               else % new voltage
                   
                   [r, ~] = size (similar_speed);
                       
                   if r == 1
                       new_vel_matrix(new_airspeed_index, :) = similar_speed;
                   else
                       new_vel_matrix(new_airspeed_index, :) = mean(similar_speed);
                   end
                   
                   new_airspeed_index = new_airspeed_index + 1;
                   avg_index = 1;
                   similar_speed = [];
                   similar_speed(avg_index, :) = venturi_velocity_matrix(i, :);
                   avg_index = avg_index + 1;
               end

           elseif i == 1 % first iteration

               similar_speed(avg_index, :) = venturi_velocity_matrix(i, :);
               avg_index = avg_index + 1;

           end

        end

        venturi_velocity_matrix = new_vel_matrix;

    end
        
    %% Delta_P = Press_Stat_1 - Press_Stat_2
    Delta_P = venturi_velocity_matrix(:, 3);
    T_Atm = venturi_velocity_matrix(:, 2);
    P_Atm = venturi_velocity_matrix(:, 1);

    %% Derived from Bernoulli's Equation for incompressible flow
    air_velocity = sqrt( (2 * Delta_P .* R_Air .* T_Atm) ./ (P_Atm .* (1 - (A2/A1)^2)) );

    %%% finding best fit to create voltage to airspeed model
    x = venturi_velocity_matrix(:, 4); % Voltage
    y = air_velocity; % airspeed

    % find best fit line of data to create voltage control model
    coefs = polyfit(x, y, 1);
    best_fit_velocity = polyval( coefs, x );

    
end