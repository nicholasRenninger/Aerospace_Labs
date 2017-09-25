function [global_vars] = GetGlobals
    
    %%% function that gets the global variation parameters 
    
    %%% purpose: function allows the global variation parameters: launch
    %%%          angle, the initial vol/mass of water, the drag
    %%%          coefficient, and the inital air pressure in the rocket to
    %%%          be passed to any other function or script without the
    %%%          other functions knowing about the variables
    %%%          
    %%%
    %%% inputs: takes no inputs.
    %%%          
    %%%
    %%% outputs: returns a vector of numeric values for the variation
    %%%          parameters.
    %%%          
    %%%
    %%% assumptions: assumes that the global vars have already been set
    %%%              before asssigning them to anything.
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
    
    % return current global variable values
    global_vars = [P_air_init, m_water_init, C_drag, theta_init];
  
end