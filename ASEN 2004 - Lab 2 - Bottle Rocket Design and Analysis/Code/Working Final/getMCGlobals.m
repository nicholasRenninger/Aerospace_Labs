function params = getMCGlobals
    
    global g C_discharge V_bottle gamma D_throat D_bottle ...
           R_air m_bottle T_air_init P_atm A_throat A_bottle ...
           v_wind_surface v_wind_aloft C_drag P_air_init V_water_init ...
           m_water_init theta_init Rho_air_atm rho_water_init
       
       
    params{1}  = g;
    params{2}  = C_discharge;
    params{3}  = V_bottle;
    params{4}  = gamma;
    params{5}  = D_throat;
    params{6}  = D_bottle;
    params{7}  = R_air;
    params{8}  = m_bottle;
    params{9}  = T_air_init;
    params{10} = P_atm;
    params{11} = A_throat;
    params{12} = A_bottle;
    params{13} = v_wind_surface;
    params{14} = v_wind_aloft;
    params{15} = C_drag;
    params{16} = P_air_init;
    params{17} = V_water_init;
    params{18} = m_water_init;
    params{19} = theta_init;
    params{20} = Rho_air_atm;
    params{21} = rho_water_init;
  
    
    

end