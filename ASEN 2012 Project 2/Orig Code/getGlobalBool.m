function [bool_out_1, bool_out_2, bool_out_3] = getGlobalBool
    
    %%% function that gets the global boolean parameter control values
    
    %%% purpose: function allows the global bool variables: "if you are 
    %%%          running a sensitivity analysis", "if you are trying to
    %%%          find the 85m range paramters", and "if you are running the
    %%%          verification case" to be passed to anywhere in any of the
    %%%          functions or scripts in use. This allows the user to get
    %%%          the parameters that control which flight params are passed
    %%%          to the dy_dt function used ODE45.
    %%%          
    %%%
    %%% inputs: no reauired inputs. 
    %%%          
    %%%
    %%% outputs: returns the bool values for the bool
    %%%          parameters for use in other functions.
    %%%          
    %%%
    %%% assumptions: assumes that the global vars have already been set
    %%%              before asssigning them to anything.
    %%%              
    %%%
    %%% author's ID: 0dc91b091fd8
    %%% date created: 11/25/2016
    %%% date modified: 12/1/2016

    global is_doing_sensitiv_analysis find_85m_range do_verification
    
    % return the current setting for which paramters are
    % used in ODE45 
    bool_out_1 = is_doing_sensitiv_analysis;
    bool_out_2 = find_85m_range;
    bool_out_3 = do_verification;

end