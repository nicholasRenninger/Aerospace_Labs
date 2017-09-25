function all_data = LiftDragMoment(all_data, Dist_CG, S, MAC)
                                                  
    %%% all_data = LiftDragMoment(all_data, Dist_CG, S, MAC)
    %%%
    %%% Function Computes the coefficients of lift, drag, and pitching
    %%% moment for every angle of attack measured, and 
    %%%
    %%% 
    %%% Inputs:
    %%%
    %%%          alldata: struct containing expiremental data and variance
    %%%                   for each data point. From one model, it contain
    %%%                   expiremental data and the statistical variance of
    %%%                   each point of data, tested at both zero (airspeed
    %%%                   = 0 m/s) and twentyFive (airspeed = 25 m/s). Each
    %%%                   of these matrices contains the filtered data from
    %%%                   the tests as a matrix in which the columns are:
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
    %%%         Dist_CG: dist. from balance center to CG & error [m]
    %%%
    %%%         S: wing planform area of scale model & error [m^2]
    %%%
    %%%         MAC: mean aerodynamic wing chord of scale model & error [m]
    %%%
    %%%
    %%% Outputs:
    %%%
    %%%         Update all_data with the following updated fields:
    %%%   
    %%%         AoA: struct containing each AoA tested and the uncertainty
    %%%             in the measurement of each AoA.
    %%%        
    %%%         C_L: struct containing the value of C_L computed at every
    %%%              AoA, with
    %%%              the uncertainty of each value of C_L computed.
    %%%              Uncertainty is computed using the general error
    %%%              propagation formula, with each intermediary value
    %%%              having its uncertainty computed, and then combined
    %%%              again using the general formula to find the
    %%%              uncertainty in C_L.
    %%%        
    %%%         C_D: struct containing the value of C_D computed at every
    %%%              AoA, with
    %%%              the uncertainty of each value of C_D computed.
    %%%              Uncertainty is computed using the general error
    %%%              propagation formula, with each intermediary value
    %%%              having its uncertainty computed, and then combined
    %%%              again using the general formula to find the
    %%%              uncertainty in C_D.
    %%%        
    %%%         C_M: struct containing the value of C_M computed at every
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
    %%%
    %%%
    %%% Author: Nicholas Renninger
    %%% Created: 2/8/17
    %%% Last modified: 3/1/17
    
    
    
    %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
    
    % pulling out data for analysis
    zero.data = all_data.zero.data;
    zero.error = all_data.zero.error;
    twentyFive.data = all_data.twentyFive.data;
    twentyFive.error = all_data.twentyFive.error;
    
    %%% pull out each column of data from constituent matrix
    
    % q [Pa]
    data_col = 3;
    
    q.data = twentyFive.data(:, data_col);
    q.error = twentyFive.error(:, data_col);
    
    % AoA [deg]
    data_col = 4;
    
    AoA.data = twentyFive.data(:, data_col);
    AoA.error = twentyFive.error(:, data_col);
    all_data.AoA = AoA; % save AoA data to struct

    % N [N]
    data_col = 5;
    
    N.data = twentyFive.data(:, data_col) - zero.data(:, data_col);
    N.error = sqrt( twentyFive.error(:, data_col).^2 + ...
                    zero.error(:, data_col).^2 ); % use gen.error formula
        
    % A [N]
    data_col = 6;
    
    A.data = twentyFive.data(:, data_col) - zero.data(:, data_col);
    A.error = sqrt( twentyFive.error(:, data_col).^2 + ...
                    zero.error(:, data_col).^2 ); % use gen.error formula
       
    % M [Nm]
    data_col = 7;
    
    M.data = twentyFive.data(:, data_col) - zero.data(:, data_col);
    M.error = sqrt( twentyFive.error(:, data_col).^2 + ...
                    zero.error(:, data_col).^2 ); % use gen.error formula
    
    
    
    %% Analyze Data - Calc L, D, M, then C_L, C_D, C_M
    
    % declare sybolic variables for the calculation of the uncertainty in
    % C_L, C_D, and C_M
    syms N_sym A_sym M_sym AoA_sym Dist_CG_sym L_sym ...
         q_sym S_sym D_sym C_sym M_CG_sym MAC_sym
     
     
    % 1) Calc L = N*cos(AoA) - A*sin(AoA)
    % 2) Calc D = N*sin(AoA) + A*cos(AoA)
    % 3) Calc C_L = L / (q * S)
    % 4) Calc C_D = D / (q * S)
    % 5) Calc P_moment = M - (N*Dist_CGref)
    % 6) Calc C_M = P_moment / (q * S * C)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Lift [N]
    L_fcn = @(N_sym, A_sym, AoA_sym) N_sym .* cos( AoA_sym * (pi/180) ) ...
                                   - A_sym .* sin( AoA_sym * (pi/180) ); 
    
    L.data = L_fcn(N.data, A.data, AoA.data);
    
    % find error in L using general error propagation
    for i = 1:length(N.data)
        
        
        L.error(i) = ErrorProp(L_fcn, [N_sym, A_sym, AoA_sym], ...
                               [N.data(i), A.data(i), AoA.data(i)], ...
                               [N.error(i), A.error(i), AoA.error(i)]);
                               
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Drag [N]
    D_fcn = @(N_sym, A_sym, AoA_sym) N_sym .* sin( AoA_sym * (pi/180) ) ...
                                   + A_sym .* cos( AoA_sym * (pi/180) ); 
    
    D.data = D_fcn(N.data, A.data, AoA.data);
    
    % find error in D using general error propagation
    for i = 1:length(N.data)
        
        
        D.error(i) = ErrorProp(D_fcn, [N_sym, A_sym, AoA_sym], ...
                               [N.data(i), A.data(i), AoA.data(i)], ...
                               [N.error(i), A.error(i), AoA.error(i)]);
                               
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Moment about CG [Nm]
    M_CG_fcn = @(M_sym, N_sym, Dist_CG_sym) M_sym - ...
                                            (N_sym .* Dist_CG_sym);
    
    M_CG.data = M_CG_fcn(M.data, N.data, Dist_CG.data);
    
    % find error in M about CG using general error propagation
    for i = 1:length(N.data)
        
        
        M_CG.error(i) = ErrorProp(M_CG_fcn, [M_sym, N_sym, Dist_CG_sym],...
                               [M.data(i), N.data(i), Dist_CG.data], ...
                               [M.error(i), N.error(i), Dist_CG.error]);
                               
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% C_L
    C_L_fcn = @(L_sym, q_sym, S_sym) L_sym ./ (q_sym .* S_sym);
    
    all_data.C_L.data = C_L_fcn(L.data, q.data, S.data);
    
    % find error in M about CG using general error propagation
    for i = 1:length(L.data)
        
        
        all_data.C_L.error(i) = ErrorProp(C_L_fcn, [L_sym, q_sym, S_sym], ...
                               [L.data(i), q.data(i), S.data], ...
                               [L.error(i), q.error(i), S.error]);
                               
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% C_D
    C_D_fcn = @(D_sym, q_sym, S_sym) D_sym ./ (q_sym .* S_sym);
    
    all_data.C_D.data = C_D_fcn(D.data, q.data, S.data);
    
    % find error in M about CG using general error propagation
    for i = 1:length(D.data)
        
        
        all_data.C_D.error(i) = ErrorProp(C_D_fcn, [D_sym, q_sym, S_sym], ...
                               [D.data(i), q.data(i), S.data], ...
                               [D.error(i), q.error(i), S.error]);
                               
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% C_M
    C_M_fcn = @(M_CG_sym, q_sym, S_sym, MAC_sym) M_CG_sym ./ ...
                                             (q_sym .* S_sym .* MAC_sym);
    
    all_data.C_M.data = C_M_fcn(M_CG.data, q.data, S.data, MAC.data);
    
    % find error in M about CG using general error propagation
    for i = 1:length(M_CG.data)
        
        
        all_data.C_M.error(i) = ErrorProp(C_M_fcn, ...
                        [M_CG_sym, q_sym, S_sym, MAC_sym], ...
                        [M_CG.data(i), q.data(i), S.data, MAC.data], ...
                        [M_CG.error(i), q.error(i), S.error, MAC.error]);
                               
    end
    
    
    
end

