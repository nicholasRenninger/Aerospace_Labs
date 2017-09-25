%%% Purpose:    
%%%            This function takes in the three calculated temperatures, along
%%%            with their uncertainties, and combines them with known
%%%            information about the calorimeter to calculate specific heat
%%%            of the sample measured in the experiment. This is done
%%%            through general thermodynamic analysis of the system:
%%%            
%%%            calculates c_s based on the 1st law of Thermodynamics applied to
%%%            and isolated/stationary system s.t.
%%%
%%%             delta_U = 0
%%%             U_1 = U_2 
%%%             (energy leaving sample = energy entering calorimeter)
%%%   
%%%             m_s * c_s * (T_1 - T_2) = m_c * c_c * (T_2 - T_o)
%%%
%%%             c_s  = ( m_c * c_c * (T_2 - T_o) ) / ( m_s * (T_1 - T_2) )
%%%                  = specific heat of sample in j / g / K
%%%             where m_c = mass of calorimeter
%%%                   m_s = mass of sample
%%%                   c_c = specific heat of calorimeter
%%%             The uncertainty in the measurement of c_s is done using the
%%%             general error propagation formula on the eqn. above. By
%%%             finding the partial derivatives of c_s with respect to each
%%%             independent variable, plugging in their respective values,
%%%             multiplying them by their respective uncertainties, and
%%%             then summing in quadrature the final uncertainty in c_s is
%%%             obtained. All differentiation and substitution was carried
%%%             out by MATLAB, and is done in these same steps below.
%%%
%%% Inputs: 
%%%         T_o - initial temperature of the calorimeter
%%%         sigma_T_o - uncertainty in measurement of T_o
%%%         T_1 - initial temperature of the sample
%%%         sigma_T_1 - uncertainty in measurement of T_1
%%%         T_2 - equilibrium temperature of the calorimeter and sample
%%%         sigma_T_2 - uncertainty in measurement of T_2
%%%
%%%
%%% Outputs:  T_2 - equilibrium temperature of the calorimeter and sample
%%%           sigma_T_2 - uncertainty in the measurement of T_2
%%%           search_midpoint_T - avg of T_H and T_L
%%%
%%% Assumptions: 
%%%             - can use eqn. 8-15 in book to find uncertainty (errors are
%%%             all independent of each other and can be summed in
%%%             quadrature).
%%%
%%%             - data actually fits a linear relationship with time, and
%%%             as such can be fitted with a line of best fit by least
%%%             square linear regression.
%%%
%%%             - can use the extrapolation error formula as the actual
%%%             uncertainty of T_2, as this encapsulates all of the
%%%             needed sources of error in its measurement
%%%
%%%             - no uncertainty in the specific heat of calorimeter
%%%
%%% Author ID:  0dc91b091fd8
%%% Date Created:   10/15/2016
%%% Date Modified:  10/21/2016
 
 
%%
function [c_s, sigma_c_s] = Project_1_calc_c_s(T_o, sigma_T_o, T_1, sigma_T_1, T_2, sigma_T_2)
        
    %% defining masses (in g) and spec. heat of calorimeter (in cal / g / C))
    
    % m_c = mass of calorimeter
    m_c = 313.50;
    sigma_m_c = 0.05;
               
    % c_c = specific heat of calorimeter
    c_c = 0.214;
    sigma_c_c = 0;
    
    %  m_s = mass of sample
    m_s = 91.75;
    sigma_m_s = 0.05;
    
    %% Calculating c_s
    c_s  = ( m_c * c_c * (T_2 - T_o) ) / ( m_s * (T_1 - T_2) );
    
    % converting to SI (j / kg / K)
    c_s = c_s * 4186.8; 
    
    % convert to j / g / C
    c_s = c_s / 1000;
    
    
    %% finding uncertainty in measurement of c_s
    
    % find partial derivatives of eqn. for c_s for use in general error
    % propagation formula
    syms mc cc ms To T1 T2
    q = ( mc .* cc .* (T2 - To) ) ./ ( ms .* (T1 - T2) ); % q = c_s
    
    % taking partials
    dq_dmc = diff(q, mc);
    dq_dcc = diff(q, cc);
    dq_dms = diff(q, ms);
    dq_dTo = diff(q, To);
    dq_dT1 = diff(q, T1);
    dq_dT2 = diff(q, T2);
    
    % evaluating them at m_c, c_c, m_s, T_o, T_1, T_2
    sym_array = {mc cc ms To T1 T2};
    exact_array = {m_c, c_c, m_s, T_o, T_1, T_2};
    
    dq_dmc_exact = double( subs(dq_dmc, sym_array, exact_array) );
    dq_dcc_exact = double( subs(dq_dcc, sym_array, exact_array) );
    dq_dms_exact = double( subs(dq_dms, sym_array, exact_array) );
    dq_dTo_exact = double( subs(dq_dTo, sym_array, exact_array) );
    dq_dT1_exact = double( subs(dq_dT1, sym_array, exact_array) );
    dq_dT2_exact = double( subs(dq_dT2, sym_array, exact_array) );
    
    % calculate error terms to be added in quadrature
    dq_dmc_sigma_m_c = dq_dmc_exact * sigma_m_c;
    dq_dcc_sigma_c_c = dq_dcc_exact * sigma_c_c;
    dq_dms_sigma_m_s = dq_dms_exact * sigma_m_s;
    dq_dTo_sigma_T_o = dq_dTo_exact * sigma_T_o;
    dq_dT1_sigma_T_1 = dq_dT1_exact * sigma_T_1;
    dq_dT2_sigma_T_2 = dq_dT2_exact * sigma_T_2;
    
    % use general error formula to sum all of the above errors in
    % quadrature
    sigma_c_s = sqrt( dq_dmc_sigma_m_c^2 + dq_dcc_sigma_c_c^2 + ...
                      dq_dms_sigma_m_s^2 + dq_dTo_sigma_T_o^2 + ...
                      dq_dT1_sigma_T_1^2 + dq_dT2_sigma_T_2^2 );
                  
    % converting to SI (j / kg / K)
    sigma_c_s = sigma_c_s * 4186.8; 
    
    % convert to j / g / C
    sigma_c_s = sigma_c_s / 1000;
    
end
