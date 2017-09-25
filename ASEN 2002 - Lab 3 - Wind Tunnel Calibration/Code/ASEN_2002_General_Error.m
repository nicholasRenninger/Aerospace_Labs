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