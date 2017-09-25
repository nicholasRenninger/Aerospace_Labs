function [S_F16_MODEL, MAC_F16_MODEL, ...
          S_787_MODEL, MAC_787_MODEL, ...
          W_F16_MODEL, W_787_MODEL, ...
          DIST_CG_F16_CLEAN, ...
          DIST_CG_F16_DIRTY, ...
          DIST_CG_787, SCALE_F16, SCALE_787] = Define_Model_Geometry
      
    %%% [S_F16_MODEL, MAC_F16_MODEL, ...
    %%%  S_787_MODEL, MAC_787_MODEL, ...
    %%%  W_F16_MODEL, W_787_MODEL, ...
    %%%  DIST_CG_F16_CLEAN, ...
    %%%  DIST_CG_F16_DIRTY, ...
    %%%  DIST_CG_787, SCALE_F16, SCALE_787] = Define_Model_Geometry
    %%%
    %%% Defines the geometry of the scale models based on the geometry of
    %%% the full-size airplane, and the scale factor between the model and
    %%% the full-size airplane.
    %%%
    %%% Returns the neccessary geometry parameters needed to compute C_L,
    %%% C_D, and C_M for the scale models in SI units.
    %%%
    %%%
    %%% Author: Nicholas Renninger
    %%% Date Created: 2/5/17
    %%% Last Modified: 3/6/17
    
    %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
    
    % define an uncertainty multiplier in the estimated MAC and S of models
    UNCERTAINTY_K = 1e-4;

    
    % this is the scaling from the real plane to the model
    % e.g. the F-16 model is 1/48 scale, 787 is 1/225
    SCALE_F16 = 1/48;
    SCALE_787 = 1/225;

    %% Find Weight of the Model
    W_F16 = 30000 * 4.448221628254617; % convert to [N]
    W_787 = 360000 * 4.448221628254617; % % convert to [N]
    
    % Scale weight of model
    W_F16_MODEL = W_F16 * SCALE_F16^3;
    W_787_MODEL = W_787 * SCALE_787^3;
    
    
    %% Real Plane Geometry
    
    % Wing surface area of the actual plane
    S_F16 = 27.87; % [m^2]
    S_787 = 325.2897752; % [m^2]

    % Define Taper Ratio and Root Chord Length of actual F-16 Wing
    t_ratio_F16 = 0.21;
    C_root_F_16 = 5.04; % [m]

    % Wing Mean Aerodynamic Chord (M.A.C.) Length of actual plane
    MAC_F16 = (2/3) * C_root_F_16 * ( (1 + t_ratio_F16 + t_ratio_F16^2) ...
                                    / (1 + t_ratio_F16) ); % [m]
    MAC_787 = 6.437376; % [m], found online source


    %% Model Plane Geometry

    % Wing surface area of the model planes. Square scale factor, as scale
    % factor is based on length ratio, area is essentially a length^2 ratio
    S_F16_MODEL.data = SCALE_F16^2 * S_F16; % [m^2]
    S_787_MODEL.data = SCALE_787^2 * S_787; % [m^2]

    % define uncertainty in this measurement
    S_F16_MODEL.error = S_F16_MODEL.data * UNCERTAINTY_K; % [m^2]
    S_787_MODEL.error = S_787_MODEL.data * UNCERTAINTY_K; % [m^2]




    % M.A.C. of the model planes. Use unadultered scale factor, as M.A.C.
    % is a function of the lenggth of root chord and taper ratio for the
    % trapezoidal wing planforms of the F-16 and the 787.
    MAC_F16_MODEL.data = SCALE_F16 * MAC_F16; % [m]
    MAC_787_MODEL.data = SCALE_787 * MAC_787; % [m]

    % define uncertainty in this measurement
    MAC_F16_MODEL.error = MAC_F16_MODEL.data * UNCERTAINTY_K; % [m^2]
    MAC_787_MODEL.error = MAC_787_MODEL.data * UNCERTAINTY_K; % [m^2]



    % defining distance from sting balance CG to CG of model
    DIST_CG_F16_CLEAN.data = 14.4 / 1000; % [m]
    DIST_CG_F16_DIRTY.data = 15.5 / 1000; % [m]
    DIST_CG_787.data = 63.0 / 1000; % [m]

    % define uncertainty in this measurement
    DIST_CG_F16_CLEAN.error = UNCERTAINTY_K; % [m]
    DIST_CG_F16_DIRTY.error = UNCERTAINTY_K; % [m]
    DIST_CG_787.error = UNCERTAINTY_K; % [m]

    
end