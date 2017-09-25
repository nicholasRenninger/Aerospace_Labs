function setGlobalBools(bool_in_1, bool_in_2, bool_in_3)
    
    %%% function that sets the global boolean parameter control values
    
    %%% purpose: function allows the global bool variables: "if you are 
    %%%          running a sensitivity analysis", "if you are trying to
    %%%          find the 85m range paramters", and "if you are running the
    %%%          verification case" to be set from anywhere in any of the
    %%%          functions or scripts in use. This allows the user to
    %%%          change which parameters are passed to the dy_dt function
    %%%          used ODE45.
    %%%          
    %%%
    %%% inputs: takes the bool values for the bool
    %%%         parameters that you want to assign to their respective
    %%%         global vars.
    %%%          
    %%%
    %%% outputs: no defined outputs, but will set the 3 bool global
    %%%          variable values for the entire workspace.
    %%%          
    %%%
    %%% assumptions: assumes that the input of bool global conditions is
    %%%              formatted properly so that the right values can be
    %%%              assigned to the right variables.
    %%%              
    %%%
    %%% author: Nicholas Renninger
    %%% date created: 11/25/2016
    %%% date modified: 12/1/2016
    
    global is_doing_sensitiv_analysis find_85m_range do_verification
    
    % Set whether running sensitivty analysis, 85m optimization, or are
    % running a verification case
    is_doing_sensitiv_analysis = bool_in_1;
    find_85m_range = bool_in_2;
    do_verification = bool_in_3;

end