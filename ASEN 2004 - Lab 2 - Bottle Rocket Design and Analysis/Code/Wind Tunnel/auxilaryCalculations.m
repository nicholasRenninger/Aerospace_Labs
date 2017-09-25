function struct_out = auxilaryCalculations(struct_in, ...
                                           S_model, W_model_theory, ...
                                           SCALE, isMilitary)
                                                    
    %%% struct_out = auxilaryCalculations(struct_in, ...
    %%%                                   S_model, W_theory, SCALE, ...
    %%%                                   isMilitary)
    %%%
    %%% Function calculates the 
    %%%
    %%% Inputs:
    %%%         
    %%%        "struct_in" Struct Containing:
    %%%          
    %%%          Two structs containing data at 25 and 0 m/s with the
    %%%          following data:
    %%%
    %%%                   1: Atmospheric Density, rho [kg/m^3]
    %%%                   2: Airspeed, V_infinity [m/s]
    %%%                   3: Pitot Dynamic Pressure, q [N/m^2] -or- [Pa]
    %%%                   4: Angle of Attack (AoA), AoA [degrees]
    %%%                   5: Sting Normal, N [N]
    %%%                   6: Sting Axial Force, A [N]
    %%%                   7: Sting Pitching Moment, M [Nm]
    %%% 
    %%%
    %%%                   Ex. usage: "alldata.zero.data" and
    %%%                   "alldata.zero.error" to get both the expiremental
    %%%                   data and the corresponding uncertainty of each
    %%%                   measurement for the current model tested at 0
    %%%                   m/s.
    %%%   
    %%%          AoA: struct containing each AoA tested and the uncertainty
    %%%             in the measurement of each AoA.
    %%%        
    %%%          C_L: struct containing the value of C_L computed at every
    %%%              AoA, with
    %%%              the uncertainty of each value of C_L computed.
    %%%              Uncertainty is computed using the general error
    %%%              propagation formula, with each intermediary value
    %%%              having its uncertainty computed, and then combined
    %%%              again using the general formula to find the
    %%%              uncertainty in C_L.
    %%%        
    %%%          C_D: struct containing the value of C_D computed at every
    %%%              AoA, with
    %%%              the uncertainty of each value of C_D computed.
    %%%              Uncertainty is computed using the general error
    %%%              propagation formula, with each intermediary value
    %%%              having its uncertainty computed, and then combined
    %%%              again using the general formula to find the
    %%%              uncertainty in C_D.
    %%%        
    %%%          C_M: struct containing the value of C_M computed at every
    %%%              AoA, with
    %%%              the uncertainty of each value of C_M computed.
    %%%              Uncertainty is computed using the general error
    %%%              propagation formula, with each intermediary value
    %%%              having its uncertainty computed, and then combined
    %%%              again using the general formula to find the
    %%%              uncertainty in C_M. Computed using the Moment measured
    %%%              about the model's CG, then C_M is computed for the
    %%%              M.A.C.
    %%%         
    %%%       - S_model: the wing area of the model in [m^2] 
    %%%
    %%%       - W_model_theory: this is the weight of the model if it were
    %%%                   correctly mass modeled. This is calculated using
    %%%                   the following: W_F16_MODEL = W_F16 * SCALE_F16^3
    %%%
    %%%       - SCALE: length Scale factor between the model and the 
    %%%                real plane.
    %%%
    %%%       - isMilitary: bool that changes analysis based on military
    %%%                     or civilian reqs.
    %%%
    %%% Outputs:
    %%%
    %%%         Update struct_in to struct_out with the 
    %%%         following updated fields:
    %%%
    %%%         - V_land_min_real_model: calclated minimum landing 
    %%%                                      speed for the model plane
    %%%                                      assuming its weight is equal
    %%%                                      to the maximum lift it
    %%%                                      experienced during the test.
    %%%
    %%%         - V_land_min_theoretical_model: calclated minimum landing 
    %%%                                      speed for the model plane
    %%%                                      assuming its weight is
    %%%                                      accurately scaled down from
    %%%                                      the real plane (i.e the model
    %%%                                      is a mass model).
    %%%
    %%%         - V_land_realPlane: calclated minimum landing 
    %%%                             speed for the real-size plane
    %%%                             assuming by scaling up
    %%%                             V_land_min_real_model using:
    %%%                             
    %%%                             V_stall_realPlane = V_stall_model /
    %%%                                                  sqrt(SCALE);
    %%%
    %%%
    %%%         - V_land_realPlane_theory: calclated minimum landing 
    %%%                             speed for the real-size plane
    %%%                             assuming by scaling up
    %%%                             V_land_min_theoretical_model using:
    %%%                             
    %%%                             V_land_realPlane_theory = 
    %%%                             V_land_min_theoretical_model / 
    %%%                             sqrt(SCALE);
    %%%
    %%% Author: Nicholas Renninger
    %%% Date Created: 2/18/17
    %%% Last Modified: 3/8/17
    
    %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
    
   
    
    %% Find Landing Speed of Model
    
    % C_L Max
    [CL_max, max_idx] = max(struct_in.C_L.data);
    
    % Rho_infinity
    rho_inf = struct_in.twentyFive.data(max_idx, 1);
    
    % V_infinity
    V_inf = struct_in.twentyFive.data(max_idx, 2);
    
    % Calculate Weight
    W_real = 0.5 * rho_inf * V_inf^2 * S_model.data * CL_max;
    
    % Calculate the Stall Speed
    V_stall_model = sqrt( (2 * W_real) / ...
                          (rho_inf * S_model.data * CL_max) );
    V_stall_model_theory = sqrt( (2 * W_model_theory) / ...
                                 (rho_inf * S_model.data * CL_max) );
    
    V_stall_realPlane = V_stall_model / sqrt(SCALE);
    V_stall_realPlane_theory = V_stall_model_theory / sqrt(SCALE);
    
    % Calculate Landing Speed of the model
 
    if isMilitary
        land_K = 1.2;
    else % is commercial/civilian
        land_K = 1.3;
    end
    
    % all in [m/s]
    struct_in.V_land_min_real_model = land_K * V_stall_model;
    struct_in.V_land_min_theoretical_model = land_K * V_stall_model_theory;
    struct_in.V_land_realPlane = land_K * V_stall_realPlane;
    struct_in.V_land_realPlane_theory = land_K * V_stall_realPlane_theory;
      
    
    %% Static Longitudinal Stability (dCM / dAoA)
    CM_AoA_slope = diff(struct_in.C_M.data) ./ diff(struct_in.AoA.data);
    zero_idx = find(abs(struct_in.AoA.data) == min(abs(struct_in.AoA.data)));
    struct_in.longit_stability_at_0 = mean([CM_AoA_slope(zero_idx - 1), ...
                                           CM_AoA_slope(zero_idx)]);
                                       
                                       
    %% Static Margin [- (dCM / dAoA) / (dCL / dAoA)]
    CL_AoA_slope = diff(struct_in.C_L.data) ./ diff(struct_in.AoA.data);
    CL_AoA_slope_at_0 = mean([CL_AoA_slope(zero_idx - 1), ...
                                           CL_AoA_slope(zero_idx)]);
    
    struct_in.dCL_dAoA = CL_AoA_slope_at_0;
    struct_in.SM_at_0 = - (struct_in.longit_stability_at_0 / ...
                          CL_AoA_slope_at_0) * 100; % in [%]
    
    %% Pass Data Out
    struct_out = struct_in;
    
