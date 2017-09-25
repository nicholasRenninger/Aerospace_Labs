function [global_vars] = getOtherGlobals
    
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
    %%% date modified: 04/16/2017
    
    % define pair i the initial pressure of air (the limit being the burst
    % pressure of the bottle, with some factor of safety), the initial
    % volume fraction (or equivalently initial mass) of water, the drag
    % coefficient and the launch angle as global variables to run the
    % simulation multiple times, all varying these paramters each time 
    global m_bottle T_air_init P_atm v_wind_surface v_wind_aloft
    
    % return current global variable values
    global_vars = {m_bottle, ... % [kg]
                   T_air_init, ... % [K]
                   P_atm, ... % [Pa]
                   v_wind_surface, ... % [m/s]
                   v_wind_aloft}; % [m/s]
  
end