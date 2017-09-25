function setGlobals(global_conditions)
    
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
    %%% date modified: 12/1/2016
    
    % define pair i the initial pressure of air (the limit being the burst
    % pressure of the bottle, with some factor of safety), the initial
    % volume fraction (or equivalently initial mass) of water, the drag
    % coefficient and the launch angle as global variables to run the
    % simulation multiple times, all varying these paramters each time 
    global P_air_init m_water_init C_drag theta_init
    
    % Set the Value of the 4 Globals
    P_air_init = global_conditions(1);
    m_water_init = global_conditions(2);
    C_drag = global_conditions(3);
    theta_init = global_conditions(4);
    

end

