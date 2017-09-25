function  [L_prime, D_prime] = find_L_D_Problem_2(N, spline_data, ...
                                                  shouldPrint)    

    %%% Numeric Simulation of Lift and Drag over a NACA 0012 Airfoil 
    %%%
    %%% Returns lift and drag per unit span for the airfoil by numerically
    %%% intergrating the pressure distribution around the airfoil using the
    %%% trapezoidal rule.
    %%%
    %%% Last Modified: 9/13/2017
    %%% Date Created: 9/9/2017
    %%% Author: Nicholas Renninger    

    
    %% Define Airfoil & Flow Constants 

    C = 0.5; % [m]
    AOA = 9; % [deg]
    V_INF = 20; % [m/s]
    RHO_INF = 1.225; % [kg/m^3]
    P_INF = 10.13e4; % [Pa]

    Q_INF = 1/2 * RHO_INF * V_INF^2; % [Pa]

    % define thickness of NACA 0012 airfoil
    t = 12/100;

    y_t_func = @(x) (t/0.2)*C .* ( 0.2969.*sqrt(x./C) - 0.1260.*(x./C) - ...
                                   0.3516.*(x./C).^2 + 0.2843.*(x./C).^3 - ...
                                   0.1036.*(x./C).^4 ); % [m]
    N_u_prime = 0; % [N/m]
    N_l_prime = 0; % [N/m]
    A_u_prime = 0; % [N/m]
    A_l_prime = 0; % [N/m]
    
    
    %% Generate Numeric Deltas

    % create x vector, and delta_xs to use for numeric integration
    x_vec = linspace(0, C, N+1); % [m]
    x_c_vec = x_vec ./ C;
    delta_x = diff(x_vec); % [m]

    % create y vector, and delta_ys to use for numeric integration
    y_vec = y_t_func(x_vec); % [m]
    delta_y = diff(y_vec); % [m]


    %% Load in Data and Generate Pressure Distribution

    % resolve into upper and lower components
    c_p.upper = fnval(spline_data.Cp_upper, x_c_vec);
    c_p.lower = fnval(spline_data.Cp_lower, x_c_vec);

    % turn c_p into Pressure: P = c_p * q_inf + P_inf
    P.upper = c_p.upper .* Q_INF + P_INF; % [Pa]
    P.lower = c_p.lower .* Q_INF + P_INF; % [Pa]


    %% Numeric Integration to find N' & A'

    % printing Progress
    if shouldPrint
        dispstat('', 'init'); % One time only initialization
        dispstat( sprintf(['Starting Numeric Integration ', ...
                            'with %0.1e Panels...'], ...
                            N), 'keepthis' );
    end

    % Numeric Integration with N panels
    for i = 1:N

        % reducing code motion 
        upper_trap = ( P.upper(i + 1) + P.upper(i) ) / 2; % [Pa]
        lower_trap = ( P.lower(i + 1) + P.lower(i) ) / 2; % [Pa]
        dx = delta_x(i); % [m]
        dy = delta_y(i); % [m]

        % calculating N' contributions
        N_u_prime = N_u_prime + (upper_trap * dx); % [N/m]
        N_l_prime = N_l_prime + (lower_trap * dx); % [N/m]

        % calculating A' contributions. Use same dy for both lower and upper
        % b/c NACA 0012 is symmetric about x
        A_u_prime = A_u_prime + (upper_trap * dy); % [N/m]
        A_l_prime = A_l_prime + (lower_trap * dy); % [N/m]

        % Print Progress at 1% intervals
        if mod(i, round(N/100)) == 0 && shouldPrint
            dispstat(sprintf('Progress %0.0f%%', i/N * 100));
        end

    end

    N_prime = -N_u_prime + N_l_prime; % [N/m]
    A_prime =  A_u_prime + A_l_prime; % [N/m]
    
    if shouldPrint
        disp('Finished Numeric Integration')
    end
    
    
    %% Transforming Normal & Axial forces into Lift & Drag

    L_prime = N_prime * cosd(AOA) - A_prime * sind(AOA); % [N/m]
    D_prime = N_prime * sind(AOA) + A_prime * cosd(AOA); % [N/m]
    
    return
    
end