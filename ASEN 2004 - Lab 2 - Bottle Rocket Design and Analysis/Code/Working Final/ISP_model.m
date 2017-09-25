function dydt = ISP_model(~, y)
    
    %%% Function for use in ODE45, calculates rate of change of launch
    %%% angle, the initial vol/mass of water, the drag coefficient, and the
    %%% inital air pressure in the rocket as functions of time. 
    
    %%% purpose: This function calculates the rate of change of the tracked
    %%%          variables - launch angle, the initial vol/mass of water,
    %%%          the drag coefficient, and the inital air pressure in the
    %%%          rocket -  as functions of time. Formats its input and
    %%%          output for use in ODE45.
    %%%          
    %%%
    %%% inputs: takes a vector y that contains all of the tracked variables
    %%%         that is used to calculate the new rate of change of all of
    %%%         these same tracked variables.
    %%%          
    %%%
    %%% outputs: outputs a vector containing how each tracked variable
    %%%          changed with each iteration.
    %%%          
    %%%
    %%% assumptions: assumes that the system is isentropic, that the gas
    %%%              can be treated as an Ideal Gas, that water is
    %%%              incompressible, and assumes steady atmospheric
    %%%              conditions for the duration of the flight.
    %%%              
    %%%
    %%% authors: Nicholas Renninger
    %%% date created: 11/25/2016
    %%% date modified: 04/16/2017
    
    % determine wheter doing sensitivity analysis or not
    [do_sens_analysis, runMonteCarlo, run_verif_case] = getGlobalBool;

    %% resolving y vec. into its constituent variables for readability
    x_pos = y(1);
    y_pos = y(2);
    z_pos = y(3);
    vel_x = y(4);
    vel_y = y(5);
    vel_z = y(6);
    ~ = y(7);
    mass_water = y(8);
    V_air = y(9);


    %% Initializing Needed Parameters for Trajectory Calculation 
    [flight_params, ~] = getInput(do_sens_analysis, ...
                                  runMonteCarlo, ...
                                  run_verif_case);
    
    g = flight_params{1};
    C_discharge = flight_params{2};
    V_bottle = flight_params{3};
    P_atm = flight_params{4};
    gamma = flight_params{5};
    rho_water = flight_params{6};
    A_throat = flight_params{7};
    A_bottle = flight_params{8};
    R_air = flight_params{9};
    mass_bottle = flight_params{10};
    V_air_init = flight_params{11};
    Rho_air_atm = flight_params{12};
%     T_air_init = flight_params{13}; % not needed as of now
    m_air_init = flight_params{14};
    P_air_init = flight_params{15};
    C_drag = flight_params{16};
    v_wind_surface = flight_params{17};
    v_wind_aloft = flight_params{18};
    theta_init = flight_params{19};
    
    
    %% compute wind effects on trajectory

    % if the rocket is above about 10m, use aloft wind data instead of
    % surface wind data.
    if z_pos < 10

        vrel = [vel_x, vel_y, vel_z]' - v_wind_surface;
        vrel_mag = norm(vrel);
    else % above 10m
        vrel = [vel_x, vel_y, vel_z]' - v_wind_aloft;
        vrel_mag = norm(vrel);
    end

    % while rocket is still on rails (0.5461m) fix the heading vec to the launch
    % angle
    if norm([x_pos, y_pos, z_pos]) < 0.5461 % [m]
        head_vec = [cot(theta_init); 0; 1] ./ norm([cot(theta_init); 0; 1]);
    else
        head_vec = vrel * (1/vrel_mag);
    end


    %%% Make sure that air volume does not exceed bottle volume
    if V_air > V_bottle
        V_air = V_bottle;
    end
 
    %% Drag
    Drag_vec = ( (Rho_air_atm / 2) * (vrel_mag ^ 2) * C_drag * ...
                A_bottle ) .* head_vec;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Determining Flight Regime of Rocket and Related parameters
    
    if V_air < V_bottle % Water Thrust Period of Flight
        
        % Air pressure at Time t
        P_air = P_air_init * (V_air_init / V_air) .^ gamma;
        
        if P_air < P_atm
            P_air = P_atm;
        end
        
        % Exhaust Velocity
        Vel_exhaust = sqrt((2/rho_water) * (P_air - P_atm));

        % Mass flow rate of water out the Throat of the Bottle and of Air
        dmWater_dt = -C_discharge * rho_water * A_throat * Vel_exhaust;
        dmAir_dt = 0;

        % Thrust of Rocket
        F = (2 * C_discharge * (P_air - P_atm) * A_throat) .* head_vec;

        %% Rate of Change of Volume of Air
        if V_air < V_bottle
            dVair_dt = C_discharge * A_throat * Vel_exhaust;
        else
            dVair_dt = 0;
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    else % Air Thrust Period of Flight
        
        % Pressure and Temperature of air in bottle when all of the water
        % is expelled.
        P_end = P_air_init * (V_air_init / V_bottle) .^ gamma;
