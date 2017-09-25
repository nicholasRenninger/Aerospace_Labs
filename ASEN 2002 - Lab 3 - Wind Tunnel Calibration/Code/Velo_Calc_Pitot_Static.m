%%% Authors:  Sotomayor, Renninger
%%% Created:  26 October 2016
%%% Modified: 11/13/16
%%% The purpose of this function is to take in the static pressure, total
%%% pressure, atmospheric pressure, and temperature and compute the free
%%% stream velocity for the pitot-static tube.  

%%% Derived from Bernoulli's equation for incompressible flow 


function [air_velocity, pitot_velocity_matrix, best_fit_velocity, coefs] = Velo_Calc_Pitot_Static(pitot_velocity_matrix, useAuxMeas, shouldAverage)
       
    % gas constant for air, in joules/(kg*K)
    R_Air = 286.9; 
    
    %  Delta_P = Total_Press - Stat_Press
    if useAuxMeas % boundry layer airpseed
        
        Delta_P = pitot_velocity_matrix(:, 4);
        
        % find airspeed for pitot and static ring measurements
        T_atm = pitot_velocity_matrix(:, 2);
        P_atm = pitot_velocity_matrix(:, 1);
        
        % eqn. from lab document, derived from bernouli's
        air_velocity = sqrt( (2 * Delta_P) .* ((R_Air .* T_atm) ./ (P_atm)) );
        
        x = pitot_velocity_matrix(:, 4); % Voltage 
        best_fit_velocity = false;
        coefs = false;
        
    else % is voltage/velocity measurement
       
        %%% finding best fit to create voltage to airspeed model
        x = pitot_velocity_matrix(:, 4); % Voltage 
        
        if shouldAverage % average the data points
            
            avg_index = 1;
            new_airspeed_index = 1;

            for i = 1:length(pitot_velocity_matrix)

               current_voltage = x(i);

               if i ~= 1
                   if current_voltage == x(i - 1)

                        similar_speed(avg_index, :) = pitot_velocity_matrix(i, :);
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
                       similar_speed(avg_index, :) = pitot_velocity_matrix(i, :);
                       avg_index = avg_index + 1;
                   end

               elseif i == 1 % first iteration

                   similar_speed(avg_index, :) = pitot_velocity_matrix(i, :);
                   avg_index = avg_index + 1;

               end

            end
            
            pitot_velocity_matrix = new_vel_matrix;
            
        end
        
        % find airspeed for pitot and static ring measurements
        T_atm = pitot_velocity_matrix(:, 2);
        P_atm = pitot_velocity_matrix(:, 1);
        
        Delta_P = pitot_velocity_matrix(:, 3);
        
        % eqn. from lab document, derived from bernouli's
    	air_velocity = sqrt( (2 * Delta_P) .* ((R_Air .* T_atm) ./ (P_atm)) );
        
        %%% finding best fit to create voltage to airspeed model
        x = pitot_velocity_matrix(:, 4); % Voltage 
        y = air_velocity; % airspeed
        
        % find best fit line of data to create voltage control model
        coefs = polyfit(x, y, 1);
        best_fit_velocity = polyval( coefs, x );
        
    end
    
end