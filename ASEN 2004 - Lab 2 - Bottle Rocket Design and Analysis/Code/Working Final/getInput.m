function [flight_params,...
          initial_conditions] = getInput(use_globals,...
                                         runMonteCarlo, ...
                                         ~)
                                                    
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

    % never change these
    g = [0; 0; 9.79]; % [m/s^2]
    C_discharge = 0.8; % discharge coefficient [dimensionless]
    V_bottle = 0.002; % volume of empty 2 litre bottle [m^3]
    gamma = 1.4; % ratio of specific heats for air [dimensionless]
    D_throat = 0.021; % diameter of throat [m]
    D_bottle = 0.105; % diameter of bottle [m]
    R_air = 287; % gas constant for air [J/kg/K]

    A_throat = (pi/4) * D_throat ^ 2; % cross-sect area of throat [m^2]
    A_bottle = (pi/4) * D_bottle ^ 2; % cross-sect area of bottle [m^2]

    %% Define Initial Conditions

    if use_globals
        
        %%% Set Global Variables for Sensitivity Analysis
        [global_sens_vars] = getSensGlobals;

        % Set the Value of the 5 Sens Globals
        P_air_init = global_sens_vars(1);
        V_water_init = global_sens_vars(2);
        C_drag = global_sens_vars(3);
        theta_init = global_sens_vars(4);
        rho_water_init = global_sens_vars(5);
        
        
        %%% Set Other Global Variables for Sensitivity Analysis
        [global_other_vars] = getOtherGlobals;
        
        % Set the Value of the 5 Other Globals
        m_bottle = global_other_vars{1}; % mass of empty bottle [kg]
        T_air_init = global_other_vars{2}; % initial temperature of air [K]
        P_atm = global_other_vars{3}; % atmospheric pressure [Pa]
        v_wind_surface = global_other_vars{4}; %surf. wind in launch coord. frame [m/s]
        v_wind_aloft = global_other_vars{5}; %wind aloft in launch coord. frame [m/s]

        Rho_air_atm = P_atm / (R_air * T_air_init); % ambient air density [kg/m^3]
        
        % re-calculate mass of water based on chosen vol of water
        m_water_init = V_water_init * rho_water_init; % initial vol. 
                                                 % of water in bottle [m^3]
        
    elseif runMonteCarlo % run random simulation
        
        params = getMCGlobals;
        
        g = params{1};
        C_discharge = params{2};
        V_bottle = params{3};
        gamma = params{4};
        R_air = params{7};
        m_bottle = params{8};
        T_air_init = params{9};
        P_atm = params{10};
        A_throat = params{11};
        A_bottle = params{12};
        v_wind_surface = params{13};
        v_wind_aloft = params{14};
        C_drag = params{15};
        P_air_init = params{16};
        V_water_init = params{17};
        m_water_init = params{18};
        theta_init = params{19};
        Rho_air_atm = params{20};
        rho_water_init = params{21};
        
    end
    

    %%% Initial Conditions of Tracked Variables
    x_init = 0; % initial velocity of the rocket [m]
    y_init = 0; % initial horizontal position [m]
    z_init = 0.1; % initial vertical position [m]
    
    vel_x_init = 0; % initial velocity of the rocket downrange [m/s]
    vel_y_init = 0; % initial velocity of the rocket crossrange [m/s]
    vel_z_init = 0; % initial velocity of the rocket up [m/s]



    % Initial Mass of Air in Bottle
    V_air_init = V_bottle - V_water_init; % [m^3]
    m_air_init = (P_air_init * V_air_init) / (R_air * T_air_init); % [kg]


    %% Formatting Output

    flight_params = {g, C_discharge, V_bottle, P_atm, gamma,...
                     rho_water_init, A_throat, A_bottle, R_air, m_bottle, ...
                     V_air_init, Rho_air_atm, ...
                     T_air_init, m_air_init, P_air_init, C_drag, ...
                     v_wind_surface, v_wind_aloft, theta_init};

    initial_conditions = [x_init, y_init, z_init, ...
                          vel_x_init, vel_y_init, vel_z_init, ...
                          m_air_init, m_water_init, V_air_init];
                  
end
