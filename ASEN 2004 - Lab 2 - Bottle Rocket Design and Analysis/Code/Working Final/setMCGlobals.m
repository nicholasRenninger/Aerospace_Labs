function setMCGlobals
    
    global g C_discharge V_bottle gamma D_throat D_bottle ...
           R_air m_bottle T_air_init P_atm A_throat A_bottle ...
           v_wind_surface v_wind_aloft C_drag P_air_init V_water_init ...
           m_water_init theta_init Rho_air_atm rho_water_init
    
    
    vec = [1 -1]; % used for randomly choosing sign
    % this array stores the uncertainties in each variable
    uncertaintyVec = [0.01, ... % g
                      0.005, ... % C_discharge
                      0.00001, ... % V_bottle
                      0.0001, ... % gamma
                      0.0005, ... % D_throat
                      0.0005, ... % D_bottle
                      0, ... % R_air
                      0.002, ... % mass_bottle
                      5, ... % T_air_init
                      1000, ... % P_atm
                      10, ... % wind magnitude
                      deg2rad(180), ... % wind direction
                      0.1, ... % C_D
                      0.05, ... % rho_water
                      2 * 6894.76, ... % init Pressure
                      0.0001, ...% V_init_water
                      deg2rad(2), ... % theta init
                      ];

    G_VAL = 9.79 + uncertaintyVec(1) * vec(randi([1 2])) * rand; % [m/s^2]
    g = [0; 0; G_VAL]; % [m/s^2]

    % discharge coefficient [dimensionless]
    C_discharge = 0.8 + uncertaintyVec(2) * vec(randi([1 2])) * rand; 

    % volume of empty 2 litre bottle [m^3]
    V_bottle = 0.002 + uncertaintyVec(3) * vec(randi([1 2])) * rand;

    % ratio of specific heats for air [dimensionless]
    gamma = 1.4 + uncertaintyVec(4) * vec(randi([1 2])) * rand; 

    % diameter of throat [m]
    D_throat = 0.021 + uncertaintyVec(5) * vec(randi([1 2])) * rand; 

    % diameter of bottle [m]
    D_bottle = 0.105 + uncertaintyVec(6) * vec(randi([1 2])) * rand;

    % gas constant for air [J/kg/K]
    R_air = 287 + uncertaintyVec(7) * vec(randi([1 2])) * rand; 

    A_throat = (pi/4) * D_throat ^ 2; % cross-sect area of throat [m^2]
    A_bottle = (pi/4) * D_bottle ^ 2; % cross-sect area of bottle [m^2]

    %%% Set Other Global Variables for Sensitivity Analysis
    [global_other_vars] = getOtherGlobals;


    %%% Set the Value of the 5 Other Globals

    % mass of empty bottle [kg]
    m_bottle = global_other_vars{1} + uncertaintyVec(8) * ...
               vec(randi([1 2])) * rand; 

    % initial temperature of air [K]
    T_air_init = global_other_vars{2} + uncertaintyVec(9) * ...
                 vec(randi([1 2])) * rand; 

    % atmospheric pressure [Pa]         
    P_atm = global_other_vars{3} + uncertaintyVec(10) * ...
            vec(randi([1 2])) * rand; 

    %%% Vary the wind speed and dir for surface winds

    %surf. wind in launch coord. frame [m/s]
    v_wind_surface = [0; 0; 0] + (uncertaintyVec(11) * ...
                     [vec(randi([1 2], 2, 1))' .* rand(2, 1); 0]);
%     v_wind_surface = [0; 4.7; 0];

    %%% Vary the wind speed and dir for surface winds

    % wind aloft in launch coord. frame [m/s] 
%     v_wind_aloft = global_other_vars{5} + (uncertaintyVec(11) * ...
%                    [vec(randi([1 2], 2, 1))' .* rand(2, 1); 0]);
    v_wind_aloft = global_other_vars{5};

    % drag coefficient [dimensionless]
    C_drag = 0.374 + uncertaintyVec(13) * vec(randi([1 2])) * rand; 

     % density of water [kg/m^3]
    rho_water_init = 1000 + uncertaintyVec(14) * vec(randi([1 2])) * rand;

    %%% Initial Absolute Pressure of Air in Bottle [Pa]

    % initial gauge pressure of air in bottle[Pa]
    P_gauge_air = 275790 + uncertaintyVec(15) * vec(randi([1 2])) * rand; 
    P_air_init = P_atm + P_gauge_air;

    % initial vol. of water in bottle [m^3]
    V_water_init = 0.00053 + uncertaintyVec(16) * vec(randi([1 2])) * rand; 

    % Initial Mass of Water
    m_water_init = rho_water_init * V_water_init; % [kg]

    % theta [rad]
    theta_init = 45 * (pi / 180) + uncertaintyVec(17) * ...
                 vec(randi([1 2])) * rand; 

    % ambient air density [kg/m^3]
    Rho_air_atm = P_atm / (R_air * T_air_init); 
    
    
end