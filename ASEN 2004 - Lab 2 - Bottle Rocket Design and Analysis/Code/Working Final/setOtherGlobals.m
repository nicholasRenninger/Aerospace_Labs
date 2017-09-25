function setOtherGlobals(global_other_conditions)
    
    %%% function that sets the global variation parameters 
    
    %%% purpose: function allows the global variation parameters: launch
    %%%          angle, the initial vol/mass of water, the drag
    %%%          coefficient, and the inital air pressure in the rocket to
    %%%          be set from anywhere in any of the functions or scripts in
    %%%          use.
    %%%          
    %%%
    %%% inputs: takes a vector of numeric values for the variation
    %%%         parameters that you want to assign to their respective
    %%%         global vars.
    %%%          
    %%%
    %%% outputs: no defined outputs, but will set the 4 variation global
    %%%          variable values for the entire workspace.
    %%%          
    %%%
    %%% assumptions: assumes that the vector of global conditions is
    %%%              formatted properly so that the right values can be
    %%%              assigned to the right variables.
    %%%              
    %%%
    %%% author's ID: 0dc91b091fd8
    %%% date created: 11/25/2016
    %%% date modified: 04/16/2017
    
    % define pair i the initial pressure of air (the limit being the burst
    % pressure of the bottle, with some factor of safety), the initial
    % volume fraction (or equivalently initial mass) of water, the drag
    % coefficient and the launch angle as global variables to run the
    % simulation multiple times, all varying these paramters each time 
    global m_bottle T_air_init P_atm v_wind_surface v_wind_aloft
    
    % Set the Value of the 5 Globals
    m_bottle = global_other_conditions{1}; % [kg]
    T_air_init = global_other_conditions{2}; % [K]
    P_atm = global_other_conditions{3}; % [Pa]
    

    %% Transform Wind Speed from Cardinal to Launch Pad Coord. Frame
    
    % get the global launch offset from N
    phi = getGlobalLaunchDir;
    
    % convert wind directions from cardinal coord. frame to the launch pad
    % centered coord. frame using rot. matrix A for the non-zenith (height)
    % dimensions. A: cardinal -> launch pad

    % [magnitude of wind (m/s), theta (rad), vertical wind (m/s)]
    cardinal_surf_wind = global_other_conditions{4}; % [m/s, rad, m/s]
    cardinal_aloft_wind = global_other_conditions{5}; % [m/s, rad, m/s]
    
    %%% Surface Wind %%%

    wind_speed = cardinal_surf_wind(1);
    theta = cardinal_surf_wind(2);
    vert_wind_speed = cardinal_surf_wind(3);
    
    % make wind vector in cardinal coord. frame
    v_wind_cardinal = [-wind_speed * cos(theta);
                       wind_speed * sin(theta);
                       vert_wind_speed];
    
    % Build rot. matrix, A, to transform - A: cardinal -> launch pad 
    A = [cos(phi)  -sin(phi) 0;
         sin(phi)   cos(phi) 0;
         0          0        1];
    
    % Transform v_wind_cardinal to v_wind_launch_pad:
    v_wind_surf_launch_pad = A * v_wind_cardinal;



    %%% Aloft Wind %%%
    wind_speed = cardinal_aloft_wind(1);
    theta = cardinal_aloft_wind(2);
    vert_wind_speed = cardinal_aloft_wind(3);
    
    % make wind vector in cardinal coord. frame
    v_wind_cardinal = [-wind_speed * cos(theta);
                       wind_speed * sin(theta);
                       vert_wind_speed];
    
    % Build rot. matrix, A, to transform - A: cardinal -> launch pad 
    A = [cos(phi) -sin(phi) 0;
         sin(phi)  cos(phi) 0;
         0         0        1];
    
    % Transform v_wind_cardinal to v_wind_launch_pad:
    v_wind_aloft_launch_pad = A * v_wind_cardinal;



    % Assigning Global Vars
    % [perp to launch dir, || to ground, launch dir, up]
    v_wind_surface = v_wind_surf_launch_pad; % [m/s, m/s, m/s]
    v_wind_aloft = v_wind_aloft_launch_pad; % [m/s, m/s, m/s]
    

end

