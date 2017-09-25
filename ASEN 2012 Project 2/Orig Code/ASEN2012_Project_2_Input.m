function [flight_params,...
          initial_conditions] = ASEN2012_Project_2_Input(use_globals,...
                                                        find_85m_range, ...
                                                        do_verification)
                                                    
    %%% Input function where constants for project are set.

    %%% purpose: This function exists to pass data to both the main and
    %%%          dy_dt function. This allows the flight parameters for
    %%%          solution in ODE45 to be consolodated to one place and
    %%%          allows for easy switching of which flight parameters are
    %%%          returned based on what type of simulation you are running.
    %%%
    %%% inputs: takes three bool inputs, which tell the function whether to
    %%%         return the specific flight parameters for running the
    %%%         sensitivity analysis, the 85m range finding, or the
    %%%         verification case.
    %%%          
    %%%
    %%% outputs: returns a formatted vector of flight parameters needed in
    %%%          each iteration of the dy_dt ODE45 function for the
    %%%          calculation of the trajectory and a formatted vector of
    %%%          initial conditions needed in ODE45 to tell it where to
    %%%          begin solving the ODE.
    %%%          
    %%%
    %%% assumptions: assumes that all parameters will be set in SI units,
    %%%              that water is incompressible, and that the gas in the
    %%%              rocket is an Ideal Gas for at lest the beginning of
    %%%              the flight.
    %%%              
    %%%
    %%% author's ID: 0dc91b091fd8
    %%% date created: 11/25/2016
    %%% date modified: 12/1/2016
    
    %% Define Contants

    g = 9.81; % [m/s^2]
    C_discharge = 0.8; % discharge coefficient [dimensionless]
    Rho_air_atm = 0.961; % ambient air density [kg/m^3]
    V_bottle = 0.002; % volume of empty 2 litre bottle [m^3]
    P_atm = 82943.93; % atmospheric pressure [Pa]
    gamma = 1.4; % ratio of specific heats for air [dimensionless]
    rho_water = 1000; % density of water [kg/m^3]
    D_throat = 0.021; % diameter of throat [m]
    D_bottle = 0.105; % diameter of bottle [m]
    R_air = 287; % gas constant for air [J/kg/K]
    m_bottle = 0.07; % mass of empty bottle [kg]
    T_air_init = 300; % initial temperature of air [K]

    A_throat = (pi/4) * D_throat ^ 2; % cross-sect area of throat [m^2]
    A_bottle = (pi/4) * D_bottle ^ 2; % cross-sect area of bottle [m^2]

    %% Define Initial Conditions

    if use_globals
        
        % Set Global Variables for Sensitivity Analysis
        [global_vars] = GetGlobals;

        % Set the Value of the 4 Globals
        P_air_init = global_vars(1);
        m_water_init = global_vars(2);
        C_drag = global_vars(3);
        theta_init = global_vars(4);
        
        % re-calculate vol of water based on chosen mass of water
        V_water_init = m_water_init / rho_water; % initial vol. 
                                                 % of water in bottle [m^3]
        
    elseif do_verification % run simulation on verification case
        
        C_drag = 0.5; % drag coefficient [dimensionless]
        
        %%% Initial Absolute Pressure of Air in Bottle [Pa]
        P_gauge_air = 344738; % initial gauge pressure of air in bottle[Pa]
        P_air_init = P_atm + P_gauge_air;
        
        V_water_init = 0.001; % initial vol. of water in bottle [m^3]
        
        % Initial Mass of Water
        m_water_init = rho_water * V_water_init; % [kg]
        
        theta_init = 45 * (pi / 180); % theta [rad]
        
    elseif find_85m_range % use preset values for sensitivity params
        
        C_drag = 0.3; % drag coefficient [dimensionless]
        
        %%% Initial Absolute Pressure of Air in Bottle [Pa]
        P_gauge_air = 461949; % initial gauge pressure of air in bottle[Pa]
        P_air_init = P_atm + P_gauge_air;
        
        V_water_init = 0.001; % initial vol. of water in bottle [m^3]
        
        % Initial Mass of Water
        m_water_init = rho_water * V_water_init; % [kg]
        
        theta_init = 33.7 * (pi / 180); % theta [rad]
        
    end
    
    % upodate global conditions so that dydt uses preset values
    global_conditions = [P_air_init, m_water_init, C_drag, theta_init];
    setGlobals(global_conditions);

    %%% Initial Conditions of Tracked Variables
    Vel_init = 0; % initial velocity of the rocket [m/s]
    x_init = 0; % initial horizontal position [m]
    y_init = 0.1; % initial vertical position [m]

    % Initial Mass of Air in Bottle
    V_air_init = V_bottle - V_water_init; % [kg]
    m_air_init = (P_air_init * V_air_init) / (R_air * T_air_init); % [kg]


    %% Formatting Output

    flight_params = [g, C_discharge, V_bottle, P_atm, gamma,...
                     rho_water, A_throat, A_bottle, R_air, m_bottle, ...
                     V_air_init, Rho_air_atm, ...
                     T_air_init, m_air_init];

    initial_conditions = [Vel_init, m_air_init, m_water_init,...
                          theta_init, x_init, y_init, V_air_init];
                  
end