%         T_end = T_air_init * (V_air_init / V_bottle) .^ (gamma - 1);
        
        % Air Pressure at Time t
        P_air_mass_eqn = P_end * (mass_air / m_air_init) .^ gamma;
        
        
        if P_air_mass_eqn > P_atm
            
            % Local Air Denisty & Air Temp 
            rho_air = mass_air / V_bottle;
            T_air = P_air_mass_eqn / (rho_air * R_air);

            % Critical Pressure
            crit_pressure = P_air_mass_eqn * (2 / (gamma + 1)) ...
                                             .^ (gamma / (gamma - 1));

            %% Check for Choked Flow (M_exit = 1)
            if crit_pressure > P_atm % Choked Flow

                T_exit = (2 / (gamma + 1)) * T_air;
                rho_exit = crit_pressure / (R_air * T_exit);
                Velocity_exit = sqrt(gamma * R_air * T_exit);
                P_air_exit = crit_pressure;

            elseif crit_pressure <= P_atm % Not Choked

                % Exit air Pressure is ambient air pressure
                P_air_exit = P_atm;

                %%% Solve System of Equations %%%
                
                M_exit = ((2/(gamma-1))*((P_air_mass_eqn/P_atm).^((gamma-1)/gamma)-1)).^0.5;
                T_exit = T_air*(1+((gamma-1)/2)*M_exit.^2);
                rho_exit = P_air_exit/(R_air*T_exit);

                % Find exit Velocity
                Velocity_exit = M_exit * sqrt(gamma * R_air * T_exit);
                
            end

            % Volume of Air no longer is changing, V_air == V_bottle
            dVair_dt = 0;

            %% Rate of Change Air Mass, Water Mass
            dmAir_dt = -C_discharge * rho_exit * A_throat * Velocity_exit;
            dmWater_dt = 0;

            %% Calculate Thrust
            F = (-dmAir_dt * Velocity_exit + (P_air_exit - P_atm) ...
                * A_throat) .* head_vec;
        
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        else % Ballistic (No Thrust Period) Phase
            
            F = [0; 0; 0]; % no thrust anymore :'(

            % no change in amount of water/air in bottle
            dmAir_dt = 0;
            dmWater_dt = 0;

            % Volume of Air no longer is changing, V_air == V_bottle
            dVair_dt = 0;
            
        end

        
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    %% Basic Governing Equations
    
    % Mass of Rocket
    if mass_water < 0
        mass_water = 0;
    end
    
    
    mass_rocket = mass_bottle + mass_air + mass_water;
    
    % Nt. II: accel = Sum F / total mass 
    accel_vec = (F - Drag_vec - mass_rocket * g) ./ mass_rocket;
    
    dvx_dt = accel_vec(1);
    dvy_dt = accel_vec(2);
    dvz_dt = accel_vec(3);
    
    dx_dt = vel_x;
    dy_dt = vel_y;
    dz_dt = vel_z;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %% Assign the change in y to the dydt vector for ode45
    

    dydt(1) = dx_dt;
    dydt(2) = dy_dt;
    dydt(3) = dz_dt;
    dydt(4) = dvx_dt;
    dydt(5) = dvy_dt;
    dydt(6) = dvz_dt;
    dydt(7) = dmAir_dt;
    dydt(8) = dmWater_dt;
    dydt(9) = dVair_dt;

    dydt = dydt';
    
end