function setGlobalHeightIDX(idx_in)
    
    %%% function that sets the global height index
    
    %%% purpose: function sets the height index used in odestop
    %%%          
    %%%
    %%% inputs: takes the value of the index of the hieght in the state
    %%% vector in the dy_dt function.
    %%%          
    %%%
    %%% outputs: will set the hieght index globally
    %%%          
    %%%
    %%% assumptions: assumes that the input of bool global conditions is
    %%%              formatted properly so that the right values can be
    %%%              assigned to the right variables.
    %%%              
    %%% author: Nicholas Renninger
    %%% date created: 04/03/2017
    %%% date modified: 04/03/2107
    
    global height_idx
    
    height_idx = idx_in;
    

end