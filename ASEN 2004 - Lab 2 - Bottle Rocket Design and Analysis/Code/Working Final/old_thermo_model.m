function dydt = old_thermo_model(~, y)
    
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
    %%% author's ID: 0dc91b091fd8
    %%% date created: 11/25/2016
    %%% date modified: 12/1/2016
    
    % determine wheter doing sensitivity analysis or not
    [do_sens_analysis, do_85m_analysis, run_verif_case] = getGlobalBool;

    %% resolving y vec. into its constituent variables for readability
    Velocity = y(1);
    mass_air = y(2);
    mass_water = y(3);
    theta = y(4);
    x_pos = y(5); % only here for debugging
    z_pos = y(6); % only here for debugging
    V_air = y(7);
    
    
    %% Initializing Needed Parameters for Trajectory Calculation 
    [flight_params, ~] = getInput(do_sens_analysis, ...
                                  do_85m_analysis, ...
                                  run_verif_case);
    
    g = flight_params(1);
    C_discharge = flight_params(2);
    V_bottle = flight_params(3);
    P_atm = flight_params(4);
    gamma = flight_params(5);
    rho_water = flight_params(6);
    A_throat = flight_params(7);
    A_bottle = flight_params(8);
    R_air = flight_params(9);
    mass_bottle = flight_params(10);
    V_air_init = flight_params(11);
    Rho_air_atm = flight_params(12);
    T_air_init = flight_params(13);
    m_air_init = flight_params(14);
    P_air_init = flight_params(15);
    C_drag = flight_params(16);
    
    
    %%% Make sure that air volume does not exceed bottle volume
    if V_air > V_bottle
        V_air = V_bottle;
    end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Determining Flight Regime of Rocket and Related parameters
    
    if V_air < V_bottle % Water Thrust Period of Flight
       
        % Air pressure at Time t
        P_air = P_air_init * (V_air_init / V_air) ^ gamma;
        
        if P_air < P_atm
            P_air = P_atm;
        end
        
        % Exhaust Velocity
        Vel_exhaust = sqrt((2/rho_water) * (P_air - P_atm));
        
        % Mass flow rate of water out the Throat of the Bottle and of Air
        dmWater_dt = -C_discharge * rho_water * A_throat * Vel_exhaust;
        dmAir_dt = 0;

        % Thrust of Rocket
        F = 2 * C_discharge * (P_air - P_atm) * A_throat;

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
        P_end = P_air_init * (V_air_init / V_bottle) ^ gamma;
        T_end = T_air_init * (V_air_init / V_bottle) ^ (gamma - 1);
        
        % Air Pressure at Time t
        P_air_mass_eqn = P_end * (mass_air / m_air_init) ^ gamma;
        
        
        if P_air_mass_eqn > P_atm
            
            % Local Air Denisty & Air Temp 
            rho_air = mass_air / V_bottle;
            T_air = P_air_mass_eqn / (rho_air * R_air);

            % Critical Pressure
            crit_pressure = P_air_mass_eqn * (2 / (gamma + 1)) ...
                                             ^ (gamma / (gamma - 1));

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

                if isempty(Velocity_exit)
                    error('All imaginary Solutions')
                end
                
            end

            % Volume of Air no longer is changing, V_air == V_bottle
            dVair_dt = 0;

            %% Rate of Change Air Mass, Water Mass
            dmAir_dt = -C_discharge * rho_exit * A_throat * Velocity_exit;
            dmWater_dt = 0;

            %% Calculate Thrust
            F = -dmAir_dt * Velocity_exit + (P_air_exit - P_atm) * A_throat;
        
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        else % Ballistic (No Thrust Period) Phase
            
            F = 0; % no thrust anymore :'(

            % no change in amount of water/air in bottle
            dmAir_dt = 0;
            dmWater_dt = 0;

            % Volume of Air no longer is changing, V_air == V_bottle
            dVair_dt = 0;
            
        end

        
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    %% Drag
    Drag = (Rho_air_atm / 2) * (Velocity ^ 2) * C_drag * A_bottle;

    
    %% Basic Governing Equations
    
    % Mass of Rocket
    if mass_water < 0
        mass_water = 0;
    end
    
    mass_rocket = mass_bottle + mass_air + mass_water;
    
    dVel_dt = (F - Drag - mass_rocket * g * sin(theta)) / mass_rocket;
        
    if Velocity > 1
        dTheta_dt = (1/Velocity) * -g * cos(theta);
    else
        dTheta_dt = 0;
    end
    
    dx_dt = Velocity * cos(theta);
    dz_dt = Velocity * sin(theta);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %% Assign the change in y to the dydt vector for ode45
    
    dydt(1) = dVel_dt;
    dydt(2) = dmAir_dt;
    dydt(3) = dmWater_dt;
    dydt(4) = dTheta_dt;
    dydt(5) = dx_dt;
    dydt(6) = dz_dt;
    dydt(7) = dVair_dt;

    dydt = dydt';
    
end